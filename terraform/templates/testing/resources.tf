##################################################################################
# CONFIGURATION
##################################################################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.51.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "2.12.0"
    }
  }
}

##################################################################################
# PROVIDERS 
##################################################################################

# AWS provider definition
provider "aws" {
  region = var.region
}

# Consul provider setup using values from variables.tf
provider "consul" {
  address    = "${var.consul_address}:${var.consul_port}"
  datacenter = var.consul_datacenter
}

##################################################################################
# LOCALS
##################################################################################

# Retreive configuration data by decoding json data stored in Consul
# Terraform interprets the json data as the correct terraform data type
locals {
  subnet_count      = 2
  key_name          = jsondecode(data.consul_keys.application.var.application)["key_name"]
  instance_count    = jsondecode(data.consul_keys.application.var.application)["instance_count"]
  instance_type     = jsondecode(data.consul_keys.application.var.application)["instance_type"]

  common_tags = merge(jsondecode(data.consul_keys.application.var.common_tags),
    {
      Environment = terraform.workspace
    }
  )
}

##################################################################################
# RESOURCES      
##################################################################################

# Security Groups #

# Web Server security group 
resource "aws_security_group" "vm-sg" {
  name        = "vm_sg"
  description = "Security group for VMs"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    # Inbound SSH from defined IP range
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ip_range]
  }

  ingress {
    # Allow HTTP from anywhere
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    # Allow all outbound traffic
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = merge(
    local.common_tags,
    {
      Name = "vm-sg"
    }
  )
}
# INSTANCES #

# Windows EC2 instance(s)
resource "aws_instance" "win-vm" {
  count         = local.instance_count
  ami           = data.aws_ami.windows.id
  instance_type = local.instance_type
  key_name      = local.key_name

  # Deploy instance in alternating subnets using the modulo operator
  # Need to find a way to count no. of subnets instead of hard coding the no. 3
  subnet_id = data.terraform_remote_state.networking.outputs.public_subnets[count.index % local.subnet_count]

  security_groups = [aws_security_group.vm-sg.id]

  user_data                   = file("./userdata/userdata_win.ps1")
  associate_public_ip_address = true

  tags = merge(
    local.common_tags,
    {
      Name = "${terraform.workspace}-win-vm${count.index + 1}"
    }
  )
}

# Linux EC2 instance(s)
resource "aws_instance" "linux-vm" {
  count         = local.instance_count
  ami           = data.aws_ami.linux.id
  instance_type = local.instance_type
  key_name      = local.key_name

  # Deploy instance in alternating subnets using the modulo operator
  # Need to find a way to count no. of subnets instead of hard coding the no. 3
  subnet_id = data.terraform_remote_state.networking.outputs.public_subnets[count.index % local.subnet_count]

  security_groups = [aws_security_group.vm-sg.id]

  user_data                   = file("./userdata/userdata_linux.sh")
  associate_public_ip_address = true

  tags = merge(
    local.common_tags,
    {
      Name = "${terraform.workspace}-linux-vm${count.index + 1}"
    }
  )
}

# Ubunutu EC2 instance(s)
resource "aws_instance" "ubuntu-vm" {
  count         = local.instance_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.instance_type
  key_name      = local.key_name

  # Deploy instance in alternating subnets using the modulo operator
  # Need to find a way to count no. of subnets instead of hard coding the no. 3
  subnet_id = data.terraform_remote_state.networking.outputs.public_subnets[count.index % local.subnet_count]

  security_groups = [aws_security_group.vm-sg.id]

  user_data                   = file("./userdata/userdata_ubuntu.sh")
  associate_public_ip_address = true

  tags = merge(
    local.common_tags,
    {
      Name = "${terraform.workspace}-ubuntu-vm${count.index + 1}"
    }
  )
}
