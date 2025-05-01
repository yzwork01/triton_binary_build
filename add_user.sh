#!/bin/bash

# Exit on any error
set -e

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Create user 'user' with home directory
echo "Creating user 'user'..."
useradd -m user

# Set a password for the user (optional, can be removed if not needed)
# echo "Setting password for user..."
# echo "user:password" | chpasswd

# Install sudo if not already installed
echo "Installing sudo..."
yum install -y sudo

# Add user to wheel group for sudo privileges
echo "Adding user to wheel group..."
usermod -aG wheel user

# Configure sudo to allow passwordless sudo for user
echo "Configuring passwordless sudo for user..."
echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user
chmod 0440 /etc/sudoers.d/user

# Verify user creation and sudo configuration
echo "Verifying user and sudo setup..."
su - user -c "whoami && sudo whoami"

echo "User 'user' created and granted sudo privileges successfully!"


