
-- Crear roles
CREATE ROLE g_cons;
CREATE ROLE g_admin;

-- Usuarios de edición de GIS
CREATE ROLE gisadmin login PASSWORD 'your_password' IN ROLE g_admin;
-- Usuarios de consulta
CREATE ROLE gis      login PASSWORD 'otro_password' IN ROLE g_cons;


-- Asignamos permisos a los roles

-- Permiso total a los esquemas
GRANT ALL ON SCHEMA limit_admin TO g_admin;
GRANT ALL ON SCHEMA medi_ambient TO g_admin;
-- Permiso total a las tablas de cada esquema
GRANT ALL ON ALL TABLES IN SCHEMA limit_admin TO g_admin;
GRANT ALL ON ALL TABLES IN SCHEMA medi_ambient TO g_admin;
-- Permiso total a las sequencias
GRANT ALL ON ALL SEQUENCES IN SCHEMA limit_admin TO g_admin;
GRANT ALL ON ALL SEQUENCES IN SCHEMA medi_ambient TO g_admin;


-- Permiso para usar los esquemas y crear tablas
GRANT CREATE, USAGE ON SCHEMA limit_admin TO g_cons;
GRANT CREATE, USAGE ON SCHEMA medi_ambient TO g_cons;
-- Permiso para todas las tablas de los esquemas
GRANT SELECT ON ALL TABLES IN SCHEMA limit_admin TO g_cons;
GRANT SELECT ON ALL TABLES IN SCHEMA medi_ambient TO g_cons;
