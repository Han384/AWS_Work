#!/bin/bash

# jq：インストール
sudo apt install jq -y


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

# Secrets Managerからユーザー名・パスワードを抽出して /tmp/workspace/env.txt に追記
AWS_DB_USER=$(aws secretsmanager get-secret-value --secret-id $secret_id | jq -r ".SecretString | fromjson | .username" >> /tmp/workspace/env.txt)
AWS_DB_PW=$(aws secretsmanager get-secret-value --secret-id $secret_id | jq -r ".SecretString | fromjson | .password" >> /tmp/workspace/env.txt)


# RDSインスタンスの情報を取得し、RDSエンドポイントを抽出して /tmp/workspace/env.txt に追記
AWS_DB_HOST=$(aws rds describe-db-instances --db-instance-identifier $db_instance_identifier --query 'DBInstances[0].Endpoint.Address' --output text >> /tmp/workspace/env.txt)


# MySQLデータベースサーバーのUNIXソケットファイルへのパスを /tmp/workspace/env.txt に追記
DB_SOCKET_PATH=$(mysql_config --socket >> /tmp/workspace/env.txt)

# ALB名の情報を取得し、ALBエンドポイント(DNS名)を抽出して /tmp/workspace/env.txt に追記
AWS_ALB_ENDPOINT=$(aws elbv2 describe-load-balancers --names $alb_name  | jq -r ".LoadBalancers[0].DNSName" >> /tmp/workspace/env.txt)

# アクセスキー・シークレットアクセスキーの情報を取得して /tmp/workspace/env.txt に追記
# (※実運用では別途セキュリティ対策が必要：今回は便宜上 下記にて情報取得)
# (※CircleCIのGUIコンソール上の環境変数からも設定を行っているが、こちらは別方法の確認のため実施)
AWS_S3_ACCESS_KEY=$(aws configure get aws_access_key_id >> /tmp/workspace/env.txt)
AWS_S3_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key >> /tmp/workspace/env.txt)

# リージョン情報を取得して /tmp/workspace/env.txt に追記
# (※CircleCIのGUIコンソール上の環境変数からも設定を行っているが、こちらは別方法の確認のため実施)
AWS_S3_REGION=$(aws configure get region >> /tmp/workspace/env.txt)

# S3バケット名を取得して /tmp/workspace/env.txt に追記
AWS_S3_BUCKET=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, 'raisetech-cfn-')].Name" --output text >> /tmp/workspace/env.txt)
