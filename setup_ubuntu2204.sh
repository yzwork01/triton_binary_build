#!/bin/bash

# 设置错误处理
set -e

# 检查磁盘空间（至少 15GB 可用）
REQUIRED_SPACE=15000000  # 15GB in KB
AVAILABLE_SPACE=$(df -k /tmp | tail -1 | awk '{print $4}')
if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
  echo "Error: Insufficient disk space in /tmp. Need 15GB, available: $((AVAILABLE_SPACE/1024))MB"
  exit 1
fi

# 检查内存（建议至少 4GB，如果 free 命令存在）
if command -v free >/dev/null 2>&1; then
  TOTAL_MEMORY=$(free -m | awk '/^Mem:/{print $2}')
  if [ "$TOTAL_MEMORY" -lt 4000 ]; then
    echo "Warning: Low memory detected ($TOTAL_MEMORY MB). Recommend at least 4GB for GCC build."
  fi
else
  echo "Warning: 'free' command not found. Skipping memory check. Recommend at least 4GB RAM."
fi

# 更新系统并安装 EPEL 仓库
dnf update -y
dnf install -y epel-release

dnf install -y dnf-plugins-core
dnf config-manager --set-enabled powertools
dnf clean all
dnf makecache

# 安装基本工具（添加更多可能需要的依赖）
dnf install -y gcc gcc-c++ make wget bzip2 file git \
               libmpc-devel mpfr-devel gmp-devel zlib-devel \
               glibc-devel libstdc++-devel binutils \
               flex bison elfutils-libelf-devel texinfo \
               autoconf automake libtool procps \
               libxcrypt-devel libatomic glibc-headers \
               kernel-headers

# 创建工作目录
mkdir -p /tmp/gcc-build
cd /tmp/gcc-build

# 下载 GCC 12.3.0 源代码
GCC_VERSION="12.3.0"
GCC_URL="https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz"
echo "Downloading GCC ${GCC_VERSION} from ${GCC_URL}"
wget "${GCC_URL}"
if [ ! -f "gcc-${GCC_VERSION}.tar.gz" ]; then
  echo "Error: Failed to download gcc-${GCC_VERSION}.tar.gz"
  ls -l /tmp/gcc-build/
  exit 1
fi

# 解压源代码
tar -xzf gcc-${GCC_VERSION}.tar.gz
cd gcc-${GCC_VERSION}

# 下载并配置 GCC 依赖（GMP、MPFR、MPC、ISL）
./contrib/download_prerequisites

# 创建构建目录
mkdir -p build
cd build

# 配置 GCC
../configure --prefix=/usr/local \
             --enable-languages=c,c++ \
             --disable-multilib \
             --with-system-zlib \
             --enable-shared \
             --enable-threads=posix \
             --enable-__cxa_atexit \
             --enable-clocale=gnu \
             --enable-lto

# 编译 GCC
make -j4 2>&1 | tee make.log

# 检查 libiberty.a 是否生成
if [ ! -f "libiberty/libiberty.a" ]; then
  echo "Error: libiberty.a not found in build/libiberty after make. Check make.log for libiberty errors."
  ls -l libiberty/
  exit 1
fi

# 明确安装 libstdc++
cd libstdc++-v3
make install 2>&1 | tee ../../libstdc++-make-install.log
cd ..

# 检查 libstdc++.so.6 是否存在
if [ ! -f "/usr/local/lib64/libstdc++.so.6" ]; then
  echo "Error: libstdc++.so.6 not found in /usr/local/lib64. Check libstdc++-make-install.log."
  exit 1
fi

# 安装 GCC
make install 2>&1 | tee make-install.log

# 更新动态链接库缓存
ldconfig

# 设置 GCC 12 作为系统默认编译器
update-alternatives --install /usr/bin/gcc gcc /usr/local/bin/gcc 100
update-alternatives --install /usr/bin/g++ g++ /usr/local/bin/g++ 100
update-alternatives --install /usr/bin/cc cc /usr/local/bin/gcc 100
update-alternatives --install /usr/bin/c++ c++ /usr/local/bin/g++ 100

# 设置环境变量并立即应用
echo "export PATH=/usr/local/bin:\$PATH" >> /etc/profile.d/gcc12.sh
echo "export LD_LIBRARY_PATH=/usr/local/lib64:\$LD_LIBRARY_PATH" >> /etc/profile.d/gcc12.sh
source /etc/profile.d/gcc12.sh

# 验证 GCC 版本
if ! /usr/local/bin/gcc --version | grep -q "12.3.0"; then
  echo "Error: GCC 12.3.0 not set as default. Current version:"
  gcc --version
  exit 1
fi
if ! /usr/local/bin/g++ --version | grep -q "12.3.0"; then
  echo "Error: G++ 12.3.0 not set as default. Current version:"
  g++ --version
  exit 1
fi

# 验证 libstdc++ 符号
if [ -f "/usr/local/lib64/libstdc++.so.6" ]; then
  strings /usr/local/lib64/libstdc++.so.6 | grep GLIBCXX_3.4.29 || echo "Warning: GLIBCXX_3.4.29 not found in libstdc++.so.6"
  strings /usr/local/lib64/libstdc++.so.6 | grep GLIBCXX_3.4.30 || echo "Warning: GLIBCXX_3.4.30 not found in libstdc++.so.6"
else
  echo "Error: libstdc++.so.6 not found in /usr/local/lib64"
  exit 1
fi

# 清理临时文件
# cd /
# rm -rf /tmp/gcc-build

# 清理 DNF 缓存
dnf clean all
rm -rf /var/cache/dnf

# 输出完成信息
echo "GCC 12.3.0 compiled and installed successfully, set as default compiler."
gcc --version
g++ --version