# Binder quickstart for reproducible-data-analysis (day1/day2)

This guide helps students run the day1 and day2 tasks in Binder.

## 1) Open Binder and Terminal

- Launch Binder for this repository.
- In JupyterLab: **File → New → Terminal**.
- Move to the module directory:

```bash
cd reproducible-data-analysis
```

> Note: Binder sessions are ephemeral. Download outputs you need before the session ends.

## 2) Verify environment

```bash
bash --version
python --version
snakemake --version
xsv --help | head -n 1
bowtie2 --version | head -n 1
samtools --version | head -n 1
python -c "import pandas, matplotlib; print('ok')"
```

## 3) Day 1 tasks

### day1/task1: word + character counting

```bash
cd day1/task1
bash count.sh ../../data/count/example1.txt
```

Expected output format:

```text
File: <path>; Word count: <N>; Character count: <N>
```

### day1/task2: mapping + sorting (Bowtie2 + Samtools)

```bash
cd ../task2
bash mapping-and-sorting.sh -i ../../data/mapping/SRS121011 -r ../../data/mapping/sample1.fq.gz -t 2
ls -lh *.sorted.bam
```

## 4) Day 2 tasks (Snakemake)

### day2/task1: simple Python processing workflow

```bash
cd ../../day2/task1
snakemake -j 1 -p
```

Expected outputs:

- `results/sample1/output.txt`
- `results/sample2/output.txt`
- `results/sample3/output.txt`

### day2/task2: country filtering + histogram plots

```bash
cd ../task2
snakemake -j 1 -p
```

Expected outputs (from config countries `fr`, `at`, `us`):

- `plots/fr.hist.pdf`
- `plots/at.hist.pdf`
- `plots/us.hist.pdf`

### day2/task3: Bowtie2 + Samtools workflow in Snakemake

```bash
cd ../task3
snakemake -j 1 -p
```

Expected outputs:

- `results/sample1.sorted.bam`
- `results/sample2.sorted.bam`

## 5) Optional: force conda-per-rule mode in Snakemake

Some Snakefiles define per-rule envs in `envs/*.yaml`. To demonstrate that behavior explicitly:

```bash
snakemake -j 1 -p --use-conda
```

For class speed/reliability in Binder, the shared preinstalled environment is usually sufficient.
