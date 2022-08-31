#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y
sudo yum install -y docker
sudo usermod -aG docker ec2-user
docker pull nginx
docker run -dit --name nginx_tf -p 80:80 nginx:latest