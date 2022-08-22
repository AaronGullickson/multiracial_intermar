#' ---
#' title: "organize_data.R"
#' author: ""
#' ---

# This script will read in raw data from the input directory, clean it up to produce 
# the analytical dataset, and then write the analytical data to the output directory. 

#source in any useful functions
library(here)
source(here("analysis","check_packages.R"))
source(here("analysis","useful_functions.R"))


# Read in the data --------------------------------------------------------

#ACS data is split into three separate files for size, but the indices are 
#identical
acs_start <- c(1, 5,13,23,25,30,34,44,45,48,49,50,51,56,60,66,71,77,83,86,90,93,94,97,100,105,111,115)
acs_end   <- c(4,12,22,24,29,33,43,44,47,48,49,50,54,58,62,70,74,80,85,89,92,93,96,99,104,108,114,117)
acs_names <- c("year","serial","hhwt","statefip","metarea","pernum","perwt",
               "sex","age","marst","marrno","marrinyr","yrmarr","raced",
               "hispand","bpld","yrimmig","languaged","educd","pernum_sp",
               "age_sp","marrno_sp","raced_sp","hispand_sp","bpld_sp",
               "yrimmig_sp","languaged_sp","educd_sp")

acs <- read_fwf(here("analysis","input","acs1418","usa_00108.dat.gz"),
                col_positions = fwf_positions(start = acs_start,
                                              end   = acs_end,
                                              col_names = acs_names),
                col_types = cols(.default = "i"), 
                progress = FALSE)



# Code variables ----------------------------------------------------------

acs <- code_census_variables(acs)

options(max.print=10000)
table(acs$race, acs$raced, exclude=NULL)
table(acs$race, acs$hispand, exclude=NULL)
options(max.print=99999)


# Duration of marriage ----------------------------------------------------

acs$dur_mar <- ifelse(acs$yrmarr==0,
                      NA, acs$year - acs$yrmarr)
tapply(acs$dur_mar, acs$marst, mean)


# Age at migration --------------------------------------------------------

#straightforward in ACS, but still get some negative values. Most of these are
#just -1 values due to calendar year/birth year issues, but a few other cases
#at older ages go back as far as -5. 
acs$age_usa <- acs$age-acs$yr_usa
acs$age_usa <- ifelse(is.na(acs$age_usa) | acs$age_usa<0, 0, acs$age_usa)
summary(acs$age_usa)
acs$age_usa_sp <- acs$age-acs$yr_usa_sp
acs$age_usa_sp <- ifelse(is.na(acs$age_usa_sp) | acs$age_usa_sp<0, 
                         0, acs$age_usa_sp)
summary(acs$age_usa_sp)

# Create counterfactual unions --------------------------------------------

years_mar <- 5

markets <- create_unions(acs, years_mar, 5)

save(markets, file=here("analysis","output","markets.RData"))
