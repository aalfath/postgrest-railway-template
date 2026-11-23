# Changelog

Each entry is one version of this Railway template. Breaking changes are listed first.

## 16.6 (2026-11-23)

- Breaking changes: none. No new variables.
- v16.5 adds `Prefer: timezone` validation to mitigate Postgres CVE-2026-14669 on unpatched Postgres versions; v16.4 and v16.6 are bug fixes (mixed-case schema root endpoint, `jwt-cache-max-entries` from the database, JSON body on internal server errors). Release notes: [v16.4](https://github.com/PostgREST/postgrest/releases/tag/v16.4), [v16.5](https://github.com/PostgREST/postgrest/releases/tag/v16.5), [v16.6](https://github.com/PostgREST/postgrest/releases/tag/v16.6).
- PostgREST v16.3 → **v16.6** (`postgrest/postgrest:v16.6@sha256:5ce030c153500fe90ba157da4da8ba99ab51d3bc7b95e071bd0b544b67a632f7`).
- Tested on Railway before merging: the published template was deployed, data was written, the service was switched to this version, and the data and login were still there.

