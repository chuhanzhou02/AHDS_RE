configfile: "config.yaml"

rule all:
    input:
         "raw/pmids.xml",
          "clean/articles.tsv",
          "clean/article_clean.tsv",
         "plot/Top_15_Keywords_Trends.png"

rule download_data:
    output:
        "raw/pmids.xml"
    params:
        retmax = 20 if config["test"] else 10000
    shell:
        """
        bash scripts/download_data.sh {params.retmax}
        """


rule clean_data:
    input:
         "raw/pmids.xml"
    output:
         "clean/articles.tsv"
    shell:
        """
        bash scripts/clean_data.sh
        """

rule clean_title:
    input:
          "clean/articles.tsv"
    output:
         "clean/article_clean.tsv"
    shell:
        """
        Rscript scripts/clean_data.R
        """

rule plot:
    input:
          "clean/article_clean.tsv"
    output:
         "plot/Top_15_Keywords_Trends.png"
    shell:
        """
        Rscript scripts/plot_data.R
        """


rule clean:
    "Clean"
    shell: """
    if [ -d raw ]; then
      rm -r raw
    else
      echo directory raw does not exist
    fi
    if [ -d plot ]; then
      rm -r plot
    else
      echo directory plot does not exist
    fi
    if [ -d clean ]; then
      rm -r clean
    else
      echo directory clean does not exist
    fi
    """