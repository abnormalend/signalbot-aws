provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = var.env
      Project     = "signalbotv2"
    }
  }
}

provider "pypi" {
  # Configuration options
}