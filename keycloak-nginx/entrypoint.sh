#!/bin/bash

if [ $KEYCLOAK_HOST ] \
    && [ $KEYCLOAK_PORT ] \
    && [ $REVERSE_PROXY_PORT ]; then

    # inject variables
    sed -i s/__KEYCLOAK_HOST__/$KEYCLOAK_HOST/g /etc/nginx/conf.d/keycloak.conf
    sed -i s/__KEYCLOAK_PORT__/$KEYCLOAK_PORT/g /etc/nginx/conf.d/keycloak.conf
    sed -i s/__REVERSE_PROXY_PORT__/$REVERSE_PROXY_PORT/g /etc/nginx/conf.d/keycloak.conf
    if [ $REVERSE_PROXY_PORT == 443 ]; then
        sed -i s/__REVERSE_PROXY_PORT_FOR_HOST__//g /etc/nginx/conf.d/keycloak.conf
    else
        sed -i s/__REVERSE_PROXY_PORT_FOR_HOST__/:$REVERSE_PROXY_PORT/g /etc/nginx/conf.d/keycloak.conf
    fi

    # if no ssl certificate is provided, create a self-signed certificate and use this
    if [ ! -e /etc/nginx/ssl/cert.pem ]; then
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

    # start nginx
    nginx -g "daemon off;"
else
    echo "ERROR: please provide KEYCLOAK_HOST, KEYCLOAK_PORT and REVERSE_PROXY_PORT"
fi