#!/bin/bash

# Check if Vault password is provided as an argument
if [ -z "$1" ]; then
  echo "Vault password is not provided. Exiting..."
  exit 1
fi

# Update the system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y curl software-properties-common git

# Add ansible PPA and install ansible
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

# Verify ansible installation
ansible --version

echo "Ansible & Git installed."

# Detect the Ubuntu release codename
UBUNTU_RELEASE=$(lsb_release -cs)
export UBUNTU_RELEASE

# Clone the homelab repository
git clone https://github.com/thatsimonsguy/homelab.git /home/oebus/homelab

# Navigate to the ansible directory
cd /home/oebus/homelab/ansible

# Run the Ansible playbook with the inventory file
ansible-playbook -i inventory.ini bootstrap_playbook.yml --vault-password-file <(echo "$1") --extra-vars "ubuntu_release=$UBUNTU_RELEASE"

echo "Bootstrapping complete."
