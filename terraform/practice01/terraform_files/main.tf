# ---------------------------------------------
# Terraform configuration
# ---------------------------------------------
terraform {
  required_version = ">=1.5.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 3.0" # 確認用
      #version = "~> 4.0" # 確認用
      version = "~> 5.0"
    }
  }
}

# ---------------------------------------------
# Provider
# ---------------------------------------------
provider "aws" {
  #profile = var.profile #確認用
  region = "ap-northeast-1"
}

# ---------------------------------------------
# Backend：S3
# ---------------------------------------------
# ※【補足】 初期化実行時、バックエンド設定(記述)では variables が使用できないため、
# 　ハードコーディングを避ける方法としては terraform init コマンド実行時に引数を渡す方法がある
# ---------------------------------------------
terraform {
  backend "s3" {
    #profile = var.profile # 確認用
    bucket = "aws-work-terraform-practice01"
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

# 確認用 (※上記記述をコメントアウト、terrafrom init コマンドに引数を渡して初期化を実行)
#   terraform {
#     backend "s3" {
#     }
#   }

# ---------------------------------------------
# Variables
# ---------------------------------------------
variable "project" {
  type = string
}

variable "environment" {
  type = string
}

# 確認用
# variable "profile" {
#   type = string
# }

# 第5回サンプルアプリのAMIを使用しての動作確認用
# variable "ami" {
#   type = string
# }
  