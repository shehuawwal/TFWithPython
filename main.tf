provider "aws" {
  region = "us-west-1"
  access_key = ""
  secret_key = ""
} 


variable "cidr_blocks" {
  description = "CIDR Blocks for VPC and Subnet" 
  type = list(string)
}

resource "aws_vpc" "tfwithpython-vpc" {
  cidr_block = var.cidr_blocks[0]
  tags = {
    "Name" = "tfwithpython-vpc"
  }
}

resource "aws_subnet" "tfwithpython-subnet" {
  vpc_id = aws_vpc.tfwithpython-vpc.id

  cidr_block = var.cidr_blocks[1]
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "tfwithpython-subnet"
  }
}

