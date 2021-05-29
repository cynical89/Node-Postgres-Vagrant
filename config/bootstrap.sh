#!/usr/bin/env bash

echo -e "\n\n====================================================="
echo -e "\t Running apt update"
echo -e "=====================================================\n\n"

apt update

echo -e "\n\n====================================================="
echo -e "\t Installing Node.js"
echo -e "=====================================================\n\n"

curl -sL https://deb.nodesource.com/setup_14.x | bash -
apt -y install nodejs
apt -y install build-essential

echo -e "\n\n====================================================="
echo -e "\t Installing yarn and pm2"
echo -e "=====================================================\n\n"

npm i -g yarn
npm i -g pm2

echo -e "\n\n====================================================="
echo -e "\t Installing PostgreSQL"
echo -e "=====================================================\n\n"
apt -y install postgresql
systemctl enable postgresql
systemctl start postgresql

sed -i "s/#listen_address.*/listen_addresses = '*'/" /etc/postgresql/10/main/postgresql.conf

cat >> /etc/postgresql/10/main/pg_hba.conf <<EOF
# Accept all IPv4 connections - FOR DEVELOPMENT ONLY!!!
host    all         all         0.0.0.0/0             md5
EOF

systemctl restart postgresql

sudo su postgres -c "psql -c \"CREATE ROLE vagrant SUPERUSER LOGIN PASSWORD 'vagrant'\" "

sudo su postgres -c "createdb -E UTF8 -T template0 --locale=en_US.utf8 -O vagrant nodedb"

echo -e "\n\n====================================================="
echo -e "\t Installing NGINX"
echo -e "=====================================================\n\n"

apt-get -y install nginx
systemctl enable nginx
systemctl start nginx

cp /vagrant/config/nginx/nodeapp.conf /etc/nginx/sites-available/nodeapp
ln -s /etc/nginx/sites-available/nodeapp /etc/nginx/sites-enabled/nodeapp

rm /etc/nginx/sites-enabled/default
systemctl restart nginx

echo -e "\n\n====================================================="
echo -e "\t Installing NPM Packages"
echo -e "=====================================================\n\n"

cd /vagrant
yarn

echo -e "\n\n====================================================="
echo -e "\t Adding project to PM2"
echo -e "=====================================================\n\n"

# commented out for making things run on staging build - the hot reload works better this way
pm2 start yarn --name "Node-Postgres" -- start
pm2 save
pm2 startup
pm2 stop 0
