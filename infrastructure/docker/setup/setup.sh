#!/usr/bin/env bash

if [ "$#" -ne 4 ]; then
  echo "Usage:   $0" '$out_folder $owner_cert_pwd $secretary_cert_pwd $validity' >&2
  echo "Example: $0 ssl Password Password 3650" >&2
  exit 1
fi

out_folder="$1"

if [ -f "$out_folder/.setup-done" ]; then
    echo "Setup already ran"
    exit
fi

printf "### Output folder: %s\n" "$out_folder"

proxy_host="nginx"

server_cert="${out_folder}/server/server.crt"
server_public_key="${out_folder}/server/server.key"

owner_alias="owner"
owner_keystore="${out_folder}/owner/keystore.p12"
owner_cert_pwd="$2"
owner_cert="${out_folder}/owner/cert.pem"
owner_public_key="${out_folder}/owner/public.pem"

secretary_alias="secretary"
secretary_keystore="${out_folder}/secretary/keystore.p12"
secretary_cert="${out_folder}/secretary/cert.pem"
secretary_cert_pwd="$3"
secretary_cert_dname="CN=LDH, OU=LDH, O=AtomGraph, L=Copenhagen, ST=Denmark, C=DK"

validity="$4"

if [ -z "${PROTOCOL}" ]; then
    echo "Configuration is incomplete: PROTOCOL is missing"
    exit 1
fi
if [ -z "${HTTPS_PORT}" ]; then
    echo "Configuration is incomplete: HTTPS_PORT is missing"
    exit 1
fi
if [ -z "${HTTP_PORT}" ]; then
    echo "Configuration is incomplete: HTTP_PORT is missing"
    exit 1
fi
if [ -z "${HOST}" ]; then
    echo "Configuration is incomplete: HOST is missing"
    exit 1
fi
if [ -z "${ABS_PATH}" ]; then
    echo "Configuration is incomplete: ABS_PATH is missing"
    exit 1
fi

if [ "${PROTOCOL}" = "https" ]; then
    if [ "${HTTPS_PORT}" = 443 ]; then
        base_uri="${PROTOCOL}://${HOST}${ABS_PATH}"
    else
        base_uri="${PROTOCOL}://${HOST}:${HTTPS_PORT}${ABS_PATH}"
    fi
else
    if [ "${HTTP_PORT}" = 80 ]; then
        base_uri="${PROTOCOL}://${HOST}${ABS_PATH}"
    else
        base_uri="${PROTOCOL}://${HOST}:${HTTP_PORT}${ABS_PATH}"
    fi
fi

printf "\n### Base URI: %s\n" "$base_uri"

### SERVER CERT ###

mkdir -p "$out_folder"/server

# crude check if the host is an IP address
IP_ADDR_MATCH=$(echo "${HOST}" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" || test $? = 1)

if [ -n "$IP_ADDR_MATCH" ]; then
    if [ -n "$proxy_host" ]; then
        ext="subjectAltName=IP:${HOST},DNS:${proxy_host}" # IP address - special case for localhost
    else
        ext="subjectAltName=IP:${HOST}" # IP address
    fi
else
    if [ -n "$proxy_host" ]; then
        ext="subjectAltName=DNS:${HOST},DNS:${proxy_host}" # hostname - special case for localhost
    else
        ext="subjectAltName=DNS:${HOST}" # hostname
    fi
fi

openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
  -keyout "$server_public_key" -out "$server_cert" \
  -subj "/CN=${HOST}/OU=LinkedDataHub/O=AtomGraph/L=Copenhagen/C=DK" \
  -addext "$ext"

### OWNER CERT ###

if [ -z "${OWNER_GIVEN_NAME}" ]; then
    echo "Configuration is incomplete: OWNER_GIVEN_NAME is missing"
    exit 1
fi
if [ -z "${OWNER_FAMILY_NAME}" ]; then
    echo "Configuration is incomplete: OWNER_FAMILY_NAME is missing"
    exit 1
fi
if [ -z "${OWNER_ORG_UNIT}" ]; then
    echo "Configuration is incomplete: OWNER_ORG_UNIT is missing"
    exit 1
fi
if [ -z "${OWNER_ORGANIZATION}" ]; then
    echo "Configuration is incomplete: OWNER_ORGANIZATION is missing"
    exit 1
fi
if [ -z "${OWNER_LOCALITY}" ]; then
    echo "Configuration is incomplete: OWNER_LOCALITY is missing"
    exit 1
fi
if [ -z "${OWNER_STATE_OR_PROVINCE}" ]; then
    echo "Configuration is incomplete: OWNER_STATE_OR_PROVINCE is missing"
    exit 1
fi
if [ -z "${OWNER_COUNTRY_NAME}" ]; then
    echo "Configuration is incomplete: OWNER_COUNTRY_NAME is missing"
    exit 1
fi

owner_uuid=$(uuidgen | tr '[:upper:]' '[:lower:]') # lowercase
owner_uri="${base_uri}admin/acl/agents/${owner_uuid}/#this"

printf "\n### Owner's WebID URI: %s\n" "$owner_uri"

owner_cert_dname="CN=${OWNER_GIVEN_NAME} ${OWNER_FAMILY_NAME}, OU=${OWNER_ORG_UNIT}, O=${OWNER_ORGANIZATION}, L=${OWNER_LOCALITY}, ST=${OWNER_STATE_OR_PROVINCE}, C=${OWNER_COUNTRY_NAME}"
printf "\n### Owner WebID certificate's DName attributes: %s\n" "$owner_cert_dname"

mkdir -p "$out_folder"/owner

keytool \
    -genkeypair \
    -alias "$owner_alias" \
    -keyalg RSA \
    -storetype PKCS12 \
    -keystore "$owner_keystore" \
    -storepass "$owner_cert_pwd" \
    -keypass "$owner_cert_pwd" \
    -dname "$owner_cert_dname" \
    -ext "SAN=uri:${owner_uri}" \
    -validity "$validity"

# convert owner's certificate to PEM

openssl \
    pkcs12 \
    -in "$owner_keystore" \
    -passin pass:"$owner_cert_pwd" \
    -out "$owner_cert" \
    -passout pass:"$owner_cert_pwd"

# convert owner's public key to PEM

openssl \
    pkcs12 \
    -in "$owner_keystore" \
    -passin pass:"$owner_cert_pwd" \
    -nokeys \
    -out "$owner_public_key"

### SECRETARY CERT ###

mkdir -p "$out_folder"/secretary

secretary_uuid=$(uuidgen | tr '[:upper:]' '[:lower:]') # lowercase
secretary_uri="${base_uri}admin/acl/agents/${secretary_uuid}/#this"

printf "\n### Secretary's WebID URI: %s\n" "$secretary_uri"

printf "\n### Secretary WebID certificate's DName attributes: %s\n" "$secretary_cert_dname"

keytool \
    -genkeypair \
    -alias "$secretary_alias" \
    -keyalg RSA \
    -storetype PKCS12 \
    -keystore "$secretary_keystore" \
    -storepass "$secretary_cert_pwd" \
    -keypass "$secretary_cert_pwd" \
    -dname "$secretary_cert_dname" \
    -ext "SAN=uri:${secretary_uri}" \
    -validity "$validity"

# convert secretary's certificate to PEM

openssl \
    pkcs12 \
    -in "$secretary_keystore" \
    -passin pass:"$secretary_cert_pwd" \
    -out "$secretary_cert" \
    -passout pass:"$secretary_cert_pwd"

touch "$out_folder/.setup-done"
