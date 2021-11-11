FROM atomgraph/nginx

COPY config/default.conf /etc/nginx/conf.d/default.conf.template
CMD ["/bin/sh", "-c", "envsubst '$HTTPS_PORT $UPSTREAM_SERVER $UPSTREAM_HTTP_PORT $SERVER_NAME $SERVER_HTTPS_PORT $SERVER_HTTP_PORT $SERVER_CERT_FILE $SERVER_KEY_FILE $BODY_MAX_SIZE' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
