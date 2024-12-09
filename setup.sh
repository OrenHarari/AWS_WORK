#!/bin/bash
# Source: https://repost.aws/articles/ARwfQMxiC-QMOgWykD9mco1w/how-do-i-install-nvidia-gpu-driver-cuda-toolkit-and-optionally-nvidia-container-toolkit-on-amazon-linux-2023-al2023
# To verify installation status, connect to your EC2 instance and view /var/log/cloud-init-output.log contents

sudo dnf update -y
sudo dnf install -y dkms kernel-devel kernel-modules-extra
cd /tmp

sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/amzn2023/x86_64/cuda-amzn2023.repo
sudo dnf clean expire-cache
sudo dnf module install -y nvidia-driver:latest-dkms
sudo dnf install -y cuda-toolkit

nvidia-smi
/usr/local/cuda/bin/nvcc -V

sudo dnf config-manager --add-repo https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
sudo dnf clean expire-cache
sudo dnf install -y nvidia-container-toolkit
nvidia-container-cli -V

sudo dnf install -y docker
sudo usermod -aG docker ec2-user
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

sudo docker run --rm --runtime=nvidia --gpus all public.ecr.aws/amazonlinux/amazonlinux:2023 nvidia-smi
sudo reboot