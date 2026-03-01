#!/bin/bash

set -e  # Exit on any error

echo "🔄 Rebuilding PyTorch container..."

# Step 1: Stop any running containers
echo "📦 Stopping existing containers..."
RUNNING_CONTAINERS=$(docker ps -q --filter ancestor=pytorch-cpu)
if [ -n "$RUNNING_CONTAINERS" ]; then
    docker stop $RUNNING_CONTAINERS
    echo "✅ Stopped existing containers"
else
    echo "ℹ️  No running containers found"
fi

# Step 2: Generate fresh lockfile
echo "🔒 Generating lockfile with uv..."
uv lock
echo "✅ Lockfile updated"

# Step 3: Rebuild image
echo "🐳 Rebuilding Docker image..."
docker build --no-cache -t pytorch-cpu .
echo "✅ Image rebuilt successfully"

# Step 4: Start new container
echo "🚀 Starting new container..."
CONTAINER_ID=$(docker run -d pytorch-cpu)
echo "✅ Container started: $CONTAINER_ID"

# Step 5: Quick sanity check
echo "🔍 Running sanity check..."
sleep 2  # Give container a moment to fully start
docker exec -t $CONTAINER_ID uv run python sanity_check.py

echo ""
echo "🎉 Rebuild complete!"
echo "Container ID: $CONTAINER_ID"
echo ""
echo "💡 Useful commands:"
echo "  Train model: docker exec -it $CONTAINER_ID uv run python train_mnist.py"
echo "  Get shell:   docker exec -it $CONTAINER_ID bash"
echo "  Stop:        docker stop $CONTAINER_ID"
