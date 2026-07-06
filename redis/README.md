# Redis + RedisInsight

Ambiente Docker para o [Redis](https://redis.io) usando a imagem oficial (`redis:8.8.0-alpine`, última versão estável), com [**RedisInsight**](https://redis.io/insight/) (`redis/redisinsight:3.6.0`) como interface gráfica.

O Redis em si **não vem com GUI** — é só o servidor, acessado via `redis-cli` ou pela porta 6379. O RedisInsight é a ferramenta oficial (feita pela Redis Inc.) para navegar/editar dados por navegador.

## Configuração

No `.env`, defina `REDIS_PASSWORD` (troque o valor padrão antes de subir).

## Como subir

```bash
docker compose up -d
```

## Acesso

- **RedisInsight**: http://localhost:5540 — mapeado só em `127.0.0.1` (veja nota de segurança abaixo).
  - Ao adicionar a conexão com o Redis, use host `redis` (nome do serviço na rede interna do compose), porta `6379`, e a senha definida em `REDIS_PASSWORD`.
- **CLI**: `docker compose exec redis redis-cli -a "$REDIS_PASSWORD"`

## Estrutura de arquivos

```
.env                  # senha do Redis
docker-compose.yml
data/                 # arquivos .rdb/.aof do Redis (persistente)
redisinsight-data/    # conexões salvas e configurações do RedisInsight (persistente)
```

## Notas de segurança

- **Redis não tem autenticação por padrão** — por isso o `command` do serviço já força `--requirepass`. Nunca remova essa proteção; Redis sem senha exposto é um dos vetores mais comuns de comprometimento em massa (botnets de cryptomining).
- **RedisInsight não tem tela de login própria** — quem acessa a porta 5540 tem acesso completo aos dados do Redis. Por isso a porta fica só em `127.0.0.1`, nunca exponha na rede.
- A porta `6379` (Redis) fica aberta para permitir conexão de apps externos ao host — protegida pela senha, mas evite deixá-la acessível a redes não confiáveis.
