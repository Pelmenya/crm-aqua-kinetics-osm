
```cmd
    docker exec -it postgres_postgis_osm bash
    psql -U postgres -d aqua_kinetics_osm
    CREATE EXTENSION IF NOT EXISTS hstore;
    \q
    osm2pgsql --create --slim -d aqua_kinetics -U postgres -G --hstore /data/central-fed-district-latest.osm.pbf
```

```cmd
osm2pgsql --create --slim -d aqua_kinetics_osm -U postgres -G --hstore /data/central-fed-district-latest.osm.pbf
```

Создание дампа в смонтированной папке:
Теперь, когда папка pg_dumps смонтирована в контейнере, вы можете создать дамп непосредственно в ней:
bashdocker exec -it postgres_postgis_osm bash
pg_dump -U postgres -d aqua_kinetics_osm -F c -b -v -f /pg_dumps/aqua_kinetics_osm.dump
exit
Дамп будет сохранен в папке pg_dumps на вашей локальной машине.

Восстановление из дампа:
Если вам нужно будет восстановить базу данных, вы можете использовать команду pg_restore, указав путь к дампу в смонтированной папке:
bashdocker exec -it postgres_postgis_osm bash
createdb -U postgres aqua_kinetics_osm_restore
pg_restore -U postgres -d aqua_kinetics_osm_restore -v /pg_dumps/aqua_kinetics_osm.dump
exit

Преимущества монтирования папки для дампов:

Удобство: Нет необходимости использовать команды для копирования файлов между контейнером и локальной машиной.
Автоматизация: Процессы создания и восстановления дампов могут быть легко автоматизированы с использованием скриптов.
Безопасность данных: Хранение дампов на локальной машине позволяет легко выполнять резервное копирование и защиту данных.