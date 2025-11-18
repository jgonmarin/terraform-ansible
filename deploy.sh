#!/bin/bash

set -e

TF_DIR="./terraform"
ANSIBLE_DIR="./ansible/ansible-terraform-practica"
INVENTORY="$ANSIBLE_DIR/inventory/aws_ec2.yml"



install_dependencies() {
    echo "--- 🔍 Checking dependencies... ---"
    
    # Detectar gestor de paquetes
    if command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt-get"
        INSTALL_CMD="sudo apt-get install -y"
        UPDATE_CMD="sudo apt-get update"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
        INSTALL_CMD="sudo yum install -y"
        UPDATE_CMD="sudo yum check-update"
    else
        echo "⚠️ No se detectó apt ni yum. Asegúrate de tener las herramientas instaladas manualmente."
        return
    fi

    # 1. Instalar Terraform si no existe
    if ! command -v terraform &> /dev/null; then
        echo "📦 Installing Terraform..."
        $UPDATE_CMD
        $INSTALL_CMD yum-utils unzip
        # Instalación genérica rápida de HashiCorp
        if [ "$PKG_MANAGER" == "yum" ]; then
            sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
            $INSTALL_CMD terraform
        else
            $INSTALL_CMD gnupg software-properties-common
            wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
            $UPDATE_CMD
            $INSTALL_CMD terraform
        fi
    else
        echo "✅ Terraform is already installed."
    fi

    # 2. Instalar Ansible si no existe
    if ! command -v ansible-playbook &> /dev/null; then
        echo "📦 Installing Ansible..."
        $UPDATE_CMD
        if [ "$PKG_MANAGER" == "yum" ]; then
            sudo yum install -y epel-release || true
        fi
        $INSTALL_CMD ansible
    else
        echo "✅ Ansible is already installed."
    fi
}

install_dependencies


# --- 1. Ejecutar Terraform ---
echo "--- 🔨 Create Terraform Infrastructure ---"


cd "$TF_DIR"

if [ ! -d ".terraform" ]; then
    terraform init
else
    echo "ℹ️  Terraform already initialized."
fi

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

if [ -f "$SSH_KEY" ]; then
    echo "🔑 Setting permissions for SSH key..."
    chmod 400 "$SSH_KEY"
else
    echo "⚠️ Warning: SSH Key not found at $SSH_KEY. Ansible might fail if it's not in the default path."
fi
export ANSIBLE_HOST_KEY_CHECKING=False


ansible-playbook -i "$INVENTORY" "$ANSIBLE_DIR/main_playbook.yml"
echo "--- 🥳 Deployment Complete ---"
echo "🌐 Wordpress Website available at: http://${WEB_PUBLIC_IP}"