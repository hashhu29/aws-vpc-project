#!/bin/bash
set -e

VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=my-first-vpc" \
  --query 'Vpcs[0].VpcId' \
  --output text)
echo "VPC: $VPC_ID"

IGW_ID=$(aws ec2 describe-internet-gateways \
  --filters "Name=tag:Name,Values=my-igw" \
  --query 'InternetGateways[0].InternetGatewayId' \
  --output text)
echo "IGW: $IGW_ID"

NAT_GW_ID=$(aws ec2 describe-nat-gateways \
  --filter "Name=tag:Name,Values=my-nat-gw" \
  --query 'NatGateways[0].NatGatewayId' \
  --output text)
echo "NAT Gateway: $NAT_GW_ID"

EIP_ID=$(aws ec2 describe-addresses \
  --query 'Addresses[?Domain==`vpc`].AllocationId' \
  --output text)
echo "EIP: $EIP_ID"

PUBLIC_SUBNET_ID=$(aws ec2 describe-subnets \
  --filters "Name=tag:Name,Values=public-subnet" \
  --query 'Subnets[0].SubnetId' \
  --output text)
echo "Public Subnet: $PUBLIC_SUBNET_ID"

PRIVATE_SUBNET_ID=$(aws ec2 describe-subnets \
  --filters "Name=tag:Name,Values=private-subnet" \
  --query 'Subnets[0].SubnetId' \
  --output text)
echo "Private Subnet: $PRIVATE_SUBNET_ID"

PUBLIC_RT_ID=$(aws ec2 describe-route-tables \
  --filters "Name=tag:Name,Values=public-rt" \
  --query 'RouteTables[0].RouteTableId' \
  --output text)
echo "Public RT: $PUBLIC_RT_ID"

PRIVATE_RT_ID=$(aws ec2 describe-route-tables \
  --filters "Name=tag:Name,Values=private-rt" \
  --query 'RouteTables[0].RouteTableId' \
  --output text)
echo "Private RT: $PRIVATE_RT_ID"

PUBLIC_SG_ID=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=public-sg" \
            "Name=vpc-id,Values=$VPC_ID" \
  --query 'SecurityGroups[0].GroupId' \
  --output text)
echo "Public SG: $PUBLIC_SG_ID"

PRIVATE_SG_ID=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=private-sg" \
            "Name=vpc-id,Values=$VPC_ID" \
  --query 'SecurityGroups[0].GroupId' \
  --output text)
echo "Private SG: $PRIVATE_SG_ID"

PUBLIC_EC2_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=public-ec2" \
            "Name=instance-state-name,Values=running" \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text)
echo "Public EC2: $PUBLIC_EC2_ID"

PRIVATE_EC2_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=private-ec2" \
            "Name=instance-state-name,Values=running" \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text)
echo "Private EC2: $PRIVATE_EC2_ID"

PUBLIC_RT_ASSOC=$(aws ec2 describe-route-tables \
  --filters "Name=tag:Name,Values=public-rt" \
  --query 'RouteTables[0].Associations[0].RouteTableAssociationId' \
  --output text)

PRIVATE_RT_ASSOC=$(aws ec2 describe-route-tables \
  --filters "Name=tag:Name,Values=private-rt" \
  --query 'RouteTables[0].Associations[0].RouteTableAssociationId' \
  --output text)



echo "Terminating EC2 instances"
aws ec2 terminate-instances --instance-ids $PUBLIC_EC2_ID $PRIVATE_EC2_ID
aws ec2 wait instance-terminated --instance-ids $PUBLIC_EC2_ID $PRIVATE_EC2_ID

echo "Deleting NAT Gateway"
aws ec2 delete-nat-gateway --nat-gateway-id $NAT_GW_ID
aws ec2 wait nat-gateway-deleted --nat-gateway-ids $NAT_GW_ID

echo "Releasing Elastic IP"
aws ec2 release-address --allocation-id $EIP_ID

echo "Detaching and deleting IGW"
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID

echo "Disassociating and deleting route tables"
aws ec2 disassociate-route-table --association-id $PUBLIC_RT_ASSOC
aws ec2 disassociate-route-table --association-id $PRIVATE_RT_ASSOC
aws ec2 delete-route-table --route-table-id $PUBLIC_RT_ID
aws ec2 delete-route-table --route-table-id $PRIVATE_RT_ID

echo "Deleting subnets"
aws ec2 delete-subnet --subnet-id $PUBLIC_SUBNET_ID
aws ec2 delete-subnet --subnet-id $PRIVATE_SUBNET_ID

echo "Deleting security groups"
aws ec2 delete-security-group --group-id $PRIVATE_SG_ID
aws ec2 delete-security-group --group-id $PUBLIC_SG_ID

echo "Deleting VPC"
aws ec2 delete-vpc --vpc-id $VPC_ID

echo "=============================="
echo "All resources deleted!"
echo "=============================="