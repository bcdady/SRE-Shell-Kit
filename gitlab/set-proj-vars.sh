#!/bin/bash

# This script sets CI variables for GitLab project.
# These variables can then be referenced as secrets from a CI job.
# https://docs.gitlab.com/ee/api/project_level_variables.html#create-variable
# key	string	yes	The key of a variable; must have no more than 255 characters; only A-Z, a-z, 0-9, and _ are allowed
# value	string	yes	The value of a variable
# variable_type	string	no	The type of a variable. Available types are: env_var (default) and file
# protected	boolean	no	Whether the variable is protected. Default: false
# masked	boolean	no	Whether the variable is masked. Default: false
# environment_scope	string	no	The environment_scope of the variable. Default: *

# API_URI is the root URI for the "GitLab REST API to automate GitLab"
# It includes specifying the API version
# https://docs.gitlab.com/ee/api/README.html
API_URI='https://subsplash.io/api/v4'
WEB_URI='https://subsplash.io'

# Check for a valid GitLab Personal Access Token to authenticate / authorize API calls
if [[ -z $1 ]]; then
  # shellcheck disable=SC2016
  echo 'No Project specified. Usage: $0 ''PROJECT'''
  exit
fi

# Project to apply the settings to
# Can be a numerical Project ID or a URL-encoded URI
# https://docs.gitlab.com/ee/api/README.html#namespaced-path-encoding
PROJ=$1

# Check for a valid GitLab Personal Access Token to authenticate / authorize API calls
if [[ -z $2 ]]; then
  # shellcheck disable=SC2016
  echo 'No Variable Key specified. Usage: $0 ''PROJECT'' ''VARIABLE-KEY'' ''VARIABLE-VALUE'''
  exit
fi

# Check for a valid GitLab Personal Access Token to authenticate / authorize API calls
if [[ -z ${GITLAB_TOKEN} ]]; then
  # shellcheck disable=SC2016
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

# Setup script variables to be used in API call

# key	string	yes	The key of a variable; must have no more than 255 characters; only A-Z, a-z, 0-9, and _ are allowed
# value	string	yes	The value of a variable
# variable_type	string	no	The type of a variable. Available types are: env_var (default) and file
# protected	boolean	no	Whether the variable is protected. Default: false
# masked	boolean	no	Whether the variable is masked. Default: false
# environment_scope	string	no	The environment_scope of the variable. Default: *

for VAR in ${VARLIST}; do

  echo ''
  echo "Updating settings for ${WEB_URI}/projects/${PROJ}/"
  echo ''

  # RFE / TODO: get current Description. If blank, parse README for Description text
  # shellcheck disable=SC2312
  curl --silent --request GET \
    --header "Authorization: Bearer ${GITLAB_TOKEN}" \
    "${API_URI}/projects/${PROJ}" |
    jq '. | {id,name,description,web_url}'

  # Project settings are specified in form entries on their own line
  # Sorted in alphabetical order
  # shellcheck disable=SC2312
  curl --silent --request PUT "${API_URI}/projects/${PROJ}" \
    --header 'Content-Type: multipart/form-data;' \
    --header "Authorization: Bearer ${GITLAB_TOKEN}" \
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
    --form visibility=internal \
    --form wiki_access_level=disabled |
    jq '. | {id,web_url}'

  echo ''
  echo 'Protect the "main" branch'
  # protect the main branch
  # no users can Push; Developers can merge. Only Admins can change approval settings
  # Valid access levels
  # 0  => No access
  # 30 => Developer access
  # 40 => Maintainer access
  # 60 => Admin access
  # shellcheck disable=SC2312
  curl --silent --request POST \
    --header "Authorization: Bearer $GITLAB_TOKEN" \
    "${API_URI}/projects/${PROJ}/protected_branches/?name=main&push_access_level=60&merge_access_level=30&unprotect_access_level=60&code_owner_approval_required=true" |
    jq '. | {message}'

  echo ''
  echo 'Set MR approval rules'
  # Set MR approval rules
  # https://docs.gitlab.com/ee/api/merge_request_approvals.html
  # approvals_before_merge is set above for the project
  # shellcheck disable=SC2312
  curl --silent --request POST \
    --header "Authorization: Bearer $GITLAB_TOKEN" \
    "${API_URI}/projects/${PROJ}/approvals?merge_requests_author_approval=true&reset_approvals_on_push=true" |
    jq '. | {approvals_before_merge}'

done

exit

# Scratchpad area of other, related, possibly useful gitlab API samples

# ARCHIVED=$(curl --request POST --header "Authorization: Bearer $GITLAB_TOKEN" "$API_URI/projects/553/archive" | jq .archived)
# echo "Project is Archived: $ARCHIVED"

# Move a project to a different group / namespace
# curl --request PUT --header "Authorization: Bearer $GITLAB_TOKEN" "$API_URI/projects/564/transfer?namespace=197"

# Get project details by project ID
# curl --request GET --header "Authorization: Bearer $GITLAB_TOKEN" "$API_URI/projects/565"

# List path of top-level groups by id
# curl --request GET --header "Authorization: Bearer $GITLAB_TOKEN" "https://subsplash.io/api/v4/namespaces/127" | jq '.[] | {id,kind,full_path} | select(.kind=="group") | {id} | join(" ")'

# List a user's projects in their personal namespace
# curl --request GET --header "Authorization: Bearer $GITLAB_TOKEN" "https://subsplash.io/api/v4/users/bryan/projects" | jq '.[] | {id,path_with_namespace}'

# List a user's projects in their personal namespace
# curl --request GET --header "Authorization: Bearer $GITLAB_TOKEN" "https://subsplash.io/api/v4/projects/127/approval_rules" | jq .
