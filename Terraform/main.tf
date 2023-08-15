# ---------------------------------------------
# Terraform configuration
# ---------------------------------------------
terraform {
  required_version = ">=1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# ---------------------------------------------
# Provider
# ---------------------------------------------
provider "aws" {
  profile = var.profile
  region  = "ap-northeast-1"
}

# ---------------------------------------------
# Backend：S3
# ---------------------------------------------
# ※バックエンド設定(記述)では variable が使用できないため、
# 　ハードコーディングを避ける方法としては init コマンド実行時に引数を渡す方法がある
# ---------------------------------------------
terraform {
  backend "s3" {
    #profile = var.profile
    # 初期化にはprofile指定が必要だが、terraform init 実行するとエラーとなるため引数として値を渡して初期化コマンドを実行
    bucket = "aws-work-terraform"
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

# 動作検証用 (※initコマンドに引数を渡して初期化を実行)
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

variable "profile" {
  type = string
}
