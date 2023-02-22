# PDF stylized spreadhseet to tabular data
## 1) tabulizer + magick
remotes::install_github(c("ropensci/tabulizerjars", "ropensci/tabulizer"))
## or maybe image magick
# With tabulizer you can have a shim to select a certain boundinig box side; then use magic to crop the image specifically, to od an x and y crop

#Could possibly look a character representation and look for many white spaces; so could us regex to break apart columns on tabs and white spaces

# OR 2) unpack the XML behind the pdf to see if the divs are connected to the data points in the table; pdf tools can do that in R

# OR 3) Rawbid (Robid) is a big Java application (https://grobid.readthedocs.io/en/latest/Introduction/) -- uses a stack of models to xtract information, but it is a standalone software that then you batch up a request through
