# aws region for creating resources
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "aws_availability_zone" {
  description = "AWS availability_zone to launch servers"
  default = "us-east-1a"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  default = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for subnet"
  default = "10.0.1.0/24"
}

# variable declaration without any default value.
# private_key value will be supplied when running terraform apply command
variable "private_key" {
  description = "private key for connection to virtual machines using SSH and remote-execution provisioner"
}

variable "aws_key_pair" {
  description = "AWS key pair for connection to aws instances"
}

# Ubuntu Precise 12.04 LTS (x64)
variable "aws_amis" {
  default = {
    eu-west-1 = "ami-674cbc1e"
    us-east-1 = "ami-1d4e7a66"
    us-west-1 = "ami-969ab1f6"
    us-west-2 = "ami-8803e0f0"
  }
}

variable "aws_instance_type" {
  description = "AWS instance type"
  default = "t2.micro"
}
