#!/bin/bash

# Set your region
REGION="us-east-2"

echo " Auditing AWS Resources in region: $REGION"
echo "--------------------------------------------------"

# EC2 Instances
echo -e "\n EC2 Instances:"
aws ec2 describe-instances --region $REGION \
  --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name,Tags[?Key==`Name`].Value|[0]]' \
  --output table

# EBS Volumes
echo -e "\n EBS Volumes:"
aws ec2 describe-volumes --region $REGION \
  --query 'Volumes[].[VolumeId,Size,State,VolumeType]' \
  --output table

# Elastic Load Balancers
echo -e "\n ELBs (Classic):"
aws elb describe-load-balancers --region $REGION \
  --query 'LoadBalancerDescriptions[].[LoadBalancerName,DNSName]' \
  --output table

echo -e "\n ELBs (Application/Network):"
aws elbv2 describe-load-balancers --region $REGION \
  --query 'LoadBalancers[].[LoadBalancerName,DNSName,Type,State.Code]' \
  --output table

# RDS Instances
echo -e "\n RDS Instances:"
aws rds describe-db-instances --region $REGION \
  --query 'DBInstances[].[DBInstanceIdentifier,DBInstanceClass,Engine,DBInstanceStatus]' \
  --output table

# S3 Buckets (with region hint)
echo -e "\n S3 Buckets:"
aws s3api list-buckets --query 'Buckets[].Name' --output text | tr '\t' '\n' | while read bucket; do
  region=$(aws s3api get-bucket-location --bucket "$bucket" --query 'LocationConstraint' --output text)
  echo " - $bucket (Region: ${region:-us-east-1})"
done

# CloudWatch Alarms
echo -e "\n CloudWatch Alarms:"
aws cloudwatch describe-alarms --region $REGION \
  --query 'MetricAlarms[].[AlarmName,StateValue,Namespace,MetricName]' \
  --output table

# Lambda Functions
echo -e "\n Lambda Functions:"
aws lambda list-functions --region $REGION \
  --query 'Functions[].[FunctionName,Runtime,MemorySize,Timeout]' \
  --output table

# ECR Repositories
echo -e "\n ECR Repositories:"
aws ecr describe-repositories --region $REGION \
  --query 'repositories[].[repositoryName,repositoryUri]' \
  --output table

# ECS Clusters & Services
echo -e "\n ECS Clusters & Services:"
CLUSTERS=$(aws ecs list-clusters --region $REGION --query 'clusterArns' --output text)
for cluster in $CLUSTERS; do
  echo -e "\nCluster: $cluster"
  aws ecs list-services --cluster $cluster --region $REGION --output table
done

# IAM Users (costs tied to their use, not existence)
echo -e "\n IAM Users:"
aws iam list-users --query 'Users[].[UserName,CreateDate]' --output table

echo -e "\n Audit Complete."
