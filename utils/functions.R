# functions.R

# Functions to code raw data ----------------------------------------------

#I will put all of the coding variable stuff into a function to ensure that we
#do the same operations on both datasets when we make changes. I will then put
#each separate variable coding into a sub-function to ensure that we do the same
#thing for each spouse.

code_census_variables <- function(census) {
  
  # Sex of respondent
  # - Male (sex 1)
  # - Female (sex 2)
  census$sex <- ifelse(census$sex==1, "Male",
                       ifelse(census$sex==2, "Female", NA))
  
  # Marital status
  census$marst <- factor(census$marst,
                         levels=1:6,
                         labels=c("Married, spouse present",
                                  "Married, spouse absent",
                                  "Separated","Divorced","Widowed",
                                  "Never married"))
  
  # Race - see details in code_race below
  census$race <- code_race(census$raced, census$hispand)
  census$race_sp <- code_race(census$raced_sp, census$hispand_sp)
  
  # Education - see details in code_educ below
  census$educ <- code_educ(census$educd)
  census$educ_sp <- code_educ(census$educd_sp)
  
  # Language 
  # We don't need to code language as a factor variable with labels because
  # ultimately all we need to know is whether the two partners speak the same
  # language. We should however code in any missing values (0), although 
  # there do not appear to be any.
  census$lang <- code_language(census$languaged)
  census$lang_sp <- code_language(census$languaged_sp)
  
  # Country of Birth 
  # The general codes are way to general. The detailed codes have some
  # overspecifity in the codes, but not in the actual data used here.
  census$bpld <- code_bpl(census$bpld)
  census$bpld_sp <- code_bpl(census$bpld_sp)
  
  #Years living in USA
  #1n 1980 this is based on intervalled data with the actual value
  #representing the last year in the interval. In this case we have 
  #intervals of 1975-1980 (1980) and 1970-1974 (1974) that are relevant.
  #this means we will not be able to measure timing of years in smaller
  #than five year increments - which is a good reason for using the marriage
  #in last five years as a benchmark. 
  census$yr_usa <- census$year-ifelse(census$yrimmig==0,NA,census$yrimmig)
  census$yr_usa_sp <- census$year-ifelse(census$yrimmig_sp==0,NA,
                                         census$yrimmig_sp)
  
  # Assign Unique Person ID - we removed the sample number to cut
  #down on size but year should do the same trick
  census$id <- census$serial*1000000+census$pernum*10000+census$year
  if(sum(duplicated(census$id))>0) {
    stop("Duplicted ids in data")
  }
  census$id_sp <- ifelse(is.na(census$pernum_sp),NA,
                         census$serial*1000000+census$pernum_sp*10000+census$year)
  if(sum(duplicated(na.omit(census$id_sp)))>0) {
    stop("Duplicted spousal ids in data")
  }
  
  #combined state and metro area id to get marriage market. Replace state id
  #with metro id for cases where it is not zero. Multiply by 100 to avoid id
  #collision
  census$mar_market <- census$statefip
  
  return(census)
}

code_race <- function(raced, hispand) {
  # We want to take the raced and hispand variables and code them into a combined
  # race variable. I am going to use the fullest possible coding here although
  # only a few of these cases will show up in the 1980 data. I am also going 
  # to leave out the indigenous population for the moment, due to some issues
  # with measurement across the two time periods.
  race <- case_when(
    # Latino trumps everything, because combined question, sigh
    hispand>0 & hispand<900 ~ "Latino",
    # The original ethnoracial triangle - white, black, indigenous
    raced==100 ~ "White",
    raced==200 ~ "Black",
    (raced>=300 & raced<400) ~ "Indig",
    # Asian
    # need to do South Asians, then Pac Islander, then E&SE Asian
    # to simplify coding nightmare
    # leave out South Asian separation, because we don't have details
    # for those that check more than one
    #(raced %in% c(610, 664, 669, 670)) ~ "South Asian",
    (raced==630 | (raced>=680 & raced<=699)) ~ "Indig",
    ((raced==400 & raced<=679) | raced %in% c(869, 887)) ~ "Asian",
    # Multiracial groups
    raced==801 ~ "White/Black",
    raced==802 ~ "White/Indig",
    (raced>=810 & raced<=819) ~ "White/Asian",
    (raced>=820 & raced<=827) ~ "White/Indig",
    raced==830 ~ "Black/Indig",
    (raced>=831 & raced<=838) ~ "Black/Asian",
    (raced>=840 & raced<=842) ~ "Black/Indig",
    (raced>=850 & raced<=854) ~ "Indig/Asian",
    raced==855 ~ "Indig",
    (raced>=860 & raced<=868) ~ "Indig/Asian",
    #raced==901 ~ "White/Black/AIAN",
    TRUE ~ NA_character_
  )
  
  race <- factor(race, 
                 levels=c("White","Black","Indig","Asian","Latino",
                          "White/Black","White/Indig","White/Asian",
                          "Black/Indig","Black/Asian","Indig/Asian"))
  
  return(race)
}


code_educ <- function(educd) {
  # We want to re-code the educd variable into the following simple
  # categories:
  # - Less than high school diploma
  # - High school diploma
  # - Some college, but less than a four year degree
  # - Four year college degree or more
  educ <- ifelse(educd<60, "LHS",
                 ifelse(educd<=65, "HS",
                        ifelse(educd<=90, "SC",
                               ifelse(educd<=999, "C", 
                                      NA))))
  educ <- factor(educ,
                 levels=c("LHS","HS","SC","C"),
                 ordered=TRUE)
  return(educ)
}

code_bpl <- function(bpld) {
  #recode any one born in the US (99 or less) as a single number. Otherwise
  #we will be fitting state level endogamy. also code in missing values
  return(ifelse(bpld>=95000, NA, 
                ifelse(bpld<10000,1,bpld)))
}

code_language <- function(language) {
  #I need to use the detailed language codes as the general language codes 
  #are too general. However the detailed language codes are too detailed in 
  #some places, particularly in translating between the two time periods. Thus
  #I make some corrections to the detailed codes for consistency between the
  #two time periods.
  
  lang_recode <- language
  
  #the following cases will be collapsed to the their top two digit codes
  #(starting at the 100 levels)
  #1:27 - European language groups (e.g. English, French, German)
  #35: Uralic
  #37: Other Altaic
  #43: Chinese
  #47: Thai/Siamese/Lao (not separable in 1980)
  #52: Indonesian
  #53: Other Malay
  #58:  Near East Arabic Dialect
  collapsed_cases <- c(1:24,35,37,43,47,52,53,58)
  collapsed_language <- floor(language/100)
  lang_recode <- ifelse(collapsed_language %in% collapsed_cases,
                        collapsed_language*100, lang_recode)
  
  #A couple of cases need to be put back into there other categories
  #420: Afrikaans
  #1140: Haitian Creole
  #1150: Cajun
  #2310: Croatian
  #2320: Serbian
  uncollapsed_cases <- c(420,1140,1150,2310,2320)
  lang_recode <- ifelse(language %in% uncollapsed_cases,
                        language, lang_recode)
  
  #put malay and other malay together
  lang_recode <- ifelse(language==5270, 5300, lang_recode)
  
  #collapse Hindi and Urdu into 3101 (Hindustani)
  lang_recode <- ifelse(language>3101 & language<=3104, 3101, lang_recode)
  
  #For 1980 consistency put all American Indian languages in one group
  lang_recode <- ifelse(lang_recode>7000 & lang_recode<=9300, 7000, 
                        lang_recode)
  
  #A few cases are "other" or "nec". These will be recoded as -1 and
  #not treated as endogamy with each other
  nec_codes <- c(3140,3150,3190,5290,5590,6200,6390,6400,9400,9410,9420,9500,
                 9600,9601,9602,9999)
  lang_recode <- ifelse(lang_recode %in% nec_codes, -1, lang_recode)
  
  #code any missing values 
  lang_recode <- ifelse(lang_recode==0, NA, lang_recode)
  
  return(lang_recode)
  
}

# Functions for marriage market creation ----------------------------------

#code variables for the marriage market dataset
add_vars <- function(market) {
  #age difference 
  market$agediff <- market$ageh-market$agew
  
  #birthplace endogamy - will produce several alternate specifications
  market <- code_birthplace_endog(market)
  
  #language endogamy 
  # The -1 cases are NEC languages, so we assume non-endogamous
  market$language_endog <- ifelse(market$languageh<0 | market$languagew<0, 
                                  FALSE, market$languageh==market$languagew)
  
  #educational hypergamy/hypogamy
  market$hypergamy <- market$educh > market$educw
  market$hypogamy <- market$educh < market$educw
  
  #educational crossing
  market$edcross_hs <- (market$educh>="HS" & market$educw<"HS") | 
    (market$educw>="HS" & market$educh<"HS")
  market$edcross_sc <- (market$educh>="SC" & market$educw<"SC") | 
    (market$educw>="SC" & market$educh<"SC")
  market$edcross_c <- (market$educh>="C" & market$educw<"C") | 
    (market$educw>="C" & market$educh<"C")
  
  # create racial exogamy terms
  
  # full racial exogamy blocks
  market$race_exog_full <- createExogamyTerms(market$raceh, 
                                              market$racew, 
                                              symmetric=TRUE)
  
  # now collapse multiracial/multiracial cases to a single dummy
  market$race_exog <- ifelse(str_count(market$race_exog_full, "/")==2,
                             "Multi/Multi", 
                             as.character(market$race_exog_full))
  market$race_exog <- relevel(factor(market$race_exog), 
                              "Endog")
  
  # now consider other codings of multiple/multiple part of the table
  # 
  # part-white to part-white
  market$multi_white_endog <- ifelse(market$race_exog!="Multi/Multi", FALSE,
                                     str_detect(market$raceh, "White") &
                                       str_detect(market$racew, "White"))
  # part-black to non part-black
  market$multi_black_exclude <- ifelse(market$race_exog!="Multi/Multi", FALSE,
                                       (str_detect(market$raceh, "Black") &
                                          !str_detect(market$racew, "Black")) |
                                         (str_detect(market$racew, "Black") &
                                            !str_detect(market$raceh, "Black")))
  
  # partial shared ancestry coding
  groups <- str_split(market$race_exog_full, "\\.")
  constituent1 <- sapply(groups, function(x) {return(x[1])})
  constituent2 <- sapply(groups, function(x) {return(x[2])})
  temp <- str_split(constituent1, "/")
  constituent1.1 <- sapply(temp, function(x) {return(x[1])})
  constituent1.2 <- sapply(temp, function(x) {return(x[2])})
  market$multi_shared_ancestry <- ifelse(market$race_exog!="Multi/Multi", FALSE,
                                         str_detect(constituent2, constituent1.1) | 
                                           str_detect(constituent2, constituent1.2))
  
  return(market)
}

#code several different variables that indicate birthplace endogamy
code_birthplace_endog <- function(market) {
  # I want to think carefully about how being a member of the 1.75 generation
  # (0-5 at entry to US), 1.5 generation (6-12 at entry), and 1.25 generation
  # (13-17 at entry) affect endogamy. I do this by how I consider endogamy, with
  # three choices:
  #
  # USA - this group is considered to be US-born only for purposes of endogamy
  # Both - this group is considered to be endogamous both with US and birthplace
  # Birthplace - this group is considered to be endogamous with birthplace only
  # 
  # Given these different options, I can construct 10 different possible codings
  # if we force the codings to be consistent so that a lower generation is never
  # given a more "assimilated" coding than a higher generation
  
  #first create booleans for generations each spouse
  is_h_1.75 <- market$bplh!=1 & market$age_usah<6
  is_h_1.5  <- market$bplh!=1 & market$age_usah>5 & market$age_usah<13
  is_h_1.25 <- market$bplh!=1 & market$age_usah>12 & market$age_usah<18
  
  is_w_1.75 <- market$bplw!=1 & market$age_usaw<6
  is_w_1.5  <- market$bplw!=1 & market$age_usaw>5 & market$age_usaw<13
  is_w_1.25 <- market$bplw!=1 & market$age_usaw>12 & market$age_usaw<18
  
  #now booleans for birthplace endog
  birthplace_endog <- market$bplh==market$bplw
  
  #create switched birthplaces for USA endog, each one inclusive of laters
  bplh_1.75 <- ifelse(is_h_1.75, 1, market$bplh)
  bplh_1.5  <- ifelse(is_h_1.75 | is_h_1.5, 1, market$bplh)
  bplh_1.25 <- ifelse(is_h_1.75 | is_h_1.5 | is_h_1.25, 1, market$bplh)
  
  bplw_1.75 <- ifelse(is_w_1.75, 1, market$bplw)
  bplw_1.5  <- ifelse(is_w_1.75 | is_w_1.5, 1, market$bplw)
  bplw_1.25 <- ifelse(is_w_1.75 | is_w_1.5 | is_w_1.25, 1, market$bplw)
  
  ## Create Variables ##
  
  ## All First Gen
  #strictest coding treats all three cases the same as second gen (birthplace)
  market$bendog_all_first <- birthplace_endog
  
  ## All Second Gen
  ## all are treated as born in the US
  market$bendog_all_second <- bplh_1.25==bplw_1.25
  
  ## All Flex
  ## either birthplace or US is treated as endogamous for all
  market$bendog_all_flex <- bplh_1.25==bplw_1.25 | birthplace_endog
  
  ## Steep Grade (1.75): 1.75: USA, 1.5: Birthplace, 1.25: Birthplace
  market$bendog_steep_grade1.75 <- bplh_1.75==bplw_1.75
  
  ## Steep Grade (1.5): 1.75: USA, 1.5: USA, 1.25: Birthplace
  market$bendog_steep_grade1.5 <- bplh_1.5==bplw_1.5
  
  ## Slight Grade (1.75): 1.75: USA, 1.5: Both, 1.25: Both
  market$bendog_slight_grade1.75 <- market$bendog_steep_grade1.75 | 
    market$bendog_all_second
  
  ## Slight Grade (1.5): 1.75: USA, 1.5: USA, 1.25: Both
  market$bendog_slight_grade1.5 <- market$bendog_steep_grade1.5 | 
    market$bendog_all_second
  
  ## Full Grade: 1.75: USA, 1.5: Both, 1.25: Birthplace
  market$bendog_full_grade <-  market$bendog_steep_grade1.5 | 
    market$bendog_steep_grade1.75
  
  ## Partial Flex (1.5): 1.75: Both, 1.5: Birthplace, 1.25: Birthplace
  market$bendog_partial_flex1.75 <- bplh_1.75==bplw_1.75 | birthplace_endog
  
  ## Partial Flex (1.75): 1.75: Both, 1.5: Both, 1.25: Birthplace
  market$bendog_partial_flex1.5 <- bplh_1.5==bplw_1.5 | birthplace_endog
  
  return(market)
}