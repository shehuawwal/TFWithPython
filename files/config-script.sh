#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install ansible2 -y
sudo yum install -y docker
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user