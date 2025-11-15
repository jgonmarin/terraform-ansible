Automated WordPress Deployment on AWS (Terraform + Ansible)
This project deploys a testing infrastructure featuring a web server (Apache + PHP) and a database server (MariaDB) on AWS. It then configures the WordPress application using Infrastructure as Code (IaC) tools, specifically integrating Terraform for infrastructure provisioning and Ansible for configuration management.

1. Prerequisites
AWS CLI configured and authenticated.

Terraform (v1.0+) installed.

Ansible (v2.9+) installed.

2. Project Structure
terraform/: Code defining the AWS infrastructure (VPC, Subnets, Security Groups, and EC2 instances).

ansible/: Vagrant machine that contains the Ansible Project. Dynamic inventory configuration (aws_ec2.yml), settings (ansible.cfg), roles (webserver and db), and the main playbook (main_playbook.yml).

deploy.sh: Automation script responsible for orchestrating the entire workflow.

3. Execution Stepsç

Bash

chmod +x deploy.sh
Run the Full Workflow: Execute the single automation script from the root directory:

Bash

./deploy.sh
This command will run Terraform to create the infrastructure.

4. Terraform and Ansible Integration
The integration is achieved through the orchestration script (deploy.sh) which performs the following steps:

Provisioning (Terraform): Runs terraform apply. EC2 instances are created with specific resource tags (role=webserver, role=db).

Dynamic Inventory Discovery (Ansible): Ansible uses the dynamic inventory plugin (aws_ec2.yml). This plugin queries the AWS API and uses the instance tags to dynamically create host groups (tag_role_webserver, tag_role_db) at runtime, eliminating the need for a static inventory file.

Configuration (Ansible): Executes the main_playbook.yml playbook using the dynamic inventory.

Validation: The playbook includes a final task to validate that the web service is responding with an HTTP 200 status code, confirming a successful WordPress deployment.