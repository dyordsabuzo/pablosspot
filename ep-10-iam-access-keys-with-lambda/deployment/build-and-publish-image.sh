#!/bin/bash

set -e

[ -z $AWS_REGION ] && echo "AWS Region not specified" && exit 1


aws_account_id=$(aws sts get-caller-identity --query "Account" --output text)
region=$AWS_REGION
repository=access-key-generator
tag=$(git rev-parse --short HEAD)

image_tag=$aws_account_id.dkr.ecr.$region.amazonaws.com/$repository:$tag

DOCKER_BUILDKIT=1 docker build lambda \
    -f lambda/Dockerfile -t $image_tag

repo=$(aws ecr describe-repositories \
    --query "repositories[?repositoryName == '$repository'].repositoryName" \
    --output text)

if [ -z $repo ]
then
    aws ecr create-repository --repository-name=$repository --region $region
fi

aws ecr get-login-password --region $region \
    | docker login --username AWS \
    --password-stdin $aws_account_id.dkr.ecr.$region.amazonaws.com

docker push $image_tag