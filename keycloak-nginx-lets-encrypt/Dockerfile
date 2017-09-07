FROM nginx:stable-alpine

MAINTAINER Jonathan Lin <ernsheong@gmail.com>

# Nginx configuration
RUN rm -rf /etc/nginx/conf.d/*
ADD keycloak.conf /etc/nginx/conf.d/keycloak.conf

# Install certbot
RUN apk update && apk add --no-cache certbot

# SSL configuration for Let's Encrypt
RUN mkdir -p /etc/letsencrypt
VOLUME /etc/letsencrypt

# Copy entrypoint.sh
ADD entrypoint.sh /custom/entrypoint.sh

CMD ["/custom/entrypoint.sh"]