-- https://postgrest.org/en/v7.0.0/schema_structure.html :
-- By default, when a function is created, the privilege to execute it is not
-- restricted by role. The function access is PUBLIC—executable by all roles
-- (more details at PostgreSQL Privileges page). This is not ideal for an API
-- schema. To disable this behavior, you can run the following SQL statement:

ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

-- the role that will actually do the things
CREATE ROLE web_anon NOLOGIN;

-- the authenticated role will use this:
GRANT web_anon TO AUTH_PLACEHOLDER;

