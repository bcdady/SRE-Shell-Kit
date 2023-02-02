#!/bin/bash

# Sets up AWS CLI V2 via steps in official docs
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html#cliv2-mac-install-cmd
# see also https://formulae.brew.sh/formula/awscli#default

curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIv2.pkg"
sudo installer -pkg AWSCLIv2.pkg -target /

# Verify the installation
command -v aws
aws --version
