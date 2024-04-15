# Files for analysis of amplicons

## Requirements
- [Docker](https://www.docker.com/products/docker-desktop/)

## Usage
Build the Docker image, if not already built:
```bash
docker build -t nijhawanlab/amplicons .
```

or pull the image:
```bash
docker pull nijhawanlab/amplicons
```

Then, from the data directory containing the FASTQ files, start a
Docker container using the `start.sh` script, or like this:
```bash
docker run -it \
       --mount type=bind,source="$(pwd)",target=/home/bio/data \
       nijhawanlab/amplicons
```
You will be logged into the container as user `bio`, in the home
directory `/home/bio`.  There are three subdirectories:
```
/home/bio
├── amplicons
├── data
└── extsource
```
`amplicons` contains this repository, the source for the analysis.
`data` is bound to the directory from which you started the container.

Optionally, you can bind `extsource` to a local directory on the host
machine.  This is useful for debugging the analysis code, since you do
not need to rebuild the Docker image when you make changes:
```bash
docker run -it \
       --mount type=bind,source="$(pwd)",target=/home/bio/data \
       --mount type=bind,source=/my/local/source/directory,target=/home/bio/extsource \
       nijhawanlab/amplicons
```
The `start.sh` script gets the name of the local source directory from
the environment variable `$SOURCE_DIR`, or defaults to `$HOME/bio/amplicons`.

Once you are at the command prompt of the running Docker container,
you can run your analysis using the `make` workflow:
```bash
cp ./amplicons/Makefile ./data
cd data/
make settings
make all
```
If you prefer to use the host machine's local copy of the source
(`extsource`), then
```bash
export EXT_SOURCE=true
```
before running the make.

## Makefile Data Flow
```mermaid
graph TD

classDef program fill:#e69f00;
classDef infile fill:#56B4E9;
classDef outfile fill:#009E73;

%% input files
primers[(primers.txt)]:::infile
barcode_patterns[(barcode_patterns.py)]:::infile
r1_reads[(R1.fastq)]:::infile
r2_reads[(R2.fastq)]:::infile
samples[(samples.tsv)]:::infile

%% generated files
merged(merged.fastq):::outfile
patterns(patterns.py):::outfile
matchfiles(matchfile_fwd.tsv\nmatchfile_fwd_rc.tsv\nmatchfile_rev.tsv\nmatchfile_rev_rc.tsv):::outfile
matches(matches.tsv):::outfile
barcode_table(barcode_table.tsv):::outfile
flat_samples(flat_samples.tsv):::outfile
barcode_counts(barcode_counts.tsv):::outfile
barcode_counts_samples(barcode_counts_samples.tsv):::outfile
sed_commands(_.sed):::outfile
new_fastq(annotated.fastq):::outfile
count_regex_output(count_regex_output.txt):::outfile
counts(totals_by_sample.tsv):::outfile
flash_log(flash.log):::outfile
barcharts(barchart.png):::outfile
logfile(_.log):::outfile
top_n_file(top_10.tsv):::outfile
top_n_xlsx(top_10.xlsx):::outfile

%% programs
flash2([flash2]):::program
get_regexes([get_regexes.py]):::program
separate_matchtable([separate_matchtable.awk]):::program
count_regex([count_regex.py]):::program
join_matches([csvtk join]):::program
merge_names([merge_names.awk]):::program
count_barcodes([count_barcodes.sh]):::program
flatten_samples([flatten_samples.py]):::program
join([csvtk join]):::program
csvtk([csvtk]):::program
barchart_grid([barchart_grid.py]):::program

r1_reads --> flash2
r2_reads --> flash2
flash2 --> merged
flash2 --> flash_log
primers --> get_regexes --> patterns
get_regexes --> separate_matchtable --> matchfiles
get_regexes --> sed_commands
patterns --> count_regex
barcode_patterns --> count_regex
merged --> count_regex
count_regex --> matches
count_regex --> count_regex_output
count_regex --> new_fastq
matchfiles --> join_matches
matches --> join_matches --> merge_names --> barcode_table
samples --> flatten_samples --> flat_samples --> join
barcode_table --> count_barcodes --> barcode_counts --> join --> barcode_counts_samples --> csvtk --> top_n_xlsx
csvtk --> counts
barcode_counts_samples --> barchart_grid --> barcharts
barchart_grid --> top_n_file
barchart_grid --> logfile
```
