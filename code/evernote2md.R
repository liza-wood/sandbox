# 1. Re-create a skeleton of your stack and notebook file structure ----

## Identify how many stacks you have
n_stacks <- 8

## Identify the number of notebooks in each stack
## This should be a vector of length = n_stacks, 
## each value representing n notebooks
n_notebooks_per_stack <- c(6, 7, 2, 3, 4, 4, 2, 5) 

## Make directories for each notebook, labelled by stack-notebook number
dir_names_pt1 <- unlist(mapply(rep_len, 1:n_stacks, n_notebooks_per_stack))
dir_names_pt2 <- unlist(sapply(n_notebooks_per_stack, function(to) seq(to)))
dir_names <- paste(dir_names_pt1, dir_names_pt2, sep = "_")

# 2. Create directory for Evernote export ----
## Identify where you would like to export your notes
export_loc <- '~/Desktop/evernotes/'
## Create the main directory
dir.create(export_loc)
## Create sub-directories based on stack-notebook structure
sapply(paste0(export_loc, dir_names), dir.create)

# 3. Manually export Evernotes ----
## Now is the manual part: you need to take files from evernote and export them
## Right click on Evernote notebooks and export to the locations you created

# 4. Create a destination for the markdown conversions ----
## Identify where you would like the markdown files to be
md_loc <- '~/Desktop/obeliskgate/'
## Create the directory
dir.create(md_loc)
## Create sub-directories to mirror the stack-notebook structure
sapply(paste0(md_loc, dir_names), dir.create)

# 5. Convert with the `evernote2md` package (thanks wormi4ok!)
## One system function `evernote2md` to run the in the command line,
## which we can do via the system() function in R
## Check out documentation https://github.com/wormi4ok/evernote2md
## `evernote2md` takes an input and output argument, which for us is the 
## export location and md location, applied across sub-directories
sapply(dir_names, function(x) system(paste('evernote2md', 
                                           paste0(export_loc, x), 
                                           paste0(md_loc, x))))

# 6. Optional: re-name directories according to notebook names ----
## Identify notebook names
notebook_names <- stringr::str_remove_all(list.files(export_loc, recursive = T),
                                          "^\\d{1,2}_\\d{1,2}\\/|\\.enex")
current_names <- list.files(md_loc, full.names = T)

## Rename by appending notebook names to stack structure
mapply(file.rename, current_names, paste(current_names, notebook_names))

