# stable version from CRAN
install.packages("patentr")

library(patentr)
library(tibble)    # for the tibble data containers
library(magrittr)  # for the pipe (%>%) operator
library(dplyr)     # to work with patent data
library(lubridate) # to work with dates

?get_bulk_patent_data
get_bulk_patent_data(
  year = rep(2022, 1),            # each week must have a corresponding year
  week = 1,                     # each week corresponds element-wise to a year
  output_file = "data/temp_output.csv" # output file in which patent data is stored
)

# import data into R
patent_data <- read.csv("data.temp_output.csv") %>%
  as_tibble() %>%
  mutate(App_Date = as_date(App_Date),
         Issue_Date=as_date(Issue_Date))


install.packages("patentsview")
library(patentsview)
View(patentsview::fieldsdf)

qry_1 <- '{"_gt":{"patent_year":2007}}'
results <- search_pv(query = qry_1, fields = NULL) 

data <- results$data$patents 

qry_1 <- '{"_gt":{"patent_date":"2007-01-01"}}'
results <- search_pv(query = qry_1, fields = NULL) 

data <- results$data$patents 

qry_2 <- '{"_gte":{"patent_year":2007}},{"_text_any":{"patent_abstract":"plant variety"}}'
search_pv(query = qry_2, fields = NULL) 

https://api.patentsview.org/patents/query?q={"_and": [{"_gte":{"patent_date":"2001-01-01"}},{"_text_any":{"patent_abstract":"international"}},{"_neq":{"assignee_lastknown_country":"US"}}]}&f=["patent_number","patent_processing_time","patent_kind"]

qry_2 <- '{"_gte":{"patent_year":2007},{"patent_abstract":"plant"}}'
search_pv(query = qry_2, fields = NULL) 
