##################################################################################
# DATA SOURCES
##################################################################################

# Retreive configuration data from consul
data "consul_keys" "application" {
  key {
    name = "application"
    # Choose the relevant config data based on environment
    path = terraform.workspace == "default" ? "application/configuration/app_info" : "application/configuration/${terraform.workspace}/app_info"
  }

  key {
    name = "common_tags"
    path = "application/configuration/common_tags"
  }
}

# Retreive the networking state data
data "terraform_remote_state" "networking" {
  backend = "consul"

  config = {
    address = "127.0.0.1:8500"
    scheme  = "http"
    # Choose the relevant data based on environment
    path    = terraform.workspace == "default" ? "networking/state/eos" : "networking/state/eos-env:${terraform.workspace}"
  }
}

# Retreive the most up to date aws linux ami ID in the current region
data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-20*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Retreive the most up to date ubuntu ami ID in the current region
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Retreive the most up to date windows server ami ID in the current region
data "aws_ami" "windows" {
  most_recent = true
  owners      = ["801119661308"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}