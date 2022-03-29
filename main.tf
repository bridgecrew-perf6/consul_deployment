terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.49.0"
    }
  }
}

provider "aws" {
  region = var.aws_default_region
}

# filter out wavelength zones
data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "group-name"
    values = ["us-east-1"]
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "consul_vpc" {
  id = aws_vpc.consul.id
}

# data source for subnet ids in VPC
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.consul_vpc.id
}