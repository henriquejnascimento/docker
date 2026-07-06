FROM flyway/flyway:12.10.0

# instala client do postgres (necessário para psql)
RUN apt-get update && apt-get install -y postgresql-client

# copia entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
