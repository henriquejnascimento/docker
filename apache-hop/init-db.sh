#!/bin/bash
# Verifica se o database do Apache Hop existe no Postgres externo e cria caso não exista.
# Executado pelo serviço hop-db-init sempre que rodar "docker compose up".
set -e

: "${PG_HOST:?PG_HOST não definida}"
: "${PG_PORT:?PG_PORT não definida}"
: "${PG_USER:?PG_USER não definida}"
: "${PG_PASSWORD:?PG_PASSWORD não definida}"
: "${PG_DB:?PG_DB não definida}"

PSQL="psql -h ${PG_HOST} -p ${PG_PORT} -U ${PG_USER} -d postgres"

until ${PSQL} -tc "SELECT 1" >/dev/null 2>&1; do
  echo "Aguardando o Postgres externo ficar disponível..."
  sleep 2
done

if ${PSQL} -tc "SELECT 1 FROM pg_database WHERE datname = '${PG_DB}'" | grep -q 1; then
  echo "Database '${PG_DB}' já existe, nada a fazer."
else
  echo "Database '${PG_DB}' não existe, criando..."
  ${PSQL} -c "CREATE DATABASE \"${PG_DB}\""
  echo "Database '${PG_DB}' criado com sucesso."
fi
