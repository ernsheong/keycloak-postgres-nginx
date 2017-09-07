#!/bin/sh

# Var checks
if [ -n "$KEYCLOAK_HOST" ] && \
    [ -n "$KEYCLOAK_PORT" ] && \
    [ -n "$KEYCLOAK_DOMAIN" ] && \
    [ -n "$LE_EMAIL" ]; then
    # Inject variables
    sed -i s/__KEYCLOAK_HOST__/$KEYCLOAK_HOST/g /etc/nginx/conf.d/keycloak.conf
    sed -i s/__KEYCLOAK_PORT__/$KEYCLOAK_PORT/g /etc/nginx/conf.d/keycloak.conf
    sed -i s/__KEYCLOAK_DOMAIN__/$KEYCLOAK_DOMAIN/g /etc/nginx/conf.d/keycloak.conf

    certbot certonly -n "${LE_OPTIONS}" --agree-tos --email "${LE_EMAIL}" --webroot -w /usr/share/nginx/html -d $KEYCLOAK_DOMAIN

    # Start nginx
    nginx -g "daemon off;"
else
    echo "ERROR: please provide KEYCLOAK_HOST, KEYCLOAK_PORT, KEYCLOAK_DOMAIN, LE_EMAIL"
fi