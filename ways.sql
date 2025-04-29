/*CREATE TABLE ways AS
SELECT
	pw.id,
	pw.nodes[1] AS source,
	pw.nodes[array_length(pw.nodes, 1)] AS target,
	ST_Length(ST_MakeLine(ARRAY(
		SELECT ST_SetSRID(ST_MakePoint(n.lon / 10000000.0, n.lat / 10000000.0), 4326)
		FROM unnest(pw.nodes) AS node_id_array(node_id)
		JOIN planet_osm_nodes n ON n.id = node_id_array.node_id
		))) AS cost,
	ST_MakeLine(ARRAY(
		SELECT ST_SetSRID(ST_MakePoint(n.lon / 10000000.0, n.lat / 10000000.0), 4326)
		FROM unnest(pw.nodes) AS node_id_array(node_id)
		JOIN planet_osm_nodes n ON n.id = node_id_array.node_id
		)) AS geom
FROM
	planet_osm_ways pw
WHERE
EXISTS (
SELECT 1 FROM unnest(pw.tags) AS tag WHERE tag LIKE 'highway%'
);
*/ 
-- Убираем циклы маленьким смещением
/*UPDATE ways
SET geom = ST_SetPoint(
            geom, 
            ST_NPoints(geom) - 1, 
            ST_Translate(ST_EndPoint(geom), 0.00001, 0)
          )
WHERE ST_Equals(ST_StartPoint(geom), ST_EndPoint(geom));
*/
-- Делаем таблицу всех вершин
/*CREATE TABLE ways_vertices AS
SELECT DISTINCT
    ST_StartPoint(geom) AS geom
FROM
    ways
UNION
SELECT DISTINCT
    ST_EndPoint(geom) AS geom
FROM
    ways;
*/
--Первичный ключ
--ALTER TABLE ways_vertices ADD COLUMN id SERIAL PRIMARY KEY;

--Устанавливаем индексы
--CREATE INDEX idx_ways_geom ON ways USING GIST(geom);
--CREATE INDEX idx_ways_vertices_geom ON ways_vertices USING GIST(geom);

