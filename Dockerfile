FROM postgis/postgis:17-3.5

# Устанавливаем необходимые пакеты для PgRouting и GDAL
RUN apt-get update && \
    apt-get install -y postgresql-17-pgrouting osm2pgsql gdal-bin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
