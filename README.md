aws sts assume-role --role-arn *** --role-session-name DevOpsNaNuvem

aws eks update-kubeconfig --region us-west-1 --name devops-na-nuvem-eks-cluster

INFO:aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin 360466417573.dkr.ecr.us-west-1.amazonaws.com
./push.sh
./update.sh

k apply -f kubernetes/backend/deploy.yaml -f kubernetes/frontend/deploy.yaml -f kubernetes/backend/service.yaml -f kubernetes/frontend/service.yaml -f kubernetes/ingress.yaml

k port-forward svc/frontend 8080:80
k port-forward svc/backend 8081:80

k get ec2nodeclass
k get nodepool
k get nodeclaim

k apply -f terraform/main-stack/manifest/nginx.yaml
k scale deployment nginx --replicas=5
k scale deployment nginx --replicas=0
