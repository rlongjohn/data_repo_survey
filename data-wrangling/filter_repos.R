# Script for getting dataset repository data from re3data.org

# Goals:
#   - choose a subset of repositories to survey in detail
#   - save basic metadata for these repositories

# setup -------------------------------------------------------------------

# load packages
library(httr) # making api requests
library(xml2) # navigating the xml tree
library(urltools) # parsing urls
library(tidyverse) # manipulating data


# getting the data --------------------------------------------------------

# request all repo ids from re3data api + parse xml
res <- content(GET("https://www.re3data.org/api/v1/repositories"))

# put entire list of repos into a data frame
repo_list <- data.frame(id = xml_text(xml_find_all(res, xpath = "//id")), 
                        name = xml_text(xml_find_all(res, xpath = "//name")))

# get the total number of repositories
num_repos <- nrow(repo_list)

# get rid of raw api response
rm(res)

# allocate columns that will get populated at after each api request
repo_list$repo_url <- NA
repo_list$end_date <- NA
repo_list$english_ui <- NA
repo_list$data_provider <- NA
repo_list$db_access_closed <- NA # open, restricted, closed
repo_list$data_access_closed <- NA # open, embargoed, restricted, closed
repo_list$upload_access_closed <- NA # open, restricted, closed
repo_list$versioning <- NA
repo_list$pid_system <- NA
repo_list$enhanced_pub <- NA
repo_list$quality_management <- NA

# loop through repos, request metadata, store relevant fields
start_time <- Sys.time()
for (i in 1:num_repos) {
  # print status
  if(i %% 100 == 0) {cat("Repo #", i, "\n")}
  
  # request repo metadata
  repo <- content(GET(paste0("https://www.re3data.org/api/v1/repository/", repo_list$id[i])))
  
  # parse metadata
  repo_list[i, "repo_url"] <- xml_text(xml_find_all(repo, xpath = "//r3d:repositoryURL"))
  repo_list[i, "end_date"] <- xml_text(xml_find_all(repo, xpath = "//r3d:endDate"))
  repo_list[i, "english_ui"] <- ifelse("eng" %in% xml_text(xml_find_all(repo, xpath = "//r3d:repositoryLanguage")), T, F)
  repo_list[i, "data_provider"] <- ifelse("dataProvider" %in% xml_text(xml_find_all(repo, xpath = "//r3d:providerType")), T, F)
  repo_list[i, "db_access_closed"] <- ifelse("closed" %in% xml_text(xml_find_all(repo, xpath = "//r3d:databaseAccessType")), T, F)
  repo_list[i, "data_access_closed"] <- ifelse("closed" %in% xml_text(xml_find_all(repo, xpath = "//r3d:dataAccessType")), T, F)
  repo_list[i, "upload_access_closed"] <- ifelse("closed" %in% xml_text(xml_find_all(repo, xpath = "//r3d:dataUploadType")), T, F)
  repo_list[i, "versioning"] <- ifelse(xml_text(xml_find_all(repo, xpath = "//r3d:versioning")) == "yes", T, F)
  repo_list[i, "pid_system"] <- ifelse("none" %in% xml_text(xml_find_all(repo, xpath = "//r3d:pidSystem")), F, T)
  repo_list[i, "enhanced_pub"] <- ifelse(xml_text(xml_find_all(repo, xpath = "//r3d:enhancedPublication")) == "yes", T, F)
  repo_list[i, "quality_management"] <- ifelse(xml_text(xml_find_all(repo, xpath = "//r3d:qualityManagement")) != "no", T, F)
  
}
end_time <- Sys.time()
end_time - start_time

# parse domain from repository url
repo_list$domain <- url_parse(repo_list$repo_url)$domain


# filtering ---------------------------------------------------------------

# initial filter sweep
filtered_repos <- repo_list %>%
  filter(data_provider == T & # provides data and not just services
           db_access_closed == F & # repo is accessible
           data_access_closed == F & # data is accessible
           upload_access_closed == F & # data can be uploaded
           end_date == "" & # repo should still be online
           english_ui == T & # ui in english
           pid_system == T & # implements a persistent id system
           repo_url != "" & # has a link to the repo
           versioning == T & # supports versioning
           enhanced_pub == T & # links publications to datasets
           quality_management == T # no qa
  )

# de-duplicate based on name
filtered_repos <- filtered_repos[!duplicated(tolower(filtered_repos$name)),]


# save --------------------------------------------------------------------
write_csv(filtered_repos, here::here("data", "survey_repos.csv"))

