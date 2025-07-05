options(repos = c(CRAN = "https://cloud.r-project.org"))

required_packages <- c("tidyverse", "tidytext", "ggplot2", "SnowballC")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}

library(tidyverse)
library(tidytext)
library(ggplot2)
library(SnowballC)

data("stop_words", package = "tidytext")

data <- read_tsv(
  "clean/article_clean.tsv",
  col_names = TRUE, 
  show_col_types = FALSE
)

data <- data %>%
  mutate(
    Year = suppressWarnings(as.numeric(Year)),
    Cleaned_Title = tolower(Cleaned_Title)
  ) %>%
  drop_na(Year, Cleaned_Title) %>%
  rename(year = Year, title = Cleaned_Title)

top_words <- data %>%
  unnest_tokens(word, title) %>%
  anti_join(stop_words, by = "word") %>%
  filter(!str_detect(word, "^[0-9]+$")) %>%
  mutate(word = SnowballC::wordStem(word)) %>%
  count(word, sort = TRUE) %>%
  slice_max(n, n = 15) %>%
  pull(word)

word_trends <- data %>%
  unnest_tokens(word, title) %>%
  filter(word %in% top_words) %>%
  count(year, word) %>%
  complete(year = 2020:2024, word, fill = list(n = 0))

gg <- ggplot(word_trends, aes(x = year, y = n, color = word, group = word)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_color_viridis_d(option = "plasma", begin = 0.1, end = 0.9) +
  labs(
    title = "Top 15 Keywords Trends (2020-2024)",
    x = "Year",
    y = "Frequency",
    color = "Keywords"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

output_dir <- "plot"
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

ggsave(file.path(output_dir, "Top_15_Keywords_Trends.png"), plot = gg, width = 10, height = 6)
