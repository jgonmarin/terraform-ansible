#!/bin/bash

# --- 1. Ejecutar Terraform ---
echo "--- 🔨 Create Terraform Infrastructure ---"
cd terraform || exit 1

terraform destroy -auto-approve
if [ $? -ne 0 ]; then
    echo "❌ Error at Terraform Destroy."
fi
terraform init
terraform apply -auto-approve
if [ $? -ne 0 ]; then
    echo "❌ Error at Terraform Apply."
    exit 1
fi

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
cd ansible/vagrant-master || exit 1

ANSIBLE_COMMAND="cd /home/vagrant/ansible-terraform-practica && ansible-playbook main_playbook.yml"

vagrant ssh control -c "$ANSIBLE_COMMAND"

if [ $? -ne 0 ]; then
    echo "❌ Error at Ansible Playbook. Check the logs."
    exit 1
fi

cd ../..


echo "--- 🥳 Deployment Complete ---"
echo "🌐 Wordpress Website available at: http://${WEB_PUBLIC_IP}"