#!/bin/bash

mkdir -p clean

echo "Processing article metadata..."

for file in raw/article-data-*.xml; do
    pmid=$(basename "$file" .xml | grep -oP '\d+')
    year=$(grep -oP '<PubDate>.*?<Year>\K\d+' "$file" | head -n 1)
    title=$(grep -oP '(?<=<ArticleTitle>|<BookTitle>).*?(?=</ArticleTitle>|</BookTitle>)' "$file" | sed 's/<[^>]*>//g')

    if [ -z "$title" ]; then
        continue
    fi

    echo -e "${pmid}\t${year}\t${title}" >> clean/articles.tsv
done

echo "Data cleaning completed. Check 'clean/articles.tsv' for results."
