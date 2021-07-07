#!/bin/bash

# This script sets GitLab project settings to a Subsplash standard.
# These settings should match up with those applied by set-gitlab-project-settings
# https://subsplash.io/go/tools/set-gitlab-project-settings/-/blob/main/main.go
# Default branch name:   main
# Issues Enabled:        False
# Wiki Enabled:          False
# Snippets Enabled:      False
# Packages Enabled:      False
# Merge Method:          FastForward
# Approvals required to Merge: 1
# Only Allow Merge If All Discussions are Resolved: True
# CI Config Path: .gitlab-ci.yaml

# API_URI is the root URI for the "GitLab REST API to automate GitLab"
# It includes specifying the API version
# https://docs.gitlab.com/ee/api/README.html
API_URI='https://subsplash.io/api/v4'
WEB_URI='https://subsplash.io'

# Check for a valid GitLab Personal Access Token to authenticate / authorize API calls
if [[ -z $GITLAB_TOKEN ]]; then
    echo "Error: No \$GITLAB_TOKEN was found."
    exit
fi

# Set GitLab target Group / Namespace ID
# To list id numbers of available top-level namespaces:
# NSIDLIST=$(curl --header "Authorization: Bearer $GITLAB_TOKEN" "https://subsplash.io/api/v4/namespaces/?per_page=100" | jq '.[] | {id,kind,full_path} | select(.kind=="group") | {id} | join(" ")')
# https://docs.gitlab.com/ee/api/namespaces.html
# GROUP_ID=127

# space-delimited list of projects to apply the settings to
# Can be a numerical Project ID or a URL-encoded URI
# https://docs.gitlab.com/ee/api/README.html#namespaced-path-encoding
PROJLIST=$@

for PROJ in $PROJLIST
do

    echo ''
    echo "Updating settings for ${WEB_URI}/projects/${PROJ}/"
    echo ''

    # RFE / TODO: get current Description. If blank, parse README for Description text
    curl --silent --request GET \
    --header "Authorization: Bearer $GITLAB_TOKEN" \
    "${API_URI}/projects/${PROJ}" \
    | jq '. | {id,name,description,web_url}'

    # Project settings are specified in form entries on their own line
    # Sorted in alphabetical order
    curl --silent --request PUT "${API_URI}/projects/${PROJ}" \
    --header 'Content-Type: multipart/form-data;' \
    --header "Authorization: Bearer $GITLAB_TOKEN" \
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
    --form wiki_access_level=disabled \
    | jq '. | {id,web_url}'

    echo ''
    echo 'Protect the "main" branch'
    # protect the main branch
    # no users can Push; Developers can merge. Only Admins can change approval settings
    # Valid access levels
    # 0  => No access
    # 30 => Developer access
    # 40 => Maintainer access
    # 60 => Admin access
    curl --silent --request POST \
    --header "Authorization: Bearer $GITLAB_TOKEN" \
    "${API_URI}/projects/${PROJ}/protected_branches/?name=main&push_access_level=60&merge_access_level=30&unprotect_access_level=60&code_owner_approval_required=true" \
    | jq '. | {message}'

    echo ''
    echo 'Set MR approval rules'
    # Set MR approval rules
    # https://docs.gitlab.com/ee/api/merge_request_approvals.html
    # approvals_before_merge is set above for the project
    curl --silent --request POST \
    --header "Authorization: Bearer $GITLAB_TOKEN" \
    "${API_URI}/projects/${PROJ}/approvals?merge_requests_author_approval=true&reset_approvals_on_push=true" \
    | jq '. | {approvals_before_merge}'

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
