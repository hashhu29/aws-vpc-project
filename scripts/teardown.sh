#!/bin/bash
set -e

VPC_ID="vpc-038c0a26e5e7bd4c9"
IGW_ID="igw-06a00d7fdc6a976d8"
PUBLIC_SUBNET_ID="subnet-078fa8b70a795e04d"
PRIVATE_SUBNET_ID="subnet-018c97e756a959537"
PUBLIC_RT_ID="rtb-0b13b276c4629f606"
PRIVATE_RT_ID="rtb-065db965d41e0bbed"
NAT_GW_ID="nat-00970afbec7d16d54"
EIP_ID="eipalloc-0b0446b707b37767d"
PUBLIC_EC2_ID="i-0e35d0c6f6132540d"
PRIVATE_EC2_ID="i-0f3f8a9c3d0c1053e"
PUBLIC_SG_ID="sg-02cfad3b71c676ffa"
PRIVATE_SG_ID="sg-0024a3bff2324429d"

echo "Terminating EC2 instances"
aws ec2 terminate-instances --instance-ids $PUBLIC_EC2_ID $PRIVATE_EC2_ID
echo "Waiting for instances to terminate..."
aws ec2 wait instance-terminated --instance-ids $PUBLIC_EC2_ID $PRIVATE_EC2_ID

echo "Deleting NAT Gateway"
aws ec2 delete-nat-gateway --nat-gateway-id $NAT_GW_ID
echo "Waiting for NAT Gateway to delete..."
aws ec2 wait nat-gateway-deleted --nat-gateway-ids $NAT_GW_ID

echo "Releasing EIP"
aws ec2 release-address --allocation-id $EIP_ID

echo "Detaching Internet Gateway"
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID

echo "Deleting route tables"
aws ec2 delete-route-table --route-table-id $PUBLIC_RT_ID
aws ec2 delete-route-table --route-table-id $PRIVATE_RT_ID

echo "Deleting subnets"
aws ec2 delete-subnet --subnet-id $PUBLIC_SUBNET_ID
aws ec2 delete-subnet --subnet-id $PRIVATE_SUBNET_ID

echo "Deleting security groups"
aws ec2 delete-security-group --group-id $PUBLIC_SG_ID
aws ec2 delete-security-group --group-id $PRIVATE_SG_ID

echo "Deleting VPC"
aws ec2 delete-vpc --vpc-id $VPC_ID

echo "=============================="
echo "All resources deleted!"
echo "=============================="