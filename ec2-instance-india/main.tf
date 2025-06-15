########################################
#           PROVIDER BLOCK             #
########################################

# AWS provider: set region and profile (customizable)
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

########################################
#          VARIABLE DEFINITIONS        #
########################################

# All variables that you can/should customize start with custom_
variable "aws_profile" {
  description = "The AWS CLI profile name to use"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "ap-south-1" # Mumbai
}

variable "ssh_public_key_path" {
  description = "Path to your SSH public key file"
  type        = string
}

variable "admin_ip" {
  description = "Your public IP for SSH/RDP access (format: x.x.x.x)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

########################################
#         DATA SOURCE: UBUNTU AMI      #
########################################

# Latest official Ubuntu 22.04 LTS AMI from Canonical
data "aws_ami" "ec2_image" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

########################################
#     EC2 SSH KEY PAIR RESOURCE        #
########################################

# Register your SSH public key (customize both resource name and AWS name)
resource "aws_key_pair" "ec2_instance_ssh_key" {
  key_name   = "ec2-instance-ssh-key"              # Shows in AWS
  public_key = file(var.ssh_public_key_path)       # Reference variable above
}

########################################
#       SECURITY GROUP RESOURCE        #
########################################

# Security group allowing SSH/RDP from your IP only (customize as needed)
resource "aws_security_group" "ec2_linux_instance_sg" {
  name        = "ec2-linux-instance-sg"
  description = "Security group for EC2 Linux instance (SSH & RDP from admin IP)"

  ingress {
    description = "SSH from admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_ip}/32"]
  }

  ingress {
    description = "RDP from admin IP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_ip}/32"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################################
#         EC2 INSTANCE RESOURCE        #
########################################

resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.ec2_image.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ec2_instance_ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_linux_instance_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y xfce4 xfce4-goodies xrdp firefox
              sudo systemctl enable xrdp
              sudo systemctl start xrdp
              echo 'ubuntu:SecurePassw0rd!' | sudo chpasswd
              EOF

  tags = {
    Name    = "IndiaEC2Instance"
    Purpose = "Browser access for Youtube Premium in India"
  }
}

########################################
#              OUTPUTS                 #
########################################

output "india_ec2_instance_public_ip" {
  description = "Public IP address of the India EC2 instance"
  value       = aws_instance.ec2_instance.public_ip
}
