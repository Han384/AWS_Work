# 【 Terraform：冗長化構成 ( redundant configuration ) に変更 】

## ■ 構成図
 - 変更前　( シングルAZ構成 )
 ![resource_diagram.png](../../Tasks/lecture10/images/resource_diagram.png)

- 変更後　( マルチAZ構成 )
  ![cfn-practice01.png](../../cloudformation/practice01/images/cfn-practice01.png)

## ■ インフラリソースの追加・設定変更
- [tf_practice01.md (シングルAZ構成)](../practice01/tf_practice01.md) で作成した既存の [terraform_files](../practice01/terraform_files) に、上図の マルチAZ・冗長化構成 となるよう下記内容を追記・修正　( ※ [cfn_practice01.md ( マルチAZ・冗長化構成 )](../../cloudformation/practice01/cfn_practice01.md) と同様の内容のリソース構築を Terraform にて実施 )
  - EC2 - シングルAZ から マルチAZ配置<br>
  ( ※起動テンプレートを作成、AutoScalingに適用してEC2を起動 )<br>
  ( ※既存のEC2の記述は削除 (コメントアウト) )
  - RDS - シングルAZ から マルチAZ配置　( ※MautiAZの有効化 )
- 作成後の tfファイル：[terraform_files_redundant_configuration](./terraform_files_redundant_configuration)

## ■ Terraform CLI で下記コマンドを実行してリソース構築
```
$ pwd
/terraform_files_redundant_configuration

$ aws-vault exec <プロファイル名>  # subshell が起動、MFAコードを入力

$ terraform init  #初期化

$ terraform plan  #ドライラン

$ terraform apply -auto-approve  #リソース構築
```

## ■ 作成リソース
- [terraform_files_redundant_configuration](./terraform_files_redundant_configuration) - ファイル構成
```
terraform_files_redundant_configuration
|-- 01_vpc.tf
|-- 02_securitygroup.tf
|-- 03_rds_multiaz.tf      # MautiAZを有効化
|-- 04_ec2_autoscaling.tf  # 起動テンプレート作成・AutoScaling設定
|-- 04_ec2_userdata.sh  　 # Autoscaling(ALBヘルスチェック対応)・RDS接続等確認用
|-- 05_iam.tf
|-- 06_elb_autoscaling.tf  # 起動テンプレート・AutoscalingによるEC2起動に伴う記述修正
|-- 07_s3.tf
|-- data.tf
|-- main.tf
`-- terraform.tfvars
```
- 構築リソース　( 下記コマンドを実行して作成されたリソース一覧を表示 )
```
$ terraform state list

data.aws_ami.EC2WebServer01
data.aws_iam_policy_document.ec2_assume_role
data.aws_ssm_parameter.KeyName-terraform
data.aws_ssm_parameter.MasterUsername-terraform
data.aws_ssm_parameter.myIP-terraform
aws_autoscaling_group.AutoScalingGroup
aws_db_instance.RDSDBInstance
aws_db_subnet_group.RDSDBSubnetGroup
aws_iam_instance_profile.EC2InstanceProfile
aws_iam_role.EC2IAMRole
aws_iam_role_policy_attachment.EC2IAMRole_ssm_managed
aws_internet_gateway.TerraformInternetGateway
aws_launch_template.EC2LaunchTemplate
aws_lb.ALB
aws_lb_listener.ALBListener_http
aws_lb_target_group.ALBTargetGroup
aws_route.PublicRoute
aws_route_table.PrivateRouteTable
aws_route_table.PublicRouteTable
aws_route_table_association.PrivateSubnet1aRouteTableAssociation
aws_route_table_association.PrivateSubnet1cRouteTableAssociation
aws_route_table_association.PublicSubnet1aRouteTableAssociation
aws_route_table_association.PublicSubnet1cRouteTableAssociation
aws_s3_bucket.S3Bucket
aws_s3_bucket_server_side_encryption_configuration.S3Bucket
aws_security_group.ALBSecurityGroup
aws_security_group.EC2SecurityGroup
aws_security_group.RDSSecurityGroup
aws_security_group_rule.alb_egress
aws_security_group_rule.alb_in_http
aws_security_group_rule.ec2_web_in_http_from_ALB
aws_security_group_rule.ec2_web_in_ssh
aws_security_group_rule.ec2_web_in_tcp3000
aws_security_group_rule.rds_egress
aws_security_group_rule.rds_in_tcp3306_from_ec2
aws_security_group_rule.web_egress
aws_subnet.PrivateSubnet1a
aws_subnet.PrivateSubnet1c
aws_subnet.PublicSubnet1a
aws_subnet.PublicSubnet1c
aws_vpc.TerraformVPC
random_string.s3_unique_key
```
## ■ 検証・動作確認・工夫点・備忘録
【 AutoScaling を使用した EC2 の起動に関して 】
- 起動テンプレート・AutoScalingを使用してEC2を起動する際、ALBのヘルスチェックが Unhealty だと EC2 が起動と終了を繰り返してしまう
- そのため、起動テンプレートが参照するユーザデータファイル `04_ec2_userdata.sh` に、 `httpd` をインストールして空の `index.html` を `/var/www/html` 配下に作成する記述を行いヘルスチェックが通るよう対応<br>

【 EC2 / RDS の接続・データ同期等の確認に関して 】
- EC2へは SessionManager にて接続
- その後、EC2 から RDS への接続確認は MySQLコマンド にてログインを実施　( ※RDSのエンドポイントを指定してログイン )
- その際にDB・テーブル・レコードを作成し、他AZ配置のEC2より作成されたRDSのレコードが参照できるかを確認
- 上記状態で RDS をフェイルオーバーして再起動を実施、スタンバイ(Slave)側のAZに切り替わっていることを確認<br>( ※RDSのイベントログも確認 )
- その後、各AZに配置されている EC2 より再度 RDS へ MySQLコマンド にてログイン
- 作成したレコードが参照できることを確認し、データが アクティブ(Master) / スタンバイ(Slave) で同期されていることを確認

## ■ 参考リンク
- Terraform公式ドキュメント関連
  - [Resource: aws_db_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance)
  - [Resource: aws_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#instance_type)
  - [Resource: aws_lb_target_group_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment)
  - [Resource: aws_autoscaling_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#mixed_instances_policy)
- AWS公式ドキュメント関連
  - [AWS::RDS::DBInstance](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-rds-dbinstance.html)
  - [Use instance scale-in protection](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-instance-protection.html)
