# Импорт OSM данных и Алгоритм построения топологии дорожной сети

## Импорт данных

### Шаг 1: Скачать дамп OSM данных

Перейдите на сайт [Geofabrik](https://download.geofabrik.de/russia.html) и выберите нужный вам регион, чтобы загрузить актуальный дамп данных в формате `.osm.pbf`.

### Шаг 2: Подключение к контейнеру

Подключитесь к вашему Docker-контейнеру с PostgreSQL и PostGIS, используя следующую команду:

```bash
docker exec -it postgres_postgis_osm bash
```

### Шаг 3: Выполнение команды ogr2ogr

Внутри контейнера выполните команду `ogr2ogr`, чтобы преобразовать и импортировать данные в базу данных PostgreSQL/PostGIS:

- Укажите файл с дампом с Geofabrik Server, в примере `central-fed-district-latest.osm.pbf`
- Укажите БД, в которую импортируем, в примере `aqua_kinetics_osm`

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
    -sql "SELECT * FROM lines WHERE highway IS NOT NULL" \
    -lco FID=id \
    | psql -U postgres -d aqua_kinetics_osm
```

### Шаг 4: Проверка данных

После выполнения команды `ogr2ogr`, вы можете проверить, были ли данные успешно импортированы, подключившись к вашей базе данных, используя `psql` или `PgAdmin`, и выполнив запросы к таблице `osm_lines`.

Такой подход позволит вам использовать GDAL для более гибкого преобразования данных перед их загрузкой в базу данных, что может быть полезно для фильтрации или трансформации данных перед импортом. Убедитесь, что все зависимости и конфигурации настроены правильно, чтобы процесс прошел гладко.

## Создание топологии карты дорожной сети для импортированных данных

Для создания топологии используем функционал `pgRouting`.

### Шаг 1: Создание таблицы `ways` на основе `osm_lines`

```sql
DROP TABLE IF EXISTS ways;
CREATE TABLE ways AS
SELECT
  osm_id,
  name,
  highway,
  ST_Length(_ogr_geometry_::geography) AS length, -- Длина в метрах
  ST_StartPoint(_ogr_geometry_) AS start_point,   -- Начальная точка
  ST_EndPoint(_ogr_geometry_) AS end_point,       -- Конечная точка
  _ogr_geometry_  AS way                          -- Геометрия линии
FROM
  osm_lines
WHERE
  highway IS NOT NULL;
```

### Шаг 2: Добавление столбцов для расчета топологии

```sql
-- Добавление необходимых столбцов
ALTER TABLE ways ADD COLUMN gid SERIAL PRIMARY KEY;
ALTER TABLE ways ADD COLUMN source INTEGER;
ALTER TABLE ways ADD COLUMN target INTEGER;
ALTER TABLE ways ADD COLUMN cost DOUBLE PRECISION;
ALTER TABLE ways ADD COLUMN reverse_cost DOUBLE PRECISION;
```

### Шаг 3: Создание топологии и заполнение столбцов `source` и `target`

Важный параметр `tolerance = 0.000001`

```sql
SELECT pgr_createTopology('ways', 0.000001, 'way', 'gid');
```

#### Что такое `tolerance`?

`Tolerance` — это параметр, который указывает, насколько близко друг к другу должны быть точки (узлы) на линии, чтобы считаться одной и той же точкой (узлом) в топологии. Это значение измеряется в тех же единицах, что и геометрия данных, обычно в градусах, если ваши данные находятся в географической системе координат, такой как WGS 84.

#### Зачем нужен `tolerance`?

При работе с геометрическими данными, особенно с данными, импортированными из OSM, вы можете столкнуться с проблемами, связанными с неточностями в данных, такими как небольшие разрывы между линиями, которые должны быть соединены. Использование `tolerance` помогает объединить такие близкие точки в один узел, тем самым создавая более правильную и полезную топологию дорожной сети. Это особенно важно для корректного выполнения маршрутизации и других сетевых анализов.

#### Как выбрать значение для `tolerance`?

Выбор значения `tolerance` зависит от вашего масштаба и точности данных:

- **Малые значения (например, 0.000001):** Подходят для данных с высокой точностью, таких как данные OSM, где расстояния между узлами в географических координатах могут быть очень малы. Это значение соответствует примерно 0.1 метра на экваторе.
- **Большие значения:** Используются, если ваши данные имеют большую погрешность или если вы работаете с данными в проекциях, где единицы измерения в метрах.

### Шаг 4: Проверка топологии

```sql
SELECT * FROM pgr_connectedComponents(
  'SELECT gid AS id, source, target, cost FROM ways'
);
```

### Шаг 5: Проверка кратчайшего пути

```sql
SELECT * FROM pgr_dijkstra(
  'SELECT gid AS id, source, target, cost FROM ways',
  1, 100, false
);
```

### Шаг 6: Установка стоимости на основе длины

```sql
UPDATE ways SET cost = length, reverse_cost = length;
```

## Альтернативный подход

Вы можете рассмотреть использование API [Project OSRM](https://project-osrm.org/docs/v5.24.0/api/?language=CLI#) для создания и работы с топологией дорожной сети.

### Вся инфраструктура в этом репозитории
