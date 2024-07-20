terraform {

  cloud {
    organization = "abnormalend-terraform"
    workspaces {
      name = "signalbot-develop"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.59.0"
    }
  }
  required_version = "~> 1.5.7"
}