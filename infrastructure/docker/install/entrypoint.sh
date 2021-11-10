#!/bin/bash

[ -z "$SCRIPT_ROOT" ] && echo "Need to set SCRIPT_ROOT" && exit 1;

if [ "$#" -ne 3 ] && [ "$#" -ne 4 ]; then
  echo "Usage:   $0" '$endpoint $cert_pem_file $cert_password [$request_base]' >&2
  echo "Example: $0" 'https://sparql.opendatahub.testingmachine.eu/sparql ./ssl/owner/cert.pem Password' >&2
  echo "Note: special characters such as $ need to be escaped in passwords!" >&2
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

base="$base_uri"
endpoint="$1"
cert_pem_file=$(realpath -s "$2")
cert_password="$3"

if [ -n "$4" ]; then
    request_base="$4"
else
    request_base="$base"
fi

printf "\n### Creating authorization to make the app public\n\n"

"$SCRIPT_ROOT"/admin/acl/make-public.sh -b "$base" -f "$cert_pem_file" -p "$cert_password" --request-base "$request_base"

printf "\n### Creating documents\n\n"

./create-documents.sh "$base" "$endpoint" "$cert_pem_file" "$cert_password" "$request_base"
