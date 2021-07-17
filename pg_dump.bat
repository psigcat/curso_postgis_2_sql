@echo off
setlocal
set pg_dump="C:\Program Files\pgAdmin 4\v5\runtime\pg_dump.exe"
rem ############## configuracio
set host=localhost
set port=5432
set db=gis_curso
set user=gisadmin
rem ############## declaremos dia y hora = fecha
set year=%date:~-4%
set month=%date:~3,2%
set day=%date:~0,2%
set hora=%time:~0,2% 
set hora=%hora: =%
if %hora% LSS 10 set hora=0%hora%
set minuto=%time:~3,2%
set fecha=%year%%month%%day%%hora%%minuto%
echo "Fecha de hoy: %fecha%"
rem
rem ############## Hacemos el Backup en formato dump
echo "Vamos a comprimir la DDBB %db% aquí %db%_%fecha%.dump"
%pg_dump% -h %host% -d %db% -U %user% -v -F custom --inserts --column-inserts -f %db%_%fecha%.dump
endlocal
echo "Fí"
pause
