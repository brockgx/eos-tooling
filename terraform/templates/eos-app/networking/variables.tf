##################################################################################
# VARIABLES 
##################################################################################

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