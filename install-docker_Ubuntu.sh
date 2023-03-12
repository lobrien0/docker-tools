#!/bin/bash

# Author Data:
#
#	Author/Owner:	Docker inc.
#	Compiled by:	Luke O'Brien
#	Updated:	9/25/2022
#
#	Note:
#		The commands are pulled from Docker inc.'s website
#		and they are to credit for those.
#		All I have done is compile them into this script
#		To make it easier to install.
#
#	Description:
#		The following is written to install the Docker Engine
#		on an Ubuntu arm64 machine, This can update docker too
#
#		Run as SuperUser


if [[ $# -eq 0 ]]
then
	echo "You must enter your username"
	exit 1
fi

# Removes anything docker just incase it was installed
apt remove docker docker-engine docker.io containerd runc

# Update repository and download dependancies
apt update
apt install -y ca-certificates \
	curl \
	gnupg \
	lsb-release

# Directory Creation w/ permissions
mkdir -m 0755 -p /etc/apt/keyrings

# Download and Extract GnuPG Encryption Key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg

# Adding Repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update Repository and download docker
apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install Done
# Post Install Quality of Life

# Docker can be run by non-root users
groupadd docker
usermod -aG docker $1

# Docker will restart w/ System
systemctl enable docker.service
systemctl enable containerd.service

# Create comamnd alias for Docker ps
echo;echo
echo "In order to add the dls command, please put the following into your .bashrc file";echo;
echo alias dls=\"docker ps --format \'table {{.ID}}\\t{{.Names}}\\t{{.State}}\\t{{.Status}}\\t{{.Size}}\\t{{.Image}}\'\"
echo
