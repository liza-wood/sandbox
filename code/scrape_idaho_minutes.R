library(rvest)
library(xml2)
library(stringr)
library(lubridate)

# input the URL to scrape
url <- 'https://www.idl.idaho.gov/about-us/land-board/land-board-meeting-materials-minutes-archive/'
# read the page in
page <- read_html(url)

# take all accordian links
links <- xml_find_all(page, '//*[(@id = "accordian")]//a') %>% 
  html_attr('href')

# three different kinds of document pdfs
minutes <- links[str_detect(links, '\\-minutes')]
materials <- links[str_detect(links, 'materials')]
comments <- links[which(!(links %in% c(minutes, materials)))]

# create filenames for just the minutes, could expand later
filenames <- str_extract(minutes, "(?<=archive\\/).*") %>% 
  str_extract(., "(?<=\\d{4}\\/)\\d*") %>% 
  mdy() 

# this is all you would need to change -- where do you want this on your computer?
file_dir <- '~/Desktop/idaho_pdfs/'
dir.create(file_dir)
filenames <- paste0(file_dir, filenames, '.pdf')

idaho_download <- function(pdf_url, dest_filename){
  Sys.sleep(2)
  download.file(pdf_url, dest_filename, mode = 'wb')
}

# give mapply the function, the 'x' and 'y' arguments for the function
mapply(idaho_download, minutes, filenames)

# now you can read them in if you want...
library(pdftools)
#pdf_text()
