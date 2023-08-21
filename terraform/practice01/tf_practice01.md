# 【 IaC / Terraform を使用したインフラリソースの構築 】

- [事前準備](#-事前準備)
- [初期設定・Backend設定・初期化実行・tfstateファイル生成確認](#-初期設定backend設定初期化実行tfstateファイル生成確認)
- [ディレクトリ・ファイル構成](#-ディレクトリファイル構成)
- [作成リソース一覧](#-作成リソース一覧)
- [感想・取組観点 など](#-感想取組観点-など)
- [参考リンク](#-参考リンク)

---

- CloudFormation で構築したインフラリソースの構成 を Terraform で構築
  - 【参考】 [第10回 - 構成図](../../Tasks/lecture10/lecture10.md)
  ![resource_diagram.png](../../Tasks/lecture10/images/resource_diagram.png)

## ■ 事前準備
- ローカルPCに `AWS CLI` をインストール・プロファイル設定
  - 必要に応じてIAMユーザーを作成・MFA設定
  - プロファイルは `.aws` 配下を参照
- ローカルPCに `Terraform CLI` をインストール
  - 必要に応じて `tfenv` 等のバージョン管理ツールを使用・パスを通す
  - インストール確認　 `terraform -v`
- ローカルPCに `aws-vault` をインストール
  - 必要に応じてパスを通す
  - 設定 ( プロファイル追加 )　`aws-vault add <プロファイル名>`
  - 設定確認 ( Profile・Credentials・Sessions 確認  )　`aws-vault list`
- ローカルPCにの VSCode に拡張機能をインストール
- AWSの S3 に tfstateファイル の管理用バケットを作成
  - バケット名は任意
  - バージョンニングを有効化

## ■ 初期設定・Backend設定・初期化実行・tfstateファイル生成確認
- 各種ディレクトリ・ファイルを作成
  - `main.tf`  に、 各ブロック：`terraform`, `provider`, `terraform - backend`, `variable` ・設定内容を記述
  - 別途、必要に応じて `terrarorm.tfvars` などのファイルに変数を定義
  - `.gitignore` を作成、認証情報等を GitHub (リモートリポジトリ) にアップロードしないよう記述を行い、ルートディレクトリに配置
- backend設定の記述を `main.tf` に記載　( 参照：[backend - S3](https://developer.hashicorp.com/terraform/language/settings/backends/s3) )
  ```
  terraform {
    backend "s3" {
      bucket = "aws-work-terraform-practice01"
      key    = "dev/terraform.tfstate"
      region = "ap-northeast-1"
    }
  }
    ```
  - 【補足】 別ファイルに切り出すことも可能： 例. `backend.tf` に記載
  - 【補足】 複数人でTerraformを扱う場合、S3バックエンドに DynamoDB の排他ロックを設定<br>
  ( ※ `terraform apply` の同時実行等による tfstate の不具合回避のため )
    - 参照：[DynamoDB State Locking](https://developer.hashicorp.com/terraform/language/settings/backends/s3#dynamodb-state-locking)
    - 今回は複数人での作業は行わないため、ロックは未適用
- 初期化を実行
  ```
  $ aws-vault exec <追加設定したプロファイル名>  # subshell が起動、MFAコードを入力
  $ terraform init  # 初期化を実行
  ```
  - 【補足】 Modeule機能を活用している場合、各環境ごと ( dev/stg/prodなど ) に実行<br>
  ( ※必要に応じて各環境のディレクトリに移動して初期化に必要なコマンドを実行 )
- 各種ファイル群が作成されることを確認
- リソース構築 実行
  - 【補足】 Terraform は直接APIを叩いて実行するため、 CFn の実行時の様にスタックは作成されない
  ```
  $ terraform apply -auto-approve
  ```
- backend設定で指定した S3バケット・パス に tfstateファイル が作成されることを確認

<details><summary>【参考】 backend設定に関して</summary>

  - backend設定(記述)では variable が使用できないため、ハードコーディングを避ける方法として<br>
  init コマンド実行時に引数を渡して初期化を実行する方法がある　 ( ※下記は 設定記述・実行例 )
    ```
    # 設定ファイルに backend設定を記述
    --------------------------------
    terraform {
      backend "s3" {
      }
    }
    --------------------------------

    # 下記コマンドにて引数を渡して初期化を実行
    $ terraform init -backend-config="profile=プロファイル名" \
                      -backend-config="bucket=aws-work-terraform" \
                      -backend-config="key=dev/terraform.tfstate" \
                      -backend-config="region=ap-northeast-1"
    ```
</details>

<details><summary>【参考】 Terraform CLI 実行方法</summary>

- 実行方法①　(※一時的な認証情報を使用して subshell を開始)
    ```
    $ aws-vault exec <追加設定したプロファイル名>
    ```
  - MFA を求められるため MFAコード を入力
  - 必要に応じて shell 切替　`bash`
  - 以降、terraformコマンド を実行
  - 終了時、 exit を実行
- 実行方法②　(※都度 `aws-vault exec` コマンドを実行)
  ```
  $ aws-vault exec <追加設定したプロファイル名> -- terraform <実行したいコマンド>
  ```
  - MFA を求められるため MFAコード を入力

  <br>

</details>

## ■ ディレクトリ・ファイル構成
- [/AWS_Work/terraform/practice01/terraform_files](../practice01/terraform_files/) 配下の各種ファイル群
```
$ tree
.
|-- 01_vpc.tf
|-- 02_securitygroup.tf
|-- 03_rds.tf   # RDS に SecretsManager による認証情報 (シークレット) 管理を適用するための記述を実施
|-- 04_ec2.tf
|-- 05_iam.tf   # EC2 に SessionManager を適用するための記述を実施
|-- 06_elb.tf
|-- 07_s3.tf
|-- data.tf     # SSMパラメータストア・AMIに関する記述を実施
|-- main.tf     # 全体的な設定関連の記述を実施
`-- terraform.tfvars   # 変数定義を記述 (※.gitigonore にリモートリポジトリへアップロードされないよう記述を実施)
```

## ■ 作成リソース一覧
- リソース構築後、下記コマンドを実行して作成されたリソース一覧を表示
```
$ terraform state list

data.aws_ami.EC2WebServer01
data.aws_iam_policy_document.ec2_assume_role
data.aws_ssm_parameter.KeyName-terraform
data.aws_ssm_parameter.MasterUsername-terraform
data.aws_ssm_parameter.myIP-terraform
aws_db_instance.RDSDBInstance
aws_db_subnet_group.RDSDBSubnetGroup
aws_iam_instance_profile.EC2InstanceProfile
aws_iam_role.EC2IAMRole
aws_iam_role_policy_attachment.EC2IAMRole_ssm_managed
aws_instance.EC2WebServer01
aws_internet_gateway.TerraformInternetGateway
aws_lb.ALB
aws_lb_listener.ALBListener_http
aws_lb_target_group.ALBTargetGroup
aws_lb_target_group_attachment.instance
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

## ■ 感想・取組観点 など
- 実践にあたっては、Terraformの公式ドキュメント等を確認して取り組みを実施
- 公式ドキュメントは、AWSの公式ドキュメントと似通っている部分があるため慣れると見やすい
- CloudFormation とはまた違った使用感があるが、基本的なことは共通している部分があるため構築はこれまでの知識を活かすことができた
- また Former2 を活用して既存リソースからのコード抽出も実施、公式ドキュメントではわかりにくかった記述方法を参考にした
- 実際の複数環境ごと ( dev/stg/prodなど ) の運用管理は、現場ごとに違うためそちらは実務で勉強していきたい<br>
( ※modules・workspace を使用しての運用管理 )
- Terraform はマルチクラウドに対応しているため、継続して学習し、今後に活かしていきたい

## ■ 参考リンク
- [Terraform](https://www.terraform.io/)
- [Terraform - Providers](https://registry.terraform.io/browse/providers)
- [【公式ドキュメント】  AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [【公式ドキュメント】  Random Provider](https://registry.terraform.io/providers/hashicorp/random/latest/docs)
- [Terraform Language Documentation](https://developer.hashicorp.com/terraform/language)
- [Terraform Language Documentation - S3](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
- [Terraform Language Documentation - S3 - DynamoDB State Locking](https://developer.hashicorp.com/terraform/language/settings/backends/s3#dynamodb-state-locking)
- [Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure)
- [Terraform CLI Documentation](https://developer.hashicorp.com/terraform/cli)
- [【Terraform】よく使用するコマンドについて書きます。](https://qiita.com/empty948/items/7db361ad875b778a456a)
- [Terraformでクレデンシャルを読み込む方法あれこれ](https://qiita.com/Hikosaburou/items/1d3765d85d5398e3763f)
- [Terraformの「ここはvariable使えないのか...」となった所](https://qiita.com/ymmy02/items/e7368abd8e3dafbc5c52)
- [[Terraform CLI]MFA認証を使ったAssumeRole。AWSVaultで解決](https://dev.classmethod.jp/articles/terraform-assumerole/)
- [【aws-vault】AWS Credential設定](https://zenn.dev/himekoh/books/202210261312/viewer/aws-vault)
- [Windows + aws-vaultにて、AWSのアクセスキーを保護し、 AWS CLIを AssumeRole で使えるようにしてみた](https://thinkami.hatenablog.com/entry/2021/02/20/211447)
- [aws-vault](https://github.com/99designs/aws-vault)
- [aws-vault：releases](https://github.com/99designs/aws-vault/releases/tag/v7.2.0)
- [aws-vault：Can't set credentials for a profile with a source_profile directive to itself #835](https://github.com/99designs/aws-vault/issues/835)
- [Terraform職人入門: 日々の運用で学んだ知見を淡々とまとめる](https://qiita.com/minamijoyo/items/1f57c62bed781ab8f4d7)
