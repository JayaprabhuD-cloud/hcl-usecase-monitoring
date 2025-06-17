terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "terraform-remote-state-bucket-s3-hcl"
    key    = "usecase-11/terraform.tfstate"
    region = "us-east-1" 
    use_lockfile = true   
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
