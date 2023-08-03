# functions.R

#A function to convert model summaries to something knitreg will understand
convertModel <- function(model) {
  tr <- createTexreg(
    coef.names = rownames(model$coef), 
    coef = model$coef[,"b.pool"], 
    se = model$coef[,"se.pool"], 
    pvalues = model$coef[,"pvalue.pool"],
    gof.names = c("Deviance","BIC (relative to null)"), 
    gof = c(mean(model$deviance), mean(model$bic)), 
    gof.decimal = c(FALSE, FALSE)
  )
}