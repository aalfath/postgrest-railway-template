# PostgREST on Railway

PostgREST v16.3 packaged for Railway: the official static binary on Alpine with `psql`, plus an entrypoint that idempotently creates the `authenticator`, `web_anon` and `authenticated` roles and the `api` schema before starting PostgREST as `authenticator`.

The full template overview is published on the Railway marketplace.
