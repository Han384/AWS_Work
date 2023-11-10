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
- CircleCI の実行結果を確認　( ※ 実行完了時間：約35分 )
- 実際にデプロイが成功しているか動作確認　( ※ ブラウザ / SessionManager 等で確認 )<br>

<br>

- ( 補足 ) 作成ファイル群
  - 【 CircleCI実行ファイル：[.circleci/config.yml](../.circleci/config.yml) 】
  -  【 動的対応 - IPアドレス追加・環境変数設定など ：[/circleci_practice](../circleci_practice/) ( ※シェルスクリプトを作成・実行 ) 】

## ■ 構成図・自動化処理フロー図
![](./images/circleci_practice01_00.png)

## ■ CircleCI - .circleci/config.yml の関連ファイル構成
- 【 CircleCI実行ファイル：[.circleci/config.yml](../.circleci/config.yml) 】
  ```
  /AWS_Work　
    |
    |-- .circleci
    |   `-- config.yml
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

## ■ 実行結果 確認
- CircleCI 一連の実行 ( パイプライン ) 結果：成功　( ※実行完了時間：約35分 )<br>
![circleci_practice01_01.png](./images/circleci_practice01_01.png)
- cfn-lint の実行結果：成功<br>
![circleci_practice01_02.png](./images/circleci_practice01_02.png)
- CloudFormation の実行結果：成功<br>
![circleci_practice01_03.png](./images/circleci_practice01_03.png)<br>
( CloudFormation - 作成した スタック / リソース )<br>
![circleci_practice01_08.png](./images/circleci_practice01_08.png)
![circleci_practice01_09.png](./images/circleci_practice01_09.png)
![circleci_practice01_10.png](./images/circleci_practice01_10.png)
![circleci_practice01_11.png](./images/circleci_practice01_11.png)
![circleci_practice01_12.png](./images/circleci_practice01_12.png)
![circleci_practice01_13.png](./images/circleci_practice01_13.png)
![circleci_practice01_14.png](./images/circleci_practice01_14.png)
- Ansible の実行結果：成功<br>
![circleci_practice01_04.png](./images/circleci_practice01_04.png)
![circleci_practice01_015.png](./images/circleci_practice01_15.png)
- Serverspec の実行結果：成功<br>
![circleci_practice01_05.png](./images/circleci_practice01_05.png)
![circleci_practice01_07.png](./images/circleci_practice01_07.png)

## ■ 動作確認
- ALBのヘルスチェック：正常<br>
![circleci_practice01_16.png](./images/circleci_practice01_16.png)
- ALBのDNS名をブラウザに入力し表示確認<br>
![circleci_practice01_17.png](./images/circleci_practice01_17.png)
![circleci_practice01_18.png](./images/circleci_practice01_18.png)
- データ登録確認①　( ブラウザ：テキスト・画像の登録 )<br>
![circleci_practice01_19.png](./images/circleci_practice01_19.png)
![circleci_practice01_20.png](./images/circleci_practice01_20.png)
- データ登録確認②<br>
( RDS - MySQL：SessionManagerでターゲットノード(EC2)へログイン、MySQLコマンドを実行して確認  )<br>
![circleci_practice01_24.png](./images/circleci_practice01_24.png)
![circleci_practice01_21.png](./images/circleci_practice01_21.png)
- データ登録確認③<br>
( S3連携：S3へのデータ登録も同時に行われているか確認 (※サイズ違いで同じ画像データが3つ登録されている) )<br>
![circleci_practice01_25.png](./images/circleci_practice01_25.png)
![circleci_practice01_22.png](./images/circleci_practice01_22.png)
- 各種バージョン確認　( SessionManagerでターゲットノード(EC2)へログインして確認 )<br>
![circleci_practice01_23.png](./images/circleci_practice01_23.png)
  | 動作環境 | バージョン |
  | -------- | ---------- |
  | Ruby     | 3.1.2      |
  | Bundler  | 2.3.14     |
  | Rails    | 7.0.4      |
  | Node     | v17.9.1    |
  | Yarn     | 1.22.19    |

## ■ 所感・取組観点など
- 今回はより発展的な内容として、CircleCI にて これまでのサンプルアプリケーションのデプロイ・構築・テスト実行の全自動化を実施
- ようやく以前から行いたかった IaC を活用した一連の手順の自動化を行うことができた
- CircleCI については、以前に実施した [lecture13.md](../Tasks/lecture13/lecture13.md) の発展的な取り組みとして、<br>デプロイ・構築・テスト全手順の組込 (※前回は git のインストール＆テストのみ ) 及び Workspace 機能を活用
- 今回は上記機能を Serverspec 実行時に必要な環境変数設定の目的で使用<br>
 ( 参考：Workspace - 各ジョブ間で共有するスペースを作成し、ファイルやデータを共有する機能  )
- また実践にあたっては、構築の度に動的に変わる部分をシェルスクリプトを作成して対応　( ※内容は下記参照 )<br>
  - [【 /circleci_practice 】](../circleci_practice/) - 今回のシェルスクリプト格納場所
  - [【 add_ec2_ip.sh 】](./add_ec2_ip.sh) - IPアドレス対応　( Ansible-inventoryに追記 / Severspec-ディレクトリ名変更 )
  - [【 env_set_ansible.sh 】](./env_set_ansible.sh) - AWS CLI を使用した環境変数設定など　( Ansible / Serverspec )
  - [【 file_check.sh 】](./file_check.sh) - CircleCI の Workspace に、 Serverspec の環境変数設定を行うシェルスクリプトがあるか確認、なければ作成
- 上記シェルスクリプトも CircleCI の各ジョブに組み込み全自動化を実施、実装したかったことが実現でき大変勉強になった
- 今後の学習は現在検討中だが、適宜題材を探し実践していきたい

## ■ 参考リンク
- [CircleCI 公式ドキュメント：環境変数の概要](https://circleci.com/docs/ja/env-vars/)
- [CircleCI 上の BASH_ENV 環境変数について](https://blog.yukii.work/posts/2021-09-18-circleci-and-bash-env/#gsc.tab=0)
