#!/bin/bash

sudo yum update
sudo yum install -y docker git jq

## docker
#sudo usermod -aG docker ec2-user
#systemctl enable docker
#systemctl start docker
#
## docker-compose
#sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#chmod +x /usr/local/bin/docker-compose

