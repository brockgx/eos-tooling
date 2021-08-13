##################################################################################
# CONFIGURATION
##################################################################################
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.51.0"
    }
    consul = {
      source = "hashicorp/consul"
      version = "2.12.0"
    }
  }
}

##################################################################################
# PROVIDERS 
##################################################################################

# AWS provider definition
provider "aws" {
  region     = var.region
}

# Consul provider setup using values from variables.tf
provider "consul" {
  address    = "${var.consul_address}:${var.consul_port}"
  datacenter = var.consul_datacenter
}

##################################################################################
# DATA 
##################################################################################

# Return the list of available AZs in the current region from AWS before provisioning resources
data "aws_availability_zones" "available" {}

# Retreive configuration data from consul
data "consul_keys" "networking" {
  key {
    name = "networking"
    # Choose the relevant config data based on environment 
    path = terraform.workspace == "default" ? "networking/configuration/net_info" : "networking/configuration/${terraform.workspace}/net_info"
  }

  key {
    name = "common_tags"
    path = "networking/configuration/common_tags"
  }
}

##################################################################################
# LOCALS
##################################################################################

# Retreive configuration data by decoding json data stored in Consul
# Terraform interprets the json data as the correct terraform data type
locals {
  cidr_block      = jsondecode(data.consul_keys.networking.var.networking)["cidr_block"]
  private_subnets = jsondecode(data.consul_keys.networking.var.networking)["private_subnets"]
  public_subnets  = jsondecode(data.consul_keys.networking.var.networking)["public_subnets"]
  subnet_count    = jsondecode(data.consul_keys.networking.var.networking)["subnet_count"]

  common_tags = merge(jsondecode(data.consul_keys.networking.var.common_tags),
    {
      Environment = terraform.workspace
    }
  )
}

##################################################################################
# RESOURCES      
##################################################################################

# NETWORKING #
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = "eos-${terraform.workspace}-vpc"

  cidr            = local.cidr_block
  azs             = slice(data.aws_availability_zones.available.names, 0, local.subnet_count)
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway = true

  create_database_subnet_group = false

  tags = local.common_tags
}