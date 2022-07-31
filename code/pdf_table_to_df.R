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
df <- pdf_text("~/Box/lgu/data_raw/license/Washington.pdf")
png <- pdf_convert("~/Box/lgu/data_raw/license/Washington.pdf", 
                          format="png", dpi=150, filenames="data/washington.png")
ocr_output <- ocr("~/Box/lgu/data_raw/license/Washington.pdf")
?ocr
cat(ocr_outpur[1])
ocr_data <- ocr_data(png)

p1 <- df[1] %>% 
  read_lines() %>% 
  grep('^\\d{3,4}\\‐|^\\d{3,4}\\s\\d{3,4}\\‐', ., value = T) %>% 
  paste(collapse = '\n') %>% 
  read_fwf(fwf_widths(c(25,18,18,23,40,30,15,40)))
?read_fwf
?fwf_empty
