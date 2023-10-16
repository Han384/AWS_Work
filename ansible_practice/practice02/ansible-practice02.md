# 【 Ansible ( advance )： サンプルアプリケーションのデプロイ・手動構築の自動化 】

## ■ 本実践内容の概要
- [lecture05.md](../../Tasks/lecture05/lecture05.md) の サンプルアプリケーションのデプロイ・手動構築 を Ansible にて自動化
- 環境
  - EC2： t2.medium を使用　(※リソース不足でインストールが進まなくなるため)
  - 動作環境


## ■ 事前準備 ( コントロールノードの EC2 上で下記を実行 )
- AWS CLI を使用できるように設定　`aws configure`
- jq をインストール & AWS CLI を介して情報取得した値を環境変数に設定<br>
( ※シェルスクリプトにて実行：[]() )
- `ansible-practice02` ディレクトリ内で下記コマンドを実行
  ```
  # 実行権限付与
  $ chmod +x env_set.sh

  # 一連の処理をシェルスクリプトにて実行
  $ ./env_set.sh

  # ~./bash_profile 読込み
  $ source ~/.bash_profile

  # 環境変数が設定されているか確認
  $ printenv | grep -E 'AWS|DB_SOCKET_PATH'
  ```

## ■ 各種ファイル作成
- ディレクトリ・ファイル構成
```
ansible-practice02
│
├── ansible.cfg
├── env_set.sh
├── inventory
├── playbook.yml
├── roles
│   ├── 00_common_packages
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
│   └── 06_application
│       ├── tasks
│       │   └── main.yml
│       └── templates
│           └── database.yml.j2
└── vars.yml

14 directories, 12 files
```
- 各種ファイル作成後、`ansible-playbook` コマンドでplaybook記載の処理を実行<br>
( ※ansible-practice02 ディレクトリ内でコマンドを実行 )
  ```
  $ ansible-playbook -i inventory playbook.yml
  -------------------------------------
  (参考)
  $ ansible-playbook -i inventory playbook.yml --check       #ドライラン
  $ ansible-playbook -i inventory playbook.yml -vvv          #デバッグ
  $ ansible-playbook -i inventory playbook.yml --check -vvv  #ドライラン + デバッグ
  ```



## ■ 参考リンク
【 Ansible全般 】
- [【公式ドキュメント】 Ansible tips and tricks General tips](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html)
- [【公式ドキュメント】 Playbook の使用 - ベストプラクティス](https://docs.ansible.com/ansible/2.9_ja/user_guide/playbooks_best_practices.html)
- [構成管理ツールのAnsibleについて丁寧に解説してみた](https://qiita.com/yuta-ushijima/items/decd8a5b6035fe76c010)
- [Ansibleで始めるインフラ構築自動化](https://www.slideshare.net/dcubeio/ansible-72056386)
- [AnsibleのRole入門](https://dev.classmethod.jp/articles/introduction_about_role/)
- [Playbookを再利用しやすくするRoleの基本と共有サービスAnsible Galaxyの使い方](https://atmarkit.itmedia.co.jp/ait/articles/1610/05/news013_2.html)

【 モジュール関連 】
- yumモジュール
  - [【公式ドキュメント】 ansible.builtin.yum module – Manages packages with the yum package manager](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/yum_module.html)
  - [[Ansible] yum モジュールの基本的な使い方（パッケージのインストールなど）](https://tekunabe.hatenablog.jp/entry/2019/02/24/ansible_yum_intro)
  - [Ansibleのyum module:各state(present,installed,latest,absent,removed)の違い](https://qiita.com/tkit/items/7ad3e93070e97033f604)
- []()
- []()
- []()
- []()
- []()
- []()
- []()
- []()
- []()
