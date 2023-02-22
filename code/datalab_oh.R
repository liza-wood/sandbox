library(rvest)
library(xml2)
# Reading a url but it is mostly XML
url <- "https://foodb.ca/compounds/FDB001390"
page <- read_html(url)
as.character(page)
div <- xml_find_all(page, "//div")
tbl <- page %>% 
  xml_find_all(., xpath = "//table")
tbl <- page %>% 
  html_nodes(xpath = "//table")
html_text(page)


library(httr)
response = GET(url)
as.character(content(response))

doc <- read_xml(url)
message(as.character(doc))
xml_text(html_elements(doc, xpath = "//kingdom"))
xml_text(html_elements(doc, xpath = "//super_class"))
write_xml(doc, 'test.xml')

library(tidyverse)
my_var <- colnames(mtcars)
mutate(mtcars, across(., ~ case_when(.)))
