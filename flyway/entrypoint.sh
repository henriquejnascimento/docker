#!/bin/sh

set -e

# Define o nome do banco caso a variável não esteja definida
DB_NAME=${FLYWAY_DATABASE_NAME:-flyway_db}

echo "⏳ Aguardando Postgres ficar disponível..."

until pg_isready -h postgres -U postgres; do
  echo "Postgres ainda não está pronto..."
  sleep 2
done

echo "✔ Postgres está pronto"

echo "⏳ Verificando/Criando banco '${DB_NAME}'..."

# Verifica a existência do banco e cria se não existir usando a variável
psql -h postgres -U postgres -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '${DB_NAME}'" | grep -q 1 || psql -h postgres -U postgres -d postgres -c "CREATE DATABASE \"${DB_NAME}\""

echo "✔ Banco '${DB_NAME}' está pronto"

echo "🚀 Rodando Flyway migrations..."

flyway migrate
