FROM nginx:stable-alpine

MAINTAINER Jonathan Lin <ernsheong@gmail.com>

# Nginx configuration
RUN rm -rf /etc/nginx/conf.d/*
ADD keycloak.conf /etc/nginx/conf.d/keycloak.conf

# SSL configuration
RUN mkdir -p /etc/nginx/ssl
VOLUME /etc/nginx/ssl

# Add OpenSSL for self-signing certificate
RUN [[ ! -e /etc/nginx/ssl/cert.pem ]] && apk update && apk add openssl

# Copy entrypoint.sh
ADD entrypoint.sh /custom/entrypoint.sh

CMD ["/custom/entrypoint.sh"]