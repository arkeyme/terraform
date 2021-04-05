terraform {
  ## https://www.terraform.io/docs/language/settings/backends/s3.html
  backend "s3" {
    bucket = "terra-back-1488"
    key    = "project-1/terraform.tfstate"
    region = "eu-north-1"
    ## https://www.terraform.io/docs/language/settings/backends/s3.html#dynamodb-state-locking
    dynamodb_table = "terraform_lock"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}
