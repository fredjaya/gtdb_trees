#!/usr/bin/env Rscript
library(dplyr)
library(tidyr)
library(ggplot2)

args = commandArgs(trailingOnly=T)
alistat_file = args[1]
n_loci = as.integer(args[2])

as <- read.csv(alistat_file, header = F)

as %>%
  ggplot(aes(x = V3, y = V4)) +
  geom_point() +
  theme_light() +
  coord_cartesian(ylim = c(0,1)) +
  labs(x = "Number of sites in alignment", y = "Unaambiguous characters/total characters")
ggsave("completeness.png")

# output training loci according to n
as %>%
  arrange(desc(V4)) %>%
  slice(1:n_loci) %>%
  select(V1) %>%
  write.table(file = "training_loci.txt", col.names = F, quote = F, row.names = F)

# output testing loci
as %>%
  arrange(desc(V4)) %>%
  slice((n_loci+1):nrow(.)) %>%
  # remove empty sequences
  # TODO: output number of loci remaining or throw error if too low
  filter(V4 > 0) %>%
  select(V1) %>%
  write.table(file = "testing_loci.txt", col.names = F, quote = F, row.names = F)
