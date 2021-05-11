library(tidyverse)

mosquito = read_csv("actual_data/anopheles_out.csv")

# For plotting 
myTheme <- theme_classic() +
  theme(axis.text = element_text(size=14),
        axis.title = element_text(size=16, margin = margin(r = 0)),
        plot.title = element_text(size = 20))

# Add categories
mosquito <- mosquito %>%
  mutate(patterns = case_when(
    I1 == I2 & F1 == F2 ~ "SameI",
    F1 == F2 & I1 != I2 ~ "SameF",
    F1 != F2 ~"DiffF"
  ))

# Plot all by familial relationship or lack thereof
mozzie_plot <- ggplot(mosquito, aes(x = patterns, y = match_percent)) +
  geom_boxplot(width = 0.5) +
  labs(title = expression(paste("Comparing ", italic("Anopheles"), " mosquitos with family relationships")),
       y = "Percentage of heterozyous k-mers shared (%)\n",
       x = "") +
  scale_x_discrete(labels = c("Separate families",
                              "Same family, \nseparate individuals",
                              "Same individual")) + 
  myTheme

ggsave("Figures/mozzies.jpg", plot = mozzie_plot, width = 9, height = 12)


# Calculating averages and standard deviations
SI <- filter(mosquito, patterns == "SameI")
SF <- filter(mosquito, patterns == "SameF")
DF <- filter(mosquito, patterns == "DiffF")

print(paste("withinI", mean(SI$match_percent), sd(SI$match_percent)))
print(paste("withinF", mean(SF$match_percent), sd(SF$match_percent)))
print(paste("betweenF", mean(DF$match_percent), sd(DF$match_percent)))

# Isolating the lower outlier from same family, separate individuals
mosquito %>% 
  filter(patterns == "SameF", match_percent < 25) %>%
  select(species, match_percent, F1, I1, F2, I2, M1, M2)

mosquito %>% 
  filter(F1 == 416, 
         F2 == 416, 
         I1 == 5 & M1 == "pacbio" | I2 == 5 & M2 == "pacbio" | 
         I1 == 6 & M1 == "hic-arima2" | I2 ==6 & M2 =="hic-arima2") %>%
  select(species, match_percent, F1, I1, F2, I2, M1, M2)