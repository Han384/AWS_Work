#!/bin/bash

# install：jq
#sudo yum install jq -y

# SSMパラメータストアに設定しているSecrets ManagerのIDを取得して変数に格納(※以降の工程で使用)
secret_id=$(aws ssm get-parameter --name SecretsManager_SecretName --query 'Parameter.Value' --output text --with-decryption)
# RDSのインスタンス名を取得して変数に格納(※以降の工程で使用)
db_instance_identifier=$(aws rds describe-db-instances --query "DBInstances[*].DBInstanceIdentifier" --output text)

echo "##### 変数：確認 #####"
echo $secret_id
echo $db_instance_identifier

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

# ~/.bash_profile
source ~/.bash_profile

echo "############# 環境変数：確認 #############"
printenv | grep -E 'AWS|DB_SOCKET_PATH'
echo "##########################################"
