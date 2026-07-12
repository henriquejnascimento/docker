# 🚨 Monitor B3 — Guia de Setup (n8n)

## 1. Instalar n8n com Docker

```bash
docker run -d \
  --name n8n \
  --restart unless-stopped \
  -p 5678:5678 \
  -e GENERIC_TIMEZONE="America/Sao_Paulo" \
  -e TZ="America/Sao_Paulo" \
  -v n8n_data:/home/node/.n8n \
  n8nio/n8n
```

Acesse: **http://localhost:5678**

---

## 2. Importar o Workflow

1. Abra o n8n no navegador
2. Vá em **Workflows → Import from File**
3. Selecione o arquivo `monitor-b3-workflow.json`

---

## 3. Configurar seu Endpoint de Alvos

O nó **"📋 Buscar Ativos-Alvo"** faz um GET na sua API. Altere a URL para o seu endpoint real.

Seu endpoint deve retornar um JSON com a lista de ativos. O workflow espera o array dentro de um campo `data`:

```json
{
  "total": 4,
  "updated_at": "2026-07-12T10:00:00-03:00",
  "data": [
    { "ticker": "PETR4", "min": 30.00, "max": 42.50 },
    { "ticker": "VALE3", "min": 58.00, "max": 78.00 },
    { "ticker": "ITUB4", "min": 28.00, "max": 35.00 },
    { "ticker": "BBDC4", "min": 12.00, "max": 16.00 }
  ]
}
```

> O nó **"🔀 Um Item por Ativo"** detecta o campo `data` automaticamente e separa cada ativo em um item.
> Se o seu endpoint devolver um **array puro** (`[ {...}, {...} ]`) em vez do objeto com `data`, ajuste o campo do nó **"🔀 Um Item por Ativo"** de acordo.

---

## 4. Configurar Telegram

### Criar o Bot
1. Abra o Telegram e fale com **@BotFather**
2. Envie `/newbot` e siga as instruções
3. Copie o **token** gerado (ex: `123456:ABC-DEF...`)

### Descobrir seu Chat ID
1. Fale com **@userinfobot** no Telegram
2. Ele responde com seu **chat_id** numérico

### Configurar no n8n
1. Clique no nó **"📱 Enviar Alerta (Telegram)"**
2. Em **Credentials → Create New**, cole o token do bot
3. No campo **Chat ID**, coloque seu chat_id

---

## 5. Configurar Email (SMTP)

### Gmail (recomendado)
1. Ative a verificação em 2 etapas na sua conta Google
2. Vá em **myaccount.google.com → Segurança → Senhas de app**
3. Crie uma senha de app para "E-mail"

### Configurar no n8n
1. Clique no nó **"📧 Enviar Alerta (Email)"**
2. Em **Credentials → Create New (SMTP)**:
   - **Host:** `smtp.gmail.com`
   - **Port:** `465`
   - **SSL/TLS:** ativado
   - **User:** seu email
   - **Password:** a senha de app (não a senha normal)
3. Ajuste os campos **From** e **To** no nó

---

## 6. API de Cotações (Yahoo Finance)

O workflow usa a API pública do **Yahoo Finance**, que é gratuita e **não exige token nem cadastro**.

- URL base: `https://query1.finance.yahoo.com/v8/finance/chart/PETR4.SA`
- **Sufixo `.SA`:** para ativos da B3, adicione `.SA` ao ticker (ex: `PETR4` → `PETR4.SA`). O nó já faz isso automaticamente.
- **Header obrigatório:** a requisição precisa de um `User-Agent` de navegador. Sem ele, o Yahoo responde **HTTP 429 (Too Many Requests)**. O nó **"📈 Buscar Cotação (Yahoo)"** já vem com esse header configurado.

> O preço vem em `chart.result[0].meta.regularMarketPrice` e o nome do ativo em `chart.result[0].meta.longName` — o nó **"🧠 Comparar Preço vs Faixa"** já faz esse parsing.

---

## 7. Ativar o Workflow

1. No canto superior direito, clique no toggle **Active**
2. O workflow roda automaticamente a cada 30 minutos
3. Para testar manualmente, clique em **Execute Workflow**

---

## Fluxo Visual

```
⏰ Agendamento (30 min)
    ↓
📋 Buscar Ativos-Alvo         → GET /api/alvos (seu endpoint)
    ↓
🔀 Um Item por Ativo          → separa o array data[] em 1 item por ticker
    ↓
📈 Buscar Cotação (Yahoo)     → GET Yahoo Finance /chart/{ticker}.SA
    ↓
🧠 Comparar Preço vs Faixa    → preço fora do min/max? monta o alerta
    ↓
🔔 Disparou alerta?
   ├─ SIM → 📱 Enviar Alerta (Telegram) + 📧 Enviar Alerta (Email)
   └─ NÃO → ✅ Preço na faixa (sem ação)
```

---

## Dicas

- **Horário de mercado:** A B3 funciona das 10h às 17h. Se quiser economizar requisições, adicione um nó **IF** após o cron para checar o horário antes de consultar.
- **Múltiplos ativos:** O nó Code já itera sobre todos os ativos do array. Basta adicionar mais tickers no seu endpoint.
- **Persistência:** O volume Docker `n8n_data` garante que suas configurações sobrevivam a restarts.
- **Logs:** Acesse **Executions** no menu lateral do n8n para ver o histórico de cada execução.
