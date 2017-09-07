#!/bin/sh

# Var checks
if [ -n "$KEYCLOAK_HOST" ] && [ -n "$KEYCLOAK_PORT" ]; then
    # Inject variables
    sed -i s/__KEYCLOAK_HOST__/$KEYCLOAK_HOST/g /etc/nginx/conf.d/keycloak.conf
    sed -i s/__KEYCLOAK_PORT__/$KEYCLOAK_PORT/g /etc/nginx/conf.d/keycloak.conf

    if [ ! -f /etc/nginx/ssl/cert.pem ]; then
        echo "Generating self-signed SSL"

        mkdir -p /etc/nginx/ssl-self-signed

        openssl req \
            -x509 \
            -sha512 \
            -newkey rsa:4096 \
            -keyout /etc/nginx/ssl-self-signed/key.pem \
            -nodes \
            -out /etc/nginx/ssl-self-signed/cert.pem \
            -days 3650 \
            -subj "/C=US/ST=California/L=San Francisco/O=docker/OU=keycloak/CN=keycloak-server"

        cp /etc/nginx/ssl-self-signed/* /etc/nginx/ssl
    fi

    # Start nginx
    nginx -g "daemon off;"
else
    echo "ERROR: please provide KEYCLOAK_HOST, KEYCLOAK_PORT"
fi