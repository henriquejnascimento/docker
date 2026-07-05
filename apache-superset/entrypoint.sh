#!/bin/bash

# Interrompe o script caso algum comando falhe
set -e

echo "Aguardando banco de dados..."
# O comando nc (netcat) verifica se a porta 5432 do container 'postgres' está aberta
while ! nc -z postgres 5432; do
  sleep 1
done
echo "database postgresSQL - accepting connections"

# --- NOVA PARTE: Criação do Banco de Dados ---
echo "Verificando se o banco de dados 'superset' existe..."
export PGPASSWORD="root"
psql -h postgres -U postgres -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'superset'" | grep -q 1 || psql -h postgres -U postgres -d postgres -c "CREATE DATABASE superset"
# ---------------------------------------------

echo "Rodando migrations..."
superset db upgrade

echo "Criando usuário admin (se não existir)..."
superset fab create-admin \
              --username admin \
              --firstname Admin \
              --lastname Superset \
              --email admin@superset.com \
              --password admin || true

echo "Configurando roles e permissões iniciais..."
superset init

echo "Iniciando a aplicação..."
# Substitua a linha abaixo pelo comando que você já usa para iniciar o Superset (gunicorn, superset run, etc.)
exec superset run -p 8088 -h 0.0.0.0 --with-threads --reload --debugger