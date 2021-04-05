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
    count = 1
    ami = "ami-02baf2b4223a343e8"
    instance_type = "t3.micro"
    tags = {
    Name = "amazon-linux"
  }
}

resource "aws_vpc" "first_vpc" {
    cidr_block = "10.10.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      "Name" = "Prod"
    }
}

resource "aws_subnet" "name" {
    vpc_id     = aws_vpc.first_vpc.id
    cidr_block = "10.10.1.0/24"
    tags = {
    Name = "Prod_subnet"
}
}