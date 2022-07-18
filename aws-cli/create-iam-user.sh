#! /bin/bash
#
# Create a new IAM user in AWS Account
# Thanks to https://automateinfra.com/2021/03/30/how-to-create-a-iam-user-on-aws-account-using-shell-script/
# Checking if access key is setup in your system

echo ""
test "$(command -v awsv2)" || (echo "Error: aws cli not found. See: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html" && exit 1)

exit

if ! grep -q aws_access_key_id ~/.aws/config; then      # grep -q  Turns off Writing to standard output
   if ! grep -q aws_access_key_id ~/.aws/credentials; then
      echo "AWS config not found or CLI is not installed"
      exit 1
    fi
fi

# check which AWS CLI Profile the commands will proceed in
[[ -z $AWS_DEFAULT_REGION || -z $ARG_ENV || -z $ARG_ROLE ]] && (echo "Usage: ${0} NAME=[User Name] ENV=[dev|stage|prod] ROLE=[Admin|ReleaseEngineer|Developer|GivingDeveloper|FillInNotesDev|QAEngineer]" && exit 2)

# check which AWS CLI Region the commands will proceed in
[[ -z $AWS_DEFAULT_REGION || -z $ARG_ENV || -z $ARG_ROLE ]] && (echo "Usage: ${0} NAME=[User Name] ENV=[dev|stage|prod] ROLE=[Admin|ReleaseEngineer|Developer|GivingDeveloper|FillInNotesDev|QAEngineer]" && exit 2)

# read command will prompt you to enter the name of IAM user you wish to create

read -r -p "Enter the username to create": username

# Using AWS CLI Command create IAM user

aws iam create-user --user-name "${username}" --output json

# Here we are creating access and secret keys and then using query and storing the values in credentials

credentials=$(aws iam create-access-key --user-name "${username}" --query 'AccessKey.[AccessKeyId,SecretAccessKey]'  --output text)

# cut command formats the output with correct coloumn.

access_key_id=$(echo ${credentials} | cut -d " " -f 1)
secret_access_key=$(echo ${credentials} | cut --complement -d " " -f 1)

# echo command will print on the screen

echo "The Username "${username}" has been created"
echo "The access key ID  of "${username}" is $access_key_id "
echo "The Secret access key of "${username}" is $secret_access_key "
