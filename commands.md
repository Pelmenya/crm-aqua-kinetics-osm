
```cmd
    docker exec -it postgres_postgis_osm bash
    psql -U postgres -d aqua_kinetics_osm
    CREATE EXTENSION IF NOT EXISTS hstore;
    \q
    osm2pgsql --create --slim -d aqua_kinetics_osm -U postgres -G --hstore /data/central-fed-district-latest.osm.pbf
```

```cmd
osm2pgsql --create --slim -d aqua_kinetics_osm -U postgres -G --hstore /data/central-fed-district-latest.osm.pbf
```

Создание дампа в смонтированной папке:
Теперь, когда папка pg_dumps смонтирована в контейнере, вы можете создать дамп непосредственно в ней:

```bash
docker exec -it postgres_postgis_osm bash
```

# Dump

```bash
pg_dump -U postgres -d aqua_kinetics_osm -F c -b -v -f /pg_dumps/aqua_kinetics_osm_central_region.dump
```

# Restore

```bash
pg_restore -U postgres -d aqua_kinetics_osm -v /pg_dumps/aqua_kinetics_osm_central_region.dump
```

Дамп будет сохранен в папке pg_dumps на вашей локальной машине.

Восстановление из дампа:
Если вам нужно будет восстановить базу данных, вы можете использовать команду pg_restore, указав путь к дампу в смонтированной папке:
bashdocker exec -it postgres_postgis_osm bash
createdb -U postgres aqua_kinetics_osm_restore
pg_restore -U postgres -d aqua_kinetics_osm_restore -v /pg_dumps/aqua_kinetics_osm_central_region.dump
exit

Преимущества монтирования папки для дампов:

Удобство: Нет необходимости использовать команды для копирования файлов между контейнером и локальной машиной.
Автоматизация: Процессы создания и восстановления дампов могут быть легко автоматизированы с использованием скриптов.
Безопасность данных: Хранение дампов на локальной машине позволяет легко выполнять резервное копирование и защиту данных.

### Чтобы использовать ogr2ogr для импорта данных OSM в вашу базу данных PostgreSQL/PostGIS, вы можете следовать следующим шагам. Это позволит вам выполнять преобразование данных с использованием GDAL и загрузить их в базу данных через psql.
Подготовка контейнера: Убедитесь, что в вашем Docker-контейнере установлен GDAL. Если GDAL не установлен, его нужно добавить в Dockerfile.
Добавьте установку GDAL в ваш Dockerfile:dockerfileFROM postgis/postgis:17-3.5

**Устанавливаем необходимые пакеты для PgRouting и GDAL**

RUN apt-get update && 
apt-get install -y postgresql-17-pgrouting osm2pgsql gdal-bin && 
apt-get clean && 
rm -rf /var/lib/apt/lists/*

Пересоберите контейнер: После изменения Dockerfile пересоберите контейнер:
bashdocker-compose build

Запуск контейнера: Запустите контейнеры с помощью docker-compose:
bashdocker-compose up -d

Использование ogr2ogr для импорта данных: После запуска контейнера войдите в контейнер, используя docker exec, и выполните команду ogr2ogr.

```bash
docker exec -it postgres_postgis_osm bash
```

Выполнение команды ogr2ogr: Внутри контейнера выполните команду ogr2ogr, чтобы преобразовать и импортировать данные в базу данных PostgreSQL/PostGIS:

```bash
ogr2ogr \
    -f PGDUMP \
    /vsistdout/ "/data/central-fed-district-latest.osm.pbf" \
    -nln "osm_lines" \
    -nlt LINESTRING \
    -progress \
    --config PG_USE_COPY YES \
    --config GEOMETRY_NAME the_geom \
    --config OSM_COMPRESS_NODES YES \
    -sql "select * from lines where highway is not null" \
    -lco FID=id \
    | psql -U postgres -d aqua_kinetics_osm
```

Проверка данных: После выполнения команды ogr2ogr вы можете проверить, были ли данные успешно импортированы, подключившись к вашей базе данных, используя psql или PgAdmin, и выполнив запросы к таблице osm_lines.

Такой подход позволит вам использовать GDAL для более гибкого преобразования данных перед их загрузкой в базу данных, что может быть полезно для фильтрации или трансформации данных перед импортом. Убедитесь, что все зависимости и конфигурации настроены правильно, чтобы процесс прошел гладко.