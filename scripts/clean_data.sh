#!/bin/bash

mkdir -p ~/AHDS_project/clean

echo "Processing article metadata..."

for file in ~/AHDS_project/raw/article-data-*.xml; do
 
    pmid=$(basename "$file" .xml | grep -oP '\d+')
    year=$(grep -oP '<PubDate>.*?<Year>\K\d+' "$file" | head -n 1)
    title=$(grep -oP '(?<=<ArticleTitle>|<BookTitle>).*?(?=</ArticleTitle>|</BookTitle>)' "$file" | sed 's/<[^>]*>//g')

    if [ -z "$title" ]; then
        continue
    fi

    echo -e "${pmid}\t${year}\t${title}" >> ~/AHDS_project/clean/articles.tsv
done

echo "Data cleaning completed. Check '~/AHDS_project/clean/articles.tsv' for results."

