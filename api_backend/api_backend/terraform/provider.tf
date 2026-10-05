terraform {
  backend "s3" {
    bucket       = "api-backend-terraform-state-750390205856"
    key          = "api-backend/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}