#!/usr/bin/env bash

# This script will generate a text report for all security groups that have wide open ingress rules that can be imported into Excel
# Columns include Security Group ID, Group Name, Description, VPC ID, From Port, To Port, Protocol, Instance ID

IFS=$'\n'

#aws ec2 describe-security-groups --filters Name=ip-permission.cidr,Values='0.0.0.0/0' --query "SecurityGroups[].GroupId" | jq -r '.[]' > sgGroupIds.txt
#aws ec2 describe-security-groups --filters Name=ip-permission.cidr,Values='0.0.0.0/0' --profile ops --region us-west-2 --query "SecurityGroups[].[GroupId,GroupName,Description,VpcId]" --output text > sgGroups.txt

for SGITEM in $(cat sgGroups.txt)
do
    SGID=$(echo ${SGITEM} | awk '{print $1}')
    FROMPORT=$(aws ec2 describe-security-groups --group-ids ${SGID} --filters Name=ip-permission.cidr,Values='0.0.0.0/0' --query "SecurityGroups[].IpPermissions[].[FromPort]" --output text)
    TOPORT=$(aws ec2 describe-security-groups --group-ids ${SGID} --filters Name=ip-permission.cidr,Values='0.0.0.0/0' --query "SecurityGroups[].IpPermissions[].[ToPort]" --output text)
    PROTOCOL=$(aws ec2 describe-security-groups --group-ids ${SGID} --filters Name=ip-permission.cidr,Values='0.0.0.0/0' --query "SecurityGroups[].IpPermissions[].[IpProtocol]" --output text)
    EC2INSTID=$(aws ec2 describe-instances --filters Name=instance.group-id,Values="${SGID}" --query "Reservations[].Instances[].[InstanceId]" --output text)
    #paste <(printf "%s\n" "${SGITEM[@]}") <(printf "%s\n" "${FROMPORT[@]}") <(printf "%s\n" "${TOPORT[@]}") <(printf "%s\n" "${PROTOCOL[@]}") <(printf "%s\n" "${EC2INSTID[@]}")
    #printf "%s\n" "${SGITEM[@]}") <(printf "%s\n" "${FROMPORT[@]}") <(printf "%s\n" "${TOPORT[@]}") <(printf "%s\n" "${PROTOCOL[@]}") <(printf "%s\n" "${EC2INSTID[@]}"
    echo "SGID: ${SGID}\nFROMPORT: ${FROMPORT}\nTOPORT: ${TOPORT} \nPROTOCOL: ${PROTOCOL}\nEC2INSTID: ${EC2INSTID}"

done