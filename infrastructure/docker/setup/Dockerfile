FROM openjdk:11

RUN apt update && apt install uuid-runtime

COPY setup.sh /entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh", "/ssl", "OWNER_CERT_PASSWORD", "SECRETARY_CERT_PASSWORD", "36500" ]
