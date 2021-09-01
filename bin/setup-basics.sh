#!/bin/bash

# Sets up SRE apps via Homebrew
# 1. Check that Homebrew is installed and available to run
# 2. Use Homebrew to install specified formulae
# 3. Use Homebrew to install specified casks

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

# Start with installing iTerm2
# Consider also adding oh-my-zsh, and other shell packages
brew install --cask iterm2

brew install awscli bat dog editorconfig jq tmux tmux-xpanes meld qlimagesize qlmarkdown quicklook-json, yamllint

# install golang and terraform tools
brew install go terraform terraform-docs tflint tfsec tfswitch

# install K8s and helm tools
brew install ktail kubectx kubernetes-cli helm helmfile
brew install --cask lens

# Other suggestions
brew install go-jira
brew install go-task/tap/go-task # go install github.com/go-task/task/v3/cmd/task@latest` -

# Recommended Casks
# iterm2 - https://formulae.brew.sh/cask/iterm2
# google-drive - https://formulae.brew.sh/cask/google-drive
# insomnia - https://formulae.brew.sh/cask/insomnia
# lens - https://formulae.brew.sh/cask/lens
# utc-menu-clock - https://formulae.brew.sh/cask/utc-menu-clock
# visual-studio-code - https://formulae.brew.sh/cask/visual-studio-code

# Suggested Casks
# appcleaner - https://formulae.brew.sh/cask/appcleaner
# authy      - https://formulae.brew.sh/cask/authy
# cyberduck  - https://formulae.brew.sh/cask/cyberduck
# firefox    - https://formulae.brew.sh/cask/firefox
# keybase    - https://formulae.brew.sh/cask/keybase
# lens       - https://formulae.brew.sh/cask/lens
# maccy      - https://formulae.brew.sh/cask/maccy
# meld       - https://formulae.brew.sh/cask/meld
# microsoft-edge - https://formulae.brew.sh/cask/microsoft-edge
# rectangle  - https://formulae.brew.sh/cask/rectangle
# spotify    - https://formulae.brew.sh/cask/spotify
# sunsama    - https://formulae.brew.sh/cask/sunsama
# owasp-zap  - https://formulae.brew.sh/cask/owasp-zap
