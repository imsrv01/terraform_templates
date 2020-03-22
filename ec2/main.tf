# Specify the provider and region
provider "aws" {
  region = var.aws_region
}

# Create a VPC to launch our instances into
# by default gets created - main route table, default network access control list and default security gets created
resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames="true"
}

# Create a subnet to launch our instances into
# subnet is associated with a VPC and AZ (mandatory)
#
resource "aws_subnet" "default" {
  vpc_id = aws_vpc.default.id
  availability_zone = var.aws_availability_zone
  cidr_block = var.subnet_cidr_block
  map_public_ip_on_launch = true
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "terraform_example"
  description = "Used in the terraform"
  vpc_id      = aws_vpc.default.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 # HTTP access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu_latest" {
  most_recent      = true
  owners           = ["099720109477"]
  #owners           = ["amazon"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    #values = ["Ubuntu Server 18.04 LTS*"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

# ec2 instance with nginx installed
resource "aws_instance" "web" {
  # ami to be used for aws_instance
  ami=data.aws_ami.ubuntu_latest.id

  # instance type
  instance_type = var.aws_key_pair

  # subnet to be used. subnet is associated with a AZ and VPC
  subnet_id = aws_subnet.default.id

  # public key that needs to be copied on the instance
  key_name = var.aws_key_pair

  # Security group that will be assigned to instance
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # type of connection to be used
    type = "ssh"
    # private key for ssh connection. associated public key will be copied during VM creation
    private_key = var.private_key
    # The default username for our AMI
    user = "ubuntu"
    # self object is used to refer to parent object
    host = self.public_ip
  }

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
    ]
  }
}
