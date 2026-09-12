#!/bin/bash

# Count the words and characters in one non-empty input file.
#
# Usage:
#   count.sh INPUT_FILE
#   count.sh --help
#
# The counts are written to standard output in the form:
#   File: INPUT_FILE; Word count: WORDS; Character count: CHARACTERS

usage() {
    cat <<EOF
Usage: $(basename "$0") INPUT_FILE
       $(basename "$0") --help

Count the number of words and characters in a non-empty text file.

Arguments:
  INPUT_FILE    Path to the input file.

Options:
  -h, --help    Show this help message and exit.

Output:
  Prints the input file name, word count, and character count to standard output.
EOF
}

# Show documentation before installing the error trap used by the command.
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

# Define the custom error messages
no_input_file_msg="Please provide an input file"
nonexistent_file_msg="The file does not exist"
file_is_empty_msg="The file is empty"
no_results_msg="The file is empty"

# Define the trap function to catch errors
trap 'handle_error $?' ERR EXIT

# Function to handle the error
handle_error() {
    if [ "${1}" -ne 0 ]; then
        if [ "${1}" -eq 2 ]; then
            echo "${no_input_file_msg}"
        elif [ "${1}" -eq 141 ]; then
            echo "${nonexistent_file_msg}"
        elif [ "${1}" -eq 142 ]; then
            echo "${file_is_empty_msg}"
        elif [ "${1}" -eq 143 ]; then
            echo "${no_results_msg}"
        else
            echo "An unexpected error occurred"
        fi
        exit 1
    fi
}

# Check if the input file is provided
INPUT_FILE="${1}"

if [ -z "${INPUT_FILE}" ]; then
    exit 2
fi

# Check if the file exists and is not empty
if [ ! -s "${INPUT_FILE}" ]; then
    # if file does not exist or is empty
    if [ ! -e "${INPUT_FILE}" ]; then
        exit 141
    else
        exit 142
    fi
fi

# Count words and characters using the standard Unix `wc` utility.
words=$(wc -w "${INPUT_FILE}" | awk '{print $1}')
characters=$(wc -c "${INPUT_FILE}" | awk '{print $1}')

# Check tha words and characters are not empty
if [ -z "${words}" ] || [ -z "${characters}" ]; then
    exit 143
fi

# Write the results to standard output.
printf 'File: %s; Word count: %s; Character count: %s\n' "${INPUT_FILE}" "${words}" "${characters}"
