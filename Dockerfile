FROM docker:latest

RUN apk update && \
    apk add git && \
    apk add --no-cache bash git py-pip py-boto

RUN pip install --upgrade pip
RUN pip install docker-compose
