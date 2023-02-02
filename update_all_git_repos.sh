#!/bin/bash
# https://gist.githubusercontent.com/douglas/1287372/raw/46f810306802099024833ea71b1af2d806561a16/update_git_repos.sh

# store the current dir
CUR_DIR=$(pwd)

if [[ $# -eq 1 ]]; then
  REPOBASE="$1"
  echo "repo: '${REPOBASE}' set by parameter"
else
  REPOBASE="${HOME}/repo"
  echo 'No repo specified by parameter. Using ~/repo'
fi

# Go to repository root
cd "${REPOBASE}" || return

# Let the person running the script know what's going on.
echo "$(pwd) Pulling all repositories..." || true

# Find all git repositories and update it to the main latest revision
for i in $(find . -iname '.git'); do
  # echo ""
  # echo "$i"
  repo=$(dirname "${i}")
  echo "cd ${repo}"

  # We have to go to the .git parent directory to call the pull command
  cd "${repo}" || break
  echo ""
  echo "pwd: $(pwd)"

  # cp .git/config .git/config-backup

  sed -i '' 's/master/main/g' .git/config
  sed -i '' 's/git@subsplash.io:/https:\/\/subsplash.io\//g' .git/config
  sed -i '' '/fetch/s/main/*/g' .git/config

  # finally: git pull
  echo git pull origin main
  git fetch --auto-maintenance --prune --prune-tags --recurse-submodules --tags
  git pull origin main --rebase --autostash --prune

  echo ''
  cd ..
done

cd "${CUR_DIR}" || return
echo 'Complete!'
