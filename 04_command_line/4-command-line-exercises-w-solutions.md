# Command-line exercises — suggested solutions

Run these from the `04_command_line` folder unless stated otherwise.

## Exercise 1

`pwd` reports the shell's current folder; `getwd()` reports R's. They may differ because RStudio can start the R session and the Terminal in different folders. Relative paths are resolved from the relevant working directory.

## Exercise 2

```bash
ls data
cd data
pwd
cd ..
mkdir scratch
ls scratch
rmdir scratch
```

`rmdir` only removes an empty directory, so it cannot accidentally remove a directory full of files.

## Exercise 3

```bash
grep -in "robin" data/bird_notes.txt
grep -ic "rain" data/bird_notes.txt
grep -iv "heard" data/bird_notes.txt
```

## Exercise 4

```bash
grep -i -o -E 'sun|cloud|rain' data/bird_notes.txt | sort | uniq -c | sort -nr > results/weather-counts.txt
cat results/weather-counts.txt
```

`>>` appends. Running the pipeline twice with `>>` would duplicate the summary in the output file.

## Exercise 5

The script writes `results/bird-counts.txt` and `results/bird-summary.csv`. One possible status message is:

```bash
echo "Creating a bird-word count and an R summary from $input"
```

With an invalid input path, `grep` reports that it cannot find the file and, because of `set -euo pipefail`, the script stops rather than producing a misleading partial report.
