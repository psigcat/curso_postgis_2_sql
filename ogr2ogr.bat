@echo off
setlocal
rem Definimos variables
rem ejecutable ogr2ogr
set ogr2ogr="C:\OSGeo4W64\bin\ogr2ogr.exe"
rem conexión a PostgreSQL
set pg="host=localhost port=5432 dbname=gis_curso schemas=aca user=gisadmin password=????????????"
rem Definimos Sistema de coordenadas
set srid="25831"
rem definomos capas
set capa1="D:\ZProjectA\HelpGIS\Curso_PostGIS\Datos\ACA\conques_principal.shp"
set capa2="D:\ZProjectA\HelpGIS\Curso_PostGIS\Datos\ACA\xarxa_rius_principal.shp"
rem  
rem ejecutamos conversión
%ogr2ogr% -a_srs EPSG:%srid% -f PostgreSQL PG:%pg% %capa1% -nln conques_principal -progress -skipfailures
%ogr2ogr% -a_srs EPSG:%srid% -f PostgreSQL PG:%pg% %capa2% -nln xarxa_rius_principal -progress -skipfailures
endlocal
echo "Fin"
pause
