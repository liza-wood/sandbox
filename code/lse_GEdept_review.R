library(RSelenium)
library(rvest)
library(xml2)
library(stringr)

url <- "https://www.lse.ac.uk/geography-and-environment/our-people"

#system('docker run --name lse -d -p 4445:4444 -p 5901:5900 selenium#/standalone-firefox-debug')
#
#remDr <- remoteDriver(
#  remoteServerAddr = "localhost",
#  port = 4445L,
#  browserName = "firefox",
#  path = '/wd/hub'
#)
#system('open vnc://127.0.0.1:5901') # password: secret
#remDr$open()
#
#remDr$navigate(url)
#
#webElem_layer <- remDr$findElements(using = 'css selector', '#.accordion__title')
#webElem_layer[[3]]$clickElement()
#
#html <- remDr$getPageSource()[[1]]

ppl <- read_html(url) %>% 
  html_nodes(css = '.sys_t0') %>%
  html_attr("href") %>% 
  trimws() %>% 
  unique()

lse_people <- data.frame()
for(i in 1:length(ppl)){
  page <- read_html(paste0('https://www.lse.ac.uk', ppl[i]))
  class <- stringr::str_extract(ppl[i], '(?<=people\\/).*(?=\\/)')
  name <- page %>% 
    html_nodes(css = '.people__name') %>% 
    html_text()
  role <- page %>% 
    html_nodes(css = '.people__position') %>% 
    html_text()
  dept <- page %>% 
    html_nodes(css = '.people__dept') %>% 
    html_text()
  #external <- page %>% 
  #  html_nodes(css = '.peopleContact__link') %>% 
  #  html_text()
  #orcid <- external[stringr::str_which(external, 'orcid|0000\\-')]
  #if(length(orcid) == 0){
  #  orcid <- NA
  #}
  bio <- page %>% 
    html_nodes(css = '.people__bio p') %>% 
    html_text()
  df <- data.frame(class, dept, name, role, #orcid, 
                   paste(bio, collapse = "\n"))
  lse_people <- rbind(lse_people, df)
}

lse_people$area <- str_extract(lse_people$role, "(?<=(in |of )).*")
lse_people$leadership <- str_extract(lse_people$area, "(?<=;).*|(?<=Acting ).*")
lse_people$area <- trimws(str_remove(lse_people$area, ";.*|and Acting.*"))
lse_people$area[lse_people$area == "Urban Planning Studies"] <- "Urban Planning"

lse_people$education <- str_detect(lse_people$role, "\\(Education\\)")

phds <- lse_people[lse_people$class == "phd-students" &
                        lse_people$dept == "Department of Geography and Environment",]

ac_staff <- lse_people[lse_people$class == "academic-staff" &
                        lse_people$dept == "Department of Geography and Environment",]

ac_staff$role_sp <- str_extract(ac_staff$role, "Fellow|Emeritus Professor|Assistant Professor|Associate Professor|Professor")
ac_staff$role_sp <- factor(ac_staff$role_sp, c("Fellow", "Assistant Professor",
                                               "Associate Professor", "Professor",
                                               "Emeritus Professor"))

envt <- c("Atkinson", "Berland", "Bridel", "Chatterjee", "Corwin", "Dajani",
          "Dietz", "Dugoua", "Galizzi", "Holman", "Jarvis", "Jones", "Khanna",
          "Mason", "Matthan", "Mourato", "Neumayer", "Pagel", "Palmer", 
          "Paprocki", "Perkins", "Pulido", "Robinson", "Roth", "Shreedhar", 
          "Thomas Smith", "Wolff")
econ_geog <- c("Aravena González", "Bagagli", "Boeri", "Carozzi", "Cheshire", 
            "Crescenzi", "Gibbons", "Henderson", "Hilber", "Hulke", "Neil Lee",
            "Monastiriotis", "Overman", "Pani", "Pietrabissa", "Renzullo",
            "Rigo", "Rodríguez-Pose", "Olmo Silva", "Storper", "Varela Varela",
            "Whitehead")
urban <- c("Antona", "Bloom", "Centner", "Corwin", "Ghoddousi", "Gordon",
           "Holman", "Jones", "Mace", "Mercer", "Pani", "Pulido", "Sanyal",
           "Scanlon", "Bang Shin", "Speer", "Zeiderman")

ac_staff$envt <- str_detect(ac_staff$name, paste(envt, collapse = "|"))
ac_staff$econ_geog <- str_detect(ac_staff$name, paste(econ_geog, collapse = "|"))
ac_staff$urban <- str_detect(ac_staff$name, paste(urban, collapse = "|"))

envt_grp <- ac_staff[ac_staff$envt == T,]
faculty <- ac_staff[ac_staff$role_sp != "Fellow",]
fellows <- ac_staff[ac_staff$role_sp == "Fellow",]

# Overview
## Roles
table(ac_staff$role_sp)

## Faculty
table(faculty$area)

## Is Education team?
table(faculty$education)
table(faculty$area[faculty$education == T])
table(fellows$area)

write.csv(faculty, 'data/lse_people_raw.csv', row.names = F)
faculty_details <- read.csv('data/lse_people_manual.csv')

faculty <- dplyr::left_join(faculty, faculty_details)
faculty_current <- faculty[faculty$role_sp != "Emeritus Professor",]

library(ggplot2)

ggplot(faculty_current, aes(x = phd_year, fill = gender)) +
  geom_bar()
summary(faculty_current$phd_year)

table(faculty_current$gender)
prop.table(table(faculty_current$gender))

table(faculty_current$gender, faculty_current$envt)
table(faculty_current$gender, faculty_current$econ_geog)
table(faculty_current$gender, faculty_current$urban)

table(faculty_current$phd_institution_country)
table(faculty_current$phd_institution)

## PhD Students
table(phds$role)


