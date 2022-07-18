#!/bin/bash

# creates variables in GitLab, using `glab` CLI
# https://glab.readthedocs.io/en/latest/intro.html
# Intended to simplify creating variables to store secrets for use in GitLab CI jobs

PATURI="https://subsplash.io/-/profile/personal_access_tokens"
RELEASE="insiders" # "v4|insiders"

# Confirm running on MacOS
UNAME="$(uname -s)"
# echo "UNAME IS $UNAME"

if ! [[ "$UNAME" =~ "Darwin" ]]; then
    # Confirm or install dependencies as necessary
    echo "Error: This script is intended for MacOS, but was found to be running on $UNAME"
    exit
fi

# 1. Check if Homebrew is available# Before invoking brew to install node, make sure it's available
if ! command -v brew >/dev/null; then
    echo "Warning: This script requires Homebrew, but it was not found. Preparing to install Homebrew."

    # 1.a. Homebrew requires / expect xcode CLT, for git
    if ! command -v gitfail >/dev/null; then
        echo "Error: This script requires git (to support install of homebrew)."
        echo "    run xcode-select --install, complete the xcode CLT setup, then try again."
        exit
    fi

    # 1.b. Install Homebrew
    echo "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # echo "Homebrew successfully installed"
fi

# 2. Check that node.js / npx command is installed

NODE_VERSION=$(node --version)
if [ "X$NODE_VERSION" = "X" ]; then
    echo "ERROR: node.js is required, but was not found installed."
    echo "       Consider installing via 'brew install node'."
    exit 13
else
    echo "Confirmed node $NODE_VERSION is available."
fi

# 3. Check that docker is installed and running

DOCKER_VERSION=$(docker --version)
if [ "X$DOCKER_VERSION" = "X" ]; then
    echo "ERROR: Docker is required, but was not found installed."
    echo "       Consider installing via 'brew install --cask docker'."
    exit 23
else
    DOCKER_RUNNING=$(pgrep -f Docker.app)
    if [ "X$DOCKER_RUNNING" = "X" ]; then
        echo "WARNING: Docker is installed, but was not found running."
        echo "         Starting Docker (open -a 'Docker Desktop')"
        open -a 'Docker Desktop'
        sleep 7
        # exit 29
    else
        echo "Confirmed $DOCKER_VERSION is running."
    fi
fi

# 4. Run mega-linter in config setup mode, if needed
if [ -f ".mega-linter.yml" ]; then
    echo "Loading config from .mega-linter.yml ..."
    echo ""
    npx mega-linter-runner --flavor $FLAVOR -e 'LOG_LEVEL=INFO' -r $RELEASE
else
    echo ""
    echo "Setting up .mega-linter.yml."
    npx mega-linter-runner --install
    echo ""
    echo "Done."
    echo "    Run this script again to invoke mega-linter with these new settings."
    echo ""
fi
