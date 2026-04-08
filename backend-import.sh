#!/bin/bash
aws s3api head-bucket --bucket app-of-apps-tf-state-1 2>/dev/null || aws s3api create-bucket --bucket app-of-apps-tf-state-1 --region eu-central-1 --create-bucket-configuration LocationConstraint=eu-central-1
aws dynamodb describe-table --table-name app-of-apps-tf-lock 2>/dev/null || aws dynamodb create-table --table-name app-of-apps-tf-lock --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region eu-central-1

cat <<BACKEND > backend.tf
terraform {
  backend "s3" {
    bucket         = "app-of-apps-tf-state-1"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "app-of-apps-tf-lock"
    encrypt        = true
  }
}
BACKEND
