#!/bin/bash

retmax=${1:-10000}

mkdir -p raw
echo "Downloading PubMed IDs with retmax=$retmax..."

curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=%22gaming+disorder%22+OR+%22smartphone+addiction%22+OR+%22internet+addiction%22+OR+%22social+media+addiction%22&retmax=${retmax}" > raw/pmids.xml
echo "PubMed IDs downloaded to raw/pmids.xml."

echo "Downloading article metadata..."

for pmid in $(grep -oP '<Id>\K[0-9]+' raw/pmids.xml); do
    file_path="raw/article-data-${pmid}.xml"

    if [ -f "$file_path" ]; then
        echo "File already exists: article-data-${pmid}.xml, skipping..."
        continue
    fi

    echo "Downloading: article-data-${pmid}.xml"
    curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=${pmid}" > "$file_path"
    sleep 1
done

echo "All articles downloaded."
