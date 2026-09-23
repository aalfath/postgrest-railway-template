# PostgREST v16.3 on Alpine, with psql for the first-run role/schema bootstrap.
FROM postgrest/postgrest:v16.3@sha256:ec0e25a4e24b0a3bc5e4f011369bfc736bd1b19f513bd01079b86329a7636962 AS postgrest

FROM alpine:3.24.2
RUN apk add --no-cache postgresql-client tini \
 && adduser -D -H -u 1000 postgrest
COPY --from=postgrest /bin/postgrest /usr/local/bin/postgrest
COPY bootstrap.sql /opt/postgrest/bootstrap.sql
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
USER postgrest
EXPOSE 3000
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
