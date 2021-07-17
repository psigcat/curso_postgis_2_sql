@echo off
setlocal
rem  Definomos path de las aplicaciones
set psql="C:\Program Files\pgAdmin 4\v5\runtime\psql.exe"
set pg_restore="C:\Program Files\pgAdmin 4\v5\runtime\pg_restore.exe"
rem configuracions
set host=localhost
set dbname=gis_curso
set user=gisadmin
set file=gis_curs_202107171254.dump
rem
rem -- Primero renombramos la base de datos actual 
%psql% -h %host% -d postgres -U %user% -c "alter database %dbname% rename TO %dbname%_old
rem 
rem -- Ahora creamos la base de dades nueva
%psql% -h %host% -d postgres -U %user% -c "create database %dbname% template postgres owner %user%;"
rem
rem -- Ahora importamos o restauramos los datos del backup
%pg_restore% -j 7 -h %host% -d %dbname% -U %user% -F custom %file%
