--1 Определите тип пространственных данных во всех таблицах.
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE DATA_TYPE IN ('geometry', 'point', 'linestring', 'polygon', 'multipoint', 'multilinestring', 'multipolygon', 'geometrycollection');
--===============================================
--2	Определите SRID
SELECT srid  
FROM geometry_columns;
--===============================================
--3	Определите атрибутивные столбцы
SELECT COLUMN_NAME, DATA_TYPE  
FROM INFORMATION_SCHEMA.COLUMNS  
WHERE TABLE_NAME = 'gis_osm_buildings_a_free_1'  AND DATA_TYPE != 'geometry';
--===============================================
--4	Верните описания пространственных объектов в формате WKT.
SELECT geom.STAsText() AS WKT_Description FROM gis_osm_buildings_a_free_1;
--===============================================
--5 Нахождение пересечения пространственных объектов;
SELECT a.qgs_fid, b.qgs_fid  
FROM gis_osm_buildings_a_free_1 a, gis_osm_buildings_a_free_1 b  
WHERE a.qgs_fid <> b.qgs_fid
  AND a.geom.STIntersects(b.geom) = 1;
--===============================================
--Нахождение координат вершин пространственного объектов
SELECT geom.STAsText() FROM gis_osm_buildings_a_free_1;
--===============================================
--Нахождение площади пространственных объектов
SELECT geom.STArea() FROM gis_osm_buildings_a_free_1;
--===============================================
--6	Создайте пространственный объект в виде точки (1) /линии (2) /полигона (3).
INSERT INTO gis_osm_buildings_a_free_1 (geom) VALUES (geometry::STGeomFromText('POINT(50 60)', 4326));
--===============================================
INSERT INTO gis_osm_buildings_a_free_1 (geom) VALUES (geometry::STGeomFromText('LINESTRING(10 20, 30 40, 50 60)', 4326));
--===============================================
INSERT INTO gis_osm_buildings_a_free_1 (geom) VALUES (geometry::STGeomFromText('POLYGON((10 10, 20 20, 30 10, 10 10))', 4326));
--===============================================
--7	Найдите, в какие пространственные объекты попадают созданные вами объекты.
SELECT * FROM gis_osm_buildings_a_free_1  
WHERE geom.STContains(geometry::STGeomFromText('POINT(50 60)', 4326)) = 1;

SELECT * FROM gis_osm_buildings_a_free_1  
WHERE geom.STContains(geometry::STGeomFromText('LINESTRING(10 20, 30 40, 50 60)', 4326)) = 1;

SELECT * FROM gis_osm_buildings_a_free_1  
WHERE geom.STContains(geometry::STGeomFromText('POLYGON((10 10, 20 20, 30 10, 10 10))', 4326)) = 1;
--===============================================
--8 Продемонстрируйте индексирование пространственных объектов.
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_vivsi_geom')
DROP INDEX IX_vivsi_geom ON lab4;

CREATE SPATIAL INDEX IX_vivsi_geom
ON gis_osm_buildings_a_free_1(geom)
WITH (BOUNDING_BOX = (0, 0, 100, 100)); 

SET STATISTICS PROFILE ON;
SELECT * FROM gis_osm_buildings_a_free_1 
WHERE geom.STIntersects(geometry::STGeomFromText('POINT(37.6178 55.7558)', 4326)) = 1;
SET STATISTICS PROFILE OFF;

SELECT  
    MIN(geom.STEnvelope().STPointN(1).STX) AS xmin,  
    MIN(geom.STEnvelope().STPointN(1).STY) AS ymin,  
    MAX(geom.STEnvelope().STPointN(3).STX) AS xmax,  
    MAX(geom.STEnvelope().STPointN(3).STY) AS ymax  
FROM gis_osm_buildings_a_free_1;

CREATE SPATIAL INDEX SpatialIndex  
ON gis_osm_buildings_a_free_1(geom)  
USING GEOMETRY_GRID  
WITH (BOUNDING_BOX = (10, 10, 50.000001, 60.0000012));
--===============================================
--Разработайте хранимую процедуру, которая принимает координаты точки и возвращает пространственный объект, в который эта точка попадает.
CREATE PROCEDURE Find
    @Point GEOMETRY  
AS  
BEGIN  
    SELECT * FROM gis_osm_buildings_a_free_1  
    WHERE geom.STContains(@Point) = 1;
END;

DECLARE @p GEOMETRY = geometry::STGeomFromText('POINT(50 60)', 4326);  
EXEC Find @p;
--===============================================
