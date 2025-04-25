#!/bin/bash
set -e

# 启用必要仓库并安装核心工具
dnf -y update
dnf install -y epel-release
dnf install -y dnf-plugins-core

dnf config-manager --set-enabled crb -y
dnf install -y rpm wget


# 下载 RPM 包
RPM_URL="http://mirror.rockylinux.org/pub/rocky/9/AppStream/x86_64/os/Packages/gcc-toolset-12-libstdc++-devel-12.2.1-7.7.el9_4.x86_64.rpm"
wget -O /tmp/gcc12-devel.rpm "$RPM_URL"

# 解压并部署文件
rpm2cpio /tmp/gcc12-devel.rpm | cpio -idmv -D /tmp/extract
sudo cp /tmp/extract/opt/rh/gcc-toolset-12/root/usr/lib64/libstdc++.so.6.0.30 \
        /opt/rh/gcc-toolset-12/root/usr/lib64/

# 创建符号链接
sudo ln -sf /opt/rh/gcc-toolset-12/root/usr/lib64/libstdc++.so.6.0.30 \
            /opt/rh/gcc-toolset-12/root/usr/lib64/libstdc++.so.6

# 清理临时文件
rm -rf /tmp/extract /tmp/gcc12-devel.rpm

# 验证
echo "=== 验证结果 ==="
ls -l /opt/rh/gcc-toolset-12/root/usr/lib64/libstdc++.so.6*
strings /opt/rh/gcc-toolset-12/root/usr/lib64/libstdc++.so.6.0.30 | grep GLIBCXX_3.4.30