FROM apache/superset:6.1.0

USER root

# Instala dependências básicas (caso precise de pg_isready, psql etc.)
RUN apt-get update && apt-get install -y \
    postgresql-client \
    curl \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Copia o entrypoint para dentro da imagem
COPY entrypoint.sh /usr/bin/entrypoint.sh

# Permissão de execução
RUN chmod +x /usr/bin/entrypoint.sh

# Volta para usuário padrão do Superset
USER superset

# Define o entrypoint como o comando padrão
ENTRYPOINT ["/usr/bin/entrypoint.sh"]