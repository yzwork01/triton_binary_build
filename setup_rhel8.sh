#!/bin/bash

# 设置错误处理
set -e


# 更新系统并安装 EPEL 仓库
dnf update -y
dnf install -y epel-release

dnf install -y dnf-plugins-core
dnf config-manager --set-enabled powertools
dnf clean all
dnf makecache

# 安装基本工具
dnf install -y dnf-plugins-core
dnf install -y gcc gcc-c++ make wget bzip2 file git \
               libmpc-devel mpfr-devel gmp-devel zlib-devel \
               glibc-devel libstdc++-devel binutils \
               flex bison elfutils-libelf-devel texinfo \
               autoconf automake libtool procps \
               libxcrypt-devel libatomic bzip2-devel


# triton dependencies
sudo dnf install -y numactl-libs