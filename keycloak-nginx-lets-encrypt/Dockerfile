FROM nginx:stable-alpine

MAINTAINER Jonathan Lin <ernsheong@gmail.com>

# Nginx configuration
RUN rm -rf /etc/nginx/conf.d/*
COPY keycloak.conf /etc/nginx/conf.d/keycloak.conf
COPY le.conf /etc/nginx/conf.d/le.conf

# Install certbot
RUN apk update && \
  apk add --no-cache certbot curl

# SSL configuration for Let's Encrypt
RUN mkdir -p /etc/letsencrypt
VOLUME /etc/letsencrypt

# Copy entrypoint.sh
COPY entrypoint.sh /custom/entrypoint.sh

CMD ["/custom/entrypoint.sh"]