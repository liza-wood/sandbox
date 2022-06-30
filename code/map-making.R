library(tidyverse)
library(data.table)

setwd("~/Box/osa_networks")
df <- fread("data_combined_3/surveys_combined.csv")
id <- df %>% select(ResponseId, RecipientEmail, Region)

notproducers <- read.csv("data_contacts/07_Qualtrics_producer_list/not_producer_viaemail.csv")
ppltn.p <- read.csv("data_producers/00_populatioN_data/email_populatioN.csv") %>% 
  filter(!(email %in% notproducers$email)) %>% 
  mutate(Operatio = operation)
ppltn.c <- read.csv("data_companies/00_populatioN_data/email_populatioN.csv") %>% 
  mutate(physical_zip = as.character(physical_zip))
ppltn.r <- read.csv("data_researcher/00_populatioN_data/populatioN.csv") %>% 
  rename(contact_last = LastName,
         contact_first = FirstName,
         email = Email,
         Operation = contact_affiliation,
         physical_state = State)
ppltn <- full_join(ppltn.p, ppltn.c) %>% full_join(ppltn.r)

state <- ppltn <- select(ppltn, email, physical_state) %>% filter(email != "")
df <- left_join(df, state, by = c("RecipientEmail" = "email")) %>% 
  rename(State = physical_state)

df %>% 
  group_by(Region) %>% 
  count()
# Unweighted response rate:
nrow(df)/nrow(ppltn) # 30% 

# Mapping the color blocks, fillig in states -- cannot do this without a State feature on the 
n.by.state <- df %>% 
  group_by(State) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(sum = sum(n), prop = n/sum) %>% 
  arrange(desc(prop))

N.by.state <- ppltn %>% 
  group_by(physical_state) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(sum = sum(n), prop = n/sum) %>% 
  arrange(desc(prop))

n.by.state <- n.by.state %>% 
  select(State, n) %>% 
  rename("n_n" = "n")
N.by.state <- N.by.state %>% 
  select(physical_state, n) %>% 
  rename("n_N" = "n")

map.df <- left_join(N.by.state, n.by.state, by = c("physical_state" = "State"))
map.df$n_n <- ifelse(is.na(map.df$n_n), 0, map.df$n_n)
map.df$rep <- round(map.df$n_n/map.df$n_N, 2)

western <- c("California", "Oregon", "Washington", "Idaho", "Nevada", "Arizona", "Utah", "New Mexico", "Colorado", "Wyoming", "Montana", "Alaska", "Hawaii")
northcentral <- c("North Dakota", "South Dakota", "Kansas", "Nebraska", "Minnesota", "Iowa", "Missouri", "Wisconsin", "Illinois", "Michigan", "Indiana", "Ohio")
southern <- c("Texas", "Oklahoma", "Arkansas", "Louisiana", "Kentucky", "Tennessee", "Mississippi", "Alabama", "Florida", "Georgia", "South Carolina", "North Carolina", "Virginia")
northeast <- c("West Virginia", "Maryland", "Delaware", "New Jersey", "Pennsylvania", "New York", "Connecticut", "Rhode Island", "Massachusetts", "Vermont", "New Hampshire", "Maine")

map.df <- map.df %>% 
  mutate(Region = case_when(
    physical_state %in% western ~ "West",
    physical_state %in% northcentral ~ "North Central",
    physical_state %in% southern ~ "South",
    physical_state %in% northeast ~ "Northeast",
    T ~ "other"))

map.df <- map.df %>% 
  group_by(Region) %>% 
  mutate(regional_n = sum(n_n),
         regional_N = sum(n_N),
         regional_rr = regional_n/regional_N) %>% 
  rename("State" = "physical_state") 

library(usmap)
# This one is finnicky but works
us_states <- usmap::us_map()
us_states$full <- tools::toTitleCase(us_states$full)
us_states <- left_join(us_states, map.df, by = c("full" = "State"))

# For the states that weren't in the dataset
us_states <- us_states %>% 
  rename("State" = "full") %>% 
  mutate(Region = case_when(
    State %in% western ~ "West",
    State %in% northcentral ~ "North Central",
    State %in% southern ~ "South",
    State %in% northeast ~ "Northeast",
    T ~ NA_character_))

us_states$regional_n <- ifelse(us_states$Region == "South", 
                               unique(map.df$regional_n[map.df$Region == "South"]),
                               ifelse(us_states$Region == "West", 
                                      unique(map.df$regional_n[map.df$Region == "West"]),
                                      ifelse(us_states$Region == "North Central", 
                                             unique(map.df$regional_n[map.df$Region == "North Central"]),
                                             ifelse(us_states$Region == "Northeast", 
                                                    unique(map.df$regional_n[map.df$Region == "Northeast"]),
                                                    NA))))

us_states <- us_states %>% 
  mutate(regional_rr = case_when(
    Region == "West" ~ unique(map.df$regional_rr[map.df$Region == "West"]),
    Region == "South" ~ unique(map.df$regional_rr[map.df$Region == "South"]),
    Region == "Northeast" ~ unique(map.df$regional_rr[map.df$Region == "Northeast"]),
    Region == "North Central" ~ unique(map.df$regional_rr[map.df$Region == "North Central"]),
    Region == "other" ~ unique(map.df$regional_rr[map.df$Region == "other"]),
    T ~ 0
  )) 

us_states <- us_states %>% filter(State != "District of Columbia")

# To plot points on the map
loc <- data.frame(lon = df$LocationLongitude, lat = df$LocationLatitude)
transformed <- usmap_transform(loc) %>% filter(lat < 51 & lat > 21)

plot_usmap() +
  geom_point(data = transformed, aes(x = x, y = y), colour = "#2d677f", shape=21, size = 2)

# To plot regional blocks
counts <- us_states %>% select(Region, regional_n) %>% unique() %>% arrange(regional_n)

us_states$n <- factor(us_states$regional_n)
levels(us_states$n) <- c(paste(counts[1,1], counts[1,2], sep = ": "),
                         paste(counts[2,1], counts[2,2], sep = ": "),
                         paste(counts[3,1], counts[3,2], sep = ": "),
                         paste(counts[4,1], counts[4,2], sep = ": "))

ggplot(us_states, aes(x = x, y = y, 
                      fill = factor(regional_n), group = group,
                      text = paste0("N:", regional_n, "\n",
                                    "Response rate: ", 
                                    round((regional_rr*100), 0), "%"))) +
  geom_polygon(color = "white", size = 0.1) + 
  #scale_fill_manual(values = COLOR[3:6]) + 
  labs(title = "",
       fill = "",
       x = "", y = "") + 
  theme_light(base_size = 10)  +
  theme(
    legend.position="none", # was bottom
    panel.grid = element_blank(),
    line = element_blank(),
    rect = element_blank(),
    axis.text = element_blank()#,
    #text = element_text(family = FONTTYPE, size = FONTSIZE),
    #legend.title = element_text(family = FONTTYPE, size = TITLESIZE),
    #axis.title = element_text(family = FONTTYPE, size = TITLESIZE)
    )
