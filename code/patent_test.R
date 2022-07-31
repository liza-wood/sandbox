#devtools::install_github("JYProjs/patentr")
library(patentr)
library(tidyverse)
library(lubridate)
library(stringr)
# https://cran.r-project.org/web/packages/patentr/vignettes/intro.html
# https://github.com/JYProjs/patentr

getOption('timeout')
options(timeout=1000)

plant_words <- paste(c("\\b[Pp]lant", "[Gg]ermplasm", "[Vv]ariet*", 
                       "[Cc]ultivar", "[Ss]cion", "[Rr]ootstock"), collapse = "|")
# Need to run from here
uni_plant_patents <- data.frame()
for(i in 2019){
  for(j in 25:52){
    get_bulk_patent_data(
      year = i,         
      week = j,                   
      output_file = "data/temp_patent_output.csv" # output file in which patent data is stored
    )
    patent_data <- read.csv("data/temp_patent_output.csv", 
                            col.names = c("WKU", "Title", "App_Date",
                                          "Issue_Date", "Inventor",
                                          "Assignee", "ICL_Class",
                                          "References", "Claims")) %>%
      mutate(App_Date = as_date(App_Date),
             Issue_Date=as_date(Issue_Date))
    
    df <- patent_data %>% 
      filter(str_detect(Assignee, "[Uu]niversity|[Vv]irginia Tech")) %>% 
      filter(str_detect(Title, plant_words))
    
    uni_plant_patents <- rbind(uni_plant_patents, df)
  }
}

uspto_df <- uni_plant_patents
uspto_df$Title <- str_replace_all(uspto_df$Title, "‘|’", "'")
write.csv(uspto_df, "~/Box/lgu/data_raw/other_ip/uspto.csv", row.names = F)

# Single example ----
get_bulk_patent_data(
  year = 2021,         
  week = 1,                   
  output_file = "data/temp_patent_output.csv" # output file in which patent data is stored
)

# import data into R; right now it is having column naming issues
patent_data <- read.csv("data/temp_patent_output.csv", 
                        col.names = c("WKU", "Title", "App_Date",
                                      "Issue_Date", "Inventor",
                                      "Assignee", "ICL_Class",
                                      "References", "Claims")) %>%
  mutate(App_Date = as_date(App_Date),
         Issue_Date=as_date(Issue_Date))

plant_words <- paste(c("\\b[Pp]lant", "[Gg]ermplasm", "[Vv]ariety", 
                       "[Cc]ultivar", "[Ss]cion", "[Rr]ootstock"), collapse = "|")
uni_patents <- patent_data %>% 
  filter(str_detect(Assignee, "[Uu]niversity")) %>% 
  filter(str_detect(Title, plant_words))


## THIS HASNT WORKED ----
library(patentsview)
search_fields <- patentsview::fieldsdf

qry_1 <- '{"_gt":{"patent_year":2007}}'
results <- search_pv(qry_1) 

data1 <- results$data$patents 

qry_2 <- '{"_gt":{"patent_date":"2007-08-01"}}'
results <- search_pv(query = qry_2, fields = NULL) 

data2 <- results$data$patents 

qry_3 <- '{"_gt":{"patent_date":"2010-08-01"}}'
results <- search_pv(query = qry_3, fields = NULL) 

data3 <- results$data 

qry_3 <- '{"_gte":{"patent_year":2007}},{"_text_any":{"patent_abstract":"plant variety"}}'
search_pv(query = qry_3, fields = NULL) 

#https://api.patentsview.org/patents/query?q={"_and": [{"_gte":{"patent_date":"2001-01-01"}},{"_text_any":{"patent_abstract":"international"}},{"_neq":{"assignee_lastknown_country":"US"}}]}&f=["patent_number","patent_processing_time","patent_kind"]

