library(stringr)
dirs <- list.files("code")[2:6]
fls <- list.files(paste0("code/", dirs), recursive = T, full.names = T)

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

