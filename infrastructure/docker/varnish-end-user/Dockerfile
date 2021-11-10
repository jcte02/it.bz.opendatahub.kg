FROM atomgraph/varnish

COPY config/varnish.vcl.template /etc/varnish/default.vcl.template
ENTRYPOINT [ "/bin/sh" ]
CMD [ "-c", "envsubst < /etc/varnish/default.vcl.template > /etc/varnish/default.vcl && /usr/local/bin/docker-varnish-entrypoint" ]
