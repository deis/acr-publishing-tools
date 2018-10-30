FROM docker:18.03.1-dind

ENV HELM_VERSION=v2.11.0

RUN \
  apk update \
  && apk add \
    bash \
    git \
    make \
    py-pip \
  && apk add --virtual=build \
    curl \
    gcc \
    libffi-dev \
    musl-dev \
    openssl-dev \
    python-dev \
  && cd /usr/local/bin \
  && curl https://storage.googleapis.com/kubernetes-helm/helm-$HELM_VERSION-linux-amd64.tar.gz \
    | tar xvz linux-amd64/helm --strip-components=1 \
  && helm init --client-only \
  && pip install azure-cli \
  && apk del --purge build
