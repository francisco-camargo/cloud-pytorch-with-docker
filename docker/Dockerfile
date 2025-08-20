# PyTorch GPU Dockerfile for EC2
# FROM pytorch/pytorch:2.1.2-cuda12.1-cudnn8-devel
FROM pytorch/pytorch:2.1.2-cuda12.1-cudnn8-runtime

# Install uv for additional package management
RUN pip install uv

# Set working directory
WORKDIR /app

# Copy project files and lockfile
COPY pyproject.toml uv.lock ./
RUN uv sync

# Copy scripts
COPY sanity_check.py train_mnist.py ./

# Keep container running for VSCode connection
CMD ["tail", "-f", "/dev/null"]