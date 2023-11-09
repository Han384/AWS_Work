# 【 CircleCI ( 全自動化 )：サンプルアプリケーションのデプロイ・構築・テストを全自動化 】

## ■ 本実践内容の概要
- [lecture05.md](../Tasks/lecture05/lecture05.md) の サンプルアプリケーションのデプロイ・手動構築・テスト実行 を、 CircleCIにて全自動化<br>
( ※ CircleCI に 、これまでの CloudFormatin・Ansible・Serverspec を組み込み自動実行 )
- インフラリソースについては、[lecture10 - CloudFormation_templates (シングルAZ構成)](../Tasks/lecture10/CloudFormation_templates/)、<br>
[lecture13 - CloudFormation_templates (シングルAZ構成)](../Tasks/lecture13/CloudFormation_templates/) を使用して構築
- 上記環境上に[前回](../ansible_practice/practice02/ansible-practice02.md)実施した [Ansible](../ansible_practice/practice02/ansible-practice02/)  を組み込み、Playbook記載内容を実行<br>
( ※ コントロールノードからターゲットノードへ  OS/ミドルウェアレイヤーのインストール・設定・起動等を自動実行 )
- 上記デプロイ・構築後、[前回](../ansible_practice/practice02/ansible-practice02.md)実施した [Serverspec](../ansible_practice/practice02/serverspec/spec/cfn-ec2-EC2WebServer01/sample_spec.rb) にてテストを実行<br>
( ※ コントロールノードからターゲットノードへのテストを自動実行 )
- CircleCI の実行結果を確認　( ※ 実行完了時間：約30分 )
- 実際にデプロイが成功しているか動作確認　( ※ ブラウザ等で確認 )<br>

<br>

- ( 補足 ) 作成ファイル群
  - 【 CircleCI実行ファイル：[.circleci/config.yml](../.circleci/config.yml) 】
  -  【 その他、環境変数設定など ( ※シェルスクリプトを作成・実行 )：[/circleci_practice](../circleci_practice/) 】

## ■ 構成図・自動化処理フロー図


## ■ CircleCI - .circleci/config.yml の関連ファイル構成
- [/AWS_Work](../../AWS_Work/)
  ```
  /AWS_Work
    |
    |-- Tasks
    |   |-- lecture10
    |   |   `-- CloudFormation_templates
    |   |       |-- 01_cfn-vpc.yml
    |   |       |-- 03_cfn-rds.yml
    |   |       |-- 05_cfn-elb.yml
    |   |       `-- 06_cfn-s3.yml
    |   `-- lecture13
    |       |-- CloudFormation_templates
    |           |-- 02_cfn-securitygroup-ansible.yml
    |           `-- 04_cfn-ec2-ansible.yml
    |-- ansible.cfg
    |-- ansible_practice
    |   `-- practice02
    |       |-- ansible-practice02
    |       |   |-- inventory
    |       |   |-- playbook.yml
    |       |   |-- roles
    |       |   |   |-- 00_common
    |       |   |   |   `-- tasks
    |       |   |   |       `-- main.yml
    |       |   |   |-- 01_ruby
    |       |   |   |   `-- tasks
    |       |   |   |       `-- main.yml
    |       |   |   |-- 02_bundler_rails
    |       |   |   |   `-- tasks
    |       |   |   |       `-- main.yml
    |       |   |   |-- 03_node_yarn
    |       |   |   |   `-- tasks
    |       |   |   |       `-- main.yml
    |       |   |   |-- 04_mysql
    |       |   |   |   `-- tasks
    |       |   |   |       `-- main.yml
    |       |   |   |-- 05_app_puma
    |       |   |   |   |-- tasks
    |       |   |   |   |   `-- main.yml
    |       |   |   |   `-- templates
    |       |   |   |       `-- database.yml.j2
    |       |   |   |-- 06_s3
    |       |   |   |   |-- tasks
    |       |   |   |   |   `-- main.yml
    |       |   |   |   `-- templates
    |       |   |   |       `-- storage.yml.j2
    |       |   |   `-- 07_app_nginx_unicorn
    |       |   |       |-- tasks
    |       |   |       |   `-- main.yml
    |       |   |       `-- templates
    |       |   |           `-- raisetech-live8-sample-app.conf.j2
    |       |   `-- vars.yml
    |       `-- serverspec
    |           |-- Gemfile
    |           |-- Gemfile.lock
    |           |-- Rakefile
    |           `-- spec
    |               |-- cfn-ec2-EC2WebServer01
    |               |   `-- sample_spec.rb
    |               `-- spec_helper.rb
    `-- circleci_practice
        |-- add_ec2_ip.sh
        |-- env_set_ansible.sh
        `-- file_check.sh
  ```

## ■ 実行結果
- CircleCI 一連の実行 ( パイプライン ) 結果<br>
![]()
- cfn-lint の実行結果<br>
![]()
- CloudFormation の実行結果<br>
![]()<br>
( CloudFormation - スタック / リソース )<br>
![]()
![]()
![]()
![]()
![]()
![]()
![]()
- Ansible の実行結果<br>
![]()
- ServerSpec の実行結果<br>
![]()
![]()

## ■ 動作確認
- ALBのヘルスチェック：正常<br>
![]()
- ALBのDNS名をブラウザに入力し表示確認<br>
![]()
- データ登録確認①　( ブラウザ：テキスト・画像の登録 )<br>
![]()
![]()
- データ登録確認②<br>
( RDS - MySQL：SessionManagerでターゲットノードへログイン、MySQLコマンドを実行して確認  )<br>
![]()
- データ登録確認③<br>
( S3連携：S3へのデータ登録も同時に行われているか確認 (※サイズ違いで同じ画像データが3つ登録されている) )<br>
![]()
- 各種バージョン確認　( SessionManagerでターゲットノードへログインして確認 )<br>
![]()
  | 動作環境 | バージョン |
  | -------- | ---------- |
  | Ruby     | 3.1.2      |
  | Bundler  | 2.3.14     |
  | Rails    | 7.0.4      |
  | Node     | v17.9.1    |
  | Yarn     | 1.22.19    |

## ■ 所感・取組観点など
- 今回はより発展的な内容として、CircleCI にて<br>
これまでのサンプルアプリケーションのデプロイ・構築・テスト実行の全自動化を実施
- ようやく以前から行いたかった IaC を活用した一連の手順の自動化を行うことができた
- 実践にあたっては、構築の度に動的に変わる部分をシェルスクリプトを作成して対応<br>
( ※IPアドレス・環境変数設定など：[/circleci_practice](../circleci_practice/) )
- 上記を CircleCI の各ジョブに組み込み全自動化を実施
- シェルスクリプト作成についても以前から作成したかったため、実装したかったことが実現できて大変勉強になった
- 今後の学習は現在検討中だが、適宜題材を探し、実践していきたい

## ■ 参考リンク
- [CircleCI 公式ドキュメント：環境変数の概要](https://circleci.com/docs/ja/env-vars/)
- [CircleCI 上の BASH_ENV 環境変数について](https://blog.yukii.work/posts/2021-09-18-circleci-and-bash-env/#gsc.tab=0)
