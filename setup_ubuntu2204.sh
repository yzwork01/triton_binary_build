#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

# 更新系统包列表
apt-get update -y && apt-get upgrade -y

# 安装基础工具
apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    gnupg \
    software-properties-common \
    unzip \
    curl \
    lsb-release \
    libnuma1 \
    libarchive13 \
    libz-dev \
    libssl-dev

# 安装 Python 3.9
add-apt-repository -y ppa:deadsnakes/ppa
apt-get update -y
apt-get install -y --no-install-recommends \
    python3.9 \
    python3.9-dev \
    python3.9-venv \
    python3-pip

# 替换默认 python3
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2

# 安装 pip 工具包
python3.9 -m ensurepip --upgrade
python3.9 -m pip install --upgrade pip setuptools wheel

# 安装 Triton Python backend 所需的依赖
python3.9 -m pip install --upgrade \
    "numpy<2" \
    scons \
    protobuf \
    docker

# 安装 libssl1.1（必须是手动下载）
wget -q https://robohub.eng.uwaterloo.ca/mirror/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.22_amd64.deb
dpkg -i libssl1.1_1.1.1f-1ubuntu2.22_amd64.deb || apt-get -f install -y
rm libssl1.1_1.1.1f-1ubuntu2.22_amd64.deb

# Setup Triton files
unzip -o /opt/full_tri.zip -d /opt
chmod -R 777 /opt/tritonserver
cp -r /opt/Triton_test /home/