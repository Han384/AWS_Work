# 【 Ansible： 】

## ■ Ansible の環境構築・設定・処理実行
- コントロールノード用のEC2を起動　( AMI：Amazon Linux 2 )
- SessionManager を使用してログイン、Ansibleインストールのため下記を実行
  ```
  #ユーザ切替
  $ sudo su - ec2-user　

  #yumアップデート
  $ sudo yum -y update

  #Ansibleをインストール
  $ sudo amazon-linux-extras install ansible2 -y

  #インストール確認
  $ ansible --version

  #Pythonインストール確認 (※必要に応じてアップグレード実施)
  $ python -V
  ```
- ターゲットノード用のEC2を起動　( AMI：Amazon Linux 2 )
- SessionManager を使用してログイン後、下記を実行
  ```
  #ユーザ切替
  $ sudo su - ec2-user　

  #yumアップデート
  $ sudo yum -y update
  ```
- コントロールノードにてターゲットノードへのSSH接続設定を実施
  - SecurityGroupを適切に設定
  - ローカルの秘密鍵 (※ターゲットノードへのログインで使う秘密鍵) をコントロールノードの `~/.ssh` 配下に送付
  - コントロールノード上で上記秘密鍵の権限変更　`$ chmod 400 秘密鍵のパス`
  - 接続確認　`$ ssh -i 秘密鍵のパス ec2-user@ターゲットノードのIPアドレス`<br>
  (※この時にログインできない場合、SecurityGroupでコントロールノードのSSH接続が許可されているか確認する)
  - 【補足】 ※別途 `~/.ssh/config` ファイルを使用する方法もある
- コントロールノードにて `playbook.yml` ・ `inventory` を作成
  ```
  $ mkdir ansible
  $ cd ansible
  $ touch playbook.yml inventory
  ```
- コントロールノードの `/etc/hosts` に名前解決ができるよう下記を追記
  ```
  $ sudo vim /etc/hosts
  -------------------------------
  xx.xx.xx.xx(=EC2のパブリックipアドレス) ansible-target01(=ホスト名)
  ```
- `inventory` に接続するターゲットノードの情報を記述<br>
(※事前にコントロールノードからターゲットノードにSSH接続する設定が必要)
  ```
  [target_node]  #グループ名
  ansible-target01  #ホスト名

  [target_node:vars]  #上記グループのホストに適用される変数
  ansible_ssh_user=ec2-user
  ansible_ssh_private_key_file=~/.ssh/xxx.pem(=使用する秘密鍵のパス)
  ```
- `ansibleコマンド` を使用して接続(疎通)確認　( コントロールノード → ターゲットノード (※ansibleディレクトリ内でコマンドを実行) )
  ```
  #inventory記載のホスト単体を指定
  $ ansible -i inventory ansible-target01 -m ping

  #〃のグループ内のホスト群を指定
  $ ansible -i inventory target_node -m ping

  #〃の全てのホストを指定
  $ ansible -i inventory all -m ping
  ```
-  `playbook.yml` に実行させたい処理を記述　(※今回はターゲットノードに Git をインストール)
    ```
    - hosts: target_node
      tasks:
      - name: install git
        become: yes
        yum:
          name: git
          state: latest
          lock_timeout: 180
    ```
- 処理を実行
  ```
  $ ansible-playbook -i inventory playbook.yml

  -------------------------------------
  #ドライラン
  $ ansible-playbook -i inventory playbook.yml --check

  #デバッグ
  $ ansible-playbook -i inventory playbook.yml -vvv

  #ドライラン + デバッグ
  $ ansible-playbook -i inventory playbook.yml --check -vvv
  ```
- ターゲットノードにて Git がインストールされているか確認
  ```
  $ git --version
  ```
