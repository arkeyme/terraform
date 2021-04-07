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
  region  = "eu-north-1"
}

resource "aws_security_group" "allow_ssh_for_proj_1" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_instance" "web" {
    count = 1
    ami = "ami-02baf2b4223a343e8"
    instance_type = "t3.micro"
    key_name = "EC2_Tutor"
    vpc_security_group_ids = [aws_security_group.allow_ssh_for_proj_1.id]
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

resource "aws_subnet" "sbnt" {
    vpc_id     = aws_vpc.first_vpc.id
    cidr_block = "10.10.1.0/24"
    tags = {
    Name = "Prod_subnet"
}
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.first_vpc.id
    tags = {
    Name = "gw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.first_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "rt"
  }
}

resource "aws_route_table_association" "a" {
    subnet_id      = aws_subnet.sbnt.id
    route_table_id = aws_route_table.rt.id
}

resource "aws_eip" "lb" {
  instance = aws_instance.web[0].id
  vpc = true
}


