# Cloud PyTorch with Docker

## Minimal EC2 PyTorch Setup (Proof of Concept)

**Goal**: Launch a single EC2 instance, run a PyTorch container, execute `train_mnist.py`. Nothing else.

### Step 1: Build Container Locally

```bash
docker build -t pytorch-app ./docker
docker run --rm pytorch-app python train_mnist.py  # Test locally first
```

### Step 2: Create OpenTofu Configuration

**`provider.tf`**

```hcl
provider "aws" {
  region = "us-east-1"
}
```

**`main.tf`**

```hcl
# Use default VPC (no custom networking needed)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security group: SSH only
resource "aws_security_group" "pytorch" {
  name_prefix = "pytorch-sg"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict this in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance
resource "aws_instance" "pytorch" {
  ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2 (us-east-1)
  instance_type = "t3.medium"              # Cheap for testing, upgrade to g4dn.xlarge for GPU

  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.pytorch.id]
  associate_public_ip_address = true

  key_name = "pytorch-key"  # Create this key pair manually in AWS console

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -a -G docker ec2-user

    # Pull and run your container
    docker pull pytorch/pytorch:2.1.2-cuda12.1-cudnn8-runtime
  EOF

  tags = {
    Name = "pytorch-dev"
  }
}

output "instance_ip" {
  value = aws_instance.pytorch.public_ip
}
```

### Step 3: Deploy

```bash
cd terraform/
tofu init
tofu apply
```

### Step 4: Connect and Run

```bash
# SSH into instance
ssh -i pytorch-key.pem ec2-user@<instance-ip>

# Run your PyTorch code
docker run --rm -v /tmp:/workspace \
  pytorch/pytorch:2.1.2-cuda12.1-cudnn8-runtime \
  python -c "import torch; print(f'PyTorch version: {torch.__version__}')"
```

**That's it.** Single EC2 instance, pre-built PyTorch image, minimal AWS services.

## If You Want GPU (Optional)

- Change instance type to `g4dn.xlarge`
- Use Deep Learning AMI: `ami-0c94855ba95b798c7`
- Add `--gpus all` to docker run command

## Local Development

For local development while iterating:

### VSCode Integration

```json
// .devcontainer/devcontainer.json
{
  "image": "pytorch/pytorch:2.1.2-cuda12.1-cudnn8-runtime",
  "customizations": {
    "vscode": {
      "extensions": ["ms-python.python"]
    }
  }
}
```

### Dependencies (Minimal Set)

Already included in PyTorch image:

- PyTorch + torchvision
- numpy
- Basic Python ML stack

Add only if needed:

```bash
pip install matplotlib tqdm tensorboard
```
