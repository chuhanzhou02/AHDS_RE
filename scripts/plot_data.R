# === Package Installation & Loading ===
options(repos = c(CRAN = "https://cloud.r-project.org"))

required_packages <- c("tidyverse", "tidytext", "ggplot2", "SnowballC", "topicmodels", "scales", "reshape2")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}
library(tidyverse)
library(tidytext)
library(ggplot2)
library(SnowballC)
library(topicmodels)
library(scales)
library(reshape2)

# === Load Stop Words ===
data("stop_words", package = "tidytext")

# === Load & Preprocess Data ===
data <- read_tsv("clean/article_clean.tsv", col_names = TRUE, show_col_types = FALSE)

data <- data %>%
  mutate(
    Year = suppressWarnings(as.numeric(Year)),
    Cleaned_Title = tolower(Cleaned_Title)
  ) %>%
  drop_na(Year, Cleaned_Title) %>%
  rename(year = Year, title = Cleaned_Title)

# === Top Keywords Trend Plot ===
top_words <- data %>%
  unnest_tokens(word, title) %>%
  anti_join(stop_words, by = "word") %>%
  filter(!str_detect(word, "^[0-9]+$")) %>%
  mutate(word = SnowballC::wordStem(word)) %>%
  count(word, sort = TRUE) %>%
  slice_max(n, n = 10) %>%
  pull(word)

# 判断样本总量
total_n <- nrow(data)

# 判断是否保留 2025 年
if (total_n < 100) {
word_trends <- data %>%
  unnest_tokens(word, title) %>%
  filter(word %in% top_words) %>%
  count(year, word) %>%
  complete(year = 2000:2024, word, fill = list(n = 0)) %>%
} else {
word_trends <- data %>%
  unnest_tokens(word, title) %>%
  filter(word %in% top_words) %>%
  count(year, word) %>%
  complete(year = 2000:2024, word, fill = list(n = 0)) %>%
  filter(year != 2025)
}


word_trends <- data %>%
  unnest_tokens(word, title) %>%
  filter(word %in% top_words) %>%
  count(year, word) %>%
  complete(year = 2000:2024, word, fill = list(n = 0)) %>%
  filter(year != 2025)


gg <- ggplot(word_trends, aes(x = year, y = n, color = word, group = word)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_color_viridis_d(option = "plasma", begin = 0.1, end = 0.9) +
  labs(
    title = "Top 10 Keywords Trends",
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

ggsave(file.path(output_dir, "Top_10_Keywords_Trends.png"), plot = gg, width = 10, height = 6)

# === LDA Topic Model ===
lda_tokens <- data %>%
  select(title, year) %>%
  unnest_tokens(word, title) %>%
  anti_join(stop_words, by = "word") %>%
  filter(!str_detect(word, "^[0-9]+$")) %>%
  mutate(word = SnowballC::wordStem(word)) %>%
  count(document = row_number(), word, year)

dtm <- lda_tokens %>%
  cast_dtm(document, word, n)

lda_model <- LDA(dtm, k = 3, control = list(seed = 123))

topic_terms <- tidy(lda_model, matrix = "beta")
doc_topics <- tidy(lda_model, matrix = "gamma")

doc_years <- data.frame(document = as.integer(rownames(dtm)),
                        year = data$year[as.integer(rownames(dtm))])

doc_topics$document <- as.integer(doc_topics$document)

# === Filter out low-frequency years (e.g., < 5 articles) ===
# 判断样本总量
total_n <- nrow(data)

# 判断是否保留 2025 年
if (total_n < 100) {
  valid_years <- data %>%
    count(year) %>%
    filter(n >= 5) %>%
    pull(year)
} else {
  valid_years <- data %>%
    filter(year != 2025) %>%
    count(year) %>%
    filter(n >= 5) %>%
    pull(year)
}



topic_time <- doc_topics %>%
  left_join(doc_years, by = "document") %>%
  filter(year %in% valid_years) %>%
  group_by(year, topic) %>%
  summarise(mean_gamma = mean(gamma), .groups = "drop")

# === Add custom labels with topic names + keywords ===
topic_labels <- topic_terms %>%
  group_by(topic) %>%
  slice_max(beta, n = 4) %>%
  summarise(keywords = paste(term, collapse = ", "), .groups = "drop")

# Optionally assign semantic names manually
topic_labels <- topic_labels %>%
  mutate(
    topic_name = case_when(
      topic == 1 ~ "Student Internet Use",
      topic == 2 ~ "Youth Addiction",
      topic == 3 ~ "Game Addiction",
      TRUE ~ paste0("Topic ", topic)
    ),
    label = paste0(topic_name, "\n[", keywords, "]")
  ) %>%
  distinct(topic, label)

# === Merge into topic_time ===
topic_time_labeled <- topic_time %>%
  left_join(topic_labels, by = "topic")

# === Plot: Faceted by Topic ===
gg_lda_facet <- ggplot(topic_time_labeled, aes(x = year, y = mean_gamma)) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_point(color = "steelblue", size = 2) +
  facet_wrap(~ label, scales = "free_y") +
  labs(
    title = "LDA Topic Trends Over Time",
    x = "Year",
    y = "Average Topic Probability"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16),
    strip.text = element_text(size = 10, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave(file.path(output_dir, "LDA_Topic_Trends_Facet_Keywords.png"),
       plot = gg_lda_facet, width = 12, height = 6)

# === Print top terms for report ===
top_terms <- topic_terms %>%
  group_by(topic) %>%
  slice_max(beta, n = 5) %>%
  arrange(topic, -beta)

print(top_terms)
