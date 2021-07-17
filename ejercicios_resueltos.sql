

-- 5 comarcas mas grandes
select nomcomar, st_area(geom) as area_m2, st_area(geom)/1000000 as area_km2
    from limit_admin.comarques
    order by ST_Area(geom) desc
    limit 5
  ;

-- 10 municipios con más habitantes
select nommuni, habitants
    from limit_admin.munis_poly
	where habitants is not null
    order by habitants desc
    limit 10
;

-- comarcas mas grandes de 1000 km2
select nomcomar, ST_AsEWKT(ST_Centroid(geom))
    from limit_admin.comarques
    where ST_Area(geom) > 1000000000
;

-- Habitantes por provincia						 
select m.codiprov, sum(m.habitants) as habitantes
     -- , ST_Union(geom) as geom
    from limit_admin.munis_poly as m
    where m.habitants is not null
    group by m.codiprov
;

-- Habitantes por comarca						 
select m.nomcomar, sum(m.habitants) as habitantes
     -- , ST_Union(geom) as geom
    from limit_admin.munis_poly as m
    where m.habitants is not null
    group by m.nomcomar
	order by sum(m.habitants) desc  
;

-- Contar cuantos municipios hay en cada comarca
select nomcomar, count(nomcomar)
    from limit_admin.munis_poly
    where habitants is not null
    group by nomcomar
;

-- listado de nombres de comarcas y espacios del PEIN
select 'comarca' as origen , nomcomar as nom
from limit_admin.comarques
union 
select 'pein' as origen, nom as nom
from medi_ambient.espais_pein
order by origen, nom
;
				       
-- listado de municipios que tocan el Massís del Montseny
select m.codimuni, m.nommuni, m.habitants, m.geom
  from limit_admin.munis_poly as m
	left join medi_ambient.espais_pein as p
              on ST_Intersects(m.geom, p.geom) 
  where p.nom='Massís del Montseny'
  group by m.codimuni, m.nommuni, m.habitants, m.geom
;

-- Provincia que tiene el municipi más pequeño
select p.id, p.nomprov
    from limit_admin.provincies as p
    where codiprov = (
        select codiprov
            from limit_admin.munis_poly
            order by ST_Area(geom) asc 
            limit 1 
    ) 
;


-- 1- listado de municipios que están dentro del pein Montseny
-- Eliminar la vista si existe
drop view if exists limit_admin.v_munis_montseny cascade;
-- Crea la vista, habitantes de Cat
create view limit_admin.v_munis_montseny as
  select m.codimuni, m.nommuni, m.geom
    from limit_admin.munis_poly as m, medi_ambient.espais_pein as p
    where ST_Intersects(m.geom, p.geom) and p.nom='Massís del Montseny'
    group by m.codimuni, m.nommuni, m.geom
;

							  
-- 2- Superfície de intersección entre el municipio de Viladrau y el PEIN del Montseny
-- Eliminar la vista si existe
drop view if exists limit_admin.v_viladrau_montseny cascade;
-- Vista Viladrau intersection Montseny
create view limit_admin.vista_viladrau as
  select m.codimuni, m.nommuni,
       ST_Intersection(m.geom, p.geom) as geom,
	   ST_Area(ST_Intersection(m.geom, p.geom))::numeric(12, 2) as area_m2
  from limit_admin.munis_poly as m
       join medi_ambient.espais_pein as p on ST_Intersects(m.geom, p.geom)
  where nommuni = 'Viladrau'					 


-- 3- metros de rio por municipio, solo para el Tordera
-- Eliminar la vista si existe
drop view if exists limit_admin.v_tordera_munis cascade;
-- Crea la vista limit_admin.v_tordera_munis de Cat
create view limit_admin.v_tordera_munis as
  select m.codimuni, m.nommuni, 
      ST_Intersection(ST_Union(m.geom),ST_Union(r.geom)) as geom, 
      ST_Length(ST_Intersection(ST_Union(m.geom),ST_Union(r.geom)))::numeric(10,2) as longitud
   from limit_admin.munis_poly as m
        join medi_ambient.xarxa_rius_principal as r on ST_Intersects(m.geom, r.geom) 
   where r.nom='la Tordera'
   group by m.codimuni, m.nommuni, r.nom
   order by longitud
;


-- create función que calcula el área
create or replace function limit_admin.calcula_area() returns trigger as $$
begin
	new.area := ST_Area(new.geom);
	return new;
end;
$$ language plpgsql;

-- create trigger para calcular el área al insertar o actializar una geometría
create trigger area_trigger
	before insert or update of geom
	on limit_admin.munis_poly  
	for each row
	execute procedure limit_admin.calcula_area();
												 
												 
												 
-- Añado 2 nuevas columnas
alter table limit_admin.munis_poly add column coordenada_x integer;
alter table limit_admin.munis_poly add column coordenada_y integer;											 
												 
												 
-- Actualizo el campo nuevo 
update limit_admin.munis_poly set coordenada_x = st_x(ST_PointOnSurface(geom)) where st_isvalid(geom) is true;
update limit_admin.munis_poly set coordenada_y = st_y(ST_PointOnSurface(geom)) where st_isvalid(geom) is true;

-- create función que calcula el centroide
create or replace function limit_admin.calcula_centroide() returns trigger as $$
begin
	new.coordenada_x := st_x(ST_PointOnSurface(new.geom));
	new.coordenada_y := st_y(ST_PointOnSurface(new.geom));
	return new;
end;
$$ language plpgsql;												 
