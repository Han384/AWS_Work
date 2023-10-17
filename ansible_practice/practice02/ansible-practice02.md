# 【 Ansible ( advance )： サンプルアプリケーションのデプロイ・手動構築の自動化 】

## ■ 本実践内容の概要・手順・補足
- [lecture05.md](../../Tasks/lecture05/lecture05.md) の サンプルアプリケーションのデプロイ・手動構築 を Ansible にて自動化
- インフラリソースについては、[lecture10 の CloudFormation_templates (シングルAZ構成)](../../Tasks/lecture10/CloudFormation_templates/) を使用<br>
( 補足：EC2以外のリソースを構築 )
- 上記環境上に EC2 ×2 (コントロールノード・ターゲットノード) をマネージメントコンソールで作成し、Ansibleを実行<br>
( 補足：コントロールノードがターゲットノードへSSH接続する設定を必要に応じて実施 )
- コントロールノードからターゲットノードへ  OS/ミドルウェアレイヤーのインストール・設定・起動等を自動実行
- 動作環境
  - EC2： t2.medium を使用<br>
  ( ※ t2.micro ではリソース不足でインストール処理が進まなくなるため)
  - 各種バージョンなど
- 構成図


## ■ 事前準備 ( コントロールノード：環境変数設定など )
- AWS CLI を使用できるように設定　`aws configure`
- jq をインストール & AWS CLI を介して情報取得した値を環境変数に設定<br>
( ※一連の処理を行うため、右記シェルスクリプトを作成：[env_set.sh](./ansible-practice02/env_set.sh) )<br>
( ※補足：IaCで新規にRDSを起動した場合、SecretMangerも新規作成され、シークレットの名前の値が変更となるため適宜マネージメントコンソール上のSSMパラメータストアの情報の書き換えが必要 )
- `ansible-practice02` ディレクトリ内で下記コマンドを実行
  ```
  # 作成したシェルスクリプトに実行権限付与
  $ chmod +x env_set.sh

  # シェルスクリプト実行(※親シェルで実行)
  $ source env_set.sh

  # 環境変数が設定されているか確認
  $ printenv | grep -E 'AWS|DB_SOCKET_PATH'
  ```

## ■ ディレクトリ・ファイル構成
- コントロールノード上で下記ディレクトリ・ファイル群を作成
```
ansible-practice02
│
├── ansible.cfg
├── env_set.sh
├── inventory
├── playbook.yml
├── roles
│   ├── 00_common
│   │   └── tasks
│   │       └── main.yml
│   ├── 01_ruby
│   │   └── tasks
│   │       └── main.yml
│   ├── 02_bundler_rails
│   │   └── tasks
│   │       └── main.yml
│   ├── 03_node_yarn
│   │   └── tasks
│   │       └── main.yml
│   ├── 04_mysql
│   │   └── tasks
│   │       └── main.yml
│   ├── 05_app_puma
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── templates
│   │       └── database.yml.j2
│   └── 06_app_nginx_unicorn
│       ├── tasks
│       │   └── main.yml
│       └── templates
│           └── raisetech-live8-sample-app.conf.j2
└── vars.yml

17 directories, 14 files
```
## ■ Ansible実行 ( コントロールノード上で実行 )
- ターゲットノードへの疎通確認：`andible`コマンドで実行　( pingモジュールを使用 )<br>
( ※ `ansible-practice02` ディレクトリ内でコマンドを実行 )
  ```
  $ ansible -i inventory target_node -m ping
  ```
- 各種ファイル作成後、`ansible-playbook` コマンドでplaybook記載の処理を実行<br>
( ※ `ansible-practice02` ディレクトリ内でコマンドを実行 )
  ```
  $ ansible-playbook -i inventory playbook.yml
  -------------------------------------
  (参考)
  $ ansible-playbook -i inventory playbook.yml --check       #ドライラン
  $ ansible-playbook -i inventory playbook.yml -vvv          #デバッグ
  $ ansible-playbook -i inventory playbook.yml --check -vvv  #ドライラン + デバッグ
  ```
## ■ 動作確認
- 組み込みサーバ (Puma) で起動

## ■所感・取組観点など
- 次回は、CircleCIを使用して全自動化を行っていきたい

## ■ 参考リンク
【 Ansible全般 】
- [【公式ドキュメント】 Ansible tips and tricks General tips](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html)
- [【公式ドキュメント】 Playbook の使用 - ベストプラクティス](https://docs.ansible.com/ansible/2.9_ja/user_guide/playbooks_best_practices.html)
- [構成管理ツールのAnsibleについて丁寧に解説してみた](https://qiita.com/yuta-ushijima/items/decd8a5b6035fe76c010)
- [Ansibleで始めるインフラ構築自動化](https://www.slideshare.net/dcubeio/ansible-72056386)
- [AnsibleのRole入門](https://dev.classmethod.jp/articles/introduction_about_role/)
- [Playbookを再利用しやすくするRoleの基本と共有サービスAnsible Galaxyの使い方](https://atmarkit.itmedia.co.jp/ait/articles/1610/05/news013_2.html)

【 Ansible：モジュール関連 】
  - [【公式ドキュメント】 ansible.builtin.yum module – Manages packages with the yum package manager](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/yum_module.html)
  - [[Ansible] yum モジュールの基本的な使い方（パッケージのインストールなど）](https://tekunabe.hatenablog.jp/entry/2019/02/24/ansible_yum_intro)
  - [Ansibleのyum module:各state(present,installed,latest,absent,removed)の違い](https://qiita.com/tkit/items/7ad3e93070e97033f604)
- [community.general.gem module – Manage Ruby gems](https://docs.ansible.com/ansible/latest/collections/community/general/gem_module.html)
- [ansible.builtin.shell module – Execute shell commands on targets](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html)
- [ansible.builtin.command module – Execute commands on targets](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/command_module.html)
- [ansible.builtin.blockinfile module – Insert/update/remove a text block surrounded by marker lines](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html)
- [ansible.builtin.file module – Manage files and file properties](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html)
- [ansible.builtin.stat module – Retrieve file or file system status](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/stat_module.html)
- []()
- []()
- []()
