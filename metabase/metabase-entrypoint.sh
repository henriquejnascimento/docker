#!/bin/sh
set -e

echo "📦 Preparando dependências do container..."
# Instala o cliente do PostgreSQL silenciosamente para podermos rodar comandos SQL
if ! command -v psql > /dev/null; then
  if command -v apk > /dev/null; then
    apk add --no-cache postgresql-client > /dev/null
  elif command -v apt-get > /dev/null; then
    apt-get update > /dev/null && apt-get install -y postgresql-client > /dev/null
  fi
fi

echo "⏳ Aguardando Postgres (isolado) aceitar conexões..."
# Agora que temos o cliente, usamos o pg_isready para verificar o status do banco
until pg_isready -h postgres -p 5432 -U postgres; do
  sleep 2
done

echo "✔ Postgres disponível"
echo "🔎 Verificando database metabase..."

# Pega a senha definida no docker-compose.yml do Metabase para não pedir confirmação manual
export PGPASSWORD="${MB_DB_PASS:-root}"

DB_EXISTS=$(psql -h postgres -U postgres -tAc "SELECT 1 FROM pg_database WHERE datname='metabase';")

if [ "$DB_EXISTS" = "1" ]; then
  echo "✔ DB 'metabase' já existe"
else
  echo "⚙ Criando database 'metabase' no seu PostgreSQL..."
  psql -h postgres -U postgres -c "CREATE DATABASE metabase;"
  echo "✔ DB criado com sucesso"
fi

echo "🚀 Iniciando serviço principal do Metabase..."
exec /app/run_metabase.sh