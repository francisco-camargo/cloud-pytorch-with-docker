# Cloud PyTorch with Docker

## Cloud Deployment with OpenTofu

For deploying PyTorch Docker containers to AWS EC2 instances, follow these milestones:

### Milestone 1: Local Container Preparation

**Objective**: Ensure your PyTorch container works locally and is ready for cloud deployment

- [ ] **Build and test Docker container locally**
  ```bash
  docker build -t pytorch-app .
  docker run --rm -v $(pwd):/workspace pytorch-app python train_mnist.py
  ```
- [ ] **Verify training script works** (e.g., `train_mnist.py` completes successfully)
- [ ] **Optimize container for cloud** (minimal layers, efficient caching)
- [ ] **Push to container registry** (ECR, Docker Hub, or private registry)
  ```bash
  docker tag pytorch-app:latest your-registry/pytorch-app:latest
  docker push your-registry/pytorch-app:latest
  ```

### Milestone 2: Infrastructure Foundation

**Objective**: Set up the basic AWS infrastructure to run containers

- [ ] **Configure OpenTofu provider** (`provider.tf`)
- [ ] **Create VPC and networking** (subnets, security groups, internet gateway)
- [ ] **Set up EC2 key pair** for SSH access
- [ ] **Define security group rules** (SSH port 22, any application ports needed)
- [ ] **Create IAM roles** for EC2 instance (if needed for AWS services access)

### Milestone 3: EC2 Instance Configuration

**Objective**: Provision and configure EC2 instance for Docker workloads

- [ ] **Define EC2 instance resource** in OpenTofu
    - **GPU Instance types**: `p3.2xlarge`, `p3.8xlarge`, `g4dn.xlarge`, `g5.xlarge` (for PyTorch GPU training)
    - **AMI selection**: Deep Learning AMI (Ubuntu) with NVIDIA drivers and Docker pre-installed
    - **Storage configuration**: EBS GP3 volumes (>=100GB for models/data)
- [ ] **Configure user data script** for instance initialization

  ```bash
  #!/bin/bash
  # Install NVIDIA Container Toolkit (if not in DL AMI)
  # Pull your PyTorch GPU container image
  # Set up data directories and permissions
  ```
- [ ] **Apply OpenTofu configuration**
  ```bash
  tofu init
  tofu plan
  tofu apply
  ```

### Milestone 4: Container Runtime Setup

**Objective**: Get Docker running and accessible on the EC2 instance

- [ ] **SSH into EC2 instance** and verify Docker installation
  ```bash
  ssh -i pytorch-key.pem ec2-user@<instance-ip>
  docker --version
  ```
- [ ] **Pull your PyTorch container image**
  ```bash
  docker pull your-registry/pytorch-app:latest
  ```
- [ ] **Test container execution**
  ```bash
  docker run --rm your-registry/pytorch-app:latest python --version
  ```
- [ ] **Set up data persistence** (mount EBS volumes, configure data directories)

### Milestone 5: Training Pipeline Deployment

**Objective**: Successfully run PyTorch training workloads in the cloud

- [ ] **Upload training data** to EC2 instance or S3
- [ ] **Run training script in container**
  ```bash
  docker run -v /data:/workspace/data your-registry/pytorch-app:latest python train_mnist.py
  ```
- [ ] **Verify model training completes** and outputs are saved
- [ ] **Monitor resource usage** (CPU, memory, disk I/O)
- [ ] **Set up logging/monitoring** (CloudWatch, container logs)

### Milestone 6: Production Readiness

**Objective**: Make the deployment robust and scalable

- [ ] **Implement container restart policies** (auto-restart on failure)
- [ ] **Set up automated deployments** (CI/CD pipeline for container updates)
- [ ] **Configure backup strategies** (model checkpoints, data backup)
- [ ] **Implement monitoring and alerting** (training progress, system health)
- [ ] **Document deployment procedures** and troubleshooting guides
- [ ] **Test disaster recovery** (instance replacement, data recovery)

### Quick Start Commands

Once infrastructure is ready:

```bash
# Connect to instance
ssh -i pytorch-key.pem ec2-user@<instance-ip>

# Run training (with GPU support)
docker run -d --name pytorch-training \
  --gpus all \
  -v /data:/workspace/data \
  -v /models:/workspace/models \
  your-registry/pytorch-app:latest python train_mnist.py

# Monitor progress
docker logs -f pytorch-training

# Copy results back
scp -i pytorch-key.pem ec2-user@<instance-ip>:/models/* ./local-models/
```

### Cost Optimization Tips

- Use **Spot Instances** for training workloads (60-90% cost savings)
- **Stop instances** when not training (only pay for storage)
- Use **appropriate instance types** (don't over-provision)
- **Monitor usage** with AWS Cost Explorer
- Consider **Batch or ECS** for large-scale training jobs

## VSCode Integration

**Dev Containers extension**:

- `.devcontainer/devcontainer.json` configures the remote connection
- VSCode attaches to running container
- Full IntelliSense, debugging, terminal access inside container
- Extensions (Python, PyTorch snippets) installed in container

## Dependencies (Minimal Set)

**CPU-optimized libraries**:

- PyTorch CPU version + torchvision
- numpy (with optimized BLAS)
- matplotlib (basics)
- tqdm (progress bars)
- tensorboard (simple logging)

**No Jupyter, no GPU libraries, no heavyweight frameworks initially**

## Development Workflow

1. **Build container** with all dependencies pre-installed
2. **Start container** (standard Docker, no GPU runtime needed)
3. **VSCode connects** via Dev Containers extension
4. **Code directly** in container environment
5. **Run training** with simple `python scripts/train.py`

## CPU Optimization

**Docker Configuration**:

- Standard Docker Desktop on Windows
- CPU resource allocation (cores/memory)
- No special runtime requirements
- Faster startup than GPU containers

## Minimal Neural Network

**Simple CNN example**:

- Basic PyTorch model (lightweight for CPU)
- MNIST dataset (smaller, faster on CPU)
- Reduced batch sizes for CPU efficiency
- CPU utilization monitoring
- Threading optimization for Windows containers

## Windows-Specific Considerations

**Docker Desktop**:

- WSL2 backend recommended
- Memory allocation for container
- File system performance (avoid bind mounts for dependencies)
- Port forwarding for any web interfaces

This approach gives you:

- **No GPU dependencies** (works on any Windows machine)
- **Fast container startup** (no CUDA runtime)
- **Full VSCode experience** with remote development
- **CPU-optimized PyTorch** for reasonable performance
- **Simple setup** on Windows Docker Desktop
- **Reproducible environment** across any CPU-based machine

The key advantage is simplicity - standard Docker setup with no special hardware requirements, while still maintaining professional development practices.
