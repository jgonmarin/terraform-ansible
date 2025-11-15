variable "aws_region" {
    description = "AWS Region where the resources will be deployed"
    type        = string
    default     = "us-east-1" 
}

variable "instance_type" {
  description = "EC2 Instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nombre del Key Pair de AWS para SSH"
  type        = string
  default     = "clave_ssh_jg"
}

variable "vpc_cidr" {
  description = "CIDR para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_tag" {
    description = "Project identifier label"
    type        = string
    default     = "StaticWebsiteProject"
}