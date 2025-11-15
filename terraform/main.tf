
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}




# Setting VPC and 2 public subnets

resource "aws_vpc" "custom_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = "Web-VPC-JG"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.custom_vpc.id

    tags = {
        Name = "Web-IGW-JG"
    }
}
resource "aws_subnet" "public_a" {
    vpc_id =  aws_vpc.custom_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "${var.aws_region}a"
    map_public_ip_on_launch = true

    tags = {
        Name = "jg-Public-Subnet-A"
    }
}

resource "aws_subnet" "public_b" {
    vpc_id =  aws_vpc.custom_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "${var.aws_region}b"
    map_public_ip_on_launch = true
    
    tags = {
        Name = "jg-Public-Subnet-B"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.custom_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "public_a" {
    subnet_id      = aws_subnet.public_a.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
    subnet_id      = aws_subnet.public_b.id
    route_table_id = aws_route_table.public.id
}


# Web Server EC2
resource "aws_instance" "web" {
    ami           = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    key_name      = var.key_name
    subnet_id     = aws_subnet.public_a.id
    vpc_security_group_ids = [aws_security_group.web_sg.id]

    tags = {
        Name = "Web-Server-JG"
        role = "webserver"
    }
}

# DB Server EC2
resource "aws_instance" "db" {
    ami           = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    key_name      = var.key_name
    subnet_id     = aws_subnet.public_b.id
    vpc_security_group_ids = [aws_security_group.db_sg.id]

    tags = {
        Name = "DB-Server-JG"
        role = "db"
    }
}



# Setting security groups rules

resource "aws_security_group" "web_sg" {
    name = "jg-web-sg"
    description = "Allows SSH, HTTP/S"
    vpc_id = aws_vpc.custom_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Web-SG-JG"
    }
}

resource "aws_security_group" "db_sg" {
    name = "db-sg-jg"
    description = "Allows MySQL from Webserver"
    vpc_id = aws_vpc.custom_vpc.id

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.web_sg.id]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "DB-SG-JG"
    }
}


#output "website_endpoint" {
#    description = "StaticWeb Endpoint"
#    value = aws_s3_bucket_website_configuration.website_config.website_endpoint
#}

output "web_public_ip" {
    value = aws_instance.web.public_ip
}

output "db_private_ip" {
    value = aws_instance.db.private_ip
}
