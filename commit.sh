#!/bin/bash

# Log file
LOG_FILE="commit.log"

# Function to log messages
log_message() {
    local message=$1
    echo "$(date +'%Y-%m-%d %H:%M:%S.%N'): $message" >> $LOG_FILE
}

# Check if CSV file exists
CSV_FILE="bugs.csv"
if [[ ! -f "$CSV_FILE" ]]; then
    log_message "Error: CSV file '$CSV_FILE' does not exist."
    echo "Error: CSV file '$CSV_FILE' does not exist."
    exit 1
fi

# Check if a parameter is provided for additional description
ADDITIONAL_DESC=$1

# Get the current branch name
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

# Read the CSV file to find the relevant bug information
BUG_INFO=$(awk -F, -v branch="$BRANCH_NAME" '$3 == branch {print $1, $2, $4, $5}' $CSV_FILE)
if [[ -z "$BUG_INFO" ]]; then
    log_message "Error: No bug information found for branch '$BRANCH_NAME' in the CSV file."
    echo "Error: No bug information found for branch '$BRANCH_NAME' in the CSV file."
    exit 1
fi

# Extract bug information
IFS=',' read -r BUG_ID DESCRIPTION DEV_NAME PRIORITY <<< "$BUG_INFO"

# Get the current date and time
CURRENT_DATETIME=$(date +"%Y-%m-%d %H:%M:%S")

# Create the commit message
COMMIT_MESSAGE="BugID:$BUG_ID:$CURRENT_DATETIME:$BRANCH_NAME:$DEV_NAME:$PRIORITY:$DESCRIPTION"
if [[ ! -z "$ADDITIONAL_DESC" ]]; then
    COMMIT_MESSAGE="$COMMIT_MESSAGE:$ADDITIONAL_DESC"
fi

# Stage all changes
git add .

# Commit with the generated message
git commit -m "$COMMIT_MESSAGE"

# Push to GitHub and set upstream branch if needed
if ! git push; then
    log_message "Upstream branch not set. Setting upstream branch for $BRANCH_NAME."
    echo "Upstream branch not set. Setting upstream branch for $BRANCH_NAME."
    if ! git push --set-upstream origin "$BRANCH_NAME"; then
        log_message "Error: Failed to push to GitHub."
        echo "Error: Failed to push to GitHub."
        exit 1
    fi
fi

log_message "Commit and push successful."
echo "Commit and push successful."
