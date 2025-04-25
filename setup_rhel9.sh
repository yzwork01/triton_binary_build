#!/bin/bash

#docker run --rm -it -v "$(pwd)":/tmp/model_repo -p 8000:8000 -p 8001:8001 -p 8002:8002 --entrypoint /bin/bash --user root ghcr.io/easybuilders/rockylinux-8.10:2024-11-25-12010010537.117


#!/bin/bash
set -e

echo "🔧 Updating packages..."
dnf -y update

dnf install -y numactl-libs

dnf groupinstall "Development Tools" -y

dnf install gcc gcc-c++ make openssl-devel bzip2-devel libffi-devel zlib-devel wget -y
dnf install glibc-devel glibc-headers libgcc libstdc++-devel -y

dnf install -y epel-release
dnf install -y compat-openssl11

dnf install -y python3-pip

pip3 install --upgrade pip \
      && pip3 install --upgrade \
          wheel \
          setuptools \
          docker \
          scons \
          "numpy<2" \
          protobuf

# dnf install -y gcc-toolset-12-gcc gcc-toolset-12-gcc-c++ gcc-toolset-12-libstdc++-devel
# # dnf install -y gcc-toolset-12-gcc gcc-toolset-12-gcc-c++ gcc-toolset-12-libstdc++-devel

# source /opt/rh/gcc-toolset-12/enable
# scl enable gcc-toolset-12 bash

# dnf install libstdc++-12 libstdc++-12-devel
