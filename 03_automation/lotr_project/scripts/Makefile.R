## clean out any previous work
outputs <- c("./03_automation/lotr_project/data/raw/lotr_raw.tsv",
             "./03_automation/lotr_project/data/processed/lotr_clean.tsv",
             list.files(path =  "./03_automation/lotr_project/outputs/figures/",pattern = "*.png$", full.names = TRUE))
file.remove(outputs)

## run scripts
source("./03_automation/lotr_project/scripts/00-packages.R")
source("./03_automation/lotr_project/scripts/01-download-data.R")
source("./03_automation/lotr_project/scripts/02-process-data.R")
source("./03_automation/lotr_project/scripts/03-plot.R")
