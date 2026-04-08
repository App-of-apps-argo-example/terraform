terraform {
  backend "s3" {
    bucket         = "app-of-apps-tf-state-1"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "app-of-apps-tf-lock"
    encrypt        = true
  }
}
