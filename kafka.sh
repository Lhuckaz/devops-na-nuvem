#!/usr/bin/env bash

k create ns kafka

k create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka

aws eks describe-addons-versions --addon-name aws-ebs-csi-driver

eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster devops-na-nuvem-eks-cluster \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --role-only \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve

arn_role=$(aws iam get-role --role-name AmazonEKS_EBS_CSI_DriverRole --query 'Role.Arn' --output text)

eksctl utils describe-addons-versions --kubernetes-version 1.34 | grep csi

eksctl create addon \
  --name aws-ebs-csi-driver \
  --cluster devops-na-nuvem-eks-cluster \
  --service-account-role-arn ${arn_role} \
  --region us-west-1 \
  --version latest \
  --force

k get po -n kube-system | grep ebs-csi

k get po -n kafka

k apply -f strimzi/manifests/kafka-cluster.yml -f strimzi/manifests/kafka.controller.yml -f strimzi/manifests/kafka.broker.yml -n kafka

k get kafkanodepool -n kafka

k get kafka -n kafka

k get po -n kafka

k get svc -n kafka

#TODO: substitute the IP address with the one from the above command



ECR_URI_CONSUMER=$(aws ecr describe-repositories \
  --repository-names devops-na-nuvem/strimzi/consumer \
  --region us-west-1 \
  --query 'repositories[0].repositoryUri' \
  --output text)

echo $ECR_URI_CONSUMER

ECR_URI_PRODUCER=$(aws ecr describe-repositories \
  --repository-names devops-na-nuvem/strimzi/producer \
  --region us-west-1 \
  --query 'repositories[0].repositoryUri' \
  --output text)

echo $ECR_URI_PRODUCER

docker build -f strimzi/node-api-consumer/Dockerfile -t $ECR_URI_CONSUMER:v2.0 strimzi/node-api-consumer

docker build -f strimzi/node-api-producer/Dockerfile -t $ECR_URI_PRODUCER:v2.0 strimzi/node-api-producer

ECR_DOMAIN=$(echo $ECR_URI_BACKEND | cut -d '/' -f1)

aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin $ECR_DOMAIN

docker push $ECR_URI_CONSUMER:v2.0

docker push $ECR_URI_PRODUCER:v2.0

#TODO: Substituir imagem no consumer.yml e no producer.yml

k apply -f strimzi/manifests/consumer.yml -f strimzi/manifests/producer.yml -n kafka

k get po -n kafka | grep consumer

k get pvc -n kafka

k get pv

# Check in your AWS Account

k run nginx --image=nginx

k get po -n kafka -o wide

#TODO: Get ip from producer pod
ip_producer=$(k get po -n kafka -o wide | grep producer | awk '{print $6}')
ip_consumer=$(k get po -n kafka -o wide | grep consumer | awk '{print $6}')

k exec -it nginx -- curl -X POST -H 'Content-Type: application/json' -d '{"topic": "devops-topic", "message": "Hello World"}' http://${ip_producer}:3000/send

k exec -it nginx -- curl -X GET -H 'Content-Type: application/json' http://${ip_consumer}:3000/consume?topic=devops-topic

consumer_pod_name=$(k get po -n kafka | grep consumer | awk '{print $1}')
k logs -n kafka -f $consumer_pod_name

#Mande outras mensagens e monitore no log
