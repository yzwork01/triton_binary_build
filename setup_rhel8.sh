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

# install python3
# curl -O https://www.python.org/ftp/python/3.11.8/Python-3.11.8.tgz && \
#     tar -xzf Python-3.11.8.tgz && \
#     cd Python-3.11.8 && \
#     ./configure --enable-optimizations --enable-optimizations --enable-shared --prefix=/usr/local LDFLAGS="-Wl,-rpath /usr/local/lib" && \
#     make -j$(nproc) && make altinstall && \
#     cd .. && rm -rf Python-3.11.8*

# rm -f /usr/local/bin/python3
# ln -s /usr/local/bin/python3.11 /usr/local/bin/python3 && \
#     ln -s /usr/local/bin/pip3.11 /usr/local/bin/pip3

# curl -O https://www.python.org/ftp/python/3.9.19/Python-3.9.19.tgz
# tar -xzf Python-3.9.19.tgz
# cd Python-3.9.19
# ./configure --enable-optimizations --enable-shared --prefix=/usr/local LDFLAGS="-Wl,-rpath /usr/local/lib" CFLAGS="-fPIC"
# make -j$(nproc)
# make altinstall

# # rm -f /usr/local/bin/python3
# ln -sf /usr/local/bin/python3.9 /usr/local/bin/python3
# ln -sf /usr/local/bin/pip3.9 /usr/local/bin/pip3

# echo "/usr/local/lib" | tee /etc/ld.so.conf.d/python3.9.conf && \
#     ldconfig

dnf install -y python3-pip

pip3 install --upgrade pip \
      && pip3 install --upgrade \
          wheel \
          setuptools \
          docker \
          scons \
          "numpy<2" \
          protobuf