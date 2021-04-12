terraform {
  backend "s3" {
    bucket = "terra-back-1339"
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
  region  = "eu-west-1"
}

resource "aws_vpc" "first_vpc" {
    cidr_block = "10.1.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      "Name" = "wordpress-vpc-1"
    }
}

resource "aws_vpc" "second_vpc" {
    cidr_block = "10.2.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      "Name" = "wordpress-vpc-2"
    }
}

resource "aws_subnet" "sbnt-vpc1" {
    vpc_id     = aws_vpc.first_vpc.id
    cidr_block = "10.1.1.0/24"
    availability_zone = data.aws_availability_zones.available.names[0]
    tags = {
    Name = "wordpress-sbnt-1"
}
}

resource "aws_subnet" "sbnt-vpc2" {
    vpc_id     = aws_vpc.second_vpc.id
    availability_zone = data.aws_availability_zones.available.names[1]
    cidr_block = "10.2.2.0/24"
    tags = {
    Name = "wordpress-sbnt-2"
}
}

resource "aws_internet_gateway" "gw1" {
    vpc_id = aws_vpc.first_vpc.id
    tags = {
    Name = "gw1"
  }
}

resource "aws_internet_gateway" "gw2" {
    vpc_id = aws_vpc.second_vpc.id
    tags = {
    Name = "gw2"
  }
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.first_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw1.id
  }
  tags = {
    Name = "rt1"
  }
}

resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.second_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw2.id
  }
  tags = {
    Name = "rt2"
  }
}

resource "aws_route_table_association" "a" {
    subnet_id      = aws_subnet.sbnt-vpc1.id
    route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "b" {
    subnet_id      = aws_subnet.sbnt-vpc2.id
    route_table_id = aws_route_table.rt2.id
}