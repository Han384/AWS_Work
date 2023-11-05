#!/bin/bash

# AWS CLIのインストールスクリプトURLを設定
AWS_CLI_INSTALL_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"

# AWS CLI インストール：インストールスクリプトをダウンロードして実行
curl -o "awscliv2.zip" $AWS_CLI_INSTALL_URL
unzip awscliv2.zip
sudo ./aws/install

# jq：インストール
#sudo yum install jq -y
#sudo apt install jq -y


###################################
# 変数設定
###################################

# SSMパラメータストアに設定しているSecrets ManagerのIDを取得して変数に格納(※以降の工程で使用)
secret_id=$(aws ssm get-parameter --name SecretsManager_SecretName --query 'Parameter.Value' --output text --with-decryption)

# RDSのインスタンス名を取得して変数に格納(※以降の工程で使用)
db_instance_identifier=$(aws rds describe-db-instances --query "DBInstances[*].DBInstanceIdentifier" --output text)

# 特定のVPCIDを取得して変数に格納(※Nameタグで指定・以降の工程で使用)
vpc_id=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=CFnVPC" --query 'Vpcs[*].VpcId' --output text)

# 特定のVPC内のALB名を取得して変数に格納(※VPCIDを指定・以降の工程で使用)
alb_name=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?VpcId=='$vpc_id'].LoadBalancerName" --output text)

# S3バケット名を取得して変数に格納(※Nameタグで指定・以降の工程で使用)
s3_name=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, 'raisetech-cfn-')].Name" --output text)

# 確認用：※必要に応じてコメントアウト
echo "##### 変数：確認 #####"
echo $secret_id
echo $db_instance_identifier
echo $vpc_id
echo $alb_name
echo $s3_name


###################################
# 環境変数設定：下記記述内で上記変数を使用
###################################

# Secrets Managerからユーザー名・パスワードを抽出して環境変数に設定し、~/.profileに追記
echo 'export AWS_DB_USER=$(aws secretsmanager get-secret-value --secret-id $secret_id | jq -r ".SecretString | fromjson | .username")' >> ~/.profile
echo 'export AWS_DB_PW=$(aws secretsmanager get-secret-value --secret-id $secret_id | jq -r ".SecretString | fromjson | .password")' >> ~/.profile

# RDSインスタンスの情報を取得し、RDSエンドポイントを抽出して環境変数に設定、~/.profileに追記
echo 'export AWS_DB_HOST=$(aws rds describe-db-instances --db-instance-identifier $db_instance_identifier --query 'DBInstances[0].Endpoint.Address' --output text)' >> ~/.profile

# MySQLデータベースサーバーのUNIXソケットファイルへのパスを環境変数に設定し、~/.profileに追記
echo 'export DB_SOCKET_PATH=$(mysql_config --socket)' >> ~/.profile

# ALB名の情報を取得し、ALBエンドポイント(DNS名)を抽出して環境変数に設定し、~/.profileに追記
echo 'export AWS_ALB_ENDPOINT=$(aws elbv2 describe-load-balancers --names $alb_name  | jq -r ".LoadBalancers[0].DNSName")' >> ~/.profile

# アクセスキー・シークレットアクセスキーの情報を取得して環境変数に設定、~/.profileに追記
# (※CircleCIのGUIコンソール上で設定した環境変数の値を使用)
echo 'export AWS_S3_ACCESS_KEY=$AWS_ACCESS_KEY_ID' >> ~/.profile
echo 'export AWS_S3_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY' >> ~/.profile

# リージョン情報を取得して環境変数に設定、~/.profileに追記
# (※CircleCIのGUIコンソール上で設定した環境変数の値を使用)
echo 'export AWS_S3_REGION=$AWS_DEFAULT_REGION' >> ~/.profile

# S3バケット名を環境変数に設定、~/.profileに追記
echo 'export AWS_S3_BUCKET=$s3_name' >> ~/.profile


###################################
# ~/.profile 読込み
source ~/.profile

# 確認用：※必要に応じてコメントアウト
echo "############# 環境変数：確認 #############"
printenv | grep -E 'AWS|DB_SOCKET_PATH'
echo "##########################################"
