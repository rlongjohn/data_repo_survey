# Script for getting full repo metadata for survey repos

# Goals:
#   - for the 208 repos extract all the metadata from re3data.org

# setup -------------------------------------------------------------------

# load packages
library(httr) # making api requests
library(xml2) # navigating the xml tree
library(tidyverse) # manipulating data

# getting the data --------------------------------------------------------

final_repos <- read_csv(here::here("data", "survey_repos.csv")) %>% 
  select(id, name, repo_url)

# get the total number of repositories
num_repos <- nrow(final_repos)

# allocate columns that will get populated at after each api request
final_repos$additional_names <- NA
final_repos$repo_identifier <- NA
final_repos$description <- NA
final_repos$repo_contact <- NA
final_repos$types <- NA 
final_repos$size <- NA 
final_repos$start_date <- NA
final_repos$ui_languages <- NA
final_repos$subjects <- NA
final_repos$mission_url <- NA
final_repos$content_types <- NA
final_repos$provider_types <- NA
final_repos$keywords <- NA
final_repos$institutions <- NA
final_repos$institution_countries <- NA
final_repos$institution_responsibilities <- NA
final_repos$institution_types <- NA
final_repos$policies <- NA
final_repos$policy_urls <- NA
final_repos$db_access_types <- NA
final_repos$db_access_restrictions <- NA
final_repos$db_licenses <- NA
final_repos$db_license_urls <- NA
final_repos$data_access <- NA
final_repos$data_access_restrictions <- NA
final_repos$data_licenses <- NA
final_repos$data_license_urls <- NA
final_repos$upload_access <- NA
final_repos$upload_access_restrictions <- NA
final_repos$upload_licenses <- NA
final_repos$upload_license_urls <- NA
final_repos$software <- NA
final_repos$apis <- NA
final_repos$pid_systems <- NA
final_repos$cite_urls <- NA
final_repos$aid_systems <- NA
final_repos$quality_management <- NA
final_repos$certificates <- NA
final_repos$metadata_standards <- NA
final_repos$metadata_urls <- NA
final_repos$remarks <- NA
final_repos$entry_date <- NA
final_repos$last_update <- NA

# loop through repos, request metadata, store relevant fields
start_time <- Sys.time()
for (i in 1:num_repos) {
  # print status
  cat("Repo #", i, "\n")
  
  # request repo metadata
  repo <- content(GET(paste0("https://www.re3data.org/api/v1/repository/", final_repos$id[i])))
  
  # parse metadata
  final_repos[i, "additional_names"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:additionalName")), collapse = ",")
  final_repos[i, "repo_identifier"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:repositoryIdentifier")), collapse = ",")
  final_repos[i, "description"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:description")), collapse = ",")
  final_repos[i, "repo_contact"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:repositoryContact")), collapse = ",")
  final_repos[i, "types"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:type")), collapse = ",")
  final_repos[i, "size"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:size")), collapse = ",")
  final_repos[i, "start_date"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:startDate")), collapse = ",")
  final_repos[i, "ui_languages"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:repositoryLanguage")), collapse = ",")
  final_repos[i, "subjects"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:subject")), collapse = ",")
  final_repos[i, "mission_url"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:missionStatementURL")), collapse = ",")
  final_repos[i, "content_types"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:contentType")), collapse = ",")
  final_repos[i, "provider_types"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:providerType")), collapse = ",")
  final_repos[i, "keywords"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:keyword")), collapse = ",")
  final_repos[i, "institutions"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:institutionName")), collapse = ",")
  final_repos[i, "institution_countries"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:institutionCountry")), collapse = ",")
  final_repos[i, "institution_responsibilities"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:responsibilityType")), collapse = ",")
  final_repos[i, "institution_types"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:institutionType")), collapse = ",")
  final_repos[i, "policies"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:policyName")), collapse = ",")
  final_repos[i, "policy_urls"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:policyURL")), collapse = ",")
  final_repos[i, "db_access_types"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:databaseAccessType")), collapse = ",")
  final_repos[i, "db_access_restrictions"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:databaseAccessRestriction")), collapse = ",")
  final_repos[i, "db_licenses"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:databaseLicenseName")), collapse = ",")
  final_repos[i, "db_license_urls"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:databaseLicenseURL")), collapse = ",")
  final_repos[i, "data_access"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:dataAccessType")), collapse = ",")
  final_repos[i, "data_access_restrictions"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:dataAccessRestriction")), collapse = ",")
  final_repos[i, "data_licenses"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:dataLicenseName")), collapse = ",")
  final_repos[i, "data_license_urls"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:dataLicenseURL")), collapse = ",")
  final_repos[i, "upload_access"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:dataUploadType")), collapse = ",")
  final_repos[i, "upload_access_restrictions"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:dataUploadRestriction")), collapse = ",")
  final_repos[i, "upload_licenses"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:dataUploadLicenseName")), collapse = ",")
  final_repos[i, "upload_license_urls"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:dataUploadLicenseURL")), collapse = ",")
  final_repos[i, "software"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:softwareName")), collapse = ",")
  final_repos[i, "apis"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:api")), collapse = ",")
  final_repos[i, "pid_systems"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:pidSystem")), collapse = ",")
  final_repos[i, "cite_urls"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:citationGuidelineURL")), collapse = ",")
  final_repos[i, "aid_systems"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:aidSystem")), collapse = ",")
  final_repos[i, "quality_management"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:qualityManagement")), collapse = ",")
  final_repos[i, "certificates"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:certificate")), collapse = ",")
  final_repos[i, "metadata_standards"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:metadataStandardName")), collapse = ",")
  final_repos[i, "metadata_urls"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:metadataStandardURL")), collapse = ",")
  final_repos[i, "remarks"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:remarks")), collapse = ",")
  final_repos[i, "entry_date"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:entryDate")), collapse = ",")
  final_repos[i, "last_update"] <- paste(xml_text(xml_find_all(repo, xpath = "//r3d:lastUpdate")), collapse = ",")
  
}
end_time <- Sys.time()
end_time - start_time


# save --------------------------------------------------------------------
write_csv(final_repos, here::here("data", "survey_repos_full.csv"))





