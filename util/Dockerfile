FROM alpine:3.13.4 as surfliner-util

RUN apk --no-cache upgrade && \
    apk add --no-cache \
    postgresql-client \
    aws-cli

RUN mkdir /data
WORKDIR /data

COPY scripts ./bin
ENV PATH="/data/bin:$PATH"
