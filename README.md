# Cloud PyTorch with Docker

[Guide](https://github.com/francisco-camargo/opentofu-aws-hello-world) to getting started with AWS and OpenTofu to launch an EC2 instance.

## Minimal EC2 PyTorch Setup (Proof of Concept)

**Goal**: Launch a single EC2 instance, run a PyTorch container, execute `train_mnist.py`. Nothing else.

### Step 1: Test Container Locally (Optional)

```bash
# Optional: Test your container locally before deploying
docker build -t pytorch-app:latest ./docker
docker run --rm pytorch-app:latest python sanity_check.py
docker run --rm pytorch-app:latest python train_mnist.py
```

**Note**: The container will be built automatically on EC2, so this step is optional.

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

**`subnet_id`**

To get your subnet ID run

```bash
aws ec2 describe-subnets --query 'Subnets[?DefaultForAz==`true`].[SubnetId,AvailabilityZone]' --output table --profile <sso-profile> --region <region>
```

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
cd tofu/
tofu init
tofu plan -out=tfplan
tofu apply tfplan
```

### Step 4: Connect and Run

```bash
# SSH into instance
ssh -i <key-name>.pem ec2-user@<instance-public-ip>
# you may get a warning due to connecting for the first time, go ahead and enter "yes"

# Run your custom PyTorch container (built automatically on EC2)
docker run --rm pytorch-app:latest python sanity_check.py
docker run --rm pytorch-app:latest python train_mnist.py

# Or run interactively to explore
docker run -it pytorch-app:latest bash
```

docker run --rm -v /home/ec2-user/cloud-pytorch-with-docker:/workspace \
```

**Success!** Your custom PyTorch container with scripts is now running on EC2!

## Build-on-EC2 Approach

This setup automatically builds your custom Docker image on the EC2 instance:

### **What happens during deployment:**
1. **EC2 launches** with Docker installed
2. **Git clones** your repository from GitHub
3. **Docker builds** your custom image using `./docker/Dockerfile`
4. **Ready to run** your PyTorch scripts

### **Benefits:**
- ✅ **Simple setup** - No DockerHub account needed
- ✅ **Self-contained** - Everything built on EC2
- ✅ **Always fresh** - Latest code from your repo
- ✅ **No external dependencies** - No registry required

### **Trade-offs:**
- ⚠️ **Slower startup** - Build time adds ~5-10 minutes to deployment
- ⚠️ **EC2 resources** - Uses CPU/memory for building

## If You Want GPU (Optional)

- Change instance type to `g4dn.xlarge`
- Use Deep Learning AMI: `ami-0c94855ba95b798c7`
- Add `--gpus all` to docker run command

## Cleanup/Shutdown

```bash
# Exit SSH session
exit
# or press Ctrl+D
```

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
