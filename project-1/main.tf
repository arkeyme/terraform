terraform {
  backend "s3" {
    bucket = "terra-back-1488"
    key    = "project-1/terraform.tfstate"
    region = "eu-north-1"
    dynamodb_table = "terraform_lock"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}
provider "aws" {
  profile = "default"
  region  = "eu-north-1"
}

resource "aws_instance" "web" {
    count = 3
    ami = "ami-02baf2b4223a343e8"
    instance_type = "t3.micro"
    tags = {
    Name = "amazon-linux"
  }
}