# H2 Database

Ambiente Docker para o [H2](https://h2database.com) — banco relacional em Java, muito usado para testes/dev por rodar embarcado ou em modo servidor sem instalação.

Não existe imagem oficial do H2 no Docker Hub (só imagens de terceiros não mantidas de forma confiável). Este `Dockerfile` roda o H2 sobre a imagem oficial `eclipse-temurin` (OpenJDK), baixando o `.jar` direto do Maven Central e validando o SHA-256 — assim você sabe exatamente o que está rodando, sem depender de um mantenedor terceiro desconhecido.

O servidor não é iniciado via CLI (`java -cp h2.jar org.h2.tools.Server ...`), e sim por um pequeno launcher (`Launcher.java`) que sobe os servidores via API Java. Isso é necessário porque o H2 **recusa** a flag `-webAdminPassword` quando passada por linha de comando — só funciona chamando a API `Server.createWebServer(...)` diretamente.

- **Versão**: `2.4.240` (última estável — confirmada via `maven-metadata.xml` em [repo1.maven.org](https://repo1.maven.org/maven2/com/h2database/h2/), não pelo índice de busca `search.maven.org`, que pode ficar desatualizado).

## Como subir

```bash
docker compose up -d --build
```

## Acesso

- **Console web**: http://localhost:8082 — mapeado só em `127.0.0.1` (não acessível pela rede).
- **JDBC/TCP** (para apps, DBeaver, etc.): `jdbc:h2:tcp://localhost:9092/test` (troque `test` pelo nome real que você quer usar)
  - O primeiro connect com um nome de banco novo **cria o banco automaticamente** dentro de `./data` (arquivo `test.mv.db`), com o usuário/senha que você digitar na tela de conexão.
  - Guarde o usuário/senha que você definir — é a única autenticação do banco em si.

## Senha de administrador (tela "Preferences")

Definida em `H2_ADMIN_PASSWORD` no `.env` (mínimo 12 caracteres, exigência do próprio H2). É uma senha separada da senha do banco — protege só as ações administrativas do H2 Console (Preferences, Tools), não o acesso aos dados.

Sem essa configuração, a tela de Preferences fica **permanentemente bloqueada** quando o console aceita conexões remotas (`-webAllowOthers`, necessário aqui por causa do mapeamento de porta do Docker) — o H2 recusa qualquer senha nesse cenário até você configurar uma de verdade via API.

## Estrutura de arquivos

```
Dockerfile
docker-compose.yml
data/              # arquivos .mv.db (persistente)
```

## Notas de segurança

- **Nunca exponha a porta 8082 (console web) além de `localhost`.** O H2 Console tem histórico de vulnerabilidades sérias de RCE quando exposto sem controle (ex: CVE-2021-42392, explorada via Spring Boot com H2 Console acessível) — a própria criação de um "alias" SQL permite executar código Java arbitrário. Por isso o `docker-compose.yml` já limita a porta a `127.0.0.1:8082`.
- A porta `9092` (TCP/JDBC) fica aberta na rede porque é assim que apps externos conectam — mas cada conexão exige usuário/senha do banco. Não deixe esse container acessível a redes não confiáveis.
- O `Dockerfile` usa `-ifNotExists`, que permite **criar bancos novos remotamente** (comportamento que o H2 desabilita por padrão desde certa versão, justamente por segurança — sem essa flag, conectar em um banco inexistente é recusado com o erro "Database not found, either pre-create it or allow remote database creation"). Se quiser travar isso depois de criar seus bancos (evitar que qualquer conexão na porta 9092 crie arquivos novos em `./data`), remova `-ifNotExists` do `ENTRYPOINT` e rebuilde.
- Esse setup é pensado para **uso local/dev**, não para produção. Para produção, prefira um banco cliente-servidor com controle de acesso mais robusto (Postgres, MySQL, etc.).
