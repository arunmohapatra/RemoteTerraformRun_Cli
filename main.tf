terraform {
  required_version = ">= 1.6.0"

  cloud {

    organization = "LTC_Terraform_Cohort"

    workspaces {
      name = "RemoteTerraformRun_Cli"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

}

provider "aws" {
  region = var.aws_region
}


# --------------------------------------------------
# Default VPC
# --------------------------------------------------

data "aws_vpc" "default" {
  default = true
}


# --------------------------------------------------
# Select ONE subnet
# --------------------------------------------------

data "aws_subnet" "default" {

  availability_zone = var.availability_zone

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# --------------------------------------------------
# Amazon Linux 2023 AMI
# --------------------------------------------------

data "aws_ami" "amazon_linux" {

  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# --------------------------------------------------
# EC2 Instance
# --------------------------------------------------

resource "aws_instance" "linux_ec2" {

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id = data.aws_subnet.default.id

  associate_public_ip_address = true

  tags = {
    Name      = "LTC-HYD-Linux-EC2"
    Project   = "LTC_HYD_PROJECT"
    ManagedBy = "Terraform"
    # This is the new tag added
    This_is   = "LTC"
  }
}


