#!/usr/bin/env bash

echo "=== Ansible ==="
helm uninstall aws-load-balancer-controller -n kube-system
kubectl delete sa aws-load-balancer-controller -n kube-system
helm repo remove eks
eksctl delete iamserviceaccount \
  --cluster devops-na-nuvem-eks-cluster \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --region us-west-1
aws iam delete-policy \
  --policy-arn arn:aws:iam::360466417573:policy/AWSLoadBalancerControllerIAMPolicy

echo "=== Kubernetes ==="
kubectl delete -f kubernetes/