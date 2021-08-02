##################################################################################
# VARIABLES 
##################################################################################

# aws credentials
# variable "aws_access_key" {}
# variable "aws_secret_key" {}

# # path to the private key
# variable "private_key_path" {}

# # key pair that exists within AWS to SSH into instance
# variable "key_name" {}

# default aws region
variable "region" {
  default = "us-east-1"
}

# No. of subnets to be created
variable "subnet_count" {
  default = 2
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  type = list(any)
}

variable "public_subnets" {
  type = list(any)
}