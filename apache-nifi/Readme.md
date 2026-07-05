# Apache NiFi (Docker)

Este projeto sobe o **Apache NiFi** usando Docker Compose, já configurado para execução local com interface web segura via HTTPS.

---

## 🚀 Como executar

### 1. Subir o container
```bash
docker compose up -d
```

---

# 🌐 Acesso ao NiFi

Após subir o container, acesse:

👉 https://localhost:8443/nifi

---

# 🔐 Credenciais de acesso

- Usuário: **admin**
- Senha: **admin123456789**

---
# CSV - Regras

Character set: Unicode (UTF-8)
Field Delimiter (Delimitador de campo): ; (Ponto e vírgula)
String Delimiter (Delimitador de texto): " (Aspas duplas)

Os arquivos CSV devem estar no diretório "uploads"