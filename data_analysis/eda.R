#####################################################################
###                 Impact of 'column precalculation' denormalisation technique              ###
#####################################################################
###                   1. Exploratory Data Analysis                ###
#####################################################################

options(scipen = 999)  # renuntam la notatie stiitifica (cu exponent)
library(tidyverse)
library(readxl)  # import fisiere excel
library(DataExplorer)
library(corrplot)
library(corrgram)
library(scales)
library(patchwork)
library(viridis)
library(ggsci)
library(svglite)
# https://corrr.tidymodels.org/reference/correlate.html
library(corrr)
library(gtsummary)
library(flextable)


#####################################################################
###                            The data set                       ###
#####################################################################
main_dir <- 'C:/Workplace-Disertatie/v2/data_analysis'
print(main_dir)


setwd(main_dir)
main_df <- readxl::read_excel('data_main.xlsx')
glimpse(main_df)

table(main_df$Scale_factor)

main_df |>
     group_by(Scale_factor) |>
     tally()

main_df |>
     count(Scale_factor) 


table(main_df$Schema_version)
table(main_df$Scale_factor, main_df$Schema_version)

# 
main_df |>
     group_by(Query_id) |>
     tally() |>
     filter(n > 1)


setwd(paste(main_dir, 'figures', sep = '/'))
getwd()


#########################################################################
###                     I. Query parameters                           ###
#########################################################################
glimpse(main_df)

df <- main_df |>
  mutate(
    Scale_factor = factor(Scale_factor),
    Schema_version = factor(Schema_version)
  )
glimpse(df)



## The simplest way of EDA
DataExplorer::create_report(df)



#########################################################################
##                Ia. Tables with descriptive statistics               ## 
#########################################################################
getwd()

## a more elaborate table
glimpse(df)

df1 <- main_df %>%
  select(-Query_id,-Query_label, -Execution_time_miliseconds, -Execution_time_seconds) %>%
  mutate(
    Scale_factor = factor(Scale_factor),
    Schema_version = fct_relevel(Schema_version, "Normalised_precalculate","Precalculate","Normalised_prejoin","Intermediate","Extreme")
  )

glimpse(df1)


fig102 <- df1 %>%
  tbl_summary(
    by = Schema_version,
    type = list(
      Scale_factor ~ "categorical",
      c(
        Tables_number,
        Columns_number,
        Joins_number,
        Subqueries_number,
        GroupBy_number,
        Having_number,
        Where_conditions_number,
        OrderBy_number,
        Aggregate_functions_number
      ) ~ "continuous"
    ),
    statistic = list(
      all_continuous() ~ "{median} [{min}, {max}] [{mean}]",
      all_categorical() ~ "{n} ({p}%)"
    ),
    missing = "no"
  ) %>%
  modify_header(label ~ "**Variable**") %>%
  bold_labels()
fig102

#show_header_names(fig102)
fig102 |>
     gtsummary::as_flex_table() |>
     flextable::save_as_image(path = "102 descriptive_statistics2_by_schema.png")

#show_header_names(fig102)
#

fig102 |>
     gtsummary::as_flex_table() |>
     flextable::save_as_image(path = "102 descriptive_statistics2_by_schema.png")

fig102 |>
     as_gt() |>  # convert to gt table
     gt::gtsave( # save table as docx document
          filename = "102 descriptive_statistics2_by_schema.docx")



## an even more elaborate table
glimpse(df1)
num_vars <- df1 |>
     keep(is.numeric) |>
     names()

t1 <- df1 |>
     keep(is.numeric) |>
     tbl_summary(
          type = list(all_of(num_vars) ~ "continuous"),          
          statistic = list(all_continuous() ~ c("{min}"))
          ) |>
     modify_header(stat_0 ~ "**Min**")
t1

t2 <- df1 |>
     keep(is.numeric) |>
     tbl_summary(
          type = list(all_of(num_vars) ~ "continuous"),          
          statistic = list(all_continuous() ~ c("{p25}"))) |>
     modify_header(stat_0 ~ "**Q1**")
t2 

t3 <- df1 |>
     keep(is.numeric) |>
     tbl_summary(
          type = list(all_of(num_vars) ~ "continuous"),          
          statistic = list(all_continuous() ~ c("{p50}"))) |>
     modify_header(stat_0 ~ "**Median**")
t3 

t4 <- df1 |>
     keep(is.numeric) |>
     tbl_summary(
          type = list(all_of(num_vars) ~ "continuous"),          
          statistic = list(all_continuous() ~ c("{p75}"))) |>
     modify_header(stat_0 ~ "**Q3**")
t4 

t5 <- df1 |>
     keep(is.numeric) |>
     tbl_summary(
          type = list(all_of(num_vars) ~ "continuous"),          
          statistic = list(all_continuous() ~ c("{max}"))) |>
     modify_header(stat_0 ~ "**Max**")
t5

t6 <- df1 |>
     keep(is.numeric) |>
     tbl_summary(
          type = list(all_of(num_vars) ~ "continuous"),          
          statistic = list(all_continuous() ~ c("{mean}"))) |>
     modify_header(stat_0 ~ "**Mean**")
t6

t7 <- df1 |>
     keep(is.numeric) |>
     tbl_summary(
          type = list(all_of(num_vars) ~ "continuous"),          
          statistic = list(all_continuous() ~ c("{sd}"))) |>
     modify_header(stat_0 ~ "**SD**")
t7

f_get_shapiro <- function(variable, ...) {
     result <- shapiro.test(df[[variable]])
     w <- as.numeric(result$statistic)
     p_value <- round(as.numeric(result$p.value),4)
     dplyr::tibble(w = w, p_value = p_value)
}
# f_get_shapiro('age')
#shapiro.test(df$age)
#shapiro.test(df$height_l1)

t8 <- df1 |>
     keep(is.numeric) |>
     tbl_custom_summary(
          type = list(all_of(num_vars) ~ "continuous"),          
          stat_fns =  ~ f_get_shapiro,
          statistic =  ~ "W:{w}, p-value:{p_value}",
          digits = everything() ~ c(3, 3)
     ) |>
     modify_header(stat_0 ~ "**Shapiro-Wilk Test**")
t8


fig103 <- tbl_merge (list(t1, t2, t3, t4, t5, t6, t7, t8), 
                     tab_spanner = NULL) |>
     modify_spanning_header(everything() ~ NA_character_) |>
     modify_footnote(everything() ~ NA) |>
     modify_header(label ~ "**Variable**") |>
     bold_labels()

fig103


fig103 |>
     gtsummary::as_flex_table() |>
     flextable::save_as_image(path = "103 descriptive_statistics3.png")

fig103 |>
     as_gt() |>  # convert to gt table
     gt::gtsave( # save table as docx document
          filename = "103 descriptive_statistics3.docx")



#########################################################################
###               I.c Data distribution - nominal variables          ###
#########################################################################


# compute the frequencies for each categorical variables and values
glimpse(df1)
eda_factors <- df1 %>%
     mutate_if(is.factor, as.character) %>%
     select_if(., is.character ) %>%
     mutate (id = row_number()) %>%
     pivot_longer(-id, names_to = "variable", values_to = "value" ) %>%
     mutate (value = coalesce(value, 'N/A')) %>%
     group_by(variable, value) %>%
     summarise (n_value = n()) %>%
     ungroup() %>%
     mutate (percent = round(n_value * 100 / nrow(df),2)) %>%
     arrange(variable, value) 

View(eda_factors)



# plot only the factors with less than 20 distinct values 
g1 <- eda_factors %>%
     group_by(variable) %>%
     summarise(n_of_values = n()) %>%
     filter (n_of_values < 20) %>%    
     ungroup() %>%
     select (variable) %>%
     inner_join(eda_factors) %>%
ggplot(., aes(x = value, y = n_value, fill = value)) +
     geom_col() +
     geom_text (aes(label = paste0(round(percent,0), '%'), 
                  vjust = if_else(n_value > 100, 1.5, -0.5))) +
     facet_wrap(~ variable, scale = "free", nrow = 1) +
     theme(legend.position="none")    +
     theme(axis.text.x = element_text(size = 10, angle = 35, hjust = 1)) +
     theme(strip.text.x = element_text(size = 11)) +
     xlab("") + ylab("frequency") 


x <- g1 + plot_layout(nrow = 1, byrow = FALSE)
ggsave("111 nominal variables.pdf", plot = x,  device = "pdf") 
ggsave("111 nominal variables.png", plot = x,  device = "png") 




#########################################################################
###                 Ic. Data distribution - numeric variables         ###
#########################################################################
glimpse(df1)
summary(df1)

# num_variables <- df %>%
#      select_if(., is.numeric ) %>%
#      select (-scale_factor, -duration_sec) %>%
#      mutate(row_num = row_number()) %>%
#      pivot_longer(-row_num, names_to = "variable", values_to = "value" ) 

num_variables <- df1 %>%
     select_if(., is.numeric ) %>%
     mutate(row_num = row_number()) %>%
     pivot_longer(-row_num, names_to = "variable", values_to = "value" ) 
View(num_variables)

num_variables_distinct_values <- num_variables %>%
     group_by(variable) %>%
     summarise(n_distinct_values  = n_distinct(value)) %>%
     ungroup()


# for variables with less of equal 5 distinct values, 
#   display bar plots
g1 <- num_variables %>%
     semi_join(
          num_variables_distinct_values %>%
               filter (n_distinct_values <= 5)
     ) %>%
     ungroup() %>%
     group_by(variable, value) %>%
     summarise (n_value = n()) %>%
     ungroup() %>%
     mutate (percent = round(n_value * 100 / nrow(df),2)) %>%
     arrange(variable, value) %>%
ggplot(., aes(x = value, y = n_value)) +
     geom_col(alpha = 0.4) +
     geom_text (aes(label = paste0(round(percent,0), '%'), 
                  vjust = if_else(n_value > 400, 1.5, -0.5)), size = 4.5) +
     facet_wrap(~ variable, scale = "free", ncol = 2) +
     theme_bw() +
     theme(legend.position="none")    +
     theme(axis.text.x = element_text(size = 11, angle = 0, hjust = 0.5)) +
     theme(strip.text = element_text(size = 14)) +
     xlab("") + ylab("frequency") 
 
x <- g1 + plot_layout(nrow = 1, byrow = FALSE)
ggsave("112a low cardinality numeric variables.pdf", plot = x,  device = "pdf")



# for variables with 6-10 distinct values, 
#   display also bar plots
g1 <- num_variables %>%
     semi_join(
          num_variables_distinct_values %>%
               filter (n_distinct_values > 5 & n_distinct_values <= 10)
     ) %>%
     ungroup() %>%
     group_by(variable, value) %>%
     summarise (n_value = n()) %>%
     ungroup() %>%
     mutate (percent = round(n_value * 100 / nrow(df),2)) %>%
     arrange(variable, value) %>%
ggplot(., aes(x = value, y = n_value)) +
     geom_col(alpha = 0.4) +
     geom_text (aes(label = paste0(round(percent,0), '%'), 
                  vjust = if_else(n_value > 350, 1.5, -0.5)), size = 3) +
     facet_wrap(~ variable, scale = "free", ncol = 2) +
     theme_bw() +
     theme(legend.position="none")    +
     theme(axis.text.x = element_text(size = 11, angle = 0, hjust = 0.5)) +
     theme(strip.text = element_text(size = 14)) +
     xlab("") + ylab("frequency") 



x <- g1 + plot_layout(nrow = 1, byrow = FALSE)
ggsave("112b medium cardinality numeric variables.pdf", plot = x,  device = "pdf") 


# for variables with more than 10 distinct values, 
#   display histogram
# separate histogram for each numeric value; free scale
g1 <- num_variables %>%
     filter(variable != 'f__proc_rows') %>%
     semi_join(
          num_variables_distinct_values %>%
               filter (n_distinct_values > 10)
     ) %>%
     ungroup() %>%
ggplot(., aes(x = value)) +
     geom_histogram(alpha = .6) +
     facet_wrap(~ variable, scale = "free") +
     theme_bw() +
     theme(legend.position="none")    +
     theme(axis.text.x = element_text(size = 11)) +
     theme(strip.text = element_text(size = 18)) +
     xlab("") + ylab("frequency") 

x <- g1 + plot_layout(nrow = 1, byrow = FALSE)
ggsave("112c other numeric variables.pdf", plot = x,  device = "pdf") 


### boxplot for all numeric variables
g1 <- num_variables %>%
ggplot(., aes(y = value)) +
     geom_boxplot() +
     facet_wrap(~ variable, ncol = 4, scales = "free") +
     theme(legend.position="none")    +
     xlab("") + ylab("value") +
     theme(axis.text.x = element_blank()) +
     theme(strip.text.x = element_text(size = 10)) 
#     scale_y_continuous(breaks = seq(0, 10, 1))

x <- g1 + plot_layout(nrow = 1, byrow = FALSE)
ggsave("112d boxplots.pdf", plot = x,  device = "pdf") 
ggsave("112d boxplots.png", plot = x,  device = "png") 



glimpse(df)
## correlation plot
corrplot::corrplot(cor(
     df1 %>% 
          select_if(., is.numeric ) , 
             method = "spearman"), method = "number", 
     type = "upper",
     tl.cex = .7, number.cex = 0.7)

## export "manually" from RStudio !!!!!!!!!!


table(df$scale_factor, df$masking_scenario)






#########################################################################
###             III. EDA for the scoring (regression) model            ###
#########################################################################
### We'll keep only the completed queries on both scenarios
glimpse(main_df)
setwd(paste0(main_dir, '/figures'))

summary(main_df$Execution_time_seconds)


df_scoring_precalc <- main_df %>%
     semi_join(
          main_df %>%
          group_by(Query_label) %>%
          tally() %>%
          filter(n == 3)
     ) %>%
     select (Scale_factor, Schema_version, 
             Execution_time_seconds) %>%
     mutate ( Schema_version = factor(Schema_version), 
           log10_duration = log10(Execution_time_seconds)) 

table(df_scoring_precalc$Scale_factor)/2
glimpse(df_scoring_precalc)
summary(df_scoring_precalc$Execution_time_seconds)

table(df_scoring_precalc$Execution_time_seconds)

hist(df_scoring_precalc$Execution_time_seconds)


df <- df_scoring_precalc

setwd(paste0(main_dir, '/figures'))
getwd()



#########################################################################
##                IIIa. Tables with descriptive statistics             ## 
#########################################################################

glimpse(df)
df <- df %>%
  mutate(
    Schema_version = fct_relevel(as.factor(Schema_version), "Normalised_prejoin", "Intermediate", "Extreme")
  )
  
fig301 <- df |>
     transmute(
          Scale_factor = factor(paste('SF', Scale_factor)), 
          Schema_version = paste('Schema', Schema_version), 
          Execution_time_seconds, log10_duration) |>
     tbl_strata(
          strata = Schema_version,
          .tbl_fun =
               ~ .x %>%
               tbl_summary(by = Scale_factor, missing = "no"),
          .header = "**{strata}**, N = {n}"
     )

fig301 <- df |>
  transmute(
    Scale_factor = factor(paste('SF', Scale_factor)), 
    Schema_version = factor(paste('Schema', Schema_version), 
                            levels = c("Schema Normalised_prejoin", "Schema Intermediate", "Schema Extreme")), 
    Execution_time_seconds, 
    log10_duration
  ) |>
  tbl_strata(
    strata = Schema_version,
    .tbl_fun = ~ .x %>%
      tbl_summary(by = Scale_factor, missing = "no"),
    .header = "**{strata}**, N = {n}"
  )
fig301

#show_header_names(fig301)
fig301 |>
     gtsummary::as_flex_table() |>
     flextable::save_as_image(path = "301 descriptive_statistics_duration_prejoin.png")


#########################################################################
###   IIIe. The outcome: duration_sec; transformation log10(duration) ###
#########################################################################
glimpse(df_scoring_precalc)

df_times <- main_df %>%
        semi_join(
          main_df %>%
            group_by(Query_label) %>%
            tally() %>%
            filter(n == 2 | n == 3)
        ) %>%
        select (Scale_factor, Schema_version, 
                Execution_time_seconds) %>%
        mutate ( Schema_version = factor(Schema_version),
                 Scale_factor = factor(Scale_factor),
                 log10_duration = log10(Execution_time_seconds))

glimpse(df_times)

g1 <- ggplot(df_times %>% mutate(Scale_factor = factor(Scale_factor)), 
       aes(x = Scale_factor, y = Execution_time_seconds)) +
     geom_boxplot() +
     theme(legend.position = "none") +
     scale_y_continuous(breaks = seq(0, 1200, by = 50))

x <- g1 + plot_layout(nrow = 1, byrow = FALSE)
ggsave("311a duration_sec.pdf", plot = x,  device = "pdf") 
ggsave("311a duration_sec.png", plot = x,  device = "png") 


ggplot(df_times %>% mutate(Scale_factor = factor(Scale_factor)), 
       aes(x = Scale_factor, y = Execution_time_seconds)) +
    geom_boxplot() +
    facet_wrap(~ Scale_factor, scale = "free", labeller = label_both ) +
    theme(legend.position = "none") 


ggplot(df_times %>% mutate(Scale_factor = factor(Scale_factor)), 
       aes(x = Scale_factor, y = Execution_time_seconds)) +
     geom_boxplot() +
     theme(legend.position = "none") +
    ggforce::facet_zoom(ylim = c(0, 155)) 

x <- g1 + plot_layout(nrow = 1, byrow = FALSE)
ggsave("312b duration_sec.pdf", plot = x,  device = "pdf") 
ggsave("312b duration_sec.png", plot = x,  device = "png") 




g1 <- ggplot(df_times %>% mutate(Scale_factor = factor(Scale_factor)), 
       aes(x = Scale_factor, y = log10_duration)) +
     geom_boxplot() +
     theme(legend.position = "none") 
     # +scale_y_continuous(breaks = seq(-3, 3, by = 0.5))


x <- g1 + plot_layout(nrow = 1, byrow = FALSE)
ggsave("313 log10_duration.pdf", plot = x,  device = "pdf") 
ggsave("313 log10_duration.png", plot = x,  device = "png") 





