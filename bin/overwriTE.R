library(dplyr) 
library(tidyverse)
library(readr)
library(ggplot2)
library(ggrepel)

TE_Map <- read.csv('~/KimLab/TE_Overlap/bin/output/final.csv', header = TRUE)

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

TE_dict <- read.table(file = '~/KimLab/TE_Overlap/bin/Rep_Dict.tsv', sep = '\t', header = FALSE)
colnames(TE_dict) <- c('repName','repClass','repFamily')

TE_dict <-
  TE_dict %>%
  group_by(repName, repClass, repFamily) %>% 
  add_count() %>% 
  rename(TE_gwide_counts = n) %>%
  ungroup() %>% 
  mutate(grfreq = TE_gwide_counts/sum(TE_gwide_counts)) %>% 
  distinct() 
  

# TE_dict %>% 
#   group_by(repFamily,n) %>% 
#   distinct() %>% 
#   filter(repFamily != 'Simple_repeat') %>% 
#   ggplot(aes(x = reorder(repFamily,n),y = n)) + 
#   geom_col() + 
#   theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

TE_Dist <- read.csv('KimLab/TE_Overlap/bin/output/trim_TE_Overlap.csv', header=TRUE)

  
TE_Dist <-
  TE_Dist %>% 
  separate(insertion_name, sep = '_range', into = c('insert', 'range')) %>% 
  group_by(isoform, gene_name, insert) %>% 
  add_count() %>% 
  rename(relative_counts = n)

TE_Dist <- 
  TE_Dist %>% 
  group_by(isoform) %>% 
  mutate(relative_freq = relative_counts/sum(relative_counts))


TE_dict %>% 
  select(repName,repFamily,repClass) %>% 
  merge(TE_Dist, by.x ='repName', by.y = 'insert', no.dups = T) %>% 
  group_by(isoform,repClass) %>% 
  add_count() %>% 
  rename(isoform_TEclass_count = n) %>% 
  ungroup() %>% 
  group_by(isoform, repFamily) %>% 
  add_count() %>% 
  rename(isoform_TEfamily_count = n) %>% 
  ungroup() -> repAnalysis

repAnalysis %>% 
  group_by(isoform,repFamily,isoform_TEfamily_count,repClass,isoform_TEclass_count) %>% 
  summarise() %>% 
  View()

repAnalysis %>% 
  group_by(isoform) %>% 
  mutate(isoform_TEfamily_freq = isoform_TEfamily_count/sum(isoform_TEfamily_count)) %>% 
  mutate(isoform_TEclass_freq = isoform_TEclass_count/sum(isoform_TEclass_count)) %>% 
  select(isoform,gene_name,repName,repFamily,isoform_TEfamily_freq,repClass,isoform_TEclass_freq) %>% 
  distinct() -> tempdf

translator <-
  TE_Dist %>% 
  select(gene_name,isoform) %>% 
  distinct()

tempdf %>% 
  filter(!grepl('Promoter',isoform)) %>% 
  filter(!grepl('\\?',repClass)) %>% 
  #group_by(repClass) %>% 
  #mutate(norm_class_frq=(isoform_TEclass_freq - mean(isoform_TEclass_freq, na.rm = TRUE)) / sd(isoform_TEclass_freq, na.rm = TRUE)) %>% 
  # filter(repClass == 'LTR') %>% 
  ggplot(aes(x=repClass,y=isoform_TEclass_freq)) +
  geom_boxplot(outlier.colour = NA) +
  coord_cartesian(ylim = c(0, 0.05)) +
  #geom_jitter(alpha=0.3)+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

tempdf %>% 
  select(isoform,gene_name,repFamily, isoform_TEfamily_freq) %>% 
  pivot_wider(names_from = repFamily,values_from = isoform_TEfamily_freq, values_fn = mean) %>% 
  replace(is.na(.),0) %>% 
  select(-gene_name) %>% 
  column_to_rownames('isoform') -> pca_tmp_in

pca_tmp_in_sd <- apply(pca_tmp_in, 2, sd)
pca_tmp_in_zero_sd <- pca_tmp_in[,pca_tmp_in_sd!=0]
non_zero_pca <- prcomp(pca_tmp_in_zero_sd, center = T, scale. = T, rank. = 50)

PCA_df <-
  as_tibble(non_zero_pca$x)
PCA_df$isoform = rownames(non_zero_pca$x)

PCA_df %>% 
  merge(translator, by='isoform') %>% 
  ggplot(aes(x=PC1,y=PC2,label=gene_name,group=gene_name))+
    geom_point()+
    geom_label_repel()+
    stat_ellipse()

#Take PC1 and correlate it with repFamily freq 
  

  
  
