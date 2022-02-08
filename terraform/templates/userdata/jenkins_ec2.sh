#!/bin/bash

sudo yum install epel-release -y
sudo yum update -y
sudo yum upgrade -y;
sudo amazon-linux-extras install epel -y;

# Install docker, nodejs, jq, git
curl -sL https://rpm.nodesource.com/setup_16.x | sudo -E bash
sudo yum install -y docker nodejs jq git

# docker
sudo usermod -aG docker ec2-user

# docker permissions
sudo chmod 666 /var/run/docker.sock
sudo chmod +x /usr/local/bin/docker-compose;

# docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install userdata
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo;
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key;

sudo yum install jenkins java-1.8.0-openjdk-devel -y;

sudo systemctl status jenkins;

# docker 실행을 위한 userdata 추가
sudo usermod -aG docker jenkins;

# Install go latest
wget https://storage.googleapis.com/golang/getgo/installer_linux;
sudo chmod +x ./installer_linux;
./installer_linux

# install kubectl
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
mkdir ~/.kube

# Restart services
sudo systemctl daemon-reload;
sudo systemctl start jenkins;
systemctl enable docker
systemctl start docker

# grant jenkins all
echo 'jenkins ALL=(ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers
