FROM debian:stable

ARG JENA_VERSION=4.2.0

# download and extract Jena
RUN apt update && apt install -y curl default-jre-headless && \
  mkdir /jena && \
  curl -SL "https://archive.apache.org/dist/jena/binaries/apache-jena-${JENA_VERSION}.tar.gz" | \
  tar -xzf - -C /jena

# setup Jena
ENV JENA_HOME="/jena/apache-jena-${JENA_VERSION}"
ENV PATH="${PATH}:${JENA_HOME}/bin"

ENV SCRIPT_ROOT=/scripts

COPY ./wait-for-it.sh /wait-for-it.sh
COPY ./entrypoint.sh /entrypoint.sh
COPY ./create-documents.sh /create-documents.sh
COPY ./scripts /scripts
COPY ./queries /queries

ENTRYPOINT [ "/entrypoint.sh", "BASE", "ENDPOINT", "/ssl/owner/cert.pem", "OWNER_CERT_PASSWORD" ]
