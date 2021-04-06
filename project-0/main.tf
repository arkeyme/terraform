terraform {
  ## https://www.terraform.io/docs/language/settings/backends/s3.html
  backend "s3" {
    bucket = "terra-back-1339"
    key    = "master/terraform.tfstate"
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

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
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

resource "aws_security_group" "allow_ssh" {
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

resource "aws_instance" "example" {
  count = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = "EC2_Tutor"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = join("",[var.instance_name,"-example-",count.index])
  }
}

resource "aws_instance" "web" {
  count = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = "EC2_Tutor"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = join("",[var.instance_name,"-web-",count.index])
  }
}

# ## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
# resource "aws_eip" "lb" {
#   for_each = toset(aws_instance.web.*.id)
#   instance = each.key
#   vpc = true
#   }

resource "aws_eip" "lb" {
  instance = aws_instance.web[0].id
  vpc = true
  }


