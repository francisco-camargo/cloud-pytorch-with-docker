# Cloud PyTorch with Docker

[Guide](https://github.com/francisco-camargo/opentofu-aws-hello-world) to getting started with AWS and OpenTofu to launch an EC2 instance.

## Minimal EC2 PyTorch Setup (Proof of Concept)

**Goal**: Launch a single EC2 instance, run a PyTorch container, execute `train_mnist.py`. Nothing else.

### Step 1: Build Container Locally

```bash
docker build -t pytorch-app ./docker
docker run --rm pytorch-app python train_mnist.py  # Test locally first
```

### Step 2: Create OpenTofu Configuration

**`provider.tf`**
Configures the AWS provider to use the `us-east-1` region. This tells OpenTofu which cloud provider to use and where to create resources.

**`main.tf`**
Creates the minimal infrastructure needed:

- **Data Sources**: Finds your default VPC and subnets (uses existing AWS networking instead of creating new ones)
- **Security Group**: Creates firewall rules allowing SSH access (port 22) and all outbound traffic
- **EC2 Instance**:
    - Uses Amazon Linux 2 AMI for simplicity
    - `t3.medium` instance type (cost-effective for testing)
    - Automatically gets a public IP for easy access
    - References the key pair `pytorch-key` (create this manually in AWS console)
- **User Data Script**: Runs on instance startup to install Docker, start the service, and pre-pull the PyTorch container image
- **Output**: Displays the instance's public IP address after creation

### How Docker Containers Get onto EC2

**There are two ways the PyTorch container can end up on your EC2 instance:**

#### **Option 1: Automatic Pre-pull (via User Data) ← THIS PROJECT USES THIS**

- When the EC2 instance starts up, the User Data script automatically runs
- This script installs Docker and pulls the public PyTorch image from Docker Hub
- Command: `docker pull pytorch/pytorch:2.1.2-cuda12.1-cudnn8-runtime`
- The container image is downloaded and cached on the instance
- When you SSH in later, the image is already available locally
- **Advantage**: Container is ready to run immediately when you connect

#### **Option 2: Manual Pull (after SSH) ← Alternative approach**

- SSH into the instance after it's created
- Manually run `docker pull pytorch/pytorch:2.1.2-cuda12.1-cudnn8-runtime`
- This downloads the image from Docker Hub to the instance
- Takes a few minutes depending on image size and network speed
- **Use this if**: User Data fails or you want different images

**Why we use public images:**

- No need to build custom images or push to registries
- PyTorch official images are maintained and optimized
- Simply reference them by name: `pytorch/pytorch:tag`
- Docker automatically downloads from Docker Hub when needed

**If you want to use your custom container:**

1. Build locally: `docker build -t my-pytorch-app .`
2. Push to registry: `docker push your-registry/my-pytorch-app`
3. Pull on EC2: `docker pull your-registry/my-pytorch-app`

### Step 3: Deploy

```bash
cd terraform/
tofu init
tofu apply
```

### Step 4: Connect and Run

```bash
# SSH into instance
ssh -i <key-name>.pem ec2-user@<instance-ip>

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

## Cleanup/Shutdown

When you're done experimenting, clean up to avoid ongoing AWS charges:

```bash
# Destroy all resources
tofu destroy

# Confirm by typing 'yes' when prompted
```

This removes:

- EC2 instance
- Security group
- All associated resources

**Manual cleanup (if needed):**

- Delete the key pair from AWS Console (EC2 → Key Pairs)
- Check for any orphaned resources in your AWS account

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
