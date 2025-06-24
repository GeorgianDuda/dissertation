#####################################################################
###                Data Masking in Oracle 2022-2023               ###
#####################################################################
###                    4. Inferential Statistics                  ###
#####################################################################
# last update: 2024-10-24

options(scipen = 999)
library(readxl)
library(tidyverse)
library(scales)
library(patchwork)
library(viridis)
library(ggsci)
library(svglite)
#install.packages('ggstatsplot')
library(ggstatsplot)
library(effectsize)
#citation('ggstatsplot')


#####################################################################
###                            The data set                       ###
#####################################################################
main_dir <- 'C:/Workplace-Disertatie/v2/data_analysis'
setwd(main_dir)
main_df <- read_excel('data_main.xlsx')
glimpse(main_df)

#########################################################################
###     II. Inferential statistics for the scoring/regression model   ###
#########################################################################

### We'll keep only the completed queries on both scenarios
glimpse(main_df)
df_scoring <- main_df %>%
     semi_join(
          main_df %>%
          group_by(Query_label) %>%
          tally() %>%
          filter(n == 3)
     ) %>%
     select (Scale_factor, Schema_version, 
           Execution_time_seconds,Joins_number) %>%
     mutate ( Schema_version = factor(Schema_version),
              log10_duration = log10(Execution_time_seconds)) 

##test to remove the ones with joins

df_scoring <- main_df %>%
  #filter(Execution_time_miliseconds <= 400) %>%
  # Keep only queries that have all 3 schema versions
  semi_join(
    main_df %>%
      group_by(Query_label) %>%
      summarise(n_versions = n_distinct(Schema_version)) %>%
      
      filter(n_versions == 3)
  ) %>%
  
  # Keep only queries where both Intermediate and Extreme have 0 joins
  group_by(Query_label) %>%
  filter(
    all(c("Intermediate", "Extreme") %in% Schema_version),
    all(Joins_number[Schema_version == "Intermediate"] == 0),
    all(Joins_number[Schema_version == "Extreme"] == 0)
  ) %>%
  ungroup() %>%
  
  select(
    Query_label, Scale_factor, Schema_version,
    Execution_time_seconds, Joins_number
  ) %>%
  mutate(
    Schema_version = factor(Schema_version),
    log10_duration = log10(Execution_time_seconds)
  )

glimpse(df_scoring)

df_scoring %>%
  ggplot(aes(x = factor(Joins_number), fill = Schema_version)) +
  geom_bar(position = "dodge") +
  labs(
    title = "Distribution of Joins in Filtered Queries (0 joins in Intermediate & Extreme)",
    x = "Number of Joins",
    y = "Count of Queries",
    fill = "Schema Version"
  ) +
  theme_minimal() +
  theme(
    text = element_text(size = 12),
    plot.title = element_text(size = 14, hjust = 0.5)
  )

df <- df_scoring %>%
     mutate(Scale_factor = factor(Scale_factor))
setwd(paste0(main_dir, '/figures'))



#########################################################################
### IIa.RQ5:Is the query duration associated with the masking scenario?
#########################################################################
glimpse(df)
length(df$Execution_time_seconds) # check actual length

shapiro.test(df$Execution_time_seconds)

#########################################################################
### Given that:
###  - variable masking scenario is nominal
###  - variable query duration is numeric and non-normally distributed
###  - the same queries were executed for both scenarios 
###  we will use the non-parametric Mann-Whitney test for paired data
#########################################################################


df_scoring_precalc <- main_df %>%
  filter(Execution_time_miliseconds <= 400) %>%
     semi_join(
          main_df %>%
          group_by(Query_label) %>%
          tally() %>%
          filter(n == 3)
     ) %>%
     select (Query_label, Schema_version, Execution_time_seconds) %>%
     mutate ( Schema_version = factor(Schema_version)) %>%
     pivot_wider(names_from = Schema_version, values_from = Execution_time_seconds) 

glimpse(df_scoring_precalc)

df_scoring_paired1 <- df_scoring_precalc

glimpse(df_scoring_precalc)

# check for the normality of the outcome
sw_test1 <- shapiro.test(df_scoring_paired1$`Normalised_prejoin`)
sw_test2 <- shapiro.test(df_scoring_paired1$`Intermediate`)
sw_test2 <- shapiro.test(df_scoring_paired1$`Extreme`)

t.test(df_scoring_paired1$`Normalised_prejoin`, df_scoring_paired1$`Intermediate`, df_scoring_paired1$`Extreme`,
       paired = T)

wilcox.test(df_scoring_paired1$`Normalised_prejoin`, df_scoring_paired1$`Intermediate`, 
       paired = T, conf.int = T)

glimpse(df_scoring)
library(forcats)
df_scoring <- df_scoring %>%
  mutate(Schema_version = factor(Schema_version))

df_scoring$Schema_version <- factor(df_scoring$Schema_version, levels = c("Normalised_prejoin", "Intermediate", "Extreme"))
glimpse(df_scoring)
set.seed(1234)
g1 <- ggwithinstats(
          data = df_scoring,
          x = Schema_version,
          y = Execution_time_seconds,
          pairwise.comparisons = TRUE,
          type = "np"  # non-parametric
               ) + 
          theme(text = element_text(size = 12),
               plot.title = element_text(size = 14, hjust = 0.5),
               plot.subtitle = element_text(size = 13, hjust = 0.5),
               legend.title = element_text(size = 12),
               #plot.caption = element_text(size = 11),
               plot.caption = element_blank(),
               legend.text = element_text(size = 11)) +
               scale_fill_viridis()   
g1

g1 <- ggbetweenstats(
  data = df_scoring,
  x = Schema_version,
  y = Execution_time_seconds,
  type = "np",  # non-parametric
  pairwise.comparisons = TRUE
) +
  theme(
    text = element_text(size = 12),
    plot.title = element_text(size = 14, hjust = 0.5),
    plot.subtitle = element_text(size = 13, hjust = 0.5),
    legend.title = element_text(size = 12),
    plot.caption = element_blank(),
    legend.text = element_text(size = 11)
  ) +
  scale_fill_viridis()

interpret_rank_biserial(-.39)

g1

x <- g1 + plot_layout(nrow = 1, byrow = FALSE)
ggsave("01 Association duration vs schema version_precalculate.pdf",
          plot = x,  device = "pdf")




#########################################################################
###    Association log10(query_duration) vs. masking scale_factor

glimpse(main_df)

main_df <- main_df %>%
  mutate(Schema_version = factor(Schema_version))

df_scoring_paired2 <- main_df %>%
  filter(Execution_time_miliseconds <= 400) %>%
     semi_join(
          main_df %>%
          group_by(Query_label) %>%
          tally() %>%
          filter(n == 3)
     ) %>%
     select (Query_label, Schema_version, Execution_time_seconds) %>%
     transmute (Query_label,  
                Schema_version = factor(Schema_version),
                log10_duration = log10(Execution_time_seconds)) %>%
     pivot_wider(names_from = Schema_version, values_from = log10_duration) 


glimpse(df_scoring_paired2)



# check for the normality of the outcome
sw_test1 <- shapiro.test(df_scoring_paired2$`Normalised`)
sw_test2 <- shapiro.test(df_scoring_paired2$`Precalculated`)

t.test(df_scoring_paired2$`Normalised`, df_scoring_paired2$`Precalculated`, 
       paired = T)

wilcox.test(df_scoring_paired2$`Normalised`, df_scoring_paired2$`Precalculated`, 
       paired = T, conf.int = T)



set.seed(1234)
g1 <- ggwithinstats(
          data = df_scoring,
          x = Schema_version,
          y = log10_duration,
          pairwise.comparisons = TRUE,
          type = "np"  # non-parametric
               ) + 
          theme(text = element_text(size = 14),
               plot.title = element_text(size = 16, hjust = 0.5),
               plot.subtitle = element_text(size = 15, hjust = 0.5),
               legend.title = element_text(size = 14),
               #plot.caption = element_text(size = 11),
               plot.caption = element_blank(),
               legend.text = element_text(size = 13)) +
               scale_fill_viridis()     

x <- g1 + plot_layout(nrow = 1, byrow = FALSE)
x
ggsave("02 Association log10_duration vs schema version_precalculate.pdf",
          plot = x,  device = "pdf")

interpret_rank_biserial(-.39)



#########################################################################
### IIb. RQ6: Is the query duration associated with the number of
###                            inner joins? 
#########################################################################
glimpse(df)
shapiro.test(df$Joins_number)

#########################################################################
### Given that:
###  - variable Joins_number is numeric and non-normally distributes
###  - variable query duration is numeric and non-normally distributed
###  we will use the correlation test (H0: there is no correlation...)
#########################################################################

g1 <- ggscatterstats(
     data = df_scoring, 
     x = Joins_number, 
     y = Execution_time_seconds,
     type = 'np'
)
g1

x <- g1 + plot_layout(nrow = 1, byrow = FALSE)
ggsave("03 Association duration vs Joins_number.pdf", plot = x,  device = "pdf")


g1 <- ggscatterstats(
  data = df_scoring %>% filter(Schema_version == "Normalised_prejoin"),
  x = Joins_number,
  y = Execution_time_seconds,
  type = "np",
  title = "Normalised Prejoin"
)

g2 <- ggscatterstats(
  data = df_scoring %>% filter(Schema_version == "Intermediate"),
  x = Joins_number,
  y = Execution_time_seconds,
  type = "np",
  title = "Prejoin Intermediate"
)

g3 <- ggscatterstats(
  data = df_scoring %>% filter(Schema_version == "Extreme"),
  x = Joins_number,
  y = Execution_time_seconds,
  type = "np",
  title = "Prejoin Extreme"
)

g1 + g2 + g3 + plot_layout(nrow = 1)
g1


df_scoring %>%
  filter(Schema_version %in% c("Normalised_prejoin", "Intermediate", "Extreme")) %>%
  group_by(Schema_version, Joins_number) %>%
  summarise(
    n = n(),
    median_time = median(Execution_time_seconds),
    max_time = max(Execution_time_seconds),
    .groups = "drop"
  )

ggplot(df_scoring %>% 
         filter(Schema_version == "Extreme"),
       aes(x = factor(Joins_number), y = log10_duration)) +
  geom_boxplot() +
  labs(title = "Extreme Schema: Execution Time by Join Count",
       x = "Number of Joins",
       y = "log10(Execution Time)") +
  theme_minimal()

df_scoring <- df_scoring %>%
  filter(Schema_version == "Extreme") %>%
  mutate(JoinBinary = ifelse(Joins_number == 0, "0 JOINs", ">0 JOINs"))

glimpse(df_scoring)

wilcox.test(
  Execution_time_seconds ~ JoinBinary,
  data = df_scoring
)

interpret_phi(.22)





#########################################################################
###  IIc. RQ7 Does the the association between the duration and       ###
###            the schema version vary among scale factors?        ###
#########################################################################


df_scoring$Schema_version <- factor(df_scoring$Schema_version, levels = c("Normalised_prejoin", "Intermediate","Extreme"))

glimpse(df_scoring)

g1 <- ggplot(df_scoring %>% mutate(Scale_factor = factor(Scale_factor)), 
       aes(x = Schema_version, y = Execution_time_seconds)) +
    geom_boxplot() +
    facet_wrap(~ Scale_factor, scale = "free", labeller = label_both ) +
    theme(legend.position = "none") 
g1

x <- g1 + plot_layout(nrow = 1, byrow = FALSE)
ggsave("03 duration_sec by sf_precalculate.pdf", plot = x,  device = "pdf") 
ggsave("03 duration_sec by sf_precalculate.png", plot = x,  device = "png") 


g1 <- ggplot(df_scoring %>% mutate(Scale_factor = factor(Scale_factor)), 
       aes(x = Schema_version, y = log10_duration)) +
     geom_boxplot() +
     theme(legend.position = "none") +
     scale_y_continuous(breaks = seq(-3, 3, by = 0.5))

x <- g1 + plot_layout(nrow = 1, byrow = FALSE)
x
ggsave("04 log10_duration_precalculate.pdf", plot = x,  device = "pdf") 
ggsave("04 log10_duration_precalculate.png", plot = x,  device = "png") 


table(df_scoring$Scale_factor)


base_theme <- theme(
  plot.title = element_text(size = 11, hjust = 0.5),
  plot.subtitle = element_text(size = 10, hjust = 0.5),
  plot.margin = margin(t = 15, r = 5, b = 5, l = 5),
  axis.text.x = element_text(angle = 30, hjust = 1)
)

### duration_sec
g1 <- ggbetweenstats(
     data = df_scoring %>% filter(Scale_factor == 1),
     x = Schema_version,
     y = Execution_time_seconds,
     type = "np",  # non-parametric,
     title = "scale_factor:1") + base_theme
	

g2 <- ggbetweenstats(
     data = df_scoring %>% filter(Scale_factor == 10),
     x = Schema_version,
     y = Execution_time_seconds,
     type = "np",  # non-parametric,
     title = "scale_factor: 10") + base_theme
	

g3 <- ggbetweenstats(
     data = df_scoring %>% filter(Scale_factor == 50),
     x = Schema_version,
     y = Execution_time_seconds,
     type = "np",  # non-parametric,
     title = "scale_factor: 50") + base_theme
     

x <- (g1 | g2 | g3) +
  plot_layout(nrow = 1) +
  plot_annotation(
    title = "Query Execution Time by Schema Type and Scale Factor",
    theme = theme(plot.title = element_text(size = 13, hjust = 0.5, face = "bold"))
  )

x

ggsave("05 duration_sec vs Schema_version_precalculate-sf1.", plot = g1,  device = "pdf", 
       width = 10, height = 10, units = "cm") 
ggsave("05 duration_sec vs Schema_version_precalculate-sf1", plot = g1,  device = "png",
       width = 10, height = 10, units = "cm") 


shapiro.test(df_scoring$log10_duration)


### log10_duration
g1 <- ggbetweenstats(
     data = df_scoring %>% filter(Scale_factor == 1),
     x = Schema_version,
     y = log10_duration,
     type = "np",  # non-parametric,
     title = "scale_factor:1") +
	theme (plot.title = element_text (colour="black", size="10", hjust = 0.5))

g2 <- ggbetweenstats(
     data = df_scoring %>% filter(Scale_factor == 10),
     x = Schema_version,
     y = log10_duration,
     type = "np",  # non-parametric,
     title = "scale_factor: 10") +
	theme (plot.title = element_text (colour="black", size="10", hjust = 0.5))

g3 <- ggbetweenstats(
     data = df_scoring %>% filter(Scale_factor == 50),
     x = Schema_version,
     y = log10_duration,
     type = "np",  # non-parametric,
     title = "scale_factor: 50") +
	theme (plot.title = element_text (colour="black", size="10", hjust = 0.5))

g1
g2
g3


x <- g1 + plot_spacer() + g2 + plot_spacer() +
     g3 + plot_spacer() + plot_layout(nrow = 2, byrow = TRUE)
x
ggsave("06 log10_duration vs schema_precalculate, by sf.pdf", plot = x,  device = "pdf", 
       width = 25, height = 10, units = "cm") 
ggsave("06 log10_duration vs schema_precalculate, by sf.png", plot = x,  device = "png",
       width = 25, height = 10, units = "cm") 




##H2

library(ggplot2)
library(dplyr)

df_plot <- df_scoring %>%
  filter(Schema_version %in% c("Normalised_prejoin", "Intermediate", "Extreme"))

glimpse(df_scoring)

glimpse(df_plot)

# Log-transformed execution time
ggplot(df_plot, aes(x = factor(Scale_factor), y = Execution_time_seconds, color = Schema_version)) +
  stat_summary(fun = median, geom = "line", aes(group = Schema_version), size = 1.2) +
  stat_summary(fun = median, geom = "point", size = 3) +
  labs(
    title = "Interaction of Schema Type and Scale Factor",
    x = "Scale Factor",
    y = "log10(Exectution time (seconds))",
    color = "Schema"
  )+
  annotate("text", x = 2, y = 2, label = "interaction_label", size = 4, hjust = 0.5) +
  theme_minimal()

install.packages('ARTool')
library(ARTool)

df_art <- df_plot %>%
  mutate(
    Scale_factor = factor(Scale_factor),
    Schema_version = factor(Schema_version)
  )

# Run ART ANOVA on log10_duration
art_model <- art(log10_duration ~ Schema_version * Scale_factor, data = df_art)
anova_results <- anova(art_model)
print(anova_results)
# ggplot(results_ok %>% filter (scale_factor == 1), 
#        aes(x = masking_scenarios, y = duration)) +
#     geom_boxplot() +
#     theme(legend.position = "none") +
#     xlab(paste('masking scenarios on the scale factor 1')) +
#     ggforce::facet_zoom(ylim = c(0, 100000)) 

# ggplot(results_ok %>% filter (scale_factor == 1), 
#        aes(x = masking_scenarios, y = log10_duration)) +
#     geom_boxplot() +
#     theme(legend.position = "none") +
#     xlab(paste('masking scenarios on the scale factor 1')) +
#     scale_y_continuous(breaks = seq(0, 6, by = 0.5))


art_model <- art(log10_duration ~ Schema_version * Scale_factor, data = df_h2)
anova_result <- anova(art_model)
print(anova_result)

interaction_label <- "ART ANOVA: F(2,594) = 3.22, p = 0.041 (interaction); main effects p < 2e-16"

ggplot(df_plot, aes(x = Scale_factor, y = log10_duration, color = Schema_version, group = Schema_version)) +
  stat_summary(fun = median, geom = "line", size = 1.2) +
  stat_summary(fun = median, geom = "point", size = 3) +
  labs(
    title = "Performance Gain from Precalculation Increases with Scale Factor",
    x = "Scale Factor",
    y = "log10(Execution Time)",
    color = "Schema_Version"
  ) +
  annotate("text", x = 2, y = 22, label = interaction_label, size = 4.5, hjust = 0.5) +
  theme_minimal()


#H3

# Step 1: Prepare data
df_join <- df_scoring %>%
  filter(Schema_version %in% c("Normalised", "Precalculated")) %>%
  mutate(
    Join_group = case_when(
      Joins_number <= 1 ~ "Low Joins",
      Joins_number >= 2 ~ "High Joins"
    ),
    log10_duration = log10(Execution_time_seconds)
  ) %>%
  filter(!is.na(Join_group))

glimpse(df_join)

df_summary <- df_join %>%
  group_by(Schema_version, Join_group) %>%
  summarise(median_duration = median(log10_duration))

ggplot(df_summary, aes(x = Join_group, y = median_duration, group = Schema_version, color = Schema_version)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  labs(
    title = "Interaction: Schema × Join Complexity",
    x = "Join Complexity",
    y = "Median log10(Execution Time)",
    color = "Schema_version"
  ) +
  theme_minimal()

# Step 2: Plot interaction
ggbetweenstats(
  data = df_join,
  x = Join_group,
  y = log10_duration,
  grouping.var = Schema,
  type = "np",
  title = "Impact of Join Complexity on Execution Time by Schema Type",
  ylab = "log10(Execution Time)",
  xlab = "Join Complexity Group",
  results.subtitle = TRUE
)

# Step 3: Test interaction (ART ANOVA)
df_join$Schema <- factor(df_join$Schema)
df_join$Join_group <- factor(df_join$Join_group)

art_model <- art(log10_duration ~ Schema * Join_group, data = df_join)
anova(art_model)

ggbetweenstats(
  data = df_join,
  x = Join_group,
  y = log10_duration,
  facet.by = Schema_version,  # Faceting by Schema to see them side-by-side
  type = "np",  # Non-parametric test
  title = "Impact of Join Complexity on Execution Time by Schema Type",
  xlab = "Join Complexity Group",
  ylab = "log10(Execution Time)",
  results.subtitle = TRUE
)

glimpse(df_join)

df_split <- df_scoring %>%
  filter(Schema_version %in% c("Normalised", "Precalculated")) %>%
  mutate(
    Join_group = if_else(Joins_number <= 1, "Low Joins", "High Joins"),
    log10_duration = log10(Execution_time_seconds)
  )

# Plot 1: Normalised
p1 <- ggbetweenstats(
  data = df_split %>% filter(Schema_version == "Normalised"),
  x = Join_group,
  y = log10_duration,
  type = "np",
  title = "Effect of Join Complexity on Execution Time (Normalised Schema)",
  xlab = "Join Complexity",
  ylab = "log10(Execution Time)",
  results.subtitle = TRUE
)

# Plot 2: Precalculated
p2 <- ggbetweenstats(
  data = df_split %>% filter(Schema_version == "Precalculated"),
  x = Join_group,
  y = log10_duration,
  type = "np",
  title = "Effect of Join Complexity on Execution Time (Precalculated Schema)",
  xlab = "Join Complexity",
  ylab = "log10(Execution Time)",
  results.subtitle = TRUE
)

# Optional: combine them
library(patchwork)
combined_plot <- p1 + p2 + plot_layout(nrow = 1)
combined_plot


df <- read_excel("data_main.xlsx")

# Keep only the Precalculate schema cases
df_filtered <- df %>%
  filter(Schema_version %in% c("Normalised_precalculate", "Precalculate"))

# Find common queries
common_queries <- df_filtered %>%
  group_by(Query_label) %>%
  summarise(n = n_distinct(Schema_version)) %>%
  filter(n == 2) %>%
  pull(Query_label)

# Filter to those queries
df_common <- df_filtered %>%
  filter(Query_label %in% common_queries)

# Reshape to wide format for paired comparison
df_wide <- df_common %>%
  select(Query_label, Schema_version, Execution_time_seconds) %>%
  tidyr::pivot_wider(names_from = Schema_version, values_from = Execution_time_seconds) %>%
  na.omit()

# Wilcoxon test
wilcox.test(df_wide$Normalised_precalculate, df_wide$Precalculate, paired = TRUE)

install.packages("ggpubr")
library(ggplot2)
library(ggpubr)

ggboxplot(df_common, 
          x = "Schema_version", 
          y = "Execution_time_seconds",
          color = "Schema_version",
          palette = "jco",
          add = "jitter") +
  stat_compare_means(method = "wilcox.test", paired = TRUE, label.y = max(df_common$Execution_time_seconds)) +
  labs(
    title = "Execution Time Comparison: Normalised vs Precalculated",
    y = "Execution Time (seconds)", x = "Schema Version"
  )

df_common %>%
  group_by(Schema_version) %>%
  summarise(
    avg_joins = mean(Joins_number, na.rm = TRUE),
    avg_agg = mean(Aggregate_functions_number, na.rm = TRUE)
  )

df_common %>%
  group_by(Schema_version) %>%
  summarise(
    avg_joins = mean(Joins_number, na.rm = TRUE),
    avg_agg = mean(Aggregate_functions_number, na.rm = TRUE)
  ) %>%
  tidyr::pivot_longer(cols = c(avg_joins, avg_agg), names_to = "Metric", values_to = "Average") %>%
  ggplot(aes(x = Schema_version, y = Average, fill = Metric)) +
  geom_col(position = "dodge") +
  labs(title = "Query Structural Complexity: Joins and Aggregations",
       y = "Average Count", x = "Schema Version") +
  theme_minimal()



library(readxl)
library(dplyr)
library(ggplot2)
library(ggpubr)
library(rstatix)

# Load dataset
df <- read_excel("data_main.xlsx")

# Filter for prejoin-related schemas
df_prejoin <- df %>%
  filter(Schema_version %in% c("Normalised_prejoin", "Intermediate", "Extreme"))

glimpse(df_prejoin)

# Kruskal-Wallis test
kruskal_result <- kruskal_test(df_prejoin, Execution_time_seconds ~ Schema_version)

# Pairwise Wilcoxon tests
pairwise_result <- df_prejoin %>%
  pairwise_wilcox_test(Execution_time_seconds ~ Schema_version, p.adjust.method = "bonferroni")

# Boxplot with p-values
ggboxplot(df_prejoin,
          x = "Schema_version",
          y = "Execution_time_seconds",
          color = "Schema_version",
          palette = "jco",
          add = "jitter") +
  stat_compare_means(method = "kruskal.test", label.y = max(df_prejoin$Execution_time_seconds)) +
  stat_compare_means(method = "wilcox.test",
                     comparisons = list(
                       c("Normalised_prejoin", "Prejoin_intermediate"),
                       c("Normalised_prejoin", "Prejoin_extreme"),
                       c("Prejoin_intermediate", "Prejoin_extreme")
                     ),
                     label = "p.signif") +
  labs(title = "Execution Time by Schema (Prejoin Hypothesis)",
       y = "Execution Time (seconds)", x = "Schema Version")


library(ARTool)      # install.packages("ARTool")
library(car)

# Filter for prejoin schemas
df_art <- df_scoring %>%
  filter(Schema_version %in% c("Normalised_prejoin", "Intermediate", "Extreme"))

# Convert Schema_version to factor
df_art$Schema_version <- factor(df_art$Schema_version)
df_art$Joins_number <- factor(df_art$Joins_number)

glimpse(df_art)

df_art$Join_group <- cut(
  as.numeric(as.character(df_art$Joins_number)),  # Convert factor → character → numeric
  breaks = c(-1, 0, 1, 2, Inf),
  labels = c("0 JOINs", "1 JOIN", "2 JOINs", "≥3 JOINs")
)

glimpse(df_art)
# Run ART ANOVA on log10_duration
art_model <- art(log10_duration ~ Join_group * Schema_version, data = df_art)
anova_result <- anova(art_model)
print(anova_result)


library(dplyr)
library(ggplot2)

# First, calculate the counts
counts_df <- df_art %>%
  group_by(Join_group, Schema_version) %>%
  summarise(n = n(), .groups = "drop")

# Create the base boxplot
p <- ggplot(df_art, aes(x = Join_group, y = log10_duration, fill = Schema_version)) +
  geom_boxplot(position = position_dodge(width = 0.8), outlier.shape = NA) +
  stat_summary(fun = mean, geom = "point", shape = 18, size = 2,
               position = position_dodge(0.8), color = "black") +
  labs(
    title = "Interaction between Join Complexity and Schema Version",
    subtitle = "Log10 of Execution Time (seconds)",
    x = "Join Complexity (Grouped)",
    y = "log10(Execution Time)",
    fill = "Schema Version"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 13, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5),
    axis.text = element_text(size = 10),
    legend.position = "top"
  )

# Add the counts as text under each box
p + geom_text(
  data = counts_df,
  aes(label = paste0("n = ", n), y = -3),  # adjust y to below the box
  position = position_dodge(width = 0.8),
  size = 3.3,
  color = "black"
)

library(dplyr)
library(ggplot2)

# First, calculate the counts
counts_df <- df_art %>%
  group_by(Join_group, Schema_version) %>%
  summarise(n = n(), .groups = "drop")

# Create the base boxplot
p <- ggplot(df_art, aes(x = Join_group, y = log10_duration, fill = Schema_version)) +
  geom_boxplot(position = position_dodge(width = 0.8), outlier.shape = NA) +
  stat_summary(fun = mean, geom = "point", shape = 18, size = 2,
               position = position_dodge(0.8), color = "black") +
  labs(
    title = "Interaction between Join Complexity and Schema Version",
    subtitle = "Log10 of Execution Time (seconds)",
    x = "Join Complexity (Grouped)",
    y = "log10(Execution Time)",
    fill = "Schema Version"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 13, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5),
    axis.text = element_text(size = 10),
    legend.position = "top"
  )

# Add the counts as text under each box
p + geom_text(
  data = counts_df,
  aes(label = paste0("n = ", n), y = -3),  # adjust y to below the box
  position = position_dodge(width = 0.8),
  size = 3.3,
  color = "black"
)

df_art %>%
  group_by(Schema_version) %>%
  do(model = lm(log10_duration ~ as.numeric(Joins_number), data = .)) %>%
  broom::tidy(model)

glimpse(df_art)
