#!/bin/bash

echo "deb http://packages.devstructure.com/ maverick main" \
	| sudo tee /etc/apt/sources.list.d/devstructure.list
wget -O - http://packages.devstructure.com/keyring.gpg | sudo apt-key add -
sudo apt-get update 2>$1 > /dev/null
sudo apt-get -y install blueprint
