
locals {
  instance_name        = "LLM-HOST-01-GPU-BNHP"
  vpc_id               = "vpc-0db8c530002af8480"
  subnet_id            = "subnet-092e326c869214c64"
  instance_type        = "g5.2xlarge"
  instance_volume_size = 100
  ssh_keypair_name     = "oren-pc"
  my_ip                = "${chomp(data.http.myip.response_body)}/32"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "LLM_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = local.instance_type
  key_name                    = local.ssh_keypair_name
  associate_public_ip_address = true
  subnet_id   = local.subnet_id

  root_block_device {
    volume_size = local.instance_volume_size
    volume_type = "gp3"
    iops        = 3000
  }

  vpc_security_group_ids = [aws_security_group.LLM_sg.id]

  tags = {
    Name = local.instance_name
  }

  monitoring = true

  metadata_options {
    http_tokens = "required"
  }

  user_data                   = base64encode(file("${path.module}/setup.sh"))
  user_data_replace_on_change = true
}

resource "aws_security_group" "LLM_sg" {
  name        = "${local.instance_name}-sg"
  description = "Security group for LLM inference server"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
    description = "SSH access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
    description = "LLM API access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
    description = "LLM API access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.instance_name}-sg"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "http" "myip" {
  url = "https://checkip.amazonaws.com/"
}

output "instance_public_ip" {
  value = aws_instance.LLM_server.public_ip
}

output "instance_public_dns" {
  value = aws_instance.LLM_server.public_dns
}
