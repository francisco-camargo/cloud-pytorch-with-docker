# outputs.tf
# This file defines the outputs that will be displayed after Terraform deployment.
# These values help you connect to and use the deployed infrastructure.

output "instance_id" {
  description = "ID of the PyTorch EC2 instance"
  value       = aws_instance.pytorch.id
}

output "public_ip" {
  description = "Public IP address of the PyTorch EC2 instance"
  value       = aws_instance.pytorch.public_ip
  sensitive   = true  # Set to true if you want to hide IP from logs
}

output "ssh_command" {
  description = "Command to SSH into the PyTorch instance"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.pytorch.public_ip}"
  sensitive   = true   # Set to true to hide SSH command from logs for security
}

output "security_group_id" {
  description = "ID of the created security group"
  value       = aws_security_group.pytorch.id
}

output "pytorch_image" {
  description = "PyTorch Docker image that was pre-pulled on the instance"
  value       = var.pytorch_image
}
