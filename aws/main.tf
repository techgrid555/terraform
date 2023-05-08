##############################################################
# input variables
#############################################################

variable "access_key" {
  description = "Specifies AWS access key"
  type        = string
}

variable "secret_key" {
  description = "Specifies client secret"
  type        = string
}

variable "region" {
  description = "Specifies region"
  type        = string
}

variable "instance_type" {
  description = "Specifies instance type"
  type        = string
}

##############################################################
# Define aws provider
##############################################################

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

#########################################################
# Resource
#########################################################

resource "aws_instance" "minikube" {
  ami                    = "ami-02396cdd13e9a1257"
  instance_type          = var.instance_type
  key_name               = "kube-key"
  vpc_security_group_ids = ["${aws_security_group.asg.id}"]
  tags = {
    Name = "minikube"
  }

  user_data = <<EOF
#!/bin/bash
# Install dependencies
sudo yum update && sudo yum install -y docker

# Install Minikube
sudo curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && sudo chmod +x minikube && sudo mv minikube /usr/local/bin/

# Start docker
sudo systemctl start docker

# Install kubectl
sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Start Minikube
sudo minikube start --driver=docker

EOF

}

resource "aws_security_group" "asg" {
  name        = "asg"
  description = "Allow ssh, http inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}
