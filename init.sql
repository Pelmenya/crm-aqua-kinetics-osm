DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT
      FROM   pg_catalog.pg_database
      WHERE  datname = 'aqua_kinetics_osm') THEN

      CREATE DATABASE aqua_kinetics_osm;
   END IF;
END
$do$;

-- Подключение к базе данных и активация расширений
\connect aqua_kinetics_osm;

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgrouting;
CREATE EXTENSION IF NOT EXISTS hstore;