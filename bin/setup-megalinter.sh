#!/bin/bash

# Sets up prerequisites to run mega-linter locally on MacOS
# More info on mega-linter-runner at https://nvuillam.github.io/mega-linter/mega-linter-runner/
# 1. Check that Homebrew is installed and available to run
# 2. Use Homebrew to install node js (if necessary)
# 3. Use Homebrew to install Docker (if necessary)
# 4. Run mega-linter with version and help parameters, just to confirm it's working

# Confirm running on MacOS
UNAME="$(uname -s)"
# echo "UNAME IS $UNAME"

if ! [[ ${UNAME} =~ "Darwin" ]]; then
  # Confirm or install dependencies as necessary
  echo "Error: This script is intended for MacOS, but was found to be running on $UNAME"
  exit
fi

# 1. Check if Homebrew is available. Install if not.
if ! command -v brew >/dev/null; then
  echo "Warning: This script requires Homebrew, but it was not found. Preparing to install Homebrew."

  # 1.a. Homebrew requires / expect xcode CLT, for git
  # https://docs.brew.sh/Installation#macos-requirements
  if ! command -v git >/dev/null; then
    echo "NOTICE: Homebrew requires xcode Command Line Tools (CLT) (with git)."
    echo "    starting xcode-select --install"
    echo "    Complete the xcode CLT setup, then homebrew setup can resume."
    xcode-select --install
  fi

  # 1.b. Install Homebrew
  echo "Installing homebrew..."
  # shellcheck disable=SC2312
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # echo "Homebrew successfully installed"
fi

# 2. Check that node.js / npx command is installed

NODE_VERSION=$(node --version)
if [[ "X${NODE_VERSION}" == "X" ]]; then
  echo "ERROR: node.js is required, but was not found installed."
  echo "       Installing via 'brew install node'."
  brew install node
else
  echo "Confirmed node ${NODE_VERSION} is available."
fi

# 3. Check that docker is installed

DOCKER_VERSION=$(docker --version)
if [[ "X${DOCKER_VERSION}" == "X" ]]; then
  echo "ERROR: Docker is required, but was not found installed."
  echo "       Installing via 'brew install --cask docker'."
  brew install --cask docker
else
  echo "Confirmed ${DOCKER_VERSION} is installed."
fi

# 4. Run mega-linter with version and help parameters, just to confirm it's working
npx mega-linter-runner --version
npx mega-linter-runner --help

# 5. Check that go-task / taskfile is installed
# https://taskfile.dev/#/installation?id=package-managers
if ! command -v task >/dev/null; then
  echo 'ERROR: Taskfile is recommended, but was not found installed.'
  echo "       Installing via 'brew install go-task/tap/go-task'."
  brew install go-task/tap/go-task
else
  echo 'Confirmed Taskfile is installed.'
fi
