library(stringr)
dirs <- list.files("~/Documents/Davis/R-Projects/sos2022/code", full.names = T)[2:6]
fls <- list.files(dirs, recursive = T, full.names = T)

read_fxs <- c("read\\.csv", "read_csv", "readRDS", "fread")
read_fxs <- paste(read_fxs, collapse = "|")
save_fxs <- c("write\\.csv", "write_csv", "saveRDS", "fwrite")
save_fxs <- paste(save_fxs, collapse = "|")

wrkflw_df <- data.frame()
for(i in 1:length(fls)){
  text <- readLines(fls[i])
  
  wd_lines <- which(str_detect(text, "setwd") == T)
  read_lines <- which(str_detect(text, read_fxs) == T)
  save_lines <- which(str_detect(text, save_fxs) == T)
  save_lines <- sort(c(save_lines, save_lines +1))
  
  df <- data.frame("script" = rep(fls[i], (length(wd_lines) + 
                                             length(read_lines) +
                                             length(save_lines))),
                   "action" = c(rep("wd", length(wd_lines)), 
                                rep("read", length(read_lines)),
                                rep("save", length(save_lines))),
                   "line" = c(wd_lines,
                              read_lines,
                              save_lines),
                   "text" = c(text[wd_lines],
                              text[read_lines],
                              text[save_lines]))
  wrkflw_df <- rbind(wrkflw_df, df)
}

wrkflw_df <- wrkflw_df[!is.na(wrkflw_df$text) & wrkflw_df$text != "",]
path <- str_extract_all(wrkflw_df$text, '(?<=").*(?=")')
path[sapply(path, function(x) length(x) == 0)] <- NA
wrkflw_df$path <- unlist(path)
wrkflw_df <- wrkflw_df[!is.na(wrkflw_df$path),]
wrkflw_df$wd <- ifelse(wrkflw_df$action == "wd", wrkflw_df$path, NA)

scripts <- unique(wrkflw_df$script)


mindr::dir2mm(
  from = getwd(),
  root = NA,
  dir_files = TRUE,
  dir_all = TRUE,
  dir_excluded = NA,
  md_maxlevel = ""
)

library(mindr)
markmap(
  from = getwd(),
  root = NA,
  input_type = "auto",
  md_list = FALSE,
  md_eq = FALSE,
  md_braces = FALSE,
  md_bookdown = FALSE,
  md_maxlevel = "",
  dir_files = TRUE,
  dir_all = TRUE,
  dir_excluded = c('.git','.DS_Store', '.Rproj.user'),
  widget_name = NA,
  widget_width = NULL,
  widget_height = NULL,
  widget_elementId = NULL,
  widget_options = markmapOption(preset = "colorful")
)
