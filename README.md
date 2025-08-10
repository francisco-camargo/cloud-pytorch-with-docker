# Cloud PyTorch with Docker


## **Set up AWS**

### **AWS CLI**
In your local machine install AWS CLI, my [guide](https://github.com/francisco-camargo/francisco-camargo/blob/master/src/aws/aws_cli/README.md).

Verify with
```bash
aws --version
```

### **IAM Identity Center**

#### Step 1: Complete Identity Center Setup

1. **Enable IAM Identity Center** in your AWS Console
2. **Choose your identity source** - for a personal account, select "Identity Center directory"
3. **Complete any remaining setup steps** AWS shows you

#### Step 2: Create Your User

1. **In Identity Center, go to "Users"** in the left sidebar
2. **Click "Add user"**
3. **Fill in your details**:
- Username (your choice)
- Email address
- First/Last name
- Set a password or have AWS generate one
4. **Create the user**

#### Step 3: Create a Permission Set

1. **Go to "Permission sets"** in the left sidebar
2. **Click "Create permission set"**
3. **Select permission set type** select "Custom permission set"
4. **Add inline policy**:
    - In the "Permissions" section, locate "Inline policy"
    - Click "Add inline policy"
    - Switch to JSON editor and paste (_you must remove the comments_):
    ```json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "ec2:*",             // For managing EC2 instances
            "elasticloadbalancing:*",  // For potential load balancing
            "iam:CreateServiceLinkedRole",  // For EC2 service roles
            "iam:PassRole",      // For assigning roles to EC2
            "s3:*"              // For OpenTofu state storage
          ],
          "Resource": "*"
        }
      ]
    }
    ```
    This permission set provides:
    - Full EC2 management for PyTorch containers
    - S3 access for OpenTofu state files
    - Minimum IAM permissions for EC2 operation
    - Load balancing capabilities if needed
5. **Configure the permission set**:
- Name: `EC2-OpenTofu-Access`
- Description: "Permissions for EC2 management and OpenTofu infrastructure deployment"
6. **Complete the creation** and proceed to Step 4 for assignment

#### Step 4: Assign User to Account

1. **Go to "AWS accounts"** in the left sidebar
2. **Select your AWS account**
3. **Click "Assign users or groups"**
4. **Select your user** and the **permission set** you created
5. **Finish the assignment**

#### Step 5: Get Your SSO Information

In Identity Center, find:
- **AWS access portal URL** (something like `https://d-xxxxxxxxxx.awsapps.com/start`)
- **SSO region** (where Identity Center is enabled)

#### Step 6: Configure AWS CLI

Now run:
```bash
aws configure sso
```

You'll be prompted for:
- **SSO session name**: Pick any name (like "personal" or "main")
- **SSO start URL**: Use the access portal URL from step 5
- **SSO region**: The region where Identity Center is set up
- **SSO registration scopes**: Enter `sso:account:access` (this is the default and minimum required scope)
- **Default client region**: Your preferred AWS region for resources
- **Default output format**: `json` (recommended)

The CLI will open a browser for you to authenticate.

#### Step 7: Test It

```bash
aws sso login --profile <sso profile>
```

Even if I granted STS permissions in the json above, I was not able to get the following to work even after successful SSO CLI login
```bash
aws sts get-caller-identity --profile <sso profile>
```

- Create or use existing Access Key ID and Secret Access Key

## **Continue from here**

e. **Create Provider Configuration**
Create a new file `provider.tf`:
``hcl provider "aws" { region = "us-east-1"  # or your preferred region } ``

f. **Generate SSH Key Pair**
``bash aws ec2 create-key-pair --key-name pytorch-key --query 'KeyMaterial' --output text > pytorch-key.pem ``

g. **Set Key Permissions** (Windows)
``powershell icacls pytorch-key.pem /inheritance:r icacls pytorch-key.pem /grant:r "%USERNAME%":"(R)" ``

## OpenTofu Infrastructure-as-Code

OpenTofu roadmap to get an EC2 instance running:

### Phase 1: Local Setup

1. **Install OpenTofu** on your Windows machine
[Guide](https://opentofu.org/docs/intro/install/windows/). Not sure if adding it to PATH helped or not

```powershell
winget install --exact --id=OpenTofu.Tofu
```

restart the terminal, then it should run in bash and powershell.

```bash
tofu -version
```

### Phase 2: Infrastructure Definition

4. **Create main.tf** - define EC2 instance, security group, key pair
5. **Create variables.tf** - parameterize instance type, region, etc.
6. **Create outputs.tf** - export instance IP, connection details
7. **Create terraform.tfvars** - set your specific values

### Phase 3: AWS Prerequisites

8. **Generate SSH key pair** for connecting to instance
9. **Verify AWS credentials** have EC2 permissions
10. **Choose AWS region** and availability zone

### Phase 4: Deployment

11. **Initialize OpenTofu** (`tofu init`)
12. **Plan deployment** (`tofu plan`) - preview what will be created
13. **Apply configuration** (`tofu apply`) - create actual resources
14. **Test SSH connection** to your new instance

### Phase 5: Setup Development Environment

15. **SSH into instance** and install Docker
16. **Clone your PyTorch repo** on the instance
17. **Configure VSCode SSH** to connect to the instance
18. **Test your container** runs on the cloud instance

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
