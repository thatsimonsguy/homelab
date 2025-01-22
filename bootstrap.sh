#!/bin/bash

# Check if Vault password is provided as an argument
if [ -z "$1" ]; then
  echo "Vault password is not provided. Exiting..."
  exit 1
fi

# Update the system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essential packages
echo "Installing essential packages..."
sudo apt install -y curl gnupg git software-properties-common python3 python3-pip

# Install Ansible using pip (preferred for Debian to avoid PPA issues)
echo "Installing Ansible..."
sudo pip3 install ansible

# Verify Ansible installation
ansible --version
if [ $? -ne 0 ]; then
  echo "Ansible installation failed. Exiting..."
  exit 1
fi

echo "Ansible & Git installed successfully."

# Detect the Debian codename
DEBIAN_RELEASE=$(grep "VERSION_CODENAME" /etc/os-release | cut -d'=' -f2)
export DEBIAN_RELEASE

# Clone the homelab repository
HOMELAB_DIR="/home/oebus/homelab"
if [ -d "$HOMELAB_DIR" ]; then
  echo "Homelab directory already exists. Pulling latest changes..."
  git -C "$HOMELAB_DIR" pull
else
  echo "Cloning homelab repository..."
  git clone https://github.com/thatsimonsguy/homelab.git "$HOMELAB_DIR"
fi

# Navigate to the ansible directory
cd "$HOMELAB_DIR/ansible" || { echo "Failed to navigate to ansible directory. Exiting..."; exit 1; }

# Run the Ansible playbook with the inventory file
echo "Running Ansible playbook..."
ansible-playbook -i inventory.ini bootstrap.yml --vault-password-file <(echo "$1") --extra-vars "debian_release=$DEBIAN_RELEASE"

echo "Bootstrapping complete."
