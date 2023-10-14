# 【 Ansible ( advance )： サンプルアプリケーションのデプロイ・手動構築の自動化 】

## ■ 本実践内容の概要
- [lecture05.md](../../Tasks/lecture05/lecture05.md) の内容である、サンプルアプリケーションのデプロイ・手動構築を Ansible にて自動実行

## ■ 各種ファイル作成
- ディレクトリ・ファイル構成
```
```
- 各種ファイル作成作成後、`ansible-playbook` コマンドでplaybook記載の処理を実行<br>
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
【Ansible全般】
- [構成管理ツールのAnsibleについて丁寧に解説してみた](https://qiita.com/yuta-ushijima/items/decd8a5b6035fe76c010)
- [Ansibleで始めるインフラ構築自動化](https://www.slideshare.net/dcubeio/ansible-72056386)
- []()



【モジュール関連】
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
