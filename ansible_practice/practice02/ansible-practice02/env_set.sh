#!/bin/bash

# install：jq
sudo yum install jq -y

###################################
# 変数設定
###################################
# SSMパラメータストアに設定しているSecrets ManagerのIDを取得して変数に格納(※以降の工程で使用)
secret_id=$(aws ssm get-parameter --name SecretsManager_SecretName --query 'Parameter.Value' --output text --with-decryption)
# RDSのインスタンス名を取得して変数に格納(※以降の工程で使用)
db_instance_identifier=$(aws rds describe-db-instances --query "DBInstances[*].DBInstanceIdentifier" --output text)
# 特定のVPCIDを取得して変数に格納(※Nameタグで指定・以降の工程で使用)
vpc_id=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=CFnVPC" --query 'Vpcs[*].VpcId' --output text)
# 特定のVPC内のALB名を取得して変数に格納(※以降の工程で使用)
alb_name=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?VpcId=='$vpc_id'].LoadBalancerName" --output text)

echo "##### 変数：確認 #####"
echo $secret_id
echo $db_instance_identifier
echo $vpc_id
echo $alb_name

###################################
# 環境変数設定：下記記述内で上記変数を使用
###################################

# ~./bash_profileに追記
echo 'secret_id=$(aws ssm get-parameter --name SecretsManager_SecretName --query 'Parameter.Value' --output text --with-decryption)' >> ~/.bash_profile
echo 'db_instance_identifier=$(aws rds describe-db-instances --query "DBInstances[*].DBInstanceIdentifier" --output text)' >> ~/.bash_profile

# Secrets Managerからユーザー名・パスワードを抽出して環境変数に設定し、~./bash_profileに追記
echo 'export AWS_DB_USER=$(aws secretsmanager get-secret-value --secret-id $secret_id | jq -r ".SecretString | fromjson | .username")' >> ~/.bash_profile
echo 'export AWS_DB_PW=$(aws secretsmanager get-secret-value --secret-id $secret_id | jq -r ".SecretString | fromjson | .password")' >> ~/.bash_profile

# RDSインスタンスの情報を取得し、RDSエンドポイントを抽出して環境変数に設定し、~./bash_profileに追記
echo 'export AWS_DB_HOST=$(aws rds describe-db-instances --db-instance-identifier $db_instance_identifier --query 'DBInstances[0].Endpoint.Address' --output text)' >> ~/.bash_profile

# MySQLデータベースサーバーのUNIXソケットファイルへのパスを環境変数に設定し、~./bash_profileに追記
echo 'export DB_SOCKET_PATH=$(mysql_config --socket)' >> ~/.bash_profile

# ALB名の情報を取得し、ALBエンドポイント(DNS名)を抽出して環境変数に設定し、~./bash_profileに追記
echo 'export AWS_ALB_ENDPOINT=$(aws elbv2 describe-load-balancers --names $alb_name  | jq -r ".LoadBalancers[0].DNSName")' >> ~/.bash_profile

###################################
# ~/.bash_profile 読込み
source ~/.bash_profile

echo "############# 環境変数：確認 #############"
printenv | grep -E 'AWS|DB_SOCKET_PATH'
echo "##########################################"
