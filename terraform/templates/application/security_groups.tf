##################################################################################
# RESOURCES
##################################################################################

# Inbound HTTP security group
resource "aws_security_group" "webapp_http_inbound_sg" {
  name        = "webapp_http_inbound"
  description = "Allow HTTP from Anywhere"

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


  vpc_id = data.terraform_remote_state.networking.outputs.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "webapp-http-inbound-sg"
    }
  )
}

# Inbound SSH from defined IP range
resource "aws_security_group" "webapp_ssh_inbound_sg" {
  name        = "webapp_ssh_inbound"
  description = "Allow SSH from certain ranges"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ip_range]
  }


  vpc_id = data.terraform_remote_state.networking.outputs.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "webapp-ssh-inbound-sg"
    }
  )
}

# Outbound traffic security group
resource "aws_security_group" "webapp_outbound_sg" {
  name        = "webapp_outbound"
  description = "Allow outbound connections"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  vpc_id = data.terraform_remote_state.networking.outputs.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "webapp-outbound-sg"
    }
  )
}

# RDS security group
resource "aws_security_group" "rds_sg" {
  name        = "rds_inbound"
  description = "Allow inbound from web tier"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id


  ingress {
    // Allows traffic from the SG itself
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    // Allow traffic for TCP 3306
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.webapp_http_inbound_sg.id]
  }

  // Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "rds-sg"
    }
  )
}