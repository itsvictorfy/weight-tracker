#!/bin/bash
sudo apt-get update
sudo apt-get install postgresql-client -y
sudo apt install net-tools -y
sudo apt install python3-pip -y
sudo apt-get -y install libpq-dev gcc
cd /home/sshuser/
git clone https://gitlab.com/sela-1090/students/itsvictorfy/terraform.git
cd terraform
pip3 install psycopg2
pip3 install Flask
sudo mv /home/sshuser/terraform/webapp.service /etc/systemd/system/
sudo systemctl enable webapp
sudo systemctl start webapp
