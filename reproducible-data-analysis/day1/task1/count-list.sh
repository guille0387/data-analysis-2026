#!/bin/bash

# Run count.sh once for every input file listed in a text file.
# The input list must contain one raw file path per line.

usage() {
    cat <<EOF
Usage: $(basename "$0") INPUT_LIST [OUTPUT_FILE]
       $(basename "$0") --help

Run count.sh for every file path in INPUT_LIST.

Arguments:
  INPUT_LIST     Text file containing one input file path per line.
  OUTPUT_FILE    File receiving the results (default: output.txt).

Blank lines in INPUT_LIST are ignored.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
    usage >&2
    exit 1
fi

input_list="$1"
output_file="${2:-output.txt}"
script_directory="$(cd "$(dirname "$0")" && pwd)"

if [[ ! -f "$input_list" ]]; then
    echo "Input list does not exist: $input_list" >&2
    exit 1
fi

# Start a fresh output file, then append one count result per input path.
: > "$output_file"
while IFS= read -r input_file; do
    [[ -z "$input_file" ]] && continue
    "$script_directory/count.sh" "$input_file" >> "$output_file"
done < "$input_list"

echo "Results written to $output_file"
