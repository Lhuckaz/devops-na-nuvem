ECR_URI_BACKEND=$(aws ecr describe-repositories \
  --repository-names devops-na-nuvem/production/backend \
  --region us-west-1 \
  --query 'repositories[0].repositoryUri' \
  --output text)

echo $ECR_URI_BACKEND

ECR_URI_FRONTEND=$(aws ecr describe-repositories \
  --repository-names devops-na-nuvem/production/frontend \
  --region us-west-1 \
  --query 'repositories[0].repositoryUri' \
  --output text)

echo $ECR_URI_FRONTEND

docker build -f apps/backend/YoutubeLiveApp/Dockerfile -t $ECR_URI_BACKEND:v1.0 apps/backend/YoutubeLiveApp

docker build -f apps/frontend/youtube-live-app/Dockerfile -t $ECR_URI_FRONTEND:v1.0 apps/frontend/youtube-live-app

ECR_DOMAIN=$(echo $ECR_URI_BACKEND | cut -d '/' -f1)

aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin $ECR_DOMAIN

docker push $ECR_URI_BACKEND:v1.0

docker push $ECR_URI_FRONTEND:v1.0
