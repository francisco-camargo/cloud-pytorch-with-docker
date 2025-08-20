variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-west-2"
}

variable "ami_id" {
  description = "Amazon Machine Image ID for the EC2 instance"
  type        = string
  # Default Amazon Linux 2 AMI in us-east-1 - update for your region
  default     = "ami-0abcdef1234567890"  # Generic placeholder
}

variable "instance_type" {
  description = "EC2 instance type to use"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key name for EC2 access"
  type        = string
  default     = "ec2-key"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access (REQUIRED: set to your public IP/32 for security)"
  type        = string
  # No default - forces explicit setting of your IP address

  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "The allowed_ssh_cidr value must be a valid CIDR block."
  }
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the EC2 instance"
  type        = string
}

variable "pytorch_image" {
  description = "PyTorch Docker image to pull on EC2 instance startup"
  type        = string
  default     = "pytorch/pytorch:2.1.2-cuda12.1-cudnn8-runtime"
}
