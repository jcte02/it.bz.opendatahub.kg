FROM nginxinc/nginx-unprivileged

COPY config/default.conf /etc/nginx/conf.d/default.conf.template
CMD ["/bin/sh", "-c", "envsubst '$HTTP_PORT $MAX_BODY_SIZE' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
