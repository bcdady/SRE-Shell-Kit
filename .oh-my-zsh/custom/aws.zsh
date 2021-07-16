#!/bin/zsh
echo $0

echo "Running awscli version: $(aws --version)"

# echo "Updating awscli"
# pip install awscli --upgrade --user && echo

# source ~/Library/Python/3.7/bin/aws_zsh_completer.sh

export AWS_EXEC_PROFILE=$(aws-vault list --credentials)
export AWS_REGION="us-west-2"

# setup kubectl completion for use with EKS
source ~/.zsh/k8s-completion
source ~/.zsh/eks-completion
