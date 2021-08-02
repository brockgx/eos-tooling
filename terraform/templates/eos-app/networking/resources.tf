##################################################################################
# CONFIGURATION
##################################################################################
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.51.0"
    }
  }
}

##################################################################################
# PROVIDERS 
##################################################################################
provider "aws" {
  region     = var.region
}

##################################################################################
# DATA 
##################################################################################

# Return the list of available AZs in the current region from AWS before provisioning resources
data "aws_availability_zones" "available" {}

##################################################################################
# LOCALS
##################################################################################

# Create a common_tag to tag all resources
locals {

  common_tags = {

  }
}

##################################################################################
# RESOURCES      
##################################################################################

# NETWORKING #

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = "eos-dev-vpc"

  cidr            = var.cidr_block
  azs             = slice(data.aws_availability_zones.available.names, 0, var.subnet_count)
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true

  create_database_subnet_group = false

  tags = local.common_tags
}