#!/bin/bash

# Removes the older docker image, setup fules, rebuild the container and runs it

set -e

DEFAULT_PROJECT_DIR="${HOME}/my-git-repo"
DEFAULT_RULES_DIR="${HOME}/rules"
PROJECT_DIR="${1:-$DEFAULT_PROJECT_DIR}"
RULES_DIR="${2:-$DEFAULT_RULES_DIR}"

echo "Starting setup script..."

echo "---"
echo "Removing existing 'opengrep-bash' Docker images..."
docker rmi opengrep-bash || true
echo "---"

echo "---"
echo "Executing './copy_rules.sh' ${RULES_DIR} ..."
./copy_rules.sh "${RULES_DIR}"
echo "---"

echo "---"
echo "Executing './git_copy.sh ${PROJECT_DIR}' ..."
./git_copy.sh "${PROJECT_DIR}"
echo "---"

echo "---"
echo "Building new 'opengrep-bash' Docker image..."
docker build -t opengrep-bash .
echo "---"

echo "---"
echo "Running 'opengrep-bash' Docker container..."
docker run --network none --rm -it opengrep-bash
echo "---"

echo "Setup script finished."
