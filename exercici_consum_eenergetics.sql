/*
Fer un mapa amb els consums energètics per sectors (primària, terciaria, industrial, etc.)  per comarca

- Consum energia elèctrica per comarca i sectors de Catalunya
- https://analisi.transparenciacatalunya.cat/Energia/Consum-d-energia-el-ctrica-per-municipis-i-sectors/8idm-becu/about_data
*/
-- Crear schema
create schema energia;

-- crear la taula
create table energia.consums_energetics (
   id serial,
   anyo integer,
   provincia text,
   comarca text,
   cdmun text,
   municipi text,
   codi_sector text,
   descripcio_sector text,
   consum_kwh bigint,
   observacions text,
   CONSTRAINT consums_energetics_pkey PRIMARY KEY (id)
);

-- anyo, provincia, comarca, cdmun, municipi, codi_sector, descripcio_sector, consum_kwh, observacions

-- Importem les dades amb la funció COPY
COPY energia.consums_energetics(anyo, provincia, comarca, cdmun, 
           municipi, codi_sector, descripcio_sector, consum_kwh, observacions)
FROM 'D:\ZProjectA\Barcelona_Activa\Curs_PostGIS_202407_juliol\Temp\Consum_d_energia_el_ctrica_per_municipis_i_sectors_de_Catalunya_20240729.csv'
DELIMITER ','
CSV HEADER;

-- eliminem la vista
drop view if exists energia.consums_energetics_per_municipi_2022 ;

-- Creem la vista
create view energia.consums_energetics_per_municipi_2022 as
select m.id, m.geom, m.codimuni, m.nommuni, m.habitants,
  --count(e.consum_kwh) filter (where e.descripcio_sector = 'PRIMARI' ) as count_primaria,
  sum(coalesce(e.consum_kwh, 0)) filter (where e.descripcio_sector = 'PRIMARI' ) as consum_khw_primaria,
  sum(coalesce(e.consum_kwh, 0)) filter (where e.descripcio_sector = 'CONSTRUCCIO I OBRES PUBLIQUES' ) as consum_khw_constru,
  sum(coalesce(e.consum_kwh, 0)) filter (where e.descripcio_sector = 'INDUSTRIAL' ) as consum_khw_industrial,
  sum(coalesce(e.consum_kwh, 0)) filter (where e.descripcio_sector = 'TERCIARI' ) as consum_khw_terciari,
  sum(coalesce(e.consum_kwh, 0)) filter (where e.descripcio_sector = 'TRANSPORT' ) as consum_khw_transport,
  sum(coalesce(e.consum_kwh, 0)) filter (where e.descripcio_sector = 'USOS DOMESTICS' ) as consum_khw_usos_domestics
from limit_admin.munis_poly as m
 left join energia.consums_energetics as e 
    on  left(m.codimuni, 5) = e.cdmun
where e.anyo = 2022
group by m.id, m.geom, m.codimuni, m.nommuni, m.habitants
;
