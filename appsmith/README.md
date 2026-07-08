# Appsmith

Plataforma low-code (self-hosted) para criar telas/frontend sobre bancos de dados e APIs REST/GraphQL — [Appsmith](https://www.appsmith.com) Community Edition.

## Stack

- `appsmith/appsmith-ce:v2.1` — última versão estável da Community Edition (open source). A imagem já inclui MongoDB, Redis e PostgreSQL internos usados pelo próprio Appsmith.

## Como subir

```bash
docker compose up -d
```

A inicialização pode levar alguns minutos (o container sobe seus bancos internos antes de ficar `healthy`). Acompanhe com:

```bash
docker compose ps
```

Depois de `healthy`, acesse **http://localhost** para fazer o setup inicial (criação do usuário admin).

## Notas

- Todo o estado (workspaces, apps, dados internos) é persistido no volume bind-mount `./stacks` → `/appsmith-stacks` dentro do container. Essa pasta é git-ignorada.
- Requisitos recomendados pela Appsmith: pelo menos ~2-4 GB de RAM livres para o container, já que ele roda vários serviços internos.
- Portas expostas: `80` (HTTP) e `443` (HTTPS, se configurado certificado).

## Comandos úteis

```bash
docker compose ps                 # status do container
docker compose logs -f appsmith   # logs em tempo real
docker compose down               # parar (mantém os dados em ./stacks)
```
