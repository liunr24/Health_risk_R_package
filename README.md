# Health_risk_R_package
HealthRisk function in the HealthRiskAir package is a function to estimate the health risk of exposure to PM2.5 and other air pollutants, or the health benefits when the exposure levels are reduced to a given value.

(1) Input data file
The users should first download the HealthRisktemplate.xlsx template file in the github webpage: https://raw.githubusercontent.com/liunr24/Health_risk_R_package/main/HealthRisktemplate.xlsx
You need to download the file to the workspace of your R file, or you need to specify the file path in the HealthRisk function later.

The template file provides input data for the health risk estimation. The meaning of each column is introduced below.
The first eight columns is specified by the template file, which include the exposure-response relationships of PM2.5 (from EPA COBRA database), ultrafine particle (UFP) counts (from two cohort studies), and NO2 (from one cohort study). You can add or remove some relationships as you want.
Pollutant: The air pollutant of which you want to estimate the health risk.
Metric: "Annual" means long-term health effects of this air pollutant exposure, while "Daily" means short-term health effects. This column is not for calculation but only for notes, so you can label this attribute as you want.
Outcome: The health outcome for this exposure-response relationship.
Age: The age groups for the epidemiological study which obtained this relationship.
Beta: The coefficient of the exposure-response relationship. Usually Beta equals to log(HR), log(RR) or log(OR). Details can be found in the user guide of COBRA.
Delta: If Delta = 1, it means that HR, RR, or OR is per 1 unit increase.
Unit: The unit of exposure concentrations of the air pollutant used in the relationship.
Form: The model form used by the epidemiological study to obtain the exposure-response relationship, i.e., Log-linear, or Logistic.

The remaining columns should be provided by the users themselves. Currently the template provides some example datasets.
Exposure: The exposure concentration of the air pollutants in your study.
Rate_per_100000: The mortality, incidence, or hospital admission rate (per 100,000) of the given health outcome in the spatial unit you focus on.
Population: The total population counts of the corresponding age group in the spatial unit you focus on.

The template file can include multiple sheets. Each sheet represent one site, and you can rename the sheet as the name of the site. The current example has three sites/sheets.

(2) HealthRisk function
Some information about this function can be found in the help page. Here are some further details. The output of this function is the attributable mortality/incidence/hospital admission cases of the air pollutant exposures, or the health benefits (i.e., avoided cases) of reducing these air pollutant exposures. If you have multiple sites, each column gives the results of each site.

Function:
HealthRisk(
  file_path = "HealthRisktemplate.xlsx",
  mode = "risk",
  target_type,
  target_value
)

file_path: The file path of the baseline data, including exposure concentration, population, baseline incidence rate, and exposure-response relationships.
mode: The estimation type: "risk" (default) for the health risk based on current exposure concentrations; "benefit" for the health benefit if the air pollutant concentrations are reduced by a given percentage or reduced to given target concentrations.
target_type: The type of target value: "threshold" means that the target_value is a threshold concentration to which the air pollutant exposure will be reduced; "percentage" means that the target_value is a percentage by which the the air pollutant exposure will be reduced; This parameter is not required when "mode" is "risk".
target_value: The target value for controlling the air pollution. It should be a threshold concentration to which the air pollutant exposure will be reduced if "target_type" is "threshold"; it should be a percentage by which the the air pollutant exposure will be reduced if "target_type" is "percentage"; This parameter is not required when "mode" is "risk".

Examples:
result1 <- HealthRisk();
result1 <- HealthRisk(file_path = "HealthRisktemplate.xlsx",mode = "risk"); # Health risk of current exposure


result2 <- HealthRisk(file_path = "HealthRisktemplate.xlsx",mode = "benefit",
                                  target_type = "percentage",target_value = rep(0.1,24)); # Health benefit from reducing exposure by 10%
