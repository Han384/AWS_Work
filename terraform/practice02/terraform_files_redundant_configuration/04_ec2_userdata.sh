#! /bin/bash
# ---------------------------------
# EC2 user data：Autoscaling (ALBヘルスチェック対応)・RDS接続等確認用
# ---------------------------------
sudo yum update -y
sudo yum -y install httpd

sudo touch /var/www/html/index.html

sudo systemctl enable httpd
sudo systemctl start httpd

sudo yum -y remove mariadb-libs
sudo yum localinstall -y https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm
sudo yum install -y mysql-community-server mysql-community-devel

sudo systemctl enable mysqld
sudo systemctl start mysqld
