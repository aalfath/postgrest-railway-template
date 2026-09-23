# Deploy and Host PostgREST on Railway

PostgREST turns a PostgreSQL database into a RESTful API. Tables, views and functions in the exposed schema become endpoints with filtering, pagination, embedding and OpenAPI docs. Permissions come from Postgres roles, grants and row-level security, and requests are authenticated with JWTs. It powers the REST layer of Supabase.

## About Hosting PostgREST

This template deploys PostgREST v16.3, a Railway Postgres database and Swagger UI. On every start, a small wrapper creates the `authenticator`, `web_anon` and `authenticated` roles and the `api` schema, and it is safe to re-run. It also adds an event trigger so new tables appear in the API without a restart. Anonymous requests get nothing until you grant access. Requests carrying a JWT with `"role": "authenticated"`, signed with the generated secret, can read and write tables in `api`. PostgREST is light and stateless, so the Hobby plan is enough for most projects.

## Common Use Cases

- An instant CRUD API for a frontend, mobile app or internal tool, backed by Postgres
- Exposing SQL views and functions as endpoints without writing a backend
- Row-level-security APIs where each JWT only sees its own rows

## Dependencies for PostgREST Hosting

- PostgREST v16.3 (official `postgrest/postgrest:v16.3` binary, digest-pinned) built from [aalfath/postgrest-railway-template](https://github.com/aalfath/postgrest-railway-template)
- Railway Postgres (`ghcr.io/railwayapp-templates/postgres-ssl:18`) with a volume
- `swaggerapi/swagger-ui:v5.33.0` for interactive API docs

### Deployment Dependencies

- [PostgREST documentation](https://docs.postgrest.org/en/v16/)
- [PostgREST v16.3 release notes](https://github.com/PostgREST/postgrest/releases/tag/v16.3)
- [Template source repository](https://github.com/aalfath/postgrest-railway-template)
- [Railway private networking](https://docs.railway.com/reference/private-networking)

### Implementation Details

| Service | Source | Networking | Storage |
| --- | --- | --- | --- |
| postgrest | repo `aalfath/postgrest-railway-template` | public domain on 3000; private IPv4/IPv6 | none |
| docs | `swaggerapi/swagger-ui:v5.33.0` | public domain on 8080 | none |
| Postgres | Railway Postgres 18 | private only | volume |

Create a table (for example with `psql` against the Postgres service) and it is live immediately:

```sql
create table api.todos (id bigint generated always as identity primary key, task text not null, done boolean default false);
```

Call it with a JWT signed (HS256) with `PGRST_JWT_SECRET`, payload `{"role": "authenticated"}`:

```bash
curl https://<postgrest domain>/todos -H "Authorization: Bearer <jwt>"
curl -X POST https://<postgrest domain>/todos -H "Authorization: Bearer <jwt>" \
  -H "Content-Type: application/json" -d '{"task": "ship it"}'
```

To allow anonymous reads of a table: `grant select on api.todos to web_anon;`

| Variable | Default | Purpose |
| --- | --- | --- |
| `PGRST_JWT_SECRET` | generated 64-character secret | Verifies request JWTs |
| `PGRST_AUTHENTICATOR_PASSWORD` | generated secret | Password of the low-privilege login role PostgREST uses |
| `PGRST_DB_SCHEMAS` | `api` | Exposed schema(s) |
| `PGRST_DB_ANON_ROLE` | `web_anon` | Role for requests without a JWT |
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | Owner connection, used only for the bootstrap |

Notes:

- Any `PGRST_*` setting from the PostgREST configuration reference can be added as a variable.
- New tables in `api` are granted to `authenticated` automatically; use row-level security for per-user access.
- Set `PGRST_BOOTSTRAP=false` to skip the role and schema setup and manage it yourself.

This is a community-maintained deployment package and does not imply affiliation with or endorsement by the PostgREST project.

## Why Deploy PostgREST on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying PostgREST on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
