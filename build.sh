#!/bin/bash

# Build and push script for large ECR test image
ECR_REGISTRY="359181413314.dkr.ecr.us-east-1.amazonaws.com"
REPO_NAME="large-test-image"
IMAGE_TAG="latest"

echo "Building large test image..."
docker build -t ${REPO_NAME}:${IMAGE_TAG} .

echo "Tagging for ECR..."
docker tag ${REPO_NAME}:${IMAGE_TAG} ${ECR_REGISTRY}/${REPO_NAME}:${IMAGE_TAG}

echo "Authenticating with ECR..."
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin ${ECR_REGISTRY}

echo "Creating ECR repository if it doesn't exist..."
aws ecr create-repository --repository-name ${REPO_NAME} --region <region> 2>/dev/null || true

echo "Pushing to ECR..."
docker push ${ECR_REGISTRY}/${REPO_NAME}:${IMAGE_TAG}

echo "Image size:"
docker images ${REPO_NAME}:${IMAGE_TAG} --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

