#!/bin/bash

# Sets up VS Code (via Homebrew) and adds elected extensions
# 1. Check that Homebrew is installed and available to run
# 2. Use Homebrew to install VS Code (if it's not already installed)
# 3. Check that VS Code is installed and available to run
# 4. Install Extensions

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
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "Homebrew install script completed."
fi

echo "brew install --cask visual-studio-code"
brew install --cask visual-studio-code

# 2. Check that `code` command is available.
if ! command -v code >/dev/null; then
  echo "Warning: This script attempted to install VS Code via Homebrew, but 'code' was not found as an available command."
  echo "    Resolve the cause of any error messages and try again."
  exit
fi

# 3. Install code extensions
code --install-extension amazonwebservices.aws-toolkit-vscode         # https://marketplace.visualstudio.com/items?itemName=AmazonWebServices.aws-toolkit-vscode
code --install-extension andyyaldoo.vscode-json                       # https://marketplace.visualstudio.com/items?itemName=andyyaldoo.vscode-json
code --install-extension atlassian.atlascode                          # https://marketplace.visualstudio.com/items?itemName=atlassian.atlascode
code --install-extension bibhasdn.unique-lines                        # https://marketplace.visualstudio.com/items?itemName=bibhasdn.unique-lines
code --install-extension DavidAnson.vscode-markdownlint               # https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint
code --install-extension eamodio.gitlens                              # https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens
code --install-extension EditorConfig.EditorConfig                    # https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig
code --install-extension esbenp.prettier-vscode                       # https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode
code --install-extension foxundermoon.shell-format                    # https://marketplace.visualstudio.com/items?itemName=foxundermoon.shell-format
code --install-extension GitLab.gitlab-workflow                       # https://marketplace.visualstudio.com/items?itemName=GitLab.gitlab-workflow
code --install-extension golang.go                                    # https://marketplace.visualstudio.com/items?itemName=golang.go
code --install-extension hashicorp.terraform                          # https://marketplace.visualstudio.com/items?itemName=hashicorp.terraform
code --install-extension ms-azuretools.vscode-docker                  # https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools  # https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension ms-vscode-remote.remote-containers           # https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers
code --install-extension ms-vscode-remote.remote-ssh                  # https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh
code --install-extension ms-vscode-remote.remote-ssh-edit             # https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh-edit
code --install-extension ms-vscode-remote.remote-wsl                  # https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl
code --install-extension ms-vscode-remote.vscode-remote-extensionpack # https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack
code --install-extension mtxr.sqltools                                # https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools
code --install-extension redhat.vscode-commons                        # https://marketplace.visualstudio.com/items?itemName=redhat.vscode-commons
code --install-extension redhat.vscode-yaml                           # https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml
code --install-extension SonatypeCommunity.vscode-iq-plugin           # https://marketplace.visualstudio.com/items?itemName=SonatypeCommunity.vscode-iq-plugin
code --install-extension yzhang.markdown-all-in-one                   # https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one
