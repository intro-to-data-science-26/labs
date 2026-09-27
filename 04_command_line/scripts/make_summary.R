args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 2) {
  stop("Usage: Rscript scripts/make_summary.R INPUT_FILE OUTPUT_FILE")
}

input_file <- args[[1]]
output_file <- args[[2]]

notes <- read.delim(
  input_file,
  sep = "|",
  header = FALSE,
  strip.white = TRUE,
  col.names = c("date", "time", "observation", "weather")
)

summary <- as.data.frame(table(notes$weather), stringsAsFactors = FALSE)
names(summary) <- c("weather", "n_notes")
summary <- summary[order(-summary$n_notes, summary$weather), ]

write.csv(summary, output_file, row.names = FALSE)
cat("Wrote", nrow(summary), "weather categories to", output_file, "\n")
