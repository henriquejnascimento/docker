terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"
  token      = "test"

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_use_path_style           = true
  skip_region_validation      = true

  endpoints {
    sqs = "http://localstack:4566"
    sns = "http://localstack:4566"
    s3  = "http://localstack:4566"
    iam = "http://localstack:4566"
  }
}

# # Fila 1: Standard (Não FIFO)
resource "aws_sqs_queue" "queue_standard" {
  name = "test-queue-from-terraform"
}

# Fila 2: FIFO
resource "aws_sqs_queue" "queue_fifo" {
  name                        = "test-queue-2-from-terraform.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}

resource "aws_sns_topic" "test_topic" {
  name = "test-topic-from-terraform"
}

resource "aws_s3_bucket" "test_bucket" {
  bucket = "test-bucket-from-terraform"
}
