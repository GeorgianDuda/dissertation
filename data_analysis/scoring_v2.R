#####################################################################
###                Data Masking in Oracle 2022-2023               ###
#####################################################################
###        4b. Scoring Models (1). Models Building and Tuning     ###
#####################################################################
# last update: 2024-10-31

options(scipen = 999)
library(readxl)
library(tidyverse)
library(broom)
library(tidymodels)
#install.packages('ranger')
library(ranger)
#install.packages('xgboost')
library(xgboost)
library(scales)
library(patchwork)
library(viridis)
library(ggsci)
library(svglite)
library(vip)
library(corrplot)

#####################################################################
###                            The data set                       ###
#####################################################################
main_dir <- 'C:/Workplace-Disertatie/v2/data_analysis'
setwd(main_dir)
main_df <- read_excel('data_main.xlsx')
glimpse(main_df)

df_scoring <- main_df %>%
     semi_join(
          main_df %>%
          group_by(Query_label) %>%
          tally() %>%
          filter(n == 3)
     ) %>%
     select (Scale_factor, Schema_version, 
             Execution_time_seconds:Aggregate_functions_number) %>%
     mutate ( Schema_version = factor(Schema_version), 
           log10_duration = log10(Execution_time_seconds)) %>%
     #select(-log10_duration) %>%
#     rename(duration = duration_sec)
     select (-Execution_time_seconds)
glimpse(df_scoring)


corrplot::corrplot(cor(
     df_scoring %>% 
          select(-log10_duration) %>%
          select_if(., is.numeric ) , 
             method = "spearman"), method = "number", 
     type = "upper",
     tl.cex = .90, number.cex = 0.7)



setwd(paste0(main_dir, '/figures/4 ml/scoring'))

getwd()
data_masking__ml_scoring <- df_scoring
rio::export(data_masking__ml_scoring, file = 'denormalization__ml_scoring.xlsx')


##########################################################################
###     Model building, tuning and asessment using cross-validation    ###
##########################################################################
###         https://www.tidymodels.org/start/
##########################################################################


##########################################################################
###                             Main split of the data                 ###
set.seed(1234)
# splits   <- initial_split(df2, prop = 0.75)
splits   <- initial_split(df_scoring, prop = 0.75)
train_tbl <- training(splits)
test_tbl  <- testing(splits)


## cross-validation folds
set.seed(1234)
cv_train <- vfold_cv(train_tbl, v = 5, repeats = 5)
cv_train



##########################################################################
###                        The recipe for data preparation             ###
recipe_sc <- recipe(log10_duration ~ ., data = train_tbl) %>%
#recipe_sc <- recipe(duration ~ ., data = train_tbl) %>%
    step_dummy(all_nominal(), -all_outcomes()) %>%
#    step_string2factor(all_nominal()) %>%
    step_impute_knn(all_predictors(), neighbors = 3) %>%
    step_zv(all_predictors()) 

any(is.na(train_tbl))



#########################################################################
###                           Model Specification

## RF
rf_spec <- rand_forest(
     mtry = tune(), 
     trees = 700,
     min_n = tune()     
          ) %>%
     set_engine("ranger") %>%
     set_mode("regression")

rf_spec


### XGBoost
xgb_spec <- boost_tree(
    trees = 1000, 
    tree_depth = tune(), min_n = tune(), 
    loss_reduction = tune(),                     ## model complexity
    sample_size = tune(), mtry = tune(),         ## randomness
    learn_rate = tune()                         ## step size
    ) %>% 
    set_engine("xgboost") %>% 
    set_mode("regression")

xgb_spec


#########################################################################
###                           Assemble the workflows

wf_rf <- workflow() %>%
    add_model(rf_spec) %>%
    add_recipe(recipe_sc)

wf_xgb <- workflow() %>%
    add_model(xgb_spec) %>%
    add_recipe(recipe_sc)



#########################################################################
###                      Grids for hyper-parameter tuning

set.seed(1234)
rf_grid <- dials::grid_max_entropy(
    finalize(mtry(), train_tbl %>% select (-log10_duration)),
    min_n(),  
    size = 100)
rf_grid

set.seed(1234)
xgb_grid <- dials::grid_max_entropy(
    tree_depth(),
    min_n(),
    loss_reduction(),
    sample_size = sample_prop(),
    finalize(mtry(), train_tbl %>% select (-log10_duration)),
    learn_rate(),
    size = 250
)
xgb_grid



#########################################################################
###   Fit the models for all k-fold folders and hyper-parameters grid
doParallel::registerDoParallel()


set.seed(1234)
rf_resamples <- wf_rf %>% 
    tune_grid(
      resamples = cv_train,
      grid = rf_grid
              )
rf_resamples


set.seed(1234)
xgb_resamples <- wf_xgb %>% 
    tune_grid(
      resamples = cv_train,
      grid = xgb_grid
    )
xgb_resamples

temp <- xgb_resamples$.notes[[1]]
temp$location[1]
temp$type[1]
temp$note[1]


#########################################################################
### Explore the results and choose the best hyper-parameter combination


# performance metrics (mean) across folds for each grid line
rf_resamples %>% collect_metrics()
autoplot(rf_resamples)

xgb_resamples %>% collect_metrics()
autoplot(xgb_resamples)



# choose the best hyper-parameter combination
best_rf <- rf_resamples %>% select_best(metric = "rmse")
best_rf

best_xgb <- xgb_resamples %>% select_best(metric = "rmse")
best_xgb



#########################################################################
###        Finalize the workflows with the best performing parameters

final_wf_rf <- wf_rf %>% 
     finalize_workflow(best_rf)

final_wf_xgb <- wf_xgb %>% 
    finalize_workflow(best_xgb)


## fit the final models on the entire train data set

set.seed(1234)
final_rf_train <- final_wf_rf %>%
    fit(data = train_tbl) 
final_rf_train

set.seed(1234)
final_xgb_train <- final_wf_xgb %>%
    fit(data = train_tbl) 
final_xgb_train


#########################################################################
###     The moment of truth: model performance on the test data set

### Function last_fit() fits the finalized workflow one last time 
### to the training data and evaluates one last time on the testing data.

set.seed(1234)
test__rf <- final_wf_rf %>% last_fit(splits) 
test__rf %>% collect_metrics() 

set.seed(1234)
test__xgb <- final_wf_xgb %>% last_fit(splits) 
test__xgb %>% collect_metrics() 



#########################################################################
###                        Variable importance
#########################################################################
library(vip)

set.seed(1234)
rf_imp_spec <- rf_spec %>%
    finalize_model(best_rf) %>%
    set_engine("ranger", importance = "permutation")

workflow() %>%
    add_recipe(recipe_sc) %>%
    add_model(rf_imp_spec) %>%
    fit(train_tbl) %>%
    extract_fit_parsnip() %>%
    vip(aesthetics = list(alpha = 0.8, fill = "midnightblue"))


set.seed(1234)
xgb_imp_spec <- xgb_spec %>%
    finalize_model(best_xgb) %>%
    set_engine("xgboost", importance = "permutation")

workflow() %>%
    add_recipe(recipe_sc) %>%
    add_model(xgb_imp_spec) %>%
    fit(train_tbl) %>%
    extract_fit_parsnip() %>%
    vip(aesthetics = list(alpha = 0.8, fill = "red"))


# ..or
final_xgb_train %>% 
    extract_fit_parsnip() %>% 
    vip()



######
#########################################################################
###                        Variable importance
#########################################################################
library(vip)

set.seed(1234)
rf_imp_spec <- rf_spec %>%
    finalize_model(best_rf) %>%
    set_engine("ranger", importance = "permutation")

g1 <- workflow() %>%
    add_recipe(recipe_sc) %>%
    add_model(rf_imp_spec) %>%
    fit(train_tbl) %>%
    extract_fit_parsnip() %>%
#    vip(aesthetics = list(alpha = 0.8, fill = "black")) +
    vip(num_features = 50L) +
     ggtitle('Random Forest') +
     theme(text = element_text(size = 15),
          plot.title = element_text(size = 15, hjust = 0.5),
          #plot.subtitle = element_text(size = 11),
          legend.title = element_text(size = 12),
          #plot.caption = element_text(size = 11),
          #plot.caption = element_blank(),
          legend.text = element_text(size = 12))  
          # scale_fill_viridis(discrete = TRUE)




set.seed(1234)
xgb_imp_spec <- xgb_spec %>%
    finalize_model(best_xgb) %>%
    set_engine("xgboost", importance = "gain")

g2 <- workflow() %>%
    add_recipe(recipe_sc) %>%
    add_model(xgb_imp_spec) %>%
    fit(train_tbl) %>%
    extract_fit_parsnip() %>%
#    vip(aesthetics = list(alpha = 0.8, fill = "red"))
    vip(num_features = 50L) +
     ggtitle('XGBoost') +
     theme(text = element_text(size = 15),
          plot.title = element_text(size = 15, hjust = 0.5),
          #plot.subtitle = element_text(size = 11),
          legend.title = element_text(size = 12),
          #plot.caption = element_text(size = 11),
          #plot.caption = element_blank(),
          legend.text = element_text(size = 12))  
          # scale_fill_viridis(discrete = TRUE)
     


g2 <- final_xgb_train %>%
    extract_fit_parsnip() %>%
    vip() +
     ggtitle('XGBoost') +
     theme(text = element_text(size = 12),
          plot.title = element_text(size = 12, hjust = 0.5),
          #plot.subtitle = element_text(size = 11),
          legend.title = element_text(size = 10),
          #plot.caption = element_text(size = 11),
          #plot.caption = element_blank(),
          legend.text = element_text(size = 11))  +
          scale_fill_viridis(discrete = TRUE)

setwd(paste0(main_dir, '/figures/4 ml/scoring'))

x <- g1 + g2 + plot_layout(nrow = 1, byrow = FALSE)
ggsave("03 vi_scoring.pdf",
     plot = x,  device = "pdf") #, width = 30, height = 15, units = "cm")




getwd()
setwd(paste(main_dir, 'R', sep = '/'))
#save.image('2022-10-26_ml_scoring.RData')
#load('2022-10-26_ml_scoring.RData')





