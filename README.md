Automated WordPress Deployment on AWS (Terraform + Ansible)
This project deploys a testing infrastructure featuring a web server (Apache + PHP) and a database server (MariaDB) on AWS. It then configures the WordPress application using Infrastructure as Code (IaC) tools, specifically integrating Terraform for infrastructure provisioning and Ansible for configuration management.

1. Prerequisites
AWS CLI configured and authenticated.

Terraform (v1.0+) installed.

Ansible (v2.9+) installed.

An SSH Key Pair must be uploaded to AWS, and the path to its private key (.pem file) must be referenced in ansible/ansible.cfg.

Ansible Collection for MySQL/MariaDB: You must install it using the command: ansible-galaxy collection install community.mysql.

2. Project Structure
terraform/: Code defining the AWS infrastructure (VPC, Subnets, Security Groups, and EC2 instances).

ansible/: Dynamic inventory configuration (aws_ec2.yml), settings (ansible.cfg), roles (web and db), and the main playbook (site.yml).

deploy.sh: Automation script responsible for orchestrating the entire workflow.

3. Execution Steps
Adjust Private Key Path: Ensure you update the path to your private SSH key within ansible/ansible.cfg:

Ini, TOML

private_key_file = /path/to/your/key/mi-clave-ansible.pem # <--- IMPORTANT!
Permissions: Make sure the main deployment script is executable:

Bash

chmod +x deploy.sh
Run the Full Workflow: Execute the single automation script from the root directory:

Bash

./deploy.sh
This command will run Terraform to create the infrastructure, wait for the instances to become available, and then execute Ansible to configure them.

4. Terraform and Ansible Integration
The integration is achieved through the orchestration script (deploy.sh) which performs the following steps:

Provisioning (Terraform): Runs terraform apply. EC2 instances are created with specific resource tags (role=web, role=db).

Dynamic Inventory Discovery (Ansible): Ansible uses the dynamic inventory plugin (aws_ec2.yml). This plugin queries the AWS API and uses the instance tags to dynamically create host groups (tag_role_web, tag_role_db) at runtime, eliminating the need for a static inventory file.

Configuration (Ansible): Executes the site.yml playbook using the dynamic inventory. Crucially, the playbook retrieves the private IP address of the Database (DB) server using hostvars and injects it via a Jinja2 template into the wp-config.php file on the web server, ensuring a secure, internal DB connection.

Validation (Optional Bonus): The playbook includes a final task to validate that the web service is responding with an HTTP 200 status code, confirming a successful WordPress deployment.