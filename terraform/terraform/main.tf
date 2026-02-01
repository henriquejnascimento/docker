provider "aws" {
  region                     = "us-east-1"
  skip_credentials_validation = true  # Ignorar validação de credenciais
  skip_requesting_account_id  = true  # Ignorar a solicitação do ID da conta AWS
  endpoints {
    sqs = "http://localstack:4566"  # Nome do serviço LocalStack no Docker Compose
  }
}

resource "aws_sqs_queue" "test_queue" {
  name = "test-queue-from-terraform"
}
