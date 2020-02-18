#!/bin/bash
# https://gist.githubusercontent.com/douglas/1287372/raw/46f810306802099024833ea71b1af2d806561a16/update_git_repos.sh

# store the current dir
CUR_DIR=$(pwd)

if [ $# -eq 1 ]; then
    repobase="$1"
    echo "repo: '$repo' set by parameter"
else
    repobase="$HOME/repo"
    echo 'No repo specified by parameter. Using ~/repo'
fi

# Go to repository root
cd $repobase

# Let the person running the script know what's going on.
echo 'Pulling all repositories...'

# Find all git repositories and update it to the master latest revision
for i in $(find . -iname '.git'); do
    # echo ""
    # echo "$i"
    repo=$(dirname "$i")
    echo "cd $repo"

    # We have to go to the .git parent directory to call the pull command
    cd $repo
    echo ""
    echo "pwd: $(pwd)"
    # finally: git pull
    echo git pull origin master

    echo ''
    # lets get back to the CUR_DIR
    cd $CUR_DIR
done

echo " Complete!'