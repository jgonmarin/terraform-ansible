#!/bin/bash

set -e

TF_DIR="./terraform"
ANSIBLE_DIR="./ansible/ansible-terraform-practica"
INVENTORY="$ANSIBLE_DIR/inventory/aws_ec2.yml"

# --- 1. Ejecutar Terraform ---
echo "--- 🔨 Create Terraform Infrastructure ---"
cd "$TF_DIR"

terraform init
terraform apply -auto-approve
if [ $? -ne 0 ]; then
    echo "❌ Error at Terraform Apply."
    exit 1
fi
@echo "Waiting for EC2 Instances to be created"
sleep 80
# Obtener la IP pública de la instancia web del output de Terraform
WEB_PUBLIC_IP=$(terraform output -raw web_public_ip)
if [ -z "$WEB_PUBLIC_IP" ]; then
    echo "❌ Error: 'web_public_ip' is empty."
    exit 1
fi

echo "✅ Infrastructure created. Web Server IP: ${WEB_PUBLIC_IP}"

cd ..

# --- 3. Ejecutar Ansible Playbook ---
echo "--- ⚙️ Setting servers with Ansible ---"

chmod 400 $ANSIBLE_DIR/key/clave_ssh_jg.pem

ansible-playbook -i "$INVENTORY" "$ANSIBLE_DIR/main_playbook.yml"
echo "--- 🥳 Deployment Complete ---"
echo "🌐 Wordpress Website available at: http://${WEB_PUBLIC_IP}"