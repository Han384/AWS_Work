# 【 lecture13：構成管理(プロビジョニング)ツール ( Ansible ) / CircleCIへの組込 】

## ■ Ansible の環境構築・設定・処理実行
- コントロールノード用のEC2を起動　( AMI：Amazon Linux 2 )
- SessionManager を使用してログイン、Ansibleインストールのため下記を実行
  ```
  #bash切替
  $ bash　

  #ユーザ切替
  $ sudo su - ec2-user　

  #yumアップデート
  $ sudo yum -y update

  #Ansibleが使用できるか確認
  $ amazon-linux-extras | grep ansible

  #Ansibleを有効化
  $ sudo amazon-linux-extras enable ansible2

  #Ansibleをインストール
  $ sudo yum install -y ansible

  #インストール確認
  $ ansible --version

  #Pythonインストール確認 (※必要に応じてアップグレード実施)
  $ python -V
  ```
- ターゲットノード用のEC2を起動　( AMI：Amazon Linux 2 )
- ログイン後、下記を実行
  ```
  #yumアップデート
  $ sudo yum -y update
  ```
- コントロールノードにてターゲットノードへのSSH接続設定を実施
  - SecurityGroupを適切に設定
  - ローカルの秘密鍵をコントロールノードの `~/.ssh` 配下に送付
  - 秘密鍵の権限変更　`$ chmod 400 秘密鍵のパス`
  - 接続確認　`$ ssh -i 秘密鍵のパス ec2-user@ターゲットノードのIPアドレス`
  - 【補足】 ※別途 `~/.ssh/config` ファイルを使用する方法もあり
- コントロールノードにて `playbook.yml` ・ `inventory` を作成
  ```
  $ mkdir ansible
  $ cd ansible
  $ touch playbook.yml inventory
  ```
- `inventory` に接続するターゲットノードの情報を記述<br>
(※事前にコントロールノードからターゲットノードにSSH接続する設定が必要)
  ```
  [target_node]
  ターゲットノードのipアドレス

  [target_node:vars]
  ansible_ssh_user=ec2-user
  ansible_ssh_private_key_file="使用する秘密鍵のパス"
  ```
- 接続確認　( コントロールノード → ターゲットノード (※ansibleディレクトリ内でコマンドを実行) )
  ```
  $ ansible -i inventory target_node -m ping
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
## ■ CircleCIへの組込　( CloudFormation / Ansible / ServerSpec )
### ■ CloudFormation によるインフラリソース構築
- [lecture10](../../Tasks/lecture10/lecture10.md) の [CloudFormation_templates - 04_cfn-ec2.yml](../../Tasks/lecture10/CloudFormation_templates/04_cfn-ec2.yml) に下記を追記

```
#EC2 に 新規取得したEIP をアタッチ

  NewMyEIP:
    Type: AWS::EC2::EIP
    Properties:
      InstanceId: !Ref EC2WebServer01
      Tags:
          - Key: Name
            Value: !Sub ${AWS::StackName}-NewMyEIP
```
- `aws cli` の使い方の復習を兼ね、自動実行のために手動にて挙動等を確認<br>
(※ 今回、CFn実行には `aws cloudformation deploy` コマンドを使用)
- 上記更新したテンプレートを `04_cfn-ec2-ver2.yml` として新規作成
- `.circleci/config` に `cfn-lint` によるCloudformationテンプレートの構文をチェックする処理(下記記述)を追加　(※ [lecture12](../../Tasks/lecture12/lecture12.md) と同様の内容 )
  ```
  version: 2.1
  orbs:
    python: circleci/python@2.0.3

  jobs:
    cfn-lint:
      executor: python/default
      steps:
        - checkout
        - run: pip install cfn-lint
        - run:
            name: run cfn-lint
            command: |
              cfn-lint -i W3002 -t Tasks/lecture10/CloudFormation_templates/*.yml

  workflows:
    AWS_Work_CircleCI:
      jobs:
        - cfn-lint
    ```
- `aws cli` を使用するため、CircleCI の環境変数 (Environment Variables) を設定
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY
  - AWS_DEFAULT_REGION
- `.circleci/config` に `aws cli` によるCloudformationを実行する処理(下記記述)を追加　( ※ `aws cli` の `ORBS` を使用 )
  ```
    version: 2.1
    orbs:
      aws-cli: circleci/aws-cli@4.0.0

    jobs:
      execute-cloudformation:
        executor: aws-cli/default
        steps:
          - checkout
          - aws-cli/setup:
              aws_access_key_id: AWS_ACCESS_KEY_ID
              aws_secret_access_key: AWS_SECRET_ACCESS_KEY
              region: ${AWS_DEFAULT_REGION}
          - run:
              name: deploy Cloudformation
              command: |          #パイプは改行させてコマンドを実行させてたい場合に必要
                set -x            # シェルが実行コマンドとその引数を出力
                aws cloudformation deploy --stack-name cfn-vpc --template-file  Tasks/lecture10/CloudFormation_templates/01_cfn-vpc.yml
                aws cloudformation deploy --stack-name cfn-securitygroup --template-file  Tasks/lecture10/CloudFormation_templates/02_cfn-securitygroup.yml
                aws cloudformation deploy --stack-name cfn-ec2-ver2 --template-file  Tasks/lecture10/CloudFormation_templates/04_cfn-ec2-ver2.yml --capabilities CAPABILITY_NAMED_IAM

    workflows:
      AWS_Work_CircleCI:
        jobs:
          - execute-cloudformation

  ```
- CircleCI・AWSマネジメントコンソールで、自動構築の実行結果を確認

### ■ Ansible による構成管理(プロビジョニング)の実行
- `ターゲットノードに Git をインストール する処理(下記記述)` を `.circleci/config` に追加<br>
( ※ `ansible` の `ORBS` を使用 )
    ```
    #【Gitインストール】：Ansible - playbook.yml の記述

    - hosts: target_node
      tasks:
      - name: install git
        become: yes
        yum:
          name: git
          state: latest
          lock_timeout: 180
    ```
### ■ ServerSpec によるテスト実行
## ■動作確認
- CircleCI 一連の実行結果
- cfn-lint の実行結果
- CloudFormation の実行結果
- Ansible の実行結果
- ServerSpec の実行結果

## ■ 感想
## ■ 今後の課題
## ■ 参考リンク ( Ansible 環境構築・設定 関連 )
- [Ansible ドキュメント](https://docs.ansible.com/ansible/2.9_ja/index.html)
- [Ansible のインストール](https://docs.ansible.com/ansible/2.9_ja/installation_guide/intro_installation.html)
- [Ansible 構成設定](https://docs.ansible.com/ansible/2.9_ja/reference_appendices/config.html)
- [Ansible の動作の制御: 優先順位のルール](https://docs.ansible.com/ansible/2.9_ja/reference_appendices/general_precedence.html)
- [Amazon Linux2にAnisbleをインストールする方法](https://qiita.com/tireidev/items/92dcfa6fa2a33cb11442)
- [Amazon Linux 2のExtras Library(amazon-linux-extras)を使ってみた](https://dev.classmethod.jp/articles/how-to-work-with-amazon-linux2-amazon-linux-extras/)
- [Ansible をインストールする](https://sid-fm.com/support/vm/guide/install-ansible.html)
- [Ansibleを使用したコマンドのインストール](https://engineer-blog.ajike.co.jp/ansible-1/)
- [ansible.cnfでssh_configを設定する](https://dev.classmethod.jp/articles/enable_ssh_conf_using_via_ansible-cnf/)
- [SSHコマンド実行時に生じたBad owner or permissions on /home/(user_name)/.ssh/config エラーの対処法](https://qiita.com/muramasa2/items/c58345b3ab6069d02849)
- [【完全版】SSHコマンドの基本からその実践方法まで実例付きで解説](https://itc.tokyo/linux/ssh-command/)
- [【SSH】公開鍵認証とEC2について](https://qiita.com/aiandrox/items/98ad9b7551481d890916)

## ■ 参考リンク ( CircleCIへの組込 ( CloudFormation / Ansible / ServerSpec ) 関連 )

## ■ 参考リンク ( CircleCIへの組込 ( CloudFormation 関連 )
- [AWS公式ドキュメント - CloudFormation ( AWS::EC2::EIP )](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-eip.html)
- [AWS公式ドキュメント - CloudFormation ( AWS::EC2::EIPAssociation )](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-eip-association.html)
- [CloudFormationで既存EIPをEC2に割り当てる](https://blog.denet.co.jp/cloudformation-eip-ec2/)
- [【AWS】CloudFormationの作成ノウハウをまとめた社内向け資料を公開してみる](https://dev.classmethod.jp/articles/cloudformation-knowhow/)
- [CloudFormationの全てを味わいつくせ！「AWSの全てをコードで管理する方法〜その理想と現実〜」](https://dev.classmethod.jp/articles/aws-all-iac/)
- [AWS CLIのエラー「Could not connect to the endpoint URL」](https://blog.serverworks.co.jp/tech/2019/02/27/post-69261/)
- [AWS CLI のエラー「Connect timeout on/Could not connect to the endpoint URL: ～」を回避するには](https://dev.classmethod.jp/articles/tsnote-awscli-couldnotconnect-001/)
