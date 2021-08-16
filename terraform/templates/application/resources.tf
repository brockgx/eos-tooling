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
  subnet_count      = 3
  key_name          = jsondecode(data.consul_keys.application.var.application)["key_name"]
  instance_count    = jsondecode(data.consul_keys.application.var.application)["instance_count"]
  instance_type     = jsondecode(data.consul_keys.application.var.application)["instance_type"]
  rds_storage_size  = jsondecode(data.consul_keys.application.var.application)["rds_storage_size"]
  rds_engine        = jsondecode(data.consul_keys.application.var.application)["rds_engine"]
  rds_version       = jsondecode(data.consul_keys.application.var.application)["rds_version"]
  rds_instance_size = jsondecode(data.consul_keys.application.var.application)["rds_instance_size"]
  rds_multi_az      = jsondecode(data.consul_keys.application.var.application)["rds_multi_az"]
  rds_db_name       = jsondecode(data.consul_keys.application.var.application)["rds_db_name"]

  common_tags = merge(jsondecode(data.consul_keys.application.var.common_tags),
    {
      Environment = terraform.workspace
    }
  )
}

##################################################################################
# RESOURCES      
##################################################################################

# Elastic Load Balancer
resource "aws_elb" "app-elb" {
  name            = "app-elb-${terraform.workspace}"
  security_groups = [aws_security_group.webapp_http_inbound_sg.id]
  subnets         = data.terraform_remote_state.networking.outputs.public_subnets

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:80"
    interval            = 10
  }

  # Use the splat operator (*) to retreive a list of instance IDs 
  instances = aws_instance.web-server[*].id

  tags = local.common_tags
}

# Public dns of elastic load balancer
output "aws_elb_public_dns" {
  value = aws_elb.app-elb.dns_name
}

# INSTANCES #
resource "aws_instance" "web-server" {
  count         = local.instance_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.instance_type
  key_name      = local.key_name

  # Deploy instance in alternating subnets using the modulo operator
  # Need to find a way to count no. of subnets instead of hard coding the no. 3
  subnet_id = data.terraform_remote_state.networking.outputs.public_subnets[count.index % subnet_count]

  security_groups = [
    aws_security_group.webapp_http_inbound_sg.id,
    aws_security_group.webapp_ssh_inbound_sg.id,
    aws_security_group.webapp_outbound_sg.id,
  ]

  user_data                   = file("./userdata/userdata.sh")
  associate_public_ip_address = true

  tags = merge(
    local.common_tags,
    {
      Name = "${terraform.workspace}-web-server${count.index + 1}"
    }
  )
}

## Database Config
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${terraform.workspace}rds-subnet-group"
  subnet_ids = data.terraform_remote_state.networking.outputs.private_subnets
}

resource "aws_db_instance" "rds" {
  identifier             = "${terraform.workspace}-eos-rds"
  allocated_storage      = local.rds_storage_size
  engine                 = local.rds_engine
  engine_version         = local.rds_version
  instance_class         = local.rds_instance_size
  multi_az               = local.rds_multi_az
  name                   = "${terraform.workspace}${local.rds_db_name}"
  username               = var.rds_username
  password               = var.rds_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true

  tags = local.common_tags
}
