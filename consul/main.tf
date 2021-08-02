##################################################################################
# CONFIGURATION
##################################################################################

terraform {
  required_providers {
    consul = {
      source = "hashicorp/consul"
      version = "2.12.0"
    }
  }
}


##################################################################################
# PROVIDERS
##################################################################################

provider "consul" {
  address    = "127.0.0.1:8500"
  datacenter = "dc1"
}

##################################################################################
# RESOURCES
##################################################################################

# Key Paths #

resource "consul_keys" "networking" {
  # Used to hold configuration data
  key {
    path  = "networking/configuration/"
    value = ""
  }

  # Used to store state data
  key {
    path  = "networking/state/"
    value = ""
  }
}

# keys for application config & state data
resource "consul_keys" "application" {

  key {
    path  = "application/configuration/"
    value = ""
  }

  key {
    path  = "application/state/"
    value = ""
  }
}

# Access Control Policies #

resource "consul_acl_policy" "networking" {
  name  = "networking"
  rules = <<-RULE
    key_prefix "networking" {
      policy = "write"
    }

    session_prefix "" {
      policy = "write"
    }
    RULE
}

resource "consul_acl_policy" "application" {
  name  = "application"
  rules = <<-RULE
    key_prefix "application" {
      policy = "write"
    }

    key_prefix "networking/state" {
      policy = "read"
    }

    session_prefix "" {
      policy = "write"
    }

    RULE
}

resource "consul_acl_token" "myron" {
  description = "token for Myron"
  policies    = [consul_acl_policy.networking.name]
}

resource "consul_acl_token" "brock" {
  description = "token for Brock"
  policies    = [consul_acl_policy.application.name]
}

##################################################################################
# OUTPUTS
##################################################################################

output "myron_token_accessor_id" {
  value = consul_acl_token.myron.id
}

output "brock_token_accessor_id" {
  value = consul_acl_token.brock.id
}
