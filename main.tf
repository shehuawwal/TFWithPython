provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
} 


variable "cidr_blocks" {
  description = "CIDR Blocks for VPC and Subnet" 
  type = list(string)
}

variable "avail_zone" {
  description = "Availability Zone"
}

variable ssh_pub_key {}

resource "aws_vpc" "tfwithpython-vpc" {
  cidr_block = var.cidr_blocks[0]
  tags = {
    "Name" = "tfwithpython-vpc"
  }
}

resource "aws_subnet" "tfwithpython-subnet" {
  vpc_id = aws_vpc.tfwithpython-vpc.id
  cidr_block = var.cidr_blocks[1]
  availability_zone = var.avail_zone

  tags = {
    "Name" = "tfwithpython-subnet"
  }
}


resource "aws_internet_gateway" "tfwithpython-internet-gw" {
  vpc_id = aws_vpc.tfwithpython-vpc.id
  tags = {
    Name = "tfwithpython-internetgw"
  }
}


resource "aws_route_table" "tfwithpython-routetable" {
  vpc_id = aws_vpc.tfwithpython-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tfwithpython-internet-gw.id
  }
  tags = {
    Name = "tfwithpython-routetable"
  }
}


resource "aws_route_table_association" "tfwithpython-rta" {
  subnet_id      = aws_subnet.tfwithpython-subnet.id
  route_table_id = aws_route_table.tfwithpython-routetable.id
}


# resource "aws_default_security_group" "default-sg" {
resource "aws_security_group" "tfwithpython-sec-group" {
  name        = "tfwithpython-sec-group"
  description = "Allow Internet Trafifc"
  vpc_id      = aws_vpc.tfwithpython-vpc.id

    lifecycle {
    create_before_destroy       = true
  }


  ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
}

  ingress {
  description      = "Allow HTTPS"
  from_port        = 443
  to_port          = 443
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]   
}

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "tfwithpython-sg-rules"
  }
}



data "aws_ami" "tfwithpython-ami" {
  most_recent = true
  owners = ["amazon"]
  # root_device_name    = "/dev/xvda"

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
} 

 resource "aws_key_pair" "tfwithpython-sshpub-key" {
  key_name   = "tfwithpython-pub-key"
  public_key = file(var.ssh_pub_key)
}


resource "aws_instance" "tfwithpython-ec2" {
  ami = data.aws_ami.tfwithpython-ami.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.tfwithpython-subnet.id
  vpc_security_group_ids = [aws_security_group.tfwithpython-sec-group.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true

  key_name = aws_key_pair.tfwithpython-sshpub-key.key_name
  # key_name = "tfwithpython-pub-key"
  tags = {
    "Name" = "tfwithpython-ec2"
  }

  user_data = file("config-script.sh")
}


output "ec2-public-ip" {
  value = aws_instance.tfwithpython-ec2.public_ip
}

