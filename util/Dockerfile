FROM alpine:3.16.2 as surfliner-util

RUN apk add --no-cache \
    postgresql-client \
    aws-cli

RUN mkdir /data
WORKDIR /data

COPY scripts ./bin
ENV PATH="/data/bin:$PATH"

ENTRYPOINT ["/data/bin/util-entrypoint.sh"]
