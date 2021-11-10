FROM debian:stable-slim

ARG JENA_VERSION=4.2.0

# download and extract Jena
RUN mkdir /jena && \
  curl -SL "https://archive.apache.org/dist/jena/binaries/apache-jena-${JENA_VERSION}.tar.gz" | \
  tar -xzf - -C /jena

# setup Jena
ENV JENA_HOME=/jena
ENV PATH="${PATH}:${JENA_HOME}/bin"

ENV SCRIPT_ROOT=/scripts

COPY ./scripts /scripts
COPY ./create-documents.sh /create-documents.sh
COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "$ENDPOINT" ]
