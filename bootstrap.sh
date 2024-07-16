#!/bin/bash

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

# Clone the homelab repository
git clone https://github.com/thatsimonsguy/homelab.git /home/oebus/homelab

# Navigate to the ansible directory
cd /home/oebus/homelab/ansible

# Prompt for Ansible Vault password
read -sp "Enter Ansible Vault password: " VAULT_PASS
continue

# Run the Ansible playbook with the inventory file
ansible-playbook -i inventory.ini bootstrap_playbook.yml --vault-password-file <(echo "$VAULT_PASS")

echo "Bootstrapping complete."
