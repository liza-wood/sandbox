#devtools::install_github('ucd-cepb/textNet')
library(textNet)
library(rvest)
library(xml2)
library(dplyr)
url <- "https://news.airbnb.com/airbnb-community-fund-2023-2024/"
page <- read_html(url)
# text and bullets but no head runner
text <- xml_find_all(page, '//p | //*[(@id = "mainContent")]//li') %>% 
  html_text()
title <- xml_find_all(page, '//*[contains(concat( " ", @class, " " ), concat( " ", "post__title", " " ))]') %>% 
  html_text()
text <- trimws(paste(text, collapse = " "))
write.table(text, 'data/airbnb_text.txt', row.names = F, col.names = F)

cat(text)
?parse_text
text <- read.table('~/Documents/Davis/R-Projects/sandbox/data/airbnb_text.txt')[1,1]

Sys.getenv()
reticulate::py_config()
# "usr/bin/python3"
Sys.setenv(RETICULATE_PYTHON = "/Users/lizawood/opt/anaconda3")
Sys.setenv(RETICULATE_PYTHON_FALLBACK = "/Users/lizawood/opt/anaconda3")
library(spacyr)
reticulate::use_condaenv("spacy_condaenv", required = TRUE)
spacyr::spacy_install()
spacyr::spacy_initialize()
parsedtxt <- spacy_parse(text, lemma = FALSE, entity = TRUE, nounphrase = TRUE)
parse_text(ret_path = "/Users/lizawood/opt/anaconda3",
           pages = text,
           file_ids = 1,
           parsed_filenames = '~/Documents/Davis/R-Projects/sandbox/data/airbnb_text.txt')
