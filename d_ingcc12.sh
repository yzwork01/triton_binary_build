#!/bin/bash

# 手动编译安装 GCC 12 的脚本
# 在 Rocky Linux 8 Docker 环境中测试通过
# 需要以 root 用户执行

set -e  # 遇到错误立即退出

# 安装基础依赖
echo "安装编译依赖..."
dnf update -y
dnf install -y epel-release

dnf install -y dnf-plugins-core
dnf config-manager --set-enabled powertools
dnf clean all
dnf makecache

dnf groupinstall -y 'Development Tools'
dnf install -y wget tar gzip xz bzip2 git make cmake \
    libmpc-devel mpfr-devel gmp-devel \
    zlib-devel texinfo ncurses-devel

# 启用 PowerTools 仓库（Rocky Linux 8 需要）
dnf config-manager --set-enabled powertools

# 下载 GCC 12.2.0 源码
GCC_VERSION=12.2.0
WORK_DIR=/tmp/gcc-build
INSTALL_DIR=/opt/gcc12

echo "创建构建目录..."
mkdir -p ${WORK_DIR}
cd ${WORK_DIR}

echo "下载 GCC ${GCC_VERSION} 源码..."
wget https://mirrors.kernel.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz
tar xzf gcc-${GCC_VERSION}.tar.gz
cd gcc-${GCC_VERSION}

echo "下载依赖库..."
./contrib/download_prerequisites

# 配置编译选项
echo "配置编译参数..."
mkdir -p ../build
cd ../build

../gcc-${GCC_VERSION}/configure \
    --prefix=${INSTALL_DIR} \
    --disable-multilib \
    --enable-languages=c,c++ \
    --with-system-zlib \
    --enable-checking=release \
    --enable-threads=posix \
    --enable-__cxa_atexit

# 编译安装 (根据 CPU 核数调整 -j 参数)
CPU_CORES=$(nproc)
echo "开始编译（使用 ${CPU_CORES} 线程）..."
make -j${CPU_CORES}

echo "安装到 ${INSTALL_DIR}..."
make install

# 配置环境变量
echo "配置环境变量..."
cat << EOF > /etc/profile.d/gcc12.sh
export PATH=${INSTALL_DIR}/bin:\$PATH
export LD_LIBRARY_PATH=${INSTALL_DIR}/lib64:\$LD_LIBRARY_PATH
EOF

source /etc/profile.d/gcc12.sh

# 更新动态库缓存
ldconfig

# 验证安装
echo "验证安装..."
${INSTALL_DIR}/bin/gcc --version | grep "12.2.0"

echo "验证 GLIBCXX 版本..."
strings ${INSTALL_DIR}/lib64/libstdc++.so.6 | grep GLIBCXX_3.4.30

echo "GCC 12 安装完成！"
echo "请重新登录或执行以下命令使环境变量生效："
echo "source /etc/profile.d/gcc12.sh"