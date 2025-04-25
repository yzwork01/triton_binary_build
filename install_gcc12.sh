#!/bin/bash
set -e

# 安装 dnf config-manager 插件
dnf install -y dnf-plugins-core

# 启用 CRB 仓库
dnf config-manager --set-enabled crb -y

# 安装 GCC 12 及依赖
dnf install -y gcc-toolset-12 gcc-toolset-12-libstdc++-devel

# 定义绝对路径
LIB_DIR="/opt/rh/gcc-toolset-12/root/usr/lib64"

# 强制修复符号链接（先删除旧链接）
rm -f "${LIB_DIR}/libstdc++.so.6"
ln -sf "${LIB_DIR}/libstdc++.so.6.0.30" "${LIB_DIR}/libstdc++.so.6"

# 配置全局环境
echo 'source /opt/rh/gcc-toolset-12/enable' > /etc/profile.d/gcc-toolset-12.sh
echo "${LIB_DIR}" > /etc/ld.so.conf.d/gcc-toolset-12.conf
ldconfig

# 验证
echo "=== 验证结果 ==="
source /opt/rh/gcc-toolset-12/enable
gcc --version | grep '12.2.1'
ls -l "${LIB_DIR}/libstdc++.so.6"
strings "${LIB_DIR}/libstdc++.so.6.0.30" | grep -q 'GLIBCXX_3.4.30' && echo "符号检查通过"