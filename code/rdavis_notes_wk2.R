# Let's talk about this thing that we're in, which is a project. You know you're in a project because it has your project name in the top right hand corner.

# We use projects in RStudio because they help position your work -- that data, the scripts, and whatever else -- in one working directory. 

# Q: What is a directory?
# Q: What is a working directory?
# Q: Why does that matter?

# FOr navigation purposes. You likely have intution about how to navigate around your computer. You know that your files are stored in a certain sequence. But your computer does not have the intuition. So when you try to tell your computer to open something up, you either need to tell it super explicitly, for example: start at the deskop, then go here, then go here, then go here. OR make sure it has some kind of benchmark or flag thta helps it know where to find something. The project serves as a benchmark for your wokring directory.

?getwd()
getwd()

# So, let's experiment with navigating through *abolsute* and *relative* filepaths
# We're going to use the list.files() function
?list.files()

## ACTIVITY ---
# 1. Use the ABSOLUTE (full) filepath to list the files in your in class Rproject data folder
list.files(path = "")
# 2. Write the RELATIVE filepath (relative to your working directory) to list the files in your in class Rproject data folder
list.files(path = "")
# ----

# Typical setup in any working directory is to have a data and scripts folder. AND, then there are typical naming conventions -- this is true outside of R also

# Lots of option
"Notes"
"9.29.22_notes"
"week2_notes"

# So let's do this setup

# ACTIVITY ----
# 1. Create a new folder/directory called "scripts" by filling in the filepath in the function:
dir.create(path = "")
# 2. Save your script where you are keeping notes, and choose a naming convention that works for you this quarter
# 3. Stage-Commit-Push your changes to Github (make sure you save your script first!) -- verify this worked by checking your repository on Github
# ----