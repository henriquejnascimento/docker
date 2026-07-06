# SQLite Web

Ambiente Docker para navegar/editar arquivos SQLite (`.db`) via navegador, usando o [**sqlite-web**](https://github.com/coleifer/sqlite-web) (imagem `ghcr.io/coleifer/sqlite-web:0.7.2`).

A imagem usa o GitHub Container Registry (ghcr.io) com tag de versão fixa, em vez de `coleifer/sqlite-web` no Docker Hub (que só publica `latest`, sem versionamento) — evita atualizações silenciosas ao dar `docker compose pull`.

Não existe imagem oficial de SQLite no Docker Hub — SQLite não é um serviço/servidor, é uma biblioteca embarcada. `sqlite-web` é uma aplicação Flask simples que expõe uma UI web nativa para o arquivo `.db`, sem depender de desktop remoto.

## Por que essa imagem (e não `linuxserver/sqlitebrowser`)

A imagem anterior (`linuxserver/sqlitebrowser`) empacota o DB Browser for SQLite dentro de um desktop Linux completo, transmitido via Selkies (WebRTC). Isso traz uma superfície de ataque bem maior:

- Sudo sem senha por padrão dentro do container (acesso root a qualquer um que logue na UI).
- Pilha extra de streaming (WebRTC/GStreamer, codecs com histórico de CVEs, PulseAudio, compositor Wayland).
- A própria linuxserver.io recomenda não expor isso à internet sem hardening adicional.

`sqlite-web` é só uma aplicação web (Python/Flask) — sem terminal, sem sudo, sem streaming de desktop. Superfície de ataque muito menor, mais adequado para uso corporativo.

## Configuração

1. Coloque seu arquivo `.db`/`.sqlite` na pasta `./data`.
2. No `.env`, defina:
   - `SQLITE_DB_FILE`: nome do arquivo dentro de `./data` (ex: `banco.db`).
   - `SQLITE_WEB_PASSWORD`: senha de acesso à interface (troque o valor padrão `admin`).

## Como subir

```bash
docker compose up -d
```

## Acesso

- **http://localhost:8080** — vai pedir a senha definida em `SQLITE_WEB_PASSWORD` antes de mostrar qualquer dado.

## Modo somente-leitura (opcional, recomendado para bases sensíveis)

Edite o `command` no `docker-compose.yml` e adicione `-r` antes do nome do arquivo:

```yaml
command: ["-P", "-r", "${SQLITE_DB_FILE:?defina SQLITE_DB_FILE no .env}"]
```

## Estrutura de arquivos

```
.env               # nome do arquivo .db e senha de acesso
docker-compose.yml
data/              # seus arquivos .db (persistente) — monte seus bancos aqui
```

## Notas de segurança

- A interface serve em HTTP puro (sem TLS embutido). Se for expor além de `localhost`/rede confiável, coloque atrás de um reverse proxy com TLS (nginx, Caddy, Traefik).
- A autenticação é só uma senha (sem usuário, sem MFA) — adequada para rede interna confiável, não para exposição direta à internet.
- Sem sudo, sem terminal, sem privilégios elevados dentro do container — o blast radius de um comprometimento fica restrito à própria aplicação Flask.
