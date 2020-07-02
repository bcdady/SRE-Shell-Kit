#!/usr/bin/env sh
# partially based on https://raw.githubusercontent.com/odwraca/aws-internal-ip-list/master/aws-internal-ip.sh

# Pseudo code for this script
# 1. Get EC2 security groups that have an ingress rule allowing traffic from 0.0.0.0
# 1. a. Keep a handle in the SG ID and/or name
# 2. List EC2 instances with instance.group-name and/or instance.group-id = variable from 1a
# 
# 
# region="$1"
# if region; then
#     echo "AWS region: :'$region' set as parameter"
# else
#     echo "No AWS region specified as parameter. Using us-west-2"
#     region='us-west-2'
# fi

# echo "Working in AWS region: :'$region'"

#echo "Listing Subsplash AWS Load Balancers:'$account'..."
echo "Account,Region,ResourceType,IP,InstanceId,Name,PublicDnsName,State"

for account in cca cde experiment giving ops sap snappages test
do
    # ec2 security groups and the IP network info
#    aws ec2 describe-security-groups --profile $account --region $region --output text --filters Name=ip-permission.cidr,Values='0.0.0.0/0' --query 'SecurityGroups[*].{Name:GroupName,TagName: Tags[?Key==`Name`].Value | [0],Description:Description,IngressRules:IpPermissions,IpPermissionsIngres:IpPermissions.IpRanges.CidrIp}'

# aws ec2 describe-security-groups --profile $account --region $region --filters Name=ip-permission.cidr,Values='0.0.0.0/0' --query 'SecurityGroups[*].{GroupId:GroupId}' --output text

    for region in us-west-1 us-west-2 us-east-1 us-east-2
    do
        OpenSecurityGroups=$(aws ec2 describe-security-groups --profile $account --region $region --filters Name=ip-permission.cidr,Values='0.0.0.0/0' --query 'SecurityGroups[*].{GroupId:GroupId}' --output text)

        #if $GroupId; then
        for GroupId in $OpenSecurityGroups
        do
            #echo GroupId: $GroupId

            echo "$account","$region",ec2,,,,,
            # Associated EC2 instances and their public and private network info
            aws ec2 describe-instances --profile $account --region $region --filters Name=instance.group-id,Values=$GroupId --query 'Reservations[*].Instances[*].{InstanceId:InstanceId,Name: Tags[?Key==`Name`].Value | [0]PublicDnsName:PublicDnsName,State:State.Name, IP:NetworkInterfaces[0].PublicIpAddress}' --output text

            #echo "SGinstances: $SGinstances"
        done
        # else
        #    echo Failed to collect GroupId for this Security Group
        # fi

        # echo "\nInstance Id\tVPC Id\tPublicDnsName\tState Name\tPublicIpAddress"
        # echo "aws ec2 describe-instances --profile $account --region $region --query 'Reservations[*].Instances[*].{InstanceId:InstanceId,VPCId:VpcId,PublicDnsName:PublicDnsName,State:State.Name, IP:NetworkInterfaces[0]"

        # Load balancers and their DNS Names
        echo "$account","$region",elb,,,,,
        aws elb describe-load-balancers --profile $account --region $region --output text --query 'LoadBalancerDescriptions[*].{DNSName:DNSName}'

        # v2 Load balancers and their DNS Names
        echo "$account","$region",elbv2,,,,,
        aws elbv2 describe-load-balancers --profile $account --region $region --output table --query 'LoadBalancerDescriptions[*].{DNSName:DNSName}'

    done

    # ec2 VPCs
#    aws ec2 describe-vpcs --profile $account --region $region --query 'Vpcs[*].[Tags[?Key==`Name`].Value, CidrBlock, VpcId]' --output text

done

#echo "aws elb describe-load-balancers --profile $account --region $region --output text --query 'LoadBalancerDescriptions[*].{LoadBalancerName:LoadBalancerName,DNSName:DNSName}'"

