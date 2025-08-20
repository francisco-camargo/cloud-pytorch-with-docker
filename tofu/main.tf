# main.tf
# This file defines the core AWS infrastructure for the PyTorch EC2 deployment.
# Creates an EC2 instance with Docker and PyTorch container pre-installed via user_data script.

# EC2 instance resource - creates the virtual machine in AWS
resource "aws_instance" "pytorch" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.pytorch.id]
  subnet_id              = var.subnet_id

  # User data script - runs on instance startup to install Docker and pull PyTorch image
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -a -G docker ec2-user
    docker pull ${var.pytorch_image}
  EOF

  tags = {
    Name = "PyTorch-EC2"
  }
}

# Security group - defines firewall rules for the EC2 instance
resource "aws_security_group" "pytorch" {
  name_prefix = "pytorch-sg-"  # Use name_prefix to avoid conflicts
  description = "Security group for PyTorch EC2 instance"

  # SSH access - allows remote terminal connection (restrict to your IP!)
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Outbound internet access - allows downloading Docker images and packages
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pytorch-security-group"
  }
}

# Output the public IP address of the created instance
output "instance_public_ip" {
  description = "Public IP address of the PyTorch EC2 instance"
  value       = aws_instance.pytorch.public_ip
}
