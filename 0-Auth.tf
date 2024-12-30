# Terraform Setup
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
      configuration_aliases = [ aws.alternate ]
    }
  }
}

# Default Region for AWS.
provider "aws" {
    region = "us-east-1"
  
}


# Set default AWS provider in Tokyo.
provider "aws" {
    alias = "tokyo"
    region = "ap-northeast-1"

}


# Add additional provier confifuration for each region.
provider "aws" {
  alias = "newyork"

  region = "us-east-1"
}


provider "aws" {
    alias = "london"

    region = "eu-west-2"
}

provider "aws" {
    alias = "saopaulo"

    region = "sa-east-1"
}


provider "aws" {
    alias = "australia"

    region = "ap-southeast-2"
  
}

provider "aws" {
    alias = "hongkong"

    region = "ap-east-1"
  
}

provider "aws" {
    alias = "california"

    region = "us-west-1"
}