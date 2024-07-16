#!/bin/bash

# Update the system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y curl software-properties-common

# Add Ansible PPA and install Ansible
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

# Verify Ansible installation
ansible --version

echo "Initial bootstrap complete. Ansible installed."

# Run Ansible playbook from a remote location (e.g., GitHub)
curl -L https://raw.githubusercontent.com/thatsimonsguy/homelab/main/Ansible/bootstrap_playbook.yml -o /tmp/setup.yml
ansible-playbook -i "localhost," -c local /tmp/setup.yml

echo "Server configuration complete."
