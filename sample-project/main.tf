terraform {
  backend "s3" {
    bucket         = "terra-back-1339"
    key            = "project-vpc-1/terraform.tfstate"
    region         = "eu-north-1"
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
  region  = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "first_vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name" = "wordpress-vpc-1"
  }
}

resource "aws_internet_gateway" "gw1" {
  vpc_id = aws_vpc.first_vpc.id
  tags = {
    Name = "gw1"
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

resource "aws_subnet" "sbnt-vpc1" {
  vpc_id            = aws_vpc.first_vpc.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "prod-sbnt-1"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.sbnt-vpc1.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_security_group" "allow_1" {
  name        = "allow_1"
  description = "Allow web and ssh inbound traffic"
  vpc_id      = aws_vpc.first_vpc.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
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
    Name = "allow_1"
  }
}

resource "aws_network_interface" "web_server_nic" {
  subnet_id       = aws_subnet.sbnt-vpc1.id
  private_ips     = ["10.1.1.15"]
  security_groups = [aws_security_group.allow_1.id]
}

resource "aws_eip" "one" {
  vpc               = true
  network_interface = aws_network_interface.web_server_nic.id
  depends_on        = [aws_internet_gateway.gw1]
}


resource "aws_instance" "web-1" {
  count                  = 1
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = "EC2_tutor"
  availability_zone      = data.aws_availability_zones.available.names[0]
  user_data              = file("install_apache.sh")
  network_interface {
    network_interface_id = aws_network_interface.web_server_nic.id
    device_index         = 0
  }
  tags = {
    Name = "web-1"
  }
}

output "instance_web-1_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web-1[0].public_ip
}
