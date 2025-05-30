
# Инструкция по командам

## Создание дампа в смонтированной папке

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

```bash
docker exec -it postgres_postgis_osm bash
```

```bash
createdb -U postgres aqua_kinetics_osm_restore
pg_restore -U postgres -d aqua_kinetics_osm_restore -v /pg_dumps/aqua_kinetics_osm_central_region.dump
exit
```

Преимущества монтирования папки для дампов:

Удобство: Нет необходимости использовать команды для копирования файлов между контейнером и локальной машиной.
Автоматизация: Процессы создания и восстановления дампов могут быть легко автоматизированы с использованием скриптов.
Безопасность данных: Хранение дампов на локальной машине позволяет легко выполнять резервное копирование и защиту данных.

UPDATE ways SET source = NULL, target = NULL;

```cmd
osm2pgsql --create --slim -d aqua_kinetics_osm -U postgres -G --hstore /data/central-fed-district-latest.osm.pbf
```
