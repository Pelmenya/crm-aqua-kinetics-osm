FROM postgis/postgis:17-3.5

# Установите необходимые пакеты для PgRouting
RUN apt-get update && \
    apt-get install -y postgresql-17-pgrouting && \
    apt-get update && \
    apt-get install -y osm2pgsql && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*