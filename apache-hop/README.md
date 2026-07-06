# Apache Hop

Ambiente Docker do [Apache Hop](https://hop.apache.org/) (2.18.1) rodando via **Hop Web**, a interface gráfica do Hop acessível pelo navegador.

## Como subir

```bash
docker compose up -d
```

Pré-requisito: o container do Postgres externo (projeto `postgreSQL`) precisa estar rodando antes, pois o Hop usa a mesma rede dele (`postgresql_postgres-network`).

## Acesso

- **URL**: http://localhost:8080/ui
- **Login**: `hop`
- **Senha**: `hop`

Autenticação HTTP Basic via Tomcat, configurada em `config/tomcat-users.xml`. Para trocar a senha, edite esse arquivo e rode `docker compose restart hop-web`.

## O que sobe

| Serviço      | Função                                                                 |
|--------------|-------------------------------------------------------------------------|
| `hop-db-init`| Roda uma vez, verifica se o database `apache_hop` existe no Postgres externo e cria caso não exista (`init-db.sh`). Sempre executa a cada `docker compose up`, mas é idempotente. |
| `hop-web`    | Interface web do Hop (Tomcat), na porta 8080. Só sobe depois que `hop-db-init` termina com sucesso. |

## Estrutura de arquivos

```
.env                              # dados de conexão com o Postgres externo (host, porta, user, senha, database)
init-db.sh                        # script que cria o database apache_hop se não existir
config/environment.json           # variáveis (PG_HOST, PG_PORT, etc.) usadas pelo ambiente "docker" do projeto Hop
config/tomcat-users.xml           # usuário/senha de acesso ao Hop Web
config/web.xml                    # web.xml da imagem + regra exigindo login em /ui e /ui-dark
project/                          # projeto Hop persistido no host (pipelines, workflows, metadata)
  project-config.json             # gerado automaticamente pelo Hop na primeira subida
  metadata/rdbms/postgres.json    # conexão pré-configurada chamada "postgres", pronta pra usar em pipelines/workflows
```

## Banco de dados

O Hop usa um database **dedicado** chamado `apache_hop` no mesmo Postgres externo dos outros projetos, para não misturar dados com `mydatabase`. Ele é criado automaticamente pelo `hop-db-init` no primeiro `docker compose up`.

Dentro do Hop (Designer/Hop Web), já existe uma conexão de banco chamada **"postgres"** (em `project/metadata/rdbms/postgres.json`) que aponta para esse database via as variáveis definidas em `config/environment.json`. Use-a em pipelines/workflows sem precisar recriar a conexão manualmente.

Para apontar para outro database (ou outro host/usuário), edite `config/environment.json` — não é necessário mexer no `.env` nem no `docker-compose.yml`, pois quem resolve essas variáveis dentro do Hop é esse arquivo. O `.env` só é usado pelo `hop-db-init` para criar o database; se mudar o nome lá, mantenha `PG_DB` igual nos dois arquivos.

## Persistência

Tudo que for criado no Hop Web (projetos, pipelines, workflows, conexões) fica salvo em `./project`, no host — sobrevive a `docker compose down` e recriação do container. Para resetar tudo do zero, apague o conteúdo dessa pasta (menos o `.gitkeep`, se houver).

## Notas

- Driver JDBC do PostgreSQL já vem embutido na imagem oficial (licença BSD), não precisa adicionar nada.
- Não existe imagem Bitnami para Apache Hop — a imagem usada (`apache/hop-web`) é a oficial do projeto.
- O login protege apenas a UI (`/ui` e `/ui-dark`). É autenticação HTTP Basic do Tomcat (usuário/senha em texto simples no `tomcat-users.xml`), suficiente para uso doméstico/local — não é adequado para expor a porta 8080 na internet.
