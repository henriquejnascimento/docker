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

## Workflow de exemplo: monitor de ativos da B3

`workflows/monitor-ativos-b3.json` — monitora uma lista de ativos da B3 a cada 30 minutos e envia um alerta no Telegram quando o preço sai de uma faixa definida (acima ou abaixo de um valor por ativo).

### Como funciona

```
Agendamento (30 min) → Gerar Lista de Ativos (Code) → Buscar Cotacao B3 (HTTP Request)
  → Simplificar Campos (Set) → 14x IF (Alta/Baixa, 2 por ativo) → Enviar Telegram
```

- **Fonte dos dados**: `https://cotacao.b3.com.br/mds/api/v1/InstrumentQuotation/{ticker}` — o mesmo endpoint que o site oficial da B3 usa, sem necessidade de token ou cadastro. Retorna o último preço conhecido mesmo com o mercado fechado (fim de semana/feriado), então dá pra testar o workflow a qualquer hora.
- **Ativos monitorados por padrão**: `PETR3`, `VALE3`, `BRKM5`, `BOVA11`, `XFIX11`, `LFTS11`, `NCDI11`.
- **Condição de alerta**: para cada ativo existem 2 nodes IF — um dispara se o preço ficar **maior que 100** ("Alta"), outro se ficar **menor que 5** ("Baixa"). Esses valores são placeholders iguais para todos os ativos — ajuste cada IF com o valor real que faz sentido para aquele ativo específico.

### Como importar

1. Acesse o n8n em **http://localhost:5678**.
2. Menu de 3 pontinhos (canto superior direito) → **"Import from File"**.
3. Selecione `workflows/monitor-ativos-b3.json`.
4. O workflow **"Monitor Ativos B3"** aparece no canvas com os 19 nodes já conectados.

### Configuração necessária antes de ativar

| Onde | O que fazer |
|---|---|
| Node **"Enviar Telegram"** | Crie um bot via [@BotFather](https://t.me/BotFather) no Telegram (`/newbot`), copie o token. Mande uma mensagem para o bot recém-criado, depois abra `https://api.telegram.org/bot<TOKEN>/getUpdates` no navegador para pegar seu `chat_id`. No node: crie uma credencial nova com o token do BotFather, e troque `SEU_CHAT_ID_AQUI` no campo **Chat ID** pelo seu `chat_id` real. |
| Cada um dos 14 nodes **IF** | Os valores `100` (Alta) e `5` (Baixa) são genéricos — edite cada IF com o valor real desejado para aquele ativo (ex: `IF PETR3 Alta` → `> 45`, `IF PETR3 Baixa` → `< 30`). |
| Toggle **"Active"** | Vem desligado após importar — ative só depois de configurar Telegram e os valores dos IFs. |
| *(Opcional)* Node **"Agendamento (30 min)"** | Por padrão roda 24/7 a cada 30 min. Para restringir ao horário de pregão (dias úteis, 10h–18h), troque para modo **Cron Expression**: `*/30 10-18 * * 1-5`. |

### Como testar

- **"Execute Workflow"** no canto do canvas roda a cadeia inteira na hora, sem esperar o agendamento.
- **Testar nó por nó**: clique em **"Test step"** em cada node, na ordem, para inspecionar o dado em cada etapa.
- **Forçar um alerta disparar**: edite temporariamente um dos IFs para uma condição já verdadeira agora (ex: `price > 0`), rode o workflow, confirme que a mensagem chega no Telegram, depois volte o valor original.
- **Mockar um preço específico**: rode o "Buscar Cotacao B3" uma vez, clique no ícone de alfinete (**Pin Data**) no painel de output e edite o JSON manualmente (ex: forçar `curPrc` de um ativo para `999`). Enquanto o dado estiver fixado, o workflow usa esse valor falso em vez de chamar a API de verdade — útil para simular cenários de alerta sem depender do preço real ou do horário de mercado. Lembre de **desafixar (unpin)** depois.

## Workflow de exemplo: monitor B3 com endpoint externo (Yahoo + Telegram + Email)

`examples/monitor-b3-workflow.json` — variação do monitor da B3 que busca a lista de ativos-alvo de um **endpoint HTTP externo** (em vez de gerar a lista dentro do próprio workflow), consulta a cotação no **Yahoo Finance** e, quando o preço sai da faixa, alerta por **Telegram e Email**. O guia passo a passo de configuração fica em `examples/GUIA-SETUP.md`.

A lista de alvos é servida pelo mock do WireMock deste repositório (`../wiremock`), no endpoint `GET /api/alvos`, que retorna:

```json
{
  "data": [
    { "ticker": "PETR4", "min": 30.00, "max": 42.50 },
    { "ticker": "VALE3", "min": 58.00, "max": 78.00 }
  ]
}
```

### Etapas do flow

Cada nó do canvas faz uma etapa da cadeia. Da esquerda para a direita:

| # | Nó | Tipo | O que faz |
|---|---|---|---|
| 1 | **⏰ Agendamento (30 min)** | Schedule Trigger | Dispara o workflow a cada 30 minutos. É o ponto de entrada. |
| 2 | **📋 Buscar Ativos-Alvo** | HTTP Request | `GET` no seu endpoint (por padrão `http://host.docker.internal:8080/api/alvos`, o WireMock). Retorna a lista de tickers com as faixas de preço (`min`/`max`) dentro de `data`. |
| 3 | **🔀 Um Item por Ativo** | Split Out | Quebra o array `data[]` em **1 item por ticker**, para que as etapas seguintes rodem uma vez para cada ativo. Detecta o campo `data` automaticamente. |
| 4 | **📈 Buscar Cotação (Yahoo)** | HTTP Request | Para cada ticker, consulta `query1.finance.yahoo.com/.../{ticker}.SA`. Envia um header `User-Agent` de browser (sem ele o Yahoo retorna HTTP 429). |
| 5 | **🧠 Comparar Preço vs Faixa** | Code | Lê o preço em `chart.result[0].meta.regularMarketPrice`, casa com o `min`/`max` do alvo e, se o preço estourou a faixa, monta a mensagem de alerta (`ACIMA_MAXIMO` / `ABAIXO_MINIMO`). |
| 6 | **🔔 Disparou alerta?** | IF | Verifica se o item tem campo `alerta`. Encaminha para a saída **true** (tem alerta) ou **false** (dentro da faixa). |
| 7 | **📱 Enviar Alerta (Telegram)** | Telegram | Saída **true**: envia a mensagem formatada para o seu `chat_id`. Exige credencial do bot. |
| 8 | **📧 Enviar Alerta (Email)** | Email (SMTP) | Saída **true**: envia o alerta em HTML por e-mail. Exige credencial SMTP. |
| 9 | **✅ Preço na faixa (sem ação)** | No Op | Saída **false**: ativos cujo preço está dentro do `min`/`max`. Não faz nada — só encerra o ramo sem alerta. |

> **Sobre os dois ramos do IF:** num mesmo ciclo, ativos que estouraram a faixa seguem pelo ramo **true** (Telegram/Email) e os que estão dentro da faixa seguem pelo **false** (nó "Preço na faixa"). Ver os dois nós verdes ao mesmo tempo é normal — significa que parte dos ativos alertou e parte não.

### Como importar e configurar

1. No n8n: menu **⋮ → Import from File** → selecione `examples/monitor-b3-workflow.json`.
2. Suba o WireMock (`../wiremock`, `docker compose up -d`) para servir o `GET /api/alvos`, **ou** troque a URL do nó **"📋 Buscar Ativos-Alvo"** pelo seu endpoint real.
3. Configure as credenciais de **Telegram** e **SMTP** (passo a passo em `examples/GUIA-SETUP.md`, seções 4 e 5).
4. Ative o toggle **Active** (ou use **Execute Workflow** para testar na hora).
