#!/bin/bash

###################################
# 各種インストール
###################################

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

ssm_name=SecretsManager_SecretName
vpc_name=CFnVPC
ec2_name=cfn-ec2-EC2WebServer01

# RDSのインスタンス名を取得して変数に格納(※以降の工程で使用)
db_instance_identifier=$(aws rds describe-db-instances --query "DBInstances[*].DBInstanceIdentifier" --output text)

# RDSのSecretsManagerのARNを取得して変数に格納(※以降の工程で使用)
secret_id1=$(aws rds describe-db-instances --db-instance-identifier $db_instance_identifier | jq -r '.DBInstances[0]."MasterUserSecret"."SecretArn"')

# SSMパラメータストアに設定しているSecrets ManagerのIDを取得して変数に格納
# secret_id2=$(aws ssm get-parameter --name $ssm_name --query 'Parameter.Value' --output text --with-decryption)

# 特定のVPCIDを取得して変数に格納(※Nameタグで指定・以降の工程で使用)
vpc_id=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$vpc_name" --query 'Vpcs[*].VpcId' --output text)

# 特定のVPC内のALB名を取得して変数に格納(※VPCIDを指定・以降の工程で使用)
alb_name=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?VpcId=='$vpc_id'].LoadBalancerName" --output text)

# S3バケット名を取得して変数に格納(※Nameタグで指定・以降の工程で使用)
s3_name=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, 'raisetech-cfn-')].Name" --output text)

###################################
# 確認用：※必要に応じてコメントアウト
###################################
echo "##### 変数：確認 #####"
echo $db_instance_identifier
echo $secret_id1
# echo $secret_id2
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

# EC2のパブリックIPを取得して環境変数に設定し、~/.profileに追記
echo 'export AWS_EC2_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$ec2_name" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)' >> ~/.profile

######################################
# 環境変数設定：CircleCiのworkspace機能を活用
######################################

# Serverspec実行用のALBエンドポイント(DNS名)を抽出、/tmp/workspace/serverspec-env.shに追記
echo '#!/bin/bash' >> /tmp/workspace/env_set_serverspec.sh
echo export AWS_ALB_ENDPOINT=$(aws elbv2 describe-load-balancers --names $alb_name  | jq -r ".LoadBalancers[0].DNSName") >> /tmp/workspace/env_set_serverspec.sh
# aws elbv2 describe-load-balancers --names $alb_name  | jq -r ".LoadBalancers[0].DNSName" >> /tmp/workspace/env_set_serverspec.txt

# EC2のパブリックIPを取得、/tmp/workspace/serverspec-env.shに追記
echo export AWS_EC2_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$ec2_name" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text) >> /tmp/workspace/env_set_serverspec.sh

# ~/.profile 読込みを、/tmp/workspace/serverspec-env.shに追記
echo 'source ~/.profile' >> /tmp/workspace/env_set_serverspec.sh

# /tmp/workspace/env_set_serverspec.shの記述内容を確認
cat /tmp/workspace/env_set_serverspec.sh

###################################
# ~/.profile 等、読込み
###################################
source ~/.profile
# source $BASH_ENV

###################################
# 確認用：※必要に応じてコメントアウト
###################################
echo "############# 環境変数：確認① #############"
printenv | grep -E 'AWS|DB_SOCKET_PATH'
echo "############# 環境変数：確認② #############"
printenv | grep BASH_ENV
# cat /tmp/.bash_env-*
