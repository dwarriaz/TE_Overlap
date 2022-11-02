library(dplyr) 
library(tidyverse)
library(readr)
library(ggplot2)

TE_Map <- read.csv('~/KimLab/TE_Overlap/bin/output/final.csv', header = TRUE)
TE_table <- read.csv('~/KimLab/TE_Overlap/bin/repeats_table.csv', header = TRUE)

summary_table <-
  TE_Map %>% 
  select(-isoform) %>% 
  separate(insertion_name, sep = '_range', into = c('insert', 'range')) %>%
  distinct() %>% 
  group_by(gene_name, classification, instrand, genstrand) %>% 
  summarize(count = n())


View(summary_table)

ggplot(data = summary_table, aes(x = gene_name, y = count, fill = classification))+
  geom_col() +
  theme(axis.text.x = element_text(angle = 40, vjust = 1, hjust=1))

summary_table %>% 
  group_by(gene_name) %>% 
  mutate(total_count = sum(count), fraction_count = (count/total_count)) %>% 
  ggplot(aes(x = gene_name, y = fraction_count, fill = classification))+
  geom_col() +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 40, vjust = 1, hjust=1)) +
  ggtitle('Transposable Element Insertional Events in LTR7 Promoted Genes')



   
      


  



