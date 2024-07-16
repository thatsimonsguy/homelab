#!/bin/bash

# Update the system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y curl software-properties-common git

# Add Ansible PPA and install Ansible
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

# Verify Ansible installation
ansible --version

echo "Ansible & Git installed."

# Clone the homelab repository
git clone https://github.com/thatsimonsguy/homelab.git /home/oebus/homelab

# Run the initial Ansible playbook
ansible-playbook -i /home/oebus/homelab/ansible/inventory.ini /home/oebus/homelab/ansible/bootstrap_playbook.yml

echo "Bootstrapping complete."
