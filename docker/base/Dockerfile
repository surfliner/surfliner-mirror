FROM docker:18.09.5

RUN uname -a
RUN echo 'http://mirror.leaseweb.com/alpine/v3.9/main' > /etc/apk/repositories; \
    echo 'http://mirror.leaseweb.com/alpine/v3.9/community' >> /etc/apk/repositories
RUN cat /etc/apk/repositories

RUN apk update && \
    apk add --no-cache git bash && \
    apk add --no-cache gcc linux-headers make musl-dev libffi-dev openssl-dev && \
    apk add --no-cache python-dev py-pip py-boto

RUN pip install --upgrade pip
RUN pip install docker-compose
