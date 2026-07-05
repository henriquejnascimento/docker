FROM apache/superset:6.1.0

USER root

# 1. Instala as dependências de sistema
RUN apt-get update && apt-get install -y \
    postgresql-client \
    curl \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# 2. Cria uma pasta customizada para pacotes e instala o psycopg2 diretamente nela
RUN mkdir -p /app/custom_python_packages && \
    pip install --no-cache-dir --target=/app/custom_python_packages psycopg2-binary && \
    chown -R superset:superset /app/custom_python_packages

# 3. Prepara o script de inicialização
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# 4. Volta para o usuário padrão por segurança
USER superset

# 5. Injeta a pasta customizada no PYTHONPATH para que o ambiente virtual a enxergue
ENV PYTHONPATH=/app/custom_python_packages:$PYTHONPATH

# Define o ponto de entrada
ENTRYPOINT ["/usr/bin/entrypoint.sh"]