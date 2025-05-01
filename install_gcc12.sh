#!/bin/bash
#!/bin/bash
set -e

INSTALL_PREFIX="$HOME/opt/gcc-12.3.0"
GCC_VERSION="12.3.0"
BUILD_DIR="/tmp/gcc-build"
SRC_DIR="${BUILD_DIR}/gcc-${GCC_VERSION}"

# 安装系统依赖
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y gcc gcc-c++ glibc-devel libstdc++-devel \
                    gmp-devel mpfr-devel libmpc-devel \
                    zlib-devel bzip2-devel

# 准备源码目录
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
rm -rf ${SRC_DIR}
cp /tmp/model_repo/gcc-${GCC_VERSION}.tar.gz .
tar -xzf gcc-${GCC_VERSION}.tar.gz
cd gcc-${GCC_VERSION}
./contrib/download_prerequisites

# 创建 build 子目录
mkdir -p build
cd build

# 配置环境
unset CC
unset CXX

# 配置构建
../configure --prefix=${INSTALL_PREFIX} \
             --enable-languages=c,c++ \
             --disable-multilib \
             --with-system-zlib \
             --enable-shared \
             --enable-threads=posix \
             --enable-__cxa_atexit \
             --enable-clocale=gnu \
             --enable-lto 2>&1 | tee configure.log

# 构建（多核）
make -j$(nproc) > ~/gcc-build-full.log 2>&1

# 安装
make install 2>&1 | tee make-install.log


# 添加到环境变量（你也可以添加到 ~/.bashrc）
echo "export PATH=${INSTALL_PREFIX}/bin:\$PATH" >> ~/.bash_profile
echo "export LD_LIBRARY_PATH=${INSTALL_PREFIX}/lib64:\$LD_LIBRARY_PATH" >> ~/.bash_profile
source ~/.bash_profile

# 验证
echo "✅ GCC version:"
gcc --version
g++ --version

# 验证 GLIBCXX version
echo "✅ Checking GLIBCXX symbols:"
strings ${INSTALL_PREFIX}/lib64/libstdc++.so.6 | grep GLIBCXX_3.4.30 || echo "❌ GLIBCXX_3.4.30 NOT FOUND"

echo "🎉 GCC ${GCC_VERSION} compiled and installed at ${INSTALL_PREFIX}"
