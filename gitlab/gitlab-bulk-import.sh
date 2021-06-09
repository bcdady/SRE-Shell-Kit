#!/bin/bash

# This script creates new projects in GitLab and mirrors a list of source repositories
# and sets some basic Subsplash standard GitLab project settings
# See https://docs.gitlab.com/ee/api/projects.html#create-project
# The example is of the Subsplash private repository at GitHub.com, but it's also been used
# for Bitbucket and GitHub public repos

# Check for a valid GitLab Personal Access Token to authenticate / authorize API calls
if [[ -z $GITLAB_TOKEN ]]; then
    echo "Error: No \$GITLAB_TOKEN was found."
    exit
fi

# Check for valid credentials to source system; these variables are used later
# if [[ -z $GITHUB_USER ]]; then
#     echo "Error: No \$GITHUB_USER was found."
#     echo "If authentication is not required for this source SCM, edit this script and try again."
#     exit
# fi

# if [[ -z $GITHUB_TOKEN ]]; then
#     echo "Error: No \$GITHUB_TOKEN was found. If a"
#     exit
# fi

# Set (boolean) whether the project should be marked as Archived in GitLab
ARCHIVE=true 

# Set (boolean) whether the project should be pulled/updated on a schedule (mirrored) to GitLab
MIRROR=false 

# Set GitLab target Group / Namespace ID
# To list all available namespaces:
# curl --header "Authorization: Bearer $GITLAB_TOKEN" "https://subsplash.io/api/v4/namespaces"
GROUP_ID=197 

# Project Description
# The REF_URL should match the SOURCE_URL, without any user or token, so it can be included in
# the target project description. See `--form description="Cloned from ${REF_URL}${REPO}" \`
REF_URL="https://github.com/Subsplash/"

# Source project URL
# Note: include https auth in SOURCE_URL if necessary (otherwise, forego "<USERNAME>:<PASSWORD>@")
# Example: https://<USERNAME>:<PASSWORD>@github.com/path/to/repo.git
SOURCE_URL="https://$GITHUB_USER:$GITHUB_TOKEN@github.com/Subsplash/"

# space-delimited list of repositories available from the SOURCE_URL
REPOLIST="fluro-vue-groups hillsong-songmerge-ui"

for REPO in $REPOLIST
do

    echo "Cloning git repository ${REPO} to subsplash.io (GitLab)"

    ID=$(curl --request POST \
    --url https://subsplash.io/api/v4/projects \
    --header 'Content-Type: multipart/form-data;' \
    --header "Authorization: Bearer $GITLAB_TOKEN" \
    --form path="${REPO}" \
    --form import_url="${SOURCE_URL}${REPO}.git" \
    --form namespace_id=$GROUP_ID \
    --form visibility=internal \
    --form description="Cloned from ${REF_URL}${REPO}" \
    --form mirror=$MIRROR \
    --form analytics_access_level=disabled \
    --form approvals_before_merge=1 \
    --form auto_cancel_pending_pipelines=enabled \
    --form auto_devops_enabled=false \
    --form container_registry_enabled=false \
    --form issues_access_level=disabled \
    --form lfs_enabled=false \
    --form operations_access_level=disabled \
    --form packages_enabled=false \
    --form pages_access_level=disabled \
    --form requirements_access_level=disabled \
    --form wiki_access_level=disabled | jq .id)

    # check the ID
    echo "new repo ID is $ID"
    if [[ "$ARCHIVE" = 'true' ]]; then
        ARCHIVED=$(curl --request POST --header "Authorization: Bearer $GITLAB_TOKEN" "https://subsplash.io/api/v4/projects/$ID/archive" | jq .archived)
        echo "Project is Archived: $ARCHIVED"
    fi
    echo ""

done

exit

# Scratchpad area of other, related, possibly useful gitlab API samples

# ARCHIVED=$(curl --request POST --header "Authorization: Bearer $GITLAB_TOKEN" "https://subsplash.io/api/v4/projects/553/archive" | jq .archived)
# echo "Project is Archived: $ARCHIVED"

# Move a project to a different group / namespace
# curl --request PUT --header "Authorization: Bearer $GITLAB_TOKEN" "https://subsplash.io/api/v4/projects/564/transfer?namespace=197"

# Get project details by project ID
# curl --request GET --header "Authorization: Bearer $GITLAB_TOKEN" "https://subsplash.io/api/v4/projects/565"
