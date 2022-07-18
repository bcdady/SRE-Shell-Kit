#!/usr/bin/env bash

# run mega-linter locally, examining the current directory / repository
# More info at https://nvuillam.github.io/mega-linter/mega-linter-runner/

FLAVOR="terraform" # check that this matches the flavor specified in .gitlab-ci.yaml

# detect if node.js is installed
NODE_VERSION=$(node --version)
if [ "X$NODE_VERSION" = "X" ]; then
    echo "ERROR: node.js is required, but was not found installed."
    echo "       Consider installing via 'brew install node'."
    exit 13
else
    echo "Confirmed node $NODE_VERSION is available."
fi

# detect if docker is installed and running
DOCKER_VERSION=$(docker --version)
if [ "X$DOCKER_VERSION" = "X" ]; then
    echo "ERROR: Docker is required, but was not found installed."
    echo "       Consider installing via 'brew install docker'."
    exit 23
else
    DOCKER_RUNNING=$(pgrep -f Docker.app)
    if [ "X$DOCKER_RUNNING" = "X" ]; then
        echo "WARNING: Docker is installed, but was not found running."
        echo "         Starting Docker (open -a 'Docker Desktop')"
        open -a 'Docker Desktop'
        sleep 12
        # exit 29
    else
        echo "Confirmed $DOCKER_VERSION is running."
    fi
fi

# Run mega-linter -- in config setup mode, if needed
if [ -f ".mega-linter.yml" ]; then
    echo "Loading config from .mega-linter.yml ..."
    echo ""
    npx mega-linter-runner --flavor $FLAVOR \
        -e 'LOG_LEVEL=INFO'
else
    echo ""
    echo "Setting up .mega-linter.yml."
    npx mega-linter-runner --install
    echo ""
    echo "Done."
    echo "    Run this script again to invoke mega-linter with these new settings."
    echo ""
fi
