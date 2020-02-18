#!/usr/bin/env pwsh
#Requires -Version 3
#========================================
# NAME      : update-repo.pwsh
# LANGUAGE  : PowerShell (Core)
# PURPOSE   : From a root path, update (git pull) all subfolders / repositories
# # https://gist.githubusercontent.com/douglas/1287372/raw/46f810306802099024833ea71b1af2d806561a16/update_git_repos.sh
#========================================
[CmdletBinding()]
param ($RootFolder)

# store the current dir
CUR_DIR=$(pwd)

if ($RootFolder) {
    echo "Root: '$RootFolder' set by parameter"
} else {
    $RootFolder="$HOME/repo"
    echo 'No repo specified by parameter. Using ~/repo'
}

# Go to repository root
cd $RootFolder

# Let the person running the script know what's going on.
'Pulling all repositories...'

# Find all git repositories and update it to the master latest revision
$RepoList = Get-ChildItem -Path ~/repo/*/.git/ -Recurse -Force | Select-Object -ExpandProperty FullName | Split-Path -parent

$RepoList | ForEach-Object -Process {
    cd $PSItem    
    pwd
    git pull origin master
} 
# lets get back to the CUR_DIR
cd $CUR_DIR

' Complete!'