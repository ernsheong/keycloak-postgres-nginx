#!/bin/sh

# Setting to false will configure with Let's Encrypt. Defaults to true.
SELF_SIGN_SSL=${SELF_SIGN_SSL:-true}

# Var checks
if [ -n "$KEYCLOAK_HOST" ] && [ -n "$KEYCLOAK_PORT" ]; then
    if ! [ "$SELF_SIGN_SSL" = true ]; then
        if ! [ -n "$KEYCLOAK_DOMAIN" ]; then
            echo "ERROR: Please provide KEYCLOAK_DOMAIN"
        fi
    fi
else
    echo "ERROR: please provide KEYCLOAK_HOST, KEYCLOAK_PORT"
fi

# Inject variables
sed -i s/__KEYCLOAK_HOST__/$KEYCLOAK_HOST/g /etc/nginx/conf.d/keycloak.conf
sed -i s/__KEYCLOAK_PORT__/$KEYCLOAK_PORT/g /etc/nginx/conf.d/keycloak.conf

if [ "$SELF_SIGN_SSL" = true ]; then
    sed -i s/__KEYCLOAK_DOMAIN__/_/g /etc/nginx/conf.d/keycloak.conf
else
    sed -i s/__KEYCLOAK_DOMAIN__/$KEYCLOAK_DOMAIN/g /etc/nginx/conf.d/keycloak.conf
fi

if [ ! -e /etc/nginx/ssl/cert.pem ] && [ "$SELF_SIGN_SSL" = "true" ]; then
    # Add OpenSSL for self-signing certificate
    apk update && apk add openssl

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
else
    # Use Let's Encrypt

    # Install certbot
    cd /tmp
    wget https://dl.eff.org/certbot-auto
    chmod a+x certbot-auto

    # Generate certificate
    /tmp/certbot-auto --nginx
fi

# Start nginx
nginx -g "daemon off;"