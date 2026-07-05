#!/bin/bash
set -e # Faz o script parar caso qualquer comando falhe

# Substitua 'postgres' pelo nome do host do seu container de banco de dados
DB_HOST="postgres"
DB_USER="postgres"
DB_PASSWORD="root"
DB_NAME="superset"

echo "Aguardando banco de dados..."

until PGPASSWORD=$DB_PASSWORD pg_isready -h $DB_HOST -p 5432 -U $DB_USER; do
  sleep 2
done

echo "Rodando migrations..."
until superset db upgrade; do
  echo "Retry migration..."
  sleep 5
done
echo "Migração concluída"

echo "Criando usuário admin..."
superset fab create-admin --username admin --firstname Superset --lastname Admin --email admin@superset.com --password admin || true

echo "Inicializando roles e permissões..."
superset init

echo "Iniciando servidor Gunicorn..."
exec gunicorn --bind 0.0.0.0:8088 --workers 1 --worker-class gthread --threads 20 --timeout 120 'superset.app:create_app()'