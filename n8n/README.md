# n8n

Automação de workflows (self-hosted), com [n8n](https://n8n.io) + PostgreSQL como banco de persistência.

## Stack

- `n8nio/n8n:2.29.7` — última versão estável (não use `2.30.0`, que na data em que este stack foi montado estava marcada como *pre-release* no GitHub).
- `postgres:15` — banco de dados do n8n (workflows, credenciais, execuções).

## Como subir

1. Confirme que existe um arquivo `.env` neste diretório (git-ignorado) com:

   ```env
   POSTGRES_USER=n8n
   POSTGRES_PASSWORD=<senha>
   POSTGRES_DB=n8n

   N8N_ENCRYPTION_KEY=<chave>
   ```

   > A `N8N_ENCRYPTION_KEY` é usada para criptografar as credenciais salvas no n8n. **Não perca esse valor** — sem ela, credenciais já salvas ficam irrecuperáveis. Se for gerar uma nova instalação do zero, gere com `openssl rand -hex 32`.

2. Suba o stack:

   ```bash
   docker compose up -d
   ```

3. Acesse **http://localhost:5678**.

## Notas

- `depends_on` com `condition: service_healthy` garante que o n8n só inicia depois do Postgres estar pronto (healthcheck via `pg_isready`).
- Os dados do Postgres ficam no volume `postgres_data`; a config/local storage do n8n (incluindo cache de chave de criptografia) fica em `n8n_data`.
- Autenticação é feita pelo sistema de **user management nativo** do n8n (tela de criação do owner no primeiro acesso) — as antigas variáveis `N8N_BASIC_AUTH_*` estão obsoletas nesta versão e não fazem mais efeito.
- Ao trocar a senha do Postgres, lembre-se que alterar `POSTGRES_PASSWORD` no `.env` **não** muda a senha de um banco já inicializado — é preciso rodar `ALTER USER` dentro do container (`docker exec -u postgres n8n_postgres psql -U n8n -d n8n -c "ALTER USER n8n WITH PASSWORD '...';"`) e só então atualizar o `.env`.
- Upgrade de major version do Postgres (ex: 15 → 16) exige migração (`pg_upgrade`/dump-restore) — não pode ser feito apenas trocando a tag da imagem sobre um volume já existente.

## Comandos úteis

```bash
docker compose ps                 # status dos containers
docker compose logs -f n8n        # logs em tempo real
docker compose down               # parar (mantém os volumes/dados)
```
