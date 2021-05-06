# Plotting some data
# Start by importing data
library(tidyverse)


all_data = read_csv("actual_data/ALL.csv")
all_data = filter(all_data, total_matches > 0)
all_species = all_data %>% select(species) %>% distinct()

myTheme <- theme_classic() +
  theme(axis.text = element_text(size=14),
        axis.title = element_text(size=16, margin = margin(r = 0)),
        plot.title = element_text(size = 20))

#OK so what we want is a plot of sharing *within* individual vs sharing *between* individuals
#within-individual rows

all_data <- all_data %>% mutate(patterns = case_when(
  I1 == I2 ~ "sameI",
  I1 != I2 & M1 == M2 ~ "diffIsameM",
  I1 != I2 & M1 != M2 ~ "diffIdiffM"
))

all_comps <- ggplot(all_data, aes(x = patterns, y = match_percent)) +
  geom_boxplot(width = 0.5) +
  labs(title = "Comparison of sharing within and between individuals", 
       y = "Percentage of heterozygous k-mers shared (%)\n",
       x = "",
       size = 0.5) +
  scale_x_discrete(labels = c("Separate individuals \n and methods", 
                              "Separate individuals,\n same method", 
                              "Same individuals, \n separate methods")) +
  myTheme

# Getting averages
sI <- filter(all_data, patterns == "sameI", match_percent > 25)
dIsM <- all_data %>% filter(patterns == "diffIsameM")
dIdM <- all_data %>% filter(patterns == "diffIdiffM")

print(mean(sI$match_percent))
print(sd(sI$match_percent))
print(mean(dIsM$match_percent))
print(sd(dIsM$match_percent))
print(mean(dIdM$match_percent))
print(sd(dIdM$match_percent))

print(mean(c(dIsM$match_percent, dIdM$match_percent)))
print(sd(c(dIsM$match_percent, dIdM$match_percent)))

#useful  
all_data %>% 
  filter(patterns == "sameI", match_percent < 25) %>% 
  select(-full_F1, -full_F2, -lower_F1, -lower_F2, -upper_F1, -upper_F2) 
all_data %>% 
  filter(species == "icAdaBipu", patterns == "sameI") %>% 
  select(-full_F1, -full_F2, -lower_F1, -lower_F2, -upper_F1, -upper_F2)

#next, compare hi-c methods to other methods
all_data <- all_data %>% 
  mutate(HiC1 = M1 == "hic-dovetail" | M1 == "hic-arima2") %>%
  mutate(HiC2 = M2 == "hic-dovetail" | M2 == "hic-arima2")

hic_comps <- all_data %>% filter(HiC1 == TRUE | HiC2 == TRUE)

# we expect that as a % of Hi-C it's lower than as a % of the alternative
# so to test this... 
hic_comps <- hic_comps %>% mutate(
  percent_hic = case_when(HiC1 == TRUE ~ 100*total_matches/F1_length, 
                          HiC2 == TRUE ~ 100*total_matches/F2_length),
  percent_not = case_when(HiC1 == TRUE ~ 100*total_matches/F2_length,
                          HiC2 == TRUE ~ 100*total_matches/F1_length))
print("GAP")
print(mean(hic_comps$percent_hic))
print(sd(hic_comps$percent_hic))
print(mean(hic_comps$percent_not))
print(sd(hic_comps$percent_not))


hic_comps_tol <- hic_comps %>% 
  select(percent_hic, percent_not) %>% 
  pivot_longer(c(percent_hic, percent_not))

hic_comps_plot <- ggplot(hic_comps_tol, aes(x = name, y = value)) +
  geom_boxplot(width = 0.5) +
  labs(title = "Comparing sharing between Hi-C based and other \nmethods",
       y = "Percentage of heterozyous k-mers shared (%)\n",
       x = "") +
  scale_x_discrete(labels = c("% of the Hi-C count",
                              "% of the the count \nin the other file")) +
  myTheme

#hic_comps <- hic_comps %>% mutate(ratio = percent_hic/percent_not)

# Save plot
ggsave("Plots/all_comps.jpg", plot = all_comps, width = 9, height = 12)
ggsave("Plots/hic.jpg", plot = hic_comps_plot, width = 9, height = 12)

