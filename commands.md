
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