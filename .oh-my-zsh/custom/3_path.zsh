#!/bin/zsh
echo $0

# ensure aws-cli path is in PATH
export AWSPATH=~/Library/Python/3.7/bin

# ensure go path is defined, and also add GOPATH/bin in PATH
export GOPATH=$HOME/go

GOBIN=$GOPATH/bin

# ensure mysql-client path is in PATH
export MYSQLPATH=/usr/local/opt/mysql-client/bin

# ensure PYTHONPATH is in PATH
PYTHONPATH="$HOME/Library/Python/3.7/lib/python/site-packages/:$HOME/Library/Python/3.8/lib/python/site-packages/:/usr/local/lib/python3.7/site-packages:/usr/local/lib/python3.8/site-packages"

# ensure pylint path is in PATH
PY3PATH=~/Library/Python/3.8/bin

# add $HOME/bin to PATH, for kubectl-eks (and aws-iam-authenticator?)
export PATH=$AWSPATH:$GOBIN:$MYSQLPATH:$PY3PATH:$PYTHONPATH:$PATH

# remove any duplicates
typeset -U path
