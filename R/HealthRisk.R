
#' Health Risk and Benefit Estimation (V 0.1.0)
#' 
#' @description Estimate the health risk based on exposure concentrations of air pollutants, 
#' and health benefits if target concentrations or reduced percentage is provided.
#' PLEASE DOWNLOAD OUR XLSX FILE TEMPLATE REQUIRED BY THIS FUNCTION: 
#' \url{https://raw.githubusercontent.com/liunr24/Health_risk_R_package/main/HealthRisktemplate.xlsx}
#'  
#' @param file_path The file path of the baseline data, including exposure concentration, 
#' population, baseline incidence rate, and exposure-response relationships. 
#' @param mode The estimation type: "risk" (default) for the health risk based on current 
#' exposure concentrations; "benefit" for the health benefit if the air pollutant concentrations 
#' are reduced by a given percentage or reduced to given target concentrations.
#' @param target_type The type of target value: "threshold" means that the target_value is a 
#' threshold concentration to which the air pollutant exposure will be reduced; "percentage"
#' means that the target_value is a percentage by which the the air pollutant exposure will be reduced; 
#' This parameter is not required when "mode" is "risk".
#' @param target_value The target value for controlling the air pollution. It should be a 
#' threshold concentration to which the air pollutant exposure will be reduced if "target_type" is "threshold"; 
#' it should be a percentage by which the the air pollutant exposure will be reduced if "target_type" is 
#' "percentage"; This parameter is not required when "mode" is "risk".
#' @return The health risk or benefits in the form of mortality and incidence cases.
#' @examples 
#' result1 <- HealthRisk();
#' result1 <- HealthRisk(file_path = "HealthRisktemplate.xlsx",mode = "risk"); # Health risk of current exposure
#' 
#' 
#' result2 <- HealthRisk(file_path = "HealthRisktemplate.xlsx",mode = "benefit",
#'                       target_type = "percentage",target_value = rep(0.1,24)); # Health benefit from reducing exposure by 10%
#' @export



HealthRisk <- function(file_path = "HealthRisktemplate.xlsx",mode = "risk",target_type,target_value) {
  ## Read files
  inputdata <- lapply(readxl::excel_sheets(file_path), readxl::read_excel, path = file_path)
  names(inputdata) <- readxl::excel_sheets(file_path)
  
  Risk_est <- function(k) {
    dat <- inputdata[[k]]
    
    ## Check the model form
    if (sum(!dat$Form %in% c("Log-linear","Logistic")) > 0) {
      stop("Please use 'Log-linear' or 'Logistic' for the attribute 'Form'.")
    }
    
    
    ## Check the assessment mode
    if (mode == "risk") {
      dat$target <- 0
    } else if (mode == "benefit") {
      if (target_type == "threshold") {
        if (sum((target_value >= 0) & (target_value < dat$Exposure)) < length(target_value)) {
          stop("Please ensure that 0 <= target threshold < exposure.")
        }
        dat$target <- target_value
      } else if (target_type == "percentage") {
        if (sum((target_value > 0) & (target_value <= 1)) < length(target_value)) {
          stop("Please ensure that 0 < reduced percentage <= 1.")
        }
        dat$target <- dat$Exposure * (1 - target_value)
      } else {
        stop("Please use 'threshold' or 'percentage' for the parameter 'target_type'.")
      }
    } else {
      stop("Please use 'risk' or 'benefit' for the parameter 'mode'.")
    }

    
    ## Health risk/benefit estimation
    dat$Risk_loglinear <- dat$Population * dat$Rate_per_100000/100000 * 
                             (1 - 1/exp(dat$Beta * (dat$Exposure - dat$target) / dat$Delta))
    dat$Risk_logistic <- dat$Population * dat$Rate_per_100000/100000 * 
                             (1 - 1/((1 - dat$Rate_per_100000/100000) * exp(dat$Beta * (dat$Exposure - dat$target) / dat$Delta) + dat$Rate_per_100000/100000))
    dat$Risk <- sapply(1:nrow(dat),function(x) ifelse(dat$Form[x] == "Log-linear",dat$Risk_loglinear[x],
                                                      ifelse(dat$Form[x] == "Logistic",dat$Risk_logistic[x],NA)))
    dat <- dat[,c("Pollutant","Metric","Outcome","Age","Risk")]
    colnames(dat)[ncol(dat)] <- names(inputdata)[k]
    
    return(dat)  
  }
  
  result <- lapply(1:length(inputdata),Risk_est)
  result <- cbind(result[[1]][,1:4],do.call(cbind,lapply(1:length(inputdata),function(j) result[[j]][,5,drop = F])))
  
  return(result)
}





