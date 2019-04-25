FROM docker:18.09.5

RUN uname -a
RUN echo 'http://mirror.leaseweb.com/alpine/latest-stable/main' > /etc/apk/repositories; \
    echo 'http://mirror.leaseweb.com/alpine/latest-stable/community' >> /etc/apk/repositories
RUN cat /etc/apk/repositories

RUN apk update && \
    apk add --no-cache curl tar gzip bash ca-certificates git && \
    apk add --no-cache gcc linux-headers make musl-dev libffi-dev openssl-dev && \
    apk add --no-cache python-dev py-pip py-boto

RUN pip install --upgrade pip
RUN pip install docker-compose

RUN curl -sSL -o /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN curl -sSL -O https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk
RUN apk add glibc-2.28-r0.apk
RUN rm glibc-2.28-r0.apk

ENV HELM_VERSION 2.13.1
ENV KUBERNETES_VERSION 1.11.9

RUN curl -sS "https://kubernetes-helm.storage.googleapis.com/helm-v${HELM_VERSION}-linux-amd64.tar.gz" | tar zx
RUN mv linux-amd64/helm /usr/bin/
RUN mv linux-amd64/tiller /usr/bin/
RUN helm version --client
RUN tiller -version

RUN curl -sSL -o /usr/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubectl"
RUN chmod +x /usr/bin/kubectl
RUN kubectl version --client
