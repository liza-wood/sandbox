# https://stackoverflow.com/questions/43546421/converting-pdf-table-to-data-frame-in-r-table-to-data-frame
# Example
library(tidyverse)
library(pdftools)

download.file("https://higherlogicdownload.s3.amazonaws.com/NASBO/9d2d2db1-c943-4f1b-b750-0fca152d64c2/UploadedImages/SER%20Archive/State%20Expenditure%20Report%20(Fiscal%202014-2016)%20-%20S.pdf", "data/nasbo14_16.pdf", mode = "wb")

txt14_16 <- pdf_text("data/nasbo14_16.pdf")

txt14_16[56] %>% 
  read_lines() %>%    # separate lines
  grep('^\\s{2}\\w', ., value = TRUE) %>%    # select lines with states, which start with space, space, letter
  paste(collapse = '\n') %>%    # recombine
  read_fwf(fwf_empty(.))  

# I want to read Washington's situation...
library(tesseract)
library(stringr)
df <- pdf_text("~/Box/lgu/data_raw/license/Washington.pdf")
png <- pdf_convert("~/Box/lgu/data_raw/license/Washington.pdf", 
                          format="png", dpi=150, filenames="data/washington.png")
#ocr_output <- ocr("~/Box/lgu/data_raw/license/Washington.pdf")
#cat(ocr_outpur[1])
ocr_data <- ocr_data(png)
ocr_data[4,]

# Break down by line and turn it into a dataframe
p1 <- df %>% 
  read_lines() 
p1df <- p1 %>% 
  as.data.frame(.) %>% 
  slice(-(1:2))  %>% 
  rename(text = ".")

# ID patterns for some of the columns
c1pattern = '^\\d{3,4}\\S*\\s?\\S*\\b|^\\d{3,4}\\s\\d{3,4}\\S+\\s?\\S*\\b|^AGR\\:\\S*'
c2pattern = '\\d{1,2}\\/\\d{1,2}\\/\\d{4}'
c3pattern = 'License|Non\\‐|Exclusive'
c7pattern = 'Seed\\s{3,}|Vegetative\\s{3,}'
c8pattern = 'College of Agricultural\\, Human\\, and|College of Engineering and Architecture|Natural Resource Sciences|Crop and Soil Sciences|Horticulture'

# Go through and identify the rows based on a few of the patterns and ID them into their groups
for(i in 1:nrow(p1df)){
  p1df$rowstart[i] = ifelse(str_detect(p1df$text[i],
                               c1pattern), T, F)
  p1df$id[i] = ifelse(str_detect(p1df$text[i],
                      c1pattern), seq(1:nrow(p1df))[i],
                      NA)
}

p1df <- na.locf(p1df, fromLast = T) %>% 
  group_by(id) %>% 
  mutate(numbering = row_number()) %>% 
  ungroup()

ids <- unique(p1df$id)
p1df$id_new = NA
for(j in 1:nrow(p1df)){
for(i in 1:length(ids)){
  if(p1df$id[j] == ids[i]){
    p1df$id_new[j] = seq(1:nrow(p1df))[i]
  }
}
}

p1df <- p1df %>% 
  mutate(id = paste(id_new, numbering, sep = "-")) 

# Separate into the columns for the first line, or "bottom" part, of the row
## First do those that have identifiable patterns
bottom <- p1df %>% 
  filter(rowstart == T) %>% 
  select(-rowstart) %>% 
  mutate(c1 = str_extract(text, c1pattern),
         c2 = str_extract(text, c2pattern),
         c3 = str_extract(text, c3pattern),
         c4 = "",
         c7 = str_extract(text, c7pattern),
         c8 = str_extract(text, c8pattern)) %>% 
  mutate(c3 = case_when(is.na(c3) ~ "", T ~ c3),
         c7 = case_when(is.na(c7) ~ "", T ~ c7),
         c8 = case_when(is.na(c8) ~ "", T ~ c8))

## Then the middle columns without easy patterns
c56 <- bottom %>% 
  mutate(text = str_remove_all(text, paste(c1pattern, c2pattern, c3pattern,
                                            c7pattern, c8pattern, sep = "|"))) %>% 
  select(text) %>% 
  mutate(text = trimws(text)) %>% 
  mutate(c5 = str_extract(text, '^.*(?=\\s{3,40})'),
         c6 = str_extract(text, '(?<=\\s{3,40}).*$')) %>% 
  mutate(text = trimws(text),
         c5 = trimws(c5),
         c6 = trimws(c6)) %>% 
  mutate(c5 = case_when(
    is.na(c5) & is.na(c6) & str_detect(text, '\\d{1,}') ~ text,
    T ~ c5),
    c6 = case_when(
      is.na(c5) & is.na(c6) ~ text,
      T ~ c6)) %>% 
  mutate(c5 = case_when(is.na(c5) ~ "", T ~ c5),
         c6 = case_when(is.na(c6) ~ "", T ~ c6)) %>% 
  select(-text)

## Combine
bottom <- cbind(bottom, c56) %>% 
  select(id, numbering, id_new, c1, c2, c3, c4, c5, c6, c7, c8)


# Upper parts
upper <- p1df %>% 
  filter(rowstart == F) %>% 
  select(-rowstart) %>% 
  mutate(c1 = str_extract(text, c1pattern),
         c2 = str_extract(text, c2pattern),
         c3 = str_extract(text, c3pattern),
         c7 = str_extract(text, c7pattern),
         c8 = str_extract(text, c8pattern)) %>% 
  mutate(c1 = case_when(is.na(c1) ~ "", T ~ c1),
         c2 = case_when(is.na(c2) ~ "", T ~ c2),
         c3 = case_when(is.na(c3) ~ "", T ~ c3),
         c7 = case_when(is.na(c7) ~ "", T ~ c7),
         c8 = case_when(is.na(c8) ~ "", T ~ c8))

## Then the middle columns without easy patterns
c4pattern = '\\b\\d{4}\\s|Plant Var\\‐\\d{2}\\/\\d{4}|\\d{4}\\‐\\S{2,6}\\‐OC|\\d{4}\\‐OC'
c4 <- upper %>% 
  mutate(text = str_remove_all(text, paste(c1pattern, c2pattern, c3pattern,
                                           c7pattern, c8pattern, sep = "|"))) %>% 
  select(id, text) %>% 
  mutate(text = trimws(text)) %>% 
  mutate(c4 = str_extract(text, c4pattern)) %>% 
  select(-text, -id) %>% 
  mutate(c4 = case_when(is.na(c4) ~ "", T ~ c4))
c56 <- upper %>% 
  select(id, text) %>% 
  mutate(text = str_remove_all(text, paste(c4pattern, c1pattern, 
                                           c2pattern, c3pattern,
                                           c7pattern, c8pattern, sep = "|"))) %>% 
  # remove leading space
  mutate(text = str_remove_all(text, '^\\s*')) %>% 
  # need to extract the first 32 characters
  mutate(c5 = str_extract(text, '.{1,31}'),
         c6 = str_extract(text, '(?<=.{31}).*')) 
  # Then these rules:
# If it starts with a dash or ) or ',' 'ar,', 'ies:', 'd\\s', 'se\\s', put in c5
# If it starts with a lower case or 'QN S.A.' or '.S.D.A', take the last letters from from c5
rmc6 <- paste(c('^\\‐', '^\\)\\s', '^\\,\\s', '^ar\\,?\\s', '^ies\\:\\s',
                '^d\\s', '^u?se\\s'), collapse = "|")
pullc5 <- paste(c('^QN S\\.A\\.', '^\\.S\\.D\\.A', '^[:lower:]'), collapse = "|")
c56 <- c56 %>% 
  mutate(
    # adding to c5new based on what is in c6
    c5new = case_when(
    str_detect(c6, rmc6) ~ paste0(c5, str_extract(c6, rmc6)),
    T ~ c5),
    # adding to c6new based on what is in c6
    c6new = case_when(
      str_detect(c6, pullc5) ~ paste0(str_extract(c5, '(?<=\\s)\\w+$'), c6),
      T ~ c6),
    # removing from c6new based on what is in c6new
    c6new = case_when(
      str_detect(c6, rmc6) ~ str_remove_all(c6new, rmc6),
      T ~ c6new),
    # removing from c5new based on what is in c6new
    c5new = case_when(
      str_detect(c6, pullc5) ~ str_remove_all(c5new, '(?<=\\s)\\w+$'),
      T ~ c5new)
    ) %>% 
  mutate(c5 = trimws(c5new), c6 = trimws(c6new)) %>% 
  select(-c5new, -c6new, -text, -id)
  
      
upper <- cbind(upper, c4, c56) %>% 
  select(id, numbering, id_new, c1, c2, c3, c4, c5, c6, c7, c8)

df <- full_join(bottom, upper) %>% 
  mutate(c6 = case_when(is.na(c6) ~ "", T ~ c6))

# STOPPED HERE, REALLY CLOSE BUT NEED TO FIGURE OUT HOW TO PASTE BY GROUP

df2 <- df %>% 
  arrange(id_new, numbering) %>% 
  group_by(id_new) %>% 
  summarize(c1 = paste(unique(c1),collapse=' '),
            c2 = paste(unique(c2),collapse=' '),
            c3 = paste(unique(c3),collapse=' '),
            c4 = paste(unique(c4),collapse=' '),
            c5 = paste(unique(c5),collapse=' '),
            c6 = paste(unique(c6),collapse=' '),
            c7 = paste(unique(c7),collapse=' '),
            c8 = paste(unique(c8),collapse=' '))

# One issue
df2 <- df2 %>% 
  mutate(c6 = case_when(c6 == "Skagit" ~ "Skagit Horticulture", T ~ c6),
       c8 = case_when(c6 == "Skagit Horticulture" ~ "Natural Resource Sciences"))


  #paste(collapse = '\n') %>% 
  #read_fwf(fwf_widths(c(25,20,10,23,40,30,15,40)))
  #read_fwf(fwf_positions(c(1,26), c(26, 44)))
  #read_fwf(fwf_empty(., col_names = c("c1", "c2", "c3", "c4", "c5",
  #                                    "c6", "c7", "c8")))
?read_fwf
?fwf_empty
?fwf_cols
fwf_sample <- readr_example("fwf-sample.txt")
writeLines(read_lines(fwf_sample))
read_fwf(fwf_sample, fwf_cols(name = 20, state = 10, ssn = 12))
read_fwf(fwf_sample, fwf_empty(fwf_sample, col_names = c("first", "last", "state", "ssn")))



