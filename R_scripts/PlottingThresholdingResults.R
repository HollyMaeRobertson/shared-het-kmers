# Plotting some data
# Start by importing data
library(tidyverse)
library(viridis)
library(patchwork)

make_plot <- function(ToPlot, hap_cov, plot_name) {
  thisplot <- ggplot(ToPlot, aes(x = lower_F1, y = upper_F1, colour = match_percent)) +
    geom_point(shape = 15, size = 7) +
    scale_color_viridis("Percentage matches", option = "plasma") +
    geom_vline(xintercept = 0.5 * hap_cov, col = "red", size = 1) +
    geom_hline(yintercept = 1.5 * hap_cov, col = "red", size = 1) +
    geom_text(aes(label = round(match_percent)), col = "black", size = 3) +
    theme_classic() +
    labs(x = "Lower boundary of first file",
         y = "Upper boundary used in first file",
         title = plot_name
         #subtitle = "Red lines show 0.5x and 1.5x haploid coverage on the x and y axes respectively"
         )
return(thisplot)
}

apa <- read_tsv("thresholding_results/apa_iris.tsv")
apa <- filter(apa, upper_F1 < 120)
har <- read_tsv("thresholding_results/har_axyr.tsv")
har <- filter(har, upper_F1 < 120)
nap1 <- read_tsv("thresholding_results/napi1_10xVsPb.tsv")
nap1 <- filter(nap1, upper_F1 < 120)
nap10x <- read_tsv("thresholding_results/napi1vs4_10x.tsv")
nap10x <- filter(nap10x, upper_F1 < 150)
napPb <- read_tsv("thresholding_results/napi1vs4_pacbio.tsv")
napPb <- filter(napPb, upper_F1 < 90)
nap4 <- read_tsv("thresholding_results/napi4_10xVsPb.tsv")
nap4 <- filter(nap4, upper_F1 < 150)
pat <- read_tsv("thresholding_results/pat_pell.tsv")
pat <- filter(pat, upper_F1 < 90)


apa_plot <- make_plot(apa, 45.23, "Apatura iris: 10x vs pacbio")
har_plot <- make_plot(har, 46.29, "Harmonia axyridis: 10x vs pacbio")
napi10x_plot <- make_plot(nap10x, 56.5, "Pieris napi, 10x: sample 1 vs sample 4")
napiPb_plot <- make_plot(napPb, 29.4, "Pieris napi, pacbio: sample 1 vs sample 4")
napi1_plot <- make_plot(nap1, 56.5, "Pieris napi, sample 1: 10x vs pacbio")
napi4_plot <- make_plot(nap4, 47.14, "Pieris napi, sample 4: 10x vs pacbio")
pat_plot <- make_plot(pat, 24.26, "Patella pellucida: 10x vs pacbio")

ggsave(plot = napi10x_plot, filename = "pieris_napi10x.jpg", width = 7, height = 10)
ggsave(plot = napiPb_plot, filename = "pieris_napiPb.jpg", width = 5, height = 8)
ggsave(plot = napi1_plot, filename = "pieris_napi1.jpg", width = 8, height = 8)
ggsave(plot = napi4_plot, filename = "pieris_napi4.jpg", width = 7, height = 10)
ggsave(plot = apa_plot, filename = "apatura_iris.jpg", width = 7, height = 9)
ggsave(plot = har_plot, filename = "harmonia_axyridis.jpg", width = 7, height = 9)
ggsave(plot = pat_plot, filename = "patella_pellucida.jpg", width = 4.8, height = 6)