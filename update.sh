#!/usr/bin/env bash

FILE="kubernetes/ingress.yaml"
FILE_GITOPS="../gitops/ingress.yml"
VPC_NAME="devops-na-nuvem-vpc"
REGION="us-west-1"

# Get VPC ID from its Name tag
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=${VPC_NAME}" \
  --query "Vpcs[0].VpcId" \
  --region "$REGION" \
  --output text)

echo "VPC ID: $VPC_ID"

# Get public subnet IDs (you can adjust the filter if you tag them differently)
SUBNETS=$(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=${VPC_ID}" "Name=tag:Name,Values=*public*" \
  --query "Subnets[*].SubnetId" \
  --region "$REGION" \
  --output text | tr '\t' ',')

echo "Using subnets: $SUBNETS"

if [[ -z "$SUBNETS" ]]; then
  echo "No public subnets found for VPC: $VPC_NAME"
  exit 1
fi

echo "Using public subnets: $SUBNETS"

# === UPDATE ingress.yaml ===
sed -i -E "s|(alb.ingress.kubernetes.io/subnets: ).*|\1$SUBNETS|" "$FILE"

sed -i -E "s|(alb.ingress.kubernetes.io/subnets: ).*|\1$SUBNETS|" "$FILE_GITOPS"

echo "Updated $FILE with public subnets: $SUBNETS"