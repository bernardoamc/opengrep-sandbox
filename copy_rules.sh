#!/usr/bin/env bash

# This script prepares a local 'rules' directory for Docker COPY.
# It deletes any existing 'rules' directory, creates a new one,
# and copies the contents from a specified source directory into it.

set -euo pipefail

LOCAL_RULES_PARENT_DIR="$(dirname "$0")"
RULES_DIR_NAME="rules"
LOCAL_RULES_DIR="${LOCAL_RULES_PARENT_DIR}/${RULES_DIR_NAME}"
DEFAULT_SOURCE_RULES_DIR="${HOME}/rules"
SOURCE_RULES_DIR="${1:-$DEFAULT_SOURCE_RULES_DIR}"

echo "Attempting to copy rules from: $SOURCE_RULES_DIR"

if [ -d "$LOCAL_RULES_DIR" ]; then
  echo "Deleting existing directory: $LOCAL_RULES_DIR"
  rm -rf "$LOCAL_RULES_DIR"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to delete $LOCAL_RULES_DIR. Check permissions."
    exit 1
  fi
else
  echo "Directory not found: $LOCAL_RULES_DIR (no deletion needed)"
fi

echo "Creating new directory: $LOCAL_RULES_DIR"
mkdir -p "$LOCAL_RULES_DIR"
if [ $? -ne 0 ]; then
  echo "Error: Failed to create $LOCAL_RULES_DIR. Check permissions."
  exit 1
fi

if [ -d "$SOURCE_RULES_DIR" ]; then
  echo "Copying rules from $SOURCE_RULES_DIR to $LOCAL_RULES_DIR"
  # Use shopt -s dotglob to copy dotfiles (like .semgrepignore) if they exist
  shopt -s dotglob
  cp -R "$SOURCE_RULES_DIR"/* "$LOCAL_RULES_DIR/"
  shopt -u dotglob # Disable dotglob after copy

  if [ $? -ne 0 ]; then
    echo "Error: Failed to copy rules from $SOURCE_RULES_DIR."
    exit 1
  fi
  echo "Successfully prepared rules directory: $LOCAL_RULES_DIR"
else
  echo "Error: Source rules directory not found: $SOURCE_RULES_DIR"
  echo "Please ensure the path is correct or provide it as an argument."
  exit 1
fi

exit 0
