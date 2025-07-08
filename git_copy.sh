#!/bin/bash

# Copies added or modified files from a git branch located in the target directory
# into a files folder relative to this script.

output_directory="./files"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <target_directory>"
    exit 1
fi

target_directory="$1"

if [ -d "$output_directory" ]; then
    echo "Existing output directory '$output_directory' found. Removing it..."
    rm -rf "$output_directory"
    if [ $? -ne 0 ]; then
        echo "Error: Could not remove existing directory '$output_directory'. Please check permissions."
        exit 1
    fi
fi

echo "Creating output directory: $output_directory"
mkdir -p "$output_directory"
if [ $? -ne 0 ]; then
    echo "Error: Could not create directory '$output_directory'. Please check permissions."
    exit 1
fi

echo "Step 1: Getting merge-base hash for origin/master and HEAD in $target_directory..."
baseSha=$(git -C "$target_directory" merge-base "origin/master" HEAD)

if [ $? -ne 0 ]; then
    echo "Error: Could not determine merge-base. Please ensure '$target_directory' is a git repository and 'origin/master' exists."
    exit 1
fi
echo "Base SHA: $baseSha"

echo "Step 2: Getting HEAD hash in $target_directory..."
branchSha=$(git -C "$target_directory" rev-parse --verify HEAD)

if [ $? -ne 0 ]; then
    echo "Error: Could not determine HEAD hash. Please ensure '$target_directory' is a git repository."
    exit 1
fi
echo "Branch SHA: $branchSha"

echo "Step 3: Running git diff to find added or modified files between $baseSha and $branchSha..."

# Use git diff --name-only --diff-filter=AM for simplified output
git -C "$target_directory" diff --name-only --diff-filter=AM --ignore-submodules "$baseSha...$branchSha" | \
while IFS= read -r file_path; do
    if [ -z "$file_path" ]; then
        # Skip empty lines, which shouldn't typically happen with --name-only
        continue
    fi

    echo "Processing file: $file_path"

    if [ -f "$target_directory/$file_path" ]; then
        mkdir -p "$(dirname "$output_directory/$file_path")"
        cp "$target_directory/$file_path" "$output_directory/$file_path"
        if [ $? -eq 0 ]; then
            echo "Copied: $file_path to $output_directory/$file_path"
        else
            echo "Error: Could not copy $file_path (cp returned $?)"
        fi
    else
        echo "Warning: Source file '$target_directory/$file_path' not found. This might indicate an issue or a file that was removed after being detected as 'A' or 'M'. Not copied."
    fi
done

echo "Script finished."
echo "Output files are located in: $(pwd)/files"
