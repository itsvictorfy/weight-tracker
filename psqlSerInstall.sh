#!/bin/bash

sudo parted /dev/sdc --script mklabel gpt mkpart xfspart xfs 0% 100%
sudo mkfs.xfs /dev/sdc1
sudo partprobe /dev/sdc1


sudo mkdir /datadrive
sudo mount /dev/sdc1 /datadrive
sudo blkid
sudo sh -c 'echo "$(blkid | grep -o "UUID=\"[0-9a-f-]\+\"" | tail -1)   /datadrive   xfs   defaults,nofail   1   2" >> /etc/fstab'

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import PostgreSQL repository key
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Install PostgreSQL
sudo apt-get update
sudo apt-get -y install postgresql

# user, database and table and grant privileges to the user.
sudo -i -u postgres psql -c "ALTER USER 'postgres' PASSWORD 'password';"
sudo -i -u postgres psql -c "CREATE DATABASE weightdb;"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE weightdb TO postgres;"
sudo -i -u postgres psql -d weightdb -c "CREATE TABLE weight (name VARCHAR, weight NUMERIC, time VARCHAR);"

ss -nlt >> ADDRESS:PORT
sudo find / -name "postgresql.conf"
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/15/main/postgresql.conf
sudo systemctl restart postgresql
ss -nlt >> *
sudo sed -i "s/127\.0\.0\.1\/32/0.0.0.0\/0/" /etc/postgresql/15/main/pg_hba.conf
sudo ufw allow 5432/tcp
sudo service postgresql restart
sudo systemctl restart postgresql
echo "Done"

