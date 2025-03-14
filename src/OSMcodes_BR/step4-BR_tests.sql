--
-- TESTS to check by QGIS,
--


SELECT OSMcodes_br.xy_to_ggeohash(5300500,9396500,8);

-- DROP TABLE osmcodes_br.grid_test1_quadrantes;
CREATE TABLE osmcodes_br.grid_test1_quadrantes AS
  SELECT lpad((j*10+i)::text,2,'0') AS gid,
        OSMcodes_br.cellgeom_from_ij(j*10+i) as geom
  FROM generate_series(0,8) as j, generate_series(0,9) as i
;

DROP TABLE osmcodes_br.grid_test1_hexadecimal;
CREATE TABLE osmcodes_br.grid_test1_hexadecimal AS
osmcodes_common.ggeohash_to_xybounds
  SELECT gid, OSMcodes_br.cellgeom_xy( OSMcodes_br.ggeohash_to_xy(gid,4) , 512000/4)
  FROM (
    SELECT lpad((j*10+i)::text,2,'0') || c AS gid
    FROM generate_series(0,8) as j, generate_series(0,9) as i, (
      SELECT substr('0123456789abcdef',k,1) as c
      FROM generate_series(1,16) t1(k)
    ) t2
  ) t3
;

INSERT INTO osmcodes_br.grid_test1(gid,geom)
  WITH   scan AS (
      SELECT '45'||c as gid, osmcodes_br.ggeohash_to_xybounds('45'||c,2) as xy_bound
      FROM (
        SELECT substr('0123456789abcdef',k,1) as c
        FROM generate_series(1,4) t1(k)
      ) t2
  )
  SELECT gid||'-'||'pt1',  ST_SetSRID(ST_MakePoint(xy_bound[1],xy_bound[2]),952019 ) as geom FROM scan
  UNION
  SELECT gid||'-'||'pt2',  ST_SetSRID(ST_MakePoint(xy_bound[3],xy_bound[4]),952019 ) as geom FROM scan
;



/*
-- NOT WORKING:
INSERT INTO osmcodes_br.grid_test1_quadrants_full(gid,geom)
  SELECT gid, OSMcodes_br.cellgeom_xy( OSMcodes_br.ggeohash_to_xy(gid,5) , 512000/32)
  FROM (
    SELECT lpad((j*10+i)::text,2,'0') || c AS gid
    FROM generate_series(0,8) as j, generate_series(0,9) as i, (
      SELECT substr('0123456789BCDFGHJKLMNPQRSTUVWXYZ',k,1) as c
      FROM generate_series(1,32) t1(k)
    ) t2
  ) t3
;

--- Debug points:
INSERT INTO osmcodes_br.grid_test1_quadrants_full(gid,geom)
  SELECT gid||'-'||'pt',  ST_SetSRID(ST_MakePoint(xy_bound[1],xy_bound[2]),952019 ) as geom
  FROM (
    SELECT '00'||c as gid, osmcodes_br.ggeohash_to_xybounds('00'||c,5) as xy_bound
    FROM (
      SELECT substr('0123456789BCDFGHJKLMNPQRSTUVWXYZ',k,1) as c
      FROM generate_series(1,32) t1(k)
    ) t2
  ) t3
;

--- Unit box
SELECT c, osmcodes_common.ggeohash_to_uxybounds(c,5)
FROM (
  SELECT substr('0123456789BCDFGHJKLMNPQRSTUVWXYZ',k,1) as c
  FROM generate_series(1,32) t1(k)
) t2;


*/
