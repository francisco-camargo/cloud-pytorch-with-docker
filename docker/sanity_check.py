#!/usr/bin/env python3
"""
Sanity check script to verify PyTorch installation and CUDA availability.
"""

import sys
import torch

def main():
    """Run sanity checks for PyTorch installation."""
    print("=== PyTorch Sanity Check ===")

    # Check PyTorch version
    print(f"PyTorch version: {torch.__version__}")

    # Check CUDA availability
    cuda_available = torch.cuda.is_available()
    print(f"CUDA available: {cuda_available}")

    if cuda_available:
        print(f"CUDA version: {torch.version.cuda}")
        print(f"Number of CUDA devices: {torch.cuda.device_count()}")

        for i in range(torch.cuda.device_count()):
            device_name = torch.cuda.get_device_name(i)
            print(f"  Device {i}: {device_name}")
    else:
        print("No CUDA devices found")

    # Test tensor operations
    print("\n=== Testing Tensor Operations ===")
    try:
        # CPU tensor
        cpu_tensor = torch.randn(3, 3)
        print(f"CPU tensor created: {cpu_tensor.shape}")

        if cuda_available:
            # GPU tensor
            gpu_tensor = torch.randn(3, 3).cuda()
            print(f"GPU tensor created: {gpu_tensor.shape}")
            print(f"GPU tensor device: {gpu_tensor.device}")

        print("✅ All sanity checks passed!")
        return 0

    except Exception as e:
        print(f"❌ Error during tensor operations: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
