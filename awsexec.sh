#!/usr/bin/env bash

# This script invokes an AWS CLI through the aws-vault utility
# https://github.com/99designs/aws-vault/
# See also:
# https://github.com/99designs/aws-vault/blob/master/USAGE.md#using-credential-helper
# https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sourcing-external.html

# Test if aws-vault is installed
command -v aws-vault >/dev/null 2>&1 || {
  echo "Error!: aws-vault Not found."

  read -rp "Install and Configure AWS-Vault? (y/n) " INSTALL
  if [[ ${INSTALL} =~ ^y$ ]]; then

    # Test if Homebrew and cask is installed
    command -v brew cask >/dev/null 2>&1 || {
      echo "Installing aws-vault"
      brew cask install aws-vault
    } && {
      echo "Warning: Did not confirm Homebrew and cask were available."
      echo "Please see this page for more info on installing aws-vault: https://github.com/99designs/aws-vault/blob/master/README.md"
    }
  fi

} && {
  # check for environment variable specifying preferred aws auth profile
  if [[ -z "${AWS_EXEC_PROFILE}" ]]; then
    # Preference not set in variable, explain to the user
    echo "AWS_EXEC_PROFILE is not set. aws-vault will use 'default' "
  fi
  # execute
  printf "exec aws-vault exec %s %s -- aws " "${AWS_EXEC_PROFILE:-default}" "$@"
  exec aws-vault exec "${AWS_EXEC_PROFILE:-default}" -- aws "$@"
}
