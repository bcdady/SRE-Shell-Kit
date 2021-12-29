#!/bin/bash

# This script creates new projects in GitLab and mirrors a list of source repositories
# and sets some basic Subsplash standard GitLab project settings
# See https://docs.gitlab.com/ee/api/projects.html#create-project
# The example is of the Subsplash private repository at GitHub.com, but it's also been used
# for Bitbucket and GitHub public repos
# API_URI is the root URI for the "GitLab REST API to automate GitLab"
# It includes specifying the API version
# https://docs.gitlab.com/ee/api/README.html
API_URI='https://subsplash.io/api/v4'
WEB_URI='https://subsplash.io'

# Check for a valid GitLab Personal Access Token to authenticate / authorize API calls
if [[ -z $GITLAB_TOKEN ]]; then
  echo 'Error: No $GITLAB_TOKEN was found.'
  exit
fi

# Check for valid credentials to source system; these variables are used later
if [[ -z $GITHUB_USER ]]; then
  echo 'Error: $GITHUB_USER was Not found.'
  echo "If authentication is not required for this source SCM, edit this script and try again."
  exit
fi

if [[ -z $GITHUB_TOKEN ]]; then
  echo 'Error: $GITHUB_TOKEN was Not found.'
  echo "If authentication is not required for this source SCM, edit this script and try again."
  exit
fi

# Set (boolean) whether the project should be marked as Archived in GitLab
ARCHIVE=false

# Set (boolean) whether the project should be pulled/updated on a schedule (mirrored) to GitLab
MIRROR=true

# Set GitLab target Group / Namespace ID
# To list all available namespaces:
# curl --header "Authorization: Bearer $GITLAB_TOKEN" "https://subsplash.io/api/v4/namespaces"
GROUP_ID=233

# Source project URL
# Note: include https auth in SOURCE_URL if necessary (otherwise, forego "<USERNAME>:<PASSWORD>@")
# Example: https://<USERNAME>:<PASSWORD>@github.com/path/to/repo.git
SOURCE_URL="https://$GITHUB_USER:$GITHUB_TOKEN@github.com/snappages/"
# SOURCE_URL="https://github.com/snappages/"

# Project Description
# The REF_URL should match the SOURCE_URL, without any user or token, so it can be included in
# the target project description. See `--form description="Cloned from ${REF_URL}${REPO}" \`
REF_URL="https://github.com/snappages/"

# space-delimited list of repositories available from the SOURCE_URL
REPOLIST="${@}"

for REPO in $REPOLIST; do

  echo "Cloning git repository ${REPO} to ${WEB_URI}/projects/${REPO}/"

  IMPORT=$(curl --request POST \
    --url $API_URI/projects \
    --header 'Content-Type: multipart/form-data;' \
    --header "Authorization: Bearer $GITLAB_TOKEN" \
    --form description="Cloned from ${REF_URL}${REPO}" \
    --form import_url="${SOURCE_URL}${REPO}.git" \
    --form mirror=$MIRROR \
    --form namespace_id=$GROUP_ID \
    --form path="${REPO}" \
    --form allow_merge_on_skipped_pipeline=false \
    --form analytics_access_level=disabled \
    --form approvals_before_merge=1 \
    --form auto_cancel_pending_pipelines=enabled \
    --form auto_devops_enabled=false \
    --form builds_access_level='enabled' \
    --form ci_config_path='.gitlab-ci.yaml' \
    --form ci_forward_deployment_enabled=true \
    --form container_registry_enabled=false \
    --form default_branch='main' \
    --form emails_disabled=true \
    --form issues_access_level=disabled \
    --form lfs_enabled=false \
    --form merge_method=ff \
    --form only_allow_merge_if_all_discussions_are_resolved=true \
    --form only_allow_merge_if_pipeline_succeeds=true \
    --form operations_access_level=disabled \
    --form packages_enabled=false \
    --form pages_access_level=disabled \
    --form remove_source_branch_after_merge=true \
    --form requirements_access_level=disabled \
    --form request_access_enabled=true \
    --form service_desk_enabled=false \
    --form snippets_access_level=disabled \
    --form wiki_access_level=disabled \
    | jq '. | {id,web_url}')

    # access properties in JSON structure of $IMPORT results
    echo ""
    echo "Cloned project to $(echo $IMPORT | jq '.web_url')"
    ID=$(echo $IMPORT | jq '.id')

  # pause for a moment, before trying to archive the newly imported project
  if [[ $ARCHIVE == 'true' ]]; then
    echo 'Marking this project as Archived'
    sleep 1
    ARCHIVED=$(curl --request POST --header "Authorization: Bearer $GITLAB_TOKEN" "${API_URI}/projects/${ID}/archive" | jq '. | {archived} | join("")')
    echo "Project is Archived: $ARCHIVED"
  fi
  echo ""

done

exit

# Scratchpad area of other, related, possibly useful GitLab API samples

# ARCHIVED=$(curl --request POST --header "Authorization: Bearer $GITLAB_TOKEN" "$API_URI/projects/553/archive" | jq .archived)
# echo "Project is Archived: $ARCHIVED"

# Move a project to a different group / namespace
# curl --request PUT --header "Authorization: Bearer $GITLAB_TOKEN" "$API_URI/projects/564/transfer?namespace=197"

# Get project details by project ID
# curl --request GET --header "Authorization: Bearer $GITLAB_TOKEN" "$API_URI/projects/565"

# GitHub API notes:
# List repositories for an Org
curl https://$GITHUB_USER:$GITHUB_TOKEN@api.github.com/orgs/snappages/repos | jq '.[].name'

curl https://$GITHUB_USER:$GITHUB_TOKEN@api.github.com/snappages/
curl -I https://api.github.com/users/octocat/orgs

curl -H "Authorization: token OAUTH-TOKEN" https://api.github.com
