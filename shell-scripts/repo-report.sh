#!/bin/bash

####################################################################################
## ABOUT: This script generates a comprehensive report for a GitHub repository.
##
## INPUT: Export username and token, and pass 2 command line arguments.
##        The 1st argument refers to the organization name and the 2nd argument refers
##        to the repository name.
##
## OWNER: Pooja S Marakala
####################################################################################

function helper {
    local expected_args=2
    if [ $# -ne $expected_args ]; then
        echo "Please enter valid command line arguments"
        echo "Usage: $0 <organization> <repository>"
        exit 1
    fi
}

# To check if command line arguments are correctly passed
helper "$@"

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and personal access token
USERNAME=$username
TOKEN=$token

# User and Repository information
REPO_OWNER=$1
REPO_NAME=$2

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Send a GET request to the GitHub API with authentication
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list open issues in the repository
function list_open_issues {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/issues"
    local issues

    # Fetch the list of open issues on the repository
    issues="$(github_api_get "$endpoint" | jq -r '.[] | "\(.number): \(.title) (created at \(.created_at))"')"

    # Display the list of open issues
    if [[ -z "$issues" ]]; then
        echo "No open issues found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Open issues in ${REPO_OWNER}/${REPO_NAME}:"
        echo "$issues"
    fi
}

# Function to list pull requests in the repository
function list_pull_requests {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/pulls"
    local pulls

    # Fetch the list of pull requests on the repository
    pulls="$(github_api_get "$endpoint" | jq -r '.[] | "\(.number): \(.title) (created at \(.created_at))"')"

    # Display the list of pull requests
    if [[ -z "$pulls" ]]; then
        echo "No pull requests found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Pull requests in ${REPO_OWNER}/${REPO_NAME}:"
        echo "$pulls"
    fi
}

# Function to list contributors to the repository
function list_contributors {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/contributors"
    local contributors

    # Fetch the list of contributors on the repository
    contributors="$(github_api_get "$endpoint" | jq -r '.[] | "\(.login): \(.contributions) contributions"')"

    # Display the list of contributors
    if [[ -z "$contributors" ]]; then
        echo "No contributors found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Contributors to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$contributors"
    fi
}

# Function to get the number of stars of the repository
function get_stars_count {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}"
    local stars

    # Fetch the repository information
    stars="$(github_api_get "$endpoint" | jq -r '.stargazers_count')"

    # Display the number of stars
    if [[ -z "$stars" ]]; then
        echo "Could not retrieve the stars count for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "The repository ${REPO_OWNER}/${REPO_NAME} has $stars stars."
    fi
}

# Main script
echo "Generating report for ${REPO_OWNER}/${REPO_NAME}..."

echo
list_open_issues
echo

echo
list_pull_requests
echo

echo
list_contributors
echo

echo
get_stars_count
echo
