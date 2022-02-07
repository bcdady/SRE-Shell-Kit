#!/bin/bash

# This script sets up GitLab labels for use by Subsplash Engineering teams.
# These labels are used by gitlab-helper to assign a team member to review an MR
# Example:
# assign-SRE
# Automatically assign the merge request to an SRE reviewer. See https://subsplash.io/go/tools/gitlab-helper

# API_URI is the root URI for the "GitLab REST API to automate GitLab"
# It includes specifying the API version
# https://docs.gitlab.com/ee/api/README.html
API_URI='https://subsplash.io/api/v4'
WEB_URI='https://subsplash.io'

28ZofqCq$y46NBw6Sf%~pV}8EgWW4X1tuG5e{IgFlGxIiAbs2r

# Check for a valid GitLab Personal Access Token to authenticate / authorize API calls
if [[ -z $1 ]]; then
  echo 'No Project specified. Usage: $0 ''GROUP'''
  exit
fi

# Project to apply the settings to
# Can be a numerical Project ID or a URL-encoded URI
# https://docs.gitlab.com/ee/api/README.html#namespaced-path-encoding
GROUP=$1

# Check for a valid GitLab Personal Access Token to authenticate / authorize API calls
if [[ -z $GITLAB_TOKEN ]]; then
  echo 'Error: $GITLAB_TOKEN not set.'
  exit
fi

# Set GitLab target Group / Namespace ID
# To list id numbers of available top-level namespaces:
# NSIDLIST=$(curl --header "Authorization: Bearer $GITLAB_TOKEN" "https://subsplash.io/api/v4/namespaces/?per_page=100" | jq '.[] | {id,kind,full_path} | select(.kind=="group") | {id} | join(" ")')
# https://docs.gitlab.com/ee/api/namespaces.html
# GROUP_ID=17 # (GO)
# GROUP_ID=38 # (OPS)
# GROUP_ID=127 # (FLURO)

echo ''
echo "Creating Label(s) for ${WEB_URI}/groups/${GROUP}/"

# Setup variables to be used in curl data
NAME="assign-SRE"                                                                                                        # "assign-backend"
DESCRIPTION="Automatically assign the merge request to an SRE reviewer. See https://subsplash.io/go/tools/gitlab-helper" # "Automatically assign the merge request to a backend reviewer. See https://subsplash.io/go/tools/gitlab-helper"
COLOR="deepskyblue"                                                                                                      # "#428BCA"

# Label settings are specified in data key-value pairs
LABELID=$(curl --silent --request POST "${API_URI}/groups/${GROUP}/labels" \
  --header "Authorization: Bearer $GITLAB_TOKEN" \
  --data "name=$NAME&description=$DESCRIPTION&color=$COLOR" |
  jq -r '.id')

exit

# Scratchpad area of other, related, possibly useful gitlab API samples

# GET /projects/:id/labels
# curl --silent --header "Authorization: Bearer $GITLAB_TOKEN" "${API_URI}/projects/${PROJ}/labels" | jq '.'
