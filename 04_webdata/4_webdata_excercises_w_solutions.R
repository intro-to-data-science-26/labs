# Stringr Excercise

# 1.
stringr::str_replace_all(words, "ing", "er")

# 2.
stringr::str_detect(stringr::words, "ise") |> sum()

# Regular Expressions
# 1.
str_view(stringr::words, "ing$|ise$")

# 2.
str_view(example.obj, ".\\.")

# 3.
str_extract_all(example.obj, "[0-9]\\.")
str_extract_all(example.obj, "[[:alpha:]]\\.")

# 4.
str_subset(stringr::words, "[^e]ed$")

# 5.
str_detect(stringr::words, '^[:alpha:]{2}y$') |> sum()

# 6.
# Note `\\b` indicates a word boundary, i.e. the start or end of a word.
str_view(example.obj, "\\b[[:alpha:]]{1,5}\\b")

# Solution using str_split() and str_subset()
str_split_1(example.obj, pattern = "\\b") |> 
  str_subset("^[[:alpha:]]{1,5}$") |>
  print()
# Note you can use `str_c()` to recombine the words into a single string if you want.
# 
# Regular Expressions Exercises
# 
# 1.a.
# "\\$[0-9]+" will match one or more numbers followed by a dollar sign. For example, "\\$[0-9]+": c(c("$150", "$690", "$75").
str_view(
  string = c(
    "$10 for two items!",
    "Buy the latest iPhone for $899!",
    "It costs just $15 per month to upgrade your phone plan."
  ), 
  pattern = "\\$[0-9]+" # Answer: this regex describes prices in dollars
)

# 1.b.
# "^.*$" will match any string. For example, "^.*$": c("dog", "$1.23", "lorem ipsum").
str_view(
  string = c(
    "dog",
    "$1.23",
    "lorem ipsum"
  ), 
  pattern = "^.*$" # Answer: this regex describes any string
)

# 1.c.
# "\\d{4}-\\d{2}-\\d{2}" will match four digits followed by a hyphen, followed by two digits followed by a hyphen, followed by another two digits. This is a regular expression that can match dates formatted like “YYYY-MM-DD” (“%Y-%m-%d”). For example, "\d{4}-\d{2}-\d{2}": "2018-01-11"
str_view(
  string = c(
    "My birthday is 1990-05-23.",
    "The event is scheduled for 2023-11-15.",
    "Today's date is 2024-06-05."
  ), 
  pattern = "\\d{4}-\\d{2}-\\d{2}" # Answer: this regex describes dates formatted like "YYYY-MM-DD"
)

# 1.d.
# ".*\\.txt$" will match any .txt file. For example, ".*\\.txt$": c("FiLeN4m3.txt", "notes.txt", "1982-10-23.txt")
str_view(
  string = c(
    "FiLeN4m3.txt",
    "notes.txt",
    "1982-10-23.txt",
    "document.pdf",
    "image.png"
  ), 
  pattern = ".*\\.txt$" # Answer: this regex describes any .txt file
)

# 1.e. 
# "\\\\{4}" is \\{4}, which will match four backslashes. For example, "\\\\{4}": "\\\\\\\\"
str_view(
  string = c(
    "\\\\\\\\",
    "This is a test string with \\\\ in it.",
    "No backslashes here."
  ), 
  pattern = "\\\\{4}" # Answer: this regex describes four backslashes
)

# 1.f.
# "b[a-z]{1,4}" will match the letter 'b' followed by three letters. For example, "b[a-z]{1,4}": c("band", "barn", "auburn")
str_view(
  string = c(
    "band",
    "barn",
    "auburn",
    "bake",
    "pine"
  ), 
  pattern = "b[a-z]{1,4}" # Answer: this regex describes the letter 'b' followed by three letters
)

# 2. 
emails <- c('456123@students.hertie-school.org', 'h.simpson@students.hertie-school.org')
str_view(emails, '(^\\d{6}|^\\w\\.\\w{1,})@students\\.hertie-school\\.org')

# 3.
ex_string <- "555-1239Moe Szyslak(636) 555-0113Burns, C. Montgomery555-6542Rev. Timothy Lovejoy555 8904Ned Flanders636-555-3226Simpson, Homer5553642Dr. Julius Hibbert"
str_view(ex_string, "[[:alpha:]., ]{2,}")
str_view(ex_string, "\\(?(\\d{3})?\\)?(-| )?\\d{3}(-| )?\\d{4}")

# 4.
secret <- "clcopCow1zmstc0d87wnkig7OvdicpNuggvhryn92Gjuwczi8hqrfpRxs5Aj5dwpn0TanwoUwisdij7Lj8kpf03AT5Idr3coc0bt7yczjatOaootj55t3Nj3ne6c4Sfek.r1w1YwwojigOd6vrfUrbz2.2bkSnbhzgv4O9i05zLcropwVgnbEqoD65fa1otf.b7wIm24k6t3s9zqe5fy89n6Td5t9kc4f905gmc4gxo5nhk!gr"

solved <- unlist(str_extract_all(secret, "[[:upper:][:punct:]]"))
str_c(solved, collapse = "")
