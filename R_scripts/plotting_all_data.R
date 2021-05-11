library(tidyverse)

all_data = read_csv("actual_data/ALL.csv")
all_data = filter(all_data, total_matches > 0)
all_species = all_data %>% select(species) %>% distinct()

# Exclude Acipenser ruthenus as individuals are related.
all_data <- filter(all_data, species != "fAciRut")

myTheme <- theme_classic() +
  theme(axis.text = element_text(size=14),
        axis.title = element_text(size=16, margin = margin(r = 0)),
        plot.title = element_text(size = 20))

# Plot of sharing *within* individual vs sharing *between* individuals 
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

# Getting averages and standard deviations
sI_raw <- all_data %>% filter(patterns == "sameI")
sI <- filter(all_data, patterns == "sameI", match_percent > 25) # i.e. with outlier excluded
dIsM <- all_data %>% filter(patterns == "diffIsameM")
dIdM <- all_data %>% filter(patterns == "diffIdiffM")

print(paste("sameI_raw", mean(sI_raw$match_percent), sd(sI_raw$match_percent)))
print(paste("sameI", mean(sI$match_percent), sd(sI$match_percent)))
print(paste("diffIsameM", mean(dIsM$match_percent), sd(dIsM$match_percent)))
print(paste("diffIdiffM", mean(dIdM$match_percent), sd(dIdM$match_percent)))

print(paste("diffIall", mean(c(dIsM$match_percent, dIdM$match_percent)), sd(c(dIsM$match_percent, dIdM$match_percent))))
print("")

# Investigating outlier
all_data %>% 
  filter(patterns == "sameI", match_percent < 25) %>% 
  select(-full_F1, -full_F2, -lower_F1, -lower_F2, -upper_F1, -upper_F2) 
all_data %>% 
  filter(species == "icAdaBipu", patterns == "sameI") %>% 
  select(-full_F1, -full_F2, -lower_F1, -lower_F2, -upper_F1, -upper_F2)

## Comparing methods
all_data <- all_data %>% 
  mutate(HiC1 = M1 == "hic-dovetail" | M1 == "hic-arima2") %>%
  mutate(HiC2 = M2 == "hic-dovetail" | M2 == "hic-arima2")

# We want to plot by method.
hic_comps <- all_data %>% 
  filter(HiC1 == TRUE | HiC2 == TRUE) %>%
  mutate(method = "HiC")

pacbio_comps <- all_data %>%
  filter(M1 == "pacbio" | M2 == "pacbio") %>%
  mutate(method = "pacbio")

tenX_comps <- all_data %>% 
  filter(M1 == "10x" | M2 == "10x") %>%
  mutate(method = "tenX")

illumina_comps <- all_data %>%
  filter(M1 == "illumina" | M2 == "illumina") %>%
  mutate(method = "illumina")

all_WITH_REPEATS <- bind_rows(hic_comps, pacbio_comps, tenX_comps, illumina_comps)

# Within individuals
withinI_comp_plot <- all_WITH_REPEATS %>%
  filter(patterns == "sameI" & match_percent > 25) %>%
  ggplot(aes(x = method, y = match_percent)) +
  geom_boxplot(width = 0.5) +
  labs(title = "Comparison of different methods: within-individuals only, \noutliers excluded",
       y = "Percentage of heterozygous k-mers shared (%)\n",
       x = "") +
  scale_x_discrete(labels = c("Hi-C", "PacBio", "10X")) +
  myTheme

a <- filter(hic_comps, patterns == "sameI" & match_percent > 25)
b <- filter(pacbio_comps, patterns == "sameI" & match_percent > 25)
c <- filter(tenX_comps, patterns == "sameI" & match_percent > 25)

print("Within-I")
print(paste("Hi-C", mean(a$match_percent), sd(a$match_percent)))
print(paste("pacbio", mean(b$match_percent), sd(b$match_percent)))
print(paste("10X", mean(c$match_percent), sd(c$match_percent)))
print("")

# Between individuals
diffI_comp_plot <- all_WITH_REPEATS %>%
  filter(patterns != "sameI") %>%
  ggplot(aes(x = method, y = match_percent)) +
  geom_boxplot(width = 0.5) +
  labs(title = "Comparison of different methods: between-individuals",
       y = "Percentage of heterozygous k-mers shared (%)\n",
       x = "") +
  scale_x_discrete(labels = c("Hi-C", "PacBio", "10X")) +
  myTheme

a <- filter(hic_comps, patterns != "sameI")
b <- filter(pacbio_comps, patterns != "sameI")
c <- filter(tenX_comps, patterns != "sameI")

print("Between-I")
print(paste("Hi-C", mean(a$match_percent), sd(a$match_percent)))
print(paste("pacbio", mean(b$match_percent), sd(b$match_percent)))
print(paste("10X", mean(c$match_percent), sd(c$match_percent)))

# Save plots
ggsave("Figures/all_comps.jpg", plot = all_comps, width = 9, height = 12)
ggsave("Figures/methods.jpg", plot = withinI_comp_plot, width = 9, height = 12)
