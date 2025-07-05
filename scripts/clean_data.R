library(tidyverse)
library(tidytext)
library(SnowballC)

data <- read_tsv("clean/articles.tsv", col_names = c("PMID", "Year", "Title"))

cleaned_data <- data %>%
  unnest_tokens(word, Title) %>%                           
  anti_join(stop_words, by = "word") %>%                   
  filter(!str_detect(word, "^[0-9]+$")) %>%                
  mutate(word = str_remove_all(word, "[0-9]")) %>%         
  filter(word != "") %>%                                   
  filter(!str_detect(word, "^[[:punct:]]+$")) %>%          
  mutate(word = SnowballC::wordStem(word)) %>%             
  group_by(PMID, Year) %>%                                 
  summarise(
    Cleaned_Title = str_squish(paste(word, collapse = " ")), 
    .groups = "drop"
  ) %>%
  arrange(Year, PMID)                                       

output_file <- "clean/article_clean.tsv"

dir.create(dirname(output_file), showWarnings = FALSE, recursive = TRUE)

write_tsv(cleaned_data, output_file, na = "NA", col_names = TRUE)

cat("Data cleaning completed. File saved to:", output_file, "\n")


