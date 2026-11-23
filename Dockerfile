# PostgREST v16.6 on Alpine, with psql for the first-run role/schema bootstrap.
FROM postgrest/postgrest:v16.6@sha256:5ce030c153500fe90ba157da4da8ba99ab51d3bc7b95e071bd0b544b67a632f7 AS postgrest

FROM alpine:3.24.2
RUN apk add --no-cache postgresql-client tini \
 && adduser -D -H -u 1000 postgrest
COPY --from=postgrest /bin/postgrest /usr/local/bin/postgrest
COPY bootstrap.sql /opt/postgrest/bootstrap.sql
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
USER postgrest
EXPOSE 3000
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
