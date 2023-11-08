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

# RDSのSecretsManagerのARNを取得して変数に格納(※以降の工程で使用)
secret_id1=$(aws rds describe-db-instances --db-instance-identifier $db_instance_identifier | jq -r '.DBInstances[0]."MasterUserSecret"."SecretArn"')

# SSMパラメータストアに設定しているSecrets ManagerのIDを取得して変数に格納
secret_id2=$(aws ssm get-parameter --name SecretsManager_SecretName --query 'Parameter.Value' --output text --with-decryption)

# RDSのインスタンス名を取得して変数に格納(※以降の工程で使用)
db_instance_identifier=$(aws rds describe-db-instances --query "DBInstances[*].DBInstanceIdentifier" --output text)

# 特定のVPCIDを取得して変数に格納(※Nameタグで指定・以降の工程で使用)
vpc_id=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=CFnVPC" --query 'Vpcs[*].VpcId' --output text)

# 特定のVPC内のALB名を取得して変数に格納(※VPCIDを指定・以降の工程で使用)
alb_name=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?VpcId=='$vpc_id'].LoadBalancerName" --output text)

# S3バケット名を取得して変数に格納(※Nameタグで指定・以降の工程で使用)
s3_name=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, 'raisetech-cfn-')].Name" --output text)

ec2_name=cfn-ec2-EC2WebServer01

# 確認用：※必要に応じてコメントアウト
echo "##### 変数：確認 #####"
echo $secret_id1
echo $secret_id2
echo $db_instance_identifier
echo $vpc_id
echo $alb_name
echo $s3_name
echo $ec2_name


###################################
# 環境変数設定：下記記述内で上記変数を使用
###################################

# Secrets Managerからユーザー名・パスワードを抽出して環境変数に設定し、~/.profileに追記
echo 'export AWS_DB_USER=$(aws secretsmanager get-secret-value --secret-id $secret_id1 | jq -r ".SecretString | fromjson | .username")' >> ~/.profile
echo 'export AWS_DB_PW=$(aws secretsmanager get-secret-value --secret-id $secret_id1 | jq -r ".SecretString | fromjson | .password")' >> ~/.profile
# echo 'export AWS_DB_USER=$(aws secretsmanager get-secret-value --secret-id $secret_id | jq -r ".SecretString | fromjson | .username")' >> $BASH_ENV
# echo 'export AWS_DB_PW=$(aws secretsmanager get-secret-value --secret-id $secret_id | jq -r ".SecretString | fromjson | .password")' >> $BASH_ENV
# export AWS_DB_USER=$(aws secretsmanager get-secret-value --secret-id $secret_id | jq -r ".SecretString | fromjson | .username") >> $BASH_ENV
# export AWS_DB_PW=$(aws secretsmanager get-secret-value --secret-id $secret_id | jq -r ".SecretString | fromjson | .password") >> $BASH_ENV
# echo export AWS_DB_USER=$(echo $AWS_DB_USER) >> $BASH_ENV
# echo export AWS_DB_PW=$(echo $AWS_DB_PW)" >> $BASH_ENV
# echo export AWS_DB_USER=$(aws secretsmanager get-secret-value --secret-id $secret_id | jq -r ".SecretString | fromjson | .username") >> $BASH_ENV
# echo export AWS_DB_PW="$(aws secretsmanager get-secret-value --secret-id $secret_id | jq -r ".SecretString | fromjson | .password")" >> $BASH_ENV

# RDSインスタンスの情報を取得し、RDSエンドポイントを抽出して環境変数に設定、~/.profileに追記
echo 'export AWS_DB_HOST=$(aws rds describe-db-instances --db-instance-identifier $db_instance_identifier --query 'DBInstances[0].Endpoint.Address' --output text)' >> ~/.profile
# echo export AWS_DB_HOST=$(aws rds describe-db-instances --db-instance-identifier $db_instance_identifier --query 'DBInstances[0].Endpoint.Address' --output text) >> $BASH_ENV

# MySQLデータベースサーバーのUNIXソケットファイルへのパスを環境変数に設定し、~/.profileに追記
echo 'export DB_SOCKET_PATH=$(mysql_config --socket)' >> ~/.profile
# echo export DB_SOCKET_PATH=$(mysql_config --socket) >> $BASH_ENV

# ALB名の情報を取得し、ALBエンドポイント(DNS名)を抽出して環境変数に設定し、~/.profileに追記
echo 'export AWS_ALB_ENDPOINT=$(aws elbv2 describe-load-balancers --names $alb_name  | jq -r ".LoadBalancers[0].DNSName")' >> ~/.profile
# echo export AWS_ALB_ENDPOINT=$(aws elbv2 describe-load-balancers --names $alb_name  | jq -r ".LoadBalancers[0].DNSName") >> $BASH_ENV

# Serverspec実行用のALBエンドポイント(DNS名)を抽出、/tmp/workspace/serverspec-env.shに追記
echo '#!/bin/bash' >> /tmp/workspace/env_set_serverspec.sh
echo export AWS_ALB_ENDPOINT=$(aws elbv2 describe-load-balancers --names $alb_name  | jq -r ".LoadBalancers[0].DNSName") >> /tmp/workspace/env_set_serverspec.sh
# aws elbv2 describe-load-balancers --names $alb_name  | jq -r ".LoadBalancers[0].DNSName" >> /tmp/workspace/env_set_serverspec.txt
echo 'source ~/.profile' >> /tmp/workspace/env_set_serverspec.sh
cat /tmp/workspace/env_set_serverspec.sh

# アクセスキー・シークレットアクセスキーの情報を取得して環境変数に設定、~/.profileに追記
# (※CircleCIのGUIコンソール上で設定した環境変数の値を使用)
echo 'export AWS_S3_ACCESS_KEY=$AWS_ACCESS_KEY_ID' >> ~/.profile
echo 'export AWS_S3_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY' >> ~/.profile
# echo export AWS_S3_ACCESS_KEY=$AWS_ACCESS_KEY_ID >> $BASH_ENV
# echo export AWS_S3_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY >> $BASH_ENV

# リージョン情報を取得して環境変数に設定、~/.profileに追記
# (※CircleCIのGUIコンソール上で設定した環境変数の値を使用)
echo 'export AWS_S3_REGION=$AWS_DEFAULT_REGION' >> ~/.profile
# echo export AWS_S3_REGION=$AWS_DEFAULT_REGION >> $BASH_ENV

# S3バケット名を環境変数に設定、~/.profileに追記
echo 'export AWS_S3_BUCKET=$s3_name' >> ~/.profile
# echo export AWS_S3_BUCKET=$s3_name >> $BASH_ENV

# EC2のパブリックIPを取得して環境変数に設定し、~/.profileに追記
echo 'export AWS_EC2_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$ec2_name" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)' >> ~/.profile

###################################
# ~/.profile 読込み
source ~/.profile
# source $BASH_ENV

# 確認用：※必要に応じてコメントアウト
echo "############# 環境変数：確認① #############"
printenv | grep -E 'AWS|DB_SOCKET_PATH'
echo "############# 環境変数：確認② #############"
printenv | grep BASH_ENV
# cat /tmp/.bash_env-*

###################################
# Ansible実行
# cd ansible_practice/practice02/ansible-practice02/
# ansible-playbook -i inventory playbook.yml
