#!/usr/bin/env bash
TOKEN="jHJnLFG5NiNbuynjtTby" # iTerm Read didn't have sufficient privileges: "JGHWf6mmeMuw-m5_eAuX"
# requires - brew install cloc
# requires - brew install jq

TMP1=$(mktemp)
printf "INFO: working in $TMP1\n"

# check if an ssh identity is available, so that subsequent git clone's don't prompt for passphrase everytime
# SSH_ID=$(ssh-add -l)
# REPO="git@subsplash.io:release/google-play.git"
# re="git@subsplash.io\:(.+)\.git"
# if [[ $REPO =~ $re ]]; then LOCAL=${BASH_REMATCH[1]}; fi
# printf "INFO: Will proceed with SSH identity: $SSH_ID\n"


for TOOL in cloc jq; do
  which $TOOL >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    printf "ERROR: couldn't find $TOOL tool. Exiting...\n"
    exit 127
  fi
done

for PAGE in 1 2 3; do
  printf "INFO: Attempting to access https://subsplash.io/api/v4/projects?per_page=100&page=$PAGE"
  curl -s --connect-timeout 5 --max-time 10 --retry 5 --retry-delay 0 --retry-max-time 60 --header "Authorization: Bearer $TOKEN" "https://subsplash.io/api/v4/projects?per_page=100&page=$PAGE" >>"$TMP1"
  # curl -s --connect-timeout 5 --max-time 10 --retry 5 --retry-delay 0 --retry-max-time 60 --header "Authorization: Bearer JGHWf6mmeMuw-m5_eAuX" "https://subsplash.io/api/v4/projects?per_page=100&page=1"
done
cd ~/repo/GitStats
jq -r '.[].ssh_url_to_repo' < "$TMP1"|
while read -r REPO; do
  printf "INFO: Processing $REPO...\n"
  # $REPO is a URI like git@subsplash.io:release/google-play.git // extract git@subsplash.io\:(.+)\.git
  #REPO="git@subsplash.io:release/google-play.git"
  re="git@subsplash.io\:(.+)\.git"
  if [[ $REPO =~ $re ]]; then LOCAL=${BASH_REMATCH[1]}; fi

  #LOCALPATH="~/repo/GitStats/$LOCAL"
  printf "Info: will clone to $LOCAL ...\n"
  #mkdir $LOCAL

  git clone --depth 1 "$REPO" "$LOCAL" # temp-linecount-repo
  # git clone --depth 1 git@subsplash.io:ops/kubernetes-app-helm-chart.git ~/repo/kubernetes-app-helm-chart
  printf "INFO: Running cloc on repo $LOCAL ...\n"
  # create a common output file to collect STDOUT, so we can collect/append output from multiple instances of cloc, instead of creating discrete files
  OUTFILE="$LOCAL-stats.csv" # example: kubernetes-app-helm-chart_stats.csv
  cloc --csv --file-encoding="UTF-8" --out=$OUTFILE $LOCAL  # Output options include --csv --md --file-encoding="UTF-8" --yaml --out=FILE
  #printf "Cleaning up repo...\n"
  #rm -rf $LOCAL # temp-linecount-repo
done
# printf "Cleaning up $TMP1 \n"
rm -f "$TMP1"
printf
exit 0