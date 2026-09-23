-- Idempotent setup for PostgREST. Runs on every start as the database owner.
-- psql variables: api_schema, anon_role, auth_role, authenticator_password
SET client_min_messages = warning;

SELECT format('CREATE ROLE %I NOLOGIN', :'anon_role')
 WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'anon_role') \gexec
SELECT format('CREATE ROLE %I NOLOGIN', :'auth_role')
 WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'auth_role') \gexec
SELECT 'CREATE ROLE authenticator LOGIN NOINHERIT NOCREATEDB NOCREATEROLE NOSUPERUSER'
 WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticator') \gexec

ALTER ROLE authenticator WITH LOGIN PASSWORD :'authenticator_password';
GRANT :"anon_role" TO authenticator;
GRANT :"auth_role" TO authenticator;

CREATE SCHEMA IF NOT EXISTS :"api_schema";
GRANT USAGE ON SCHEMA :"api_schema" TO :"anon_role", :"auth_role";

-- Tables, views and sequences created later in the API schema are usable by
-- requests carrying a JWT with the authenticated role; anonymous requests get
-- nothing until you grant it explicitly.
ALTER DEFAULT PRIVILEGES IN SCHEMA :"api_schema"
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"auth_role";
ALTER DEFAULT PRIVILEGES IN SCHEMA :"api_schema"
  GRANT USAGE, SELECT ON SEQUENCES TO :"auth_role";

-- Reload the PostgREST schema cache automatically after DDL.
CREATE OR REPLACE FUNCTION public.pgrst_watch() RETURNS event_trigger
  LANGUAGE plpgsql AS $$
BEGIN
  NOTIFY pgrst, 'reload schema';
END;
$$;
DROP EVENT TRIGGER IF EXISTS pgrst_watch;
CREATE EVENT TRIGGER pgrst_watch ON ddl_command_end EXECUTE PROCEDURE public.pgrst_watch();
