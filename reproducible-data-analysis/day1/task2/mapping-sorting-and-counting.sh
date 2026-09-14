#!/bin/bash
set -euo pipefail

trap 'echo "Error: ${BASH_SOURCE}:${LINENO}: ${BASH_COMMAND}" >&2' ERR
trap 'echo "Interrupted" >&2 ; exit 1' INT

# Map unpaired reads, sort the mapped alignments, and count reads per reference.
# The count table is created from samtools idxstats output.

usage() {
    cat <<EOF
Usage: $(basename "$0") -i INDEX -r READS [-t THREADS]
       $(basename "$0") -h|--help

Map unpaired reads to a Bowtie2 index, sort the mapped reads, and create a
simple count table showing mapped reads for each reference sequence.

Required arguments:
  -i INDEX      Bowtie2 index basename.
  -r READS      Input reads file in a format supported by Bowtie2.

Optional arguments:
  -t THREADS    Number of threads for Bowtie2 and Samtools (default: 2).
  -h, --help    Show this help message and exit.

Output:
  <reads-basename>.sorted.bam
  <reads-basename>.sorted.bam.bai
  <reads-basename>.count-matrix.tsv

The count table contains one row per reference sequence and its mapped-read
count.
EOF
}

# Handle the long help option before getopts, which only understands short options.
if [[ "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

# Parse command-line arguments.
while getopts ":hi:r:t:" opt; do
    case ${opt} in
    h)
        usage
        exit 0
        ;;
    i) index="${OPTARG}" ;;
    r) reads="${OPTARG}" ;;
    t) threads="${OPTARG}" ;;
    \?)
        echo "Invalid option: -${OPTARG}" >&2
        usage
        exit 1
        ;;
    :)
        echo "Option -${OPTARG} requires an argument" >&2
        usage
        exit 1
        ;;
    esac
done

# Check that required options were provided.
if [[ -z "${index:-}" || -z "${reads:-}" ]]; then
    usage
    exit 1
fi

threads="${threads:-2}"

# Construct output file paths from the reads file basename.
file_name=$(basename "${reads}")
sample_name="${file_name%%[ .]*}"
bam_mapped_file="${sample_name}.mapped.bam"
bam_file="${sample_name}.sorted.bam"
count_file="${sample_name}.count-matrix.tsv"

# Map reads and keep only mapped alignments.
bowtie2 --threads "${threads}" -x "${index}" -U "${reads}" \
    | samtools view -@ "${threads}" -bS -F 4 > "${bam_mapped_file}"

# Sort the mapped alignments and create an index for reference-level counting.
samtools sort -@ "${threads}" -o "${bam_file}" "${bam_mapped_file}"
samtools index "${bam_file}"

# Create a simple reference-by-count table from the sorted BAM.
{
    printf 'reference\tlength\tmapped_reads\n'
    samtools idxstats "${bam_file}" | awk -F '\t' 'BEGIN { OFS="\t" } $1 != "*" { print $1, $2, $3 }'
} > "${count_file}"

# Remove the intermediate unsorted BAM after all downstream steps succeed.
rm "${bam_mapped_file}"

echo "Count matrix written to ${count_file}"
