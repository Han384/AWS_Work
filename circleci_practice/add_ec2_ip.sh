#!/bin/bash

#######################################
# Ansible：inventoryにEC2のIPアドレスを追加
#######################################

# 挿入したい値を環境変数から取得
insert_value="$AWS_EC2_IP"

# ファイル名
file_name="../ansible_practice/practice02/ansible-practice02/inventory"

# 2行目に環境変数の値を挿入
#sed -i "2i $insert_value" $file_name

# 2行目を環境変数の値で置き換え
sed -i "2s/.*/$insert_value/" $file_name

############################################
# Serverspec：指定のディレクトリ名を、EC2のIPアドレスに変更
############################################

# 既存のディレクトリ名を取得
existing_directory=$(find ../ansible_practice/practice02/serverspec/spec/* -type d -maxdepth 1)

# $existing_directory の値が空(長さが0の文字列)かどうかを検証、空であれば真、
# 空でなければ偽となりスクリプトをエラーコード1で終了(=何も実行せず次工程に移る)
if [ -z "$existing_directory" ]; then
    echo "ディレクトリが見つかりません。"
    exit 1
fi

# 既存のディレクトリ名を表示
echo "既存のディレクトリ名: $existing_directory"

# 既存のディレクトリ名を、新しいディレクトリ名に変更
mv "$existing_directory" "../ansible_practice/practice02/serverspec/spec/$insert_value"

# 新しいディレクトリ名を表示
echo "新しいディレクトリ名: ../ansible_practice/practice02/serverspec/spec/$insert_value"
