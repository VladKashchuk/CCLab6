#!/bin/bash
sudo yum update -y
sudo yum -y install httpd
sudo service httpd start
sudo chkconfig httpd on
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} +
find /var/www -type f -exec sudo chmod 0664 {} +
echo "<h1>Vlad Kashchuk page1</h1>" > /var/www/html/index.html
