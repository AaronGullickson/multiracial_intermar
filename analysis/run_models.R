#' ---
#' title: "run_models.R"
#' author: ""
#' ---
#' 


# run all the models here, because they take time to run

# Load libraries, functions, and data -------------------------------------

library(here)
source(here("analysis","check_packages.R"))
source(here("analysis","useful_functions.R"))
load(here("analysis","output","markets.RData"))


# Run models --------------------------------------------------------------

markets <- lapply(markets, add_vars)

formula_base <- formula(choice~race_exog+agediff+I(agediff^2)+
                          hypergamy+hypogamy+edcross_hs+edcross_sc+edcross_c+
                          +bendog_partial_flex1.5+language_endog+
                          strata(group))

model <- poolChoiceModel(formula_base, data=markets, method="efron")

save(model, file=here("analysis","output","models.RData"))
