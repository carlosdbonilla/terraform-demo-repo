# ------------------------------------------------------------------
# PRODUCT TEAM OWNS THIS FILE
# One request. Two platforms. Same guardrails.
# No Python script, no ServiceNow ticket, no waiting.
# ------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  # Runs in HCP Terraform (formerly Terraform Cloud):
  # shared state, locking, run history, secrets kept out of code.
  cloud {
    organization = "carlos-hashicorp-demo"
    workspaces {
      name = "acme-initech-self-service"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Platform 1: AWS. Keys come from HCP Terraform workspace variables, not this file.
provider "aws" {
  region = "us-east-1"
}

# Platform 2: GitHub. Token comes from the GITHUB_TOKEN workspace variable.
provider "github" {
  owner = var.github_owner
}

# ------------------------------------------------------------------
# THE REQUEST: the team fills this in once.
# ------------------------------------------------------------------
locals {
  request = {
    team        = "billing"
    company     = "initech"               # DEMO: change to "initek" -> plan fails
    owner       = "jane.doe@acme.example" # DEMO: change to ""       -> plan fails
    cost_center = "CC-1042"
    environment = "dev"
    #public      = false                   # DEMO: change to true     -> plan fails
  }
}

# The same request goes to both approved modules (written by the platform team).
module "storage" {
  source  = "app.terraform.io/carlos-hashicorp-demo/modules/aws" #AWS
  version = "1.0.0"

  team        = local.request.team
  company     = local.request.company
  owner       = local.request.owner
  cost_center = local.request.cost_center
  environment = local.request.environment
  public      = var.public
}

module "code_repo" {
  source  = "app.terraform.io/carlos-hashicorp-demo/modules/github" #GitHub
  version = "1.0.0"
  

  team        = local.request.team
  company     = local.request.company
  owner       = local.request.owner
  cost_center = local.request.cost_center
  environment = local.request.environment
  public      = var.public
}

output "bucket_name" {
  value = module.storage.bucket_name
}

output "repo_url" {
  value = module.code_repo.repo_url
}
