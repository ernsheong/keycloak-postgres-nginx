#!/bin/sh

set -e

# Var checks
if [ -n "$KEYCLOAK_HOST" ] && \
    [ -n "$KEYCLOAK_PORT" ] && \
    [ -n "$KEYCLOAK_DOMAIN" ] && \
    [ -n "$LE_EMAIL" ]; then
    # Inject variables
    sed -i s/__KEYCLOAK_HOST__/$KEYCLOAK_HOST/g /etc/nginx/conf.d/keycloak.conf
    sed -i s/__KEYCLOAK_PORT__/$KEYCLOAK_PORT/g /etc/nginx/conf.d/keycloak.conf

    sed -i s/__KEYCLOAK_DOMAIN__/$KEYCLOAK_DOMAIN/g /etc/nginx/conf.d/keycloak.conf
    sed -i s/__KEYCLOAK_DOMAIN__/$KEYCLOAK_DOMAIN/g /etc/nginx/conf.d/le.conf

    # https://github.com/docker/compose/issues/2854 :(
    # See https://stackoverflow.com/a/24358387/1161743
    # Strip literal quotes in variable value
    LE_OPTIONS=$(eval echo $LE_OPTIONS)
    LE_RENEW_OPTIONS=$(eval echo $LE_RENEW_OPTIONS)
    LE_RENEW_CRON_COMMAND=$(eval echo $LE_RENEW_CRON_COMMAND)

    # Disable Keycloak config first as cert not present.
    mv -v /etc/nginx/conf.d/keycloak.conf /etc/nginx/conf.d/keycloak.conf.disabled

    (
        # Give nginx time to start
        sleep 5

        echo "Starting Let's Encrypt certificate install..."
        certbot certonly -n "${LE_OPTIONS}" \
            --agree-tos --email "${LE_EMAIL}" \
            --webroot -w /usr/share/nginx/html -d $KEYCLOAK_DOMAIN

        # Enable Keycloak config
        mv -v /etc/nginx/conf.d/keycloak.conf.disabled /etc/nginx/conf.d/keycloak.conf

        echo "Reloading NGINX with SSL..."
        nginx -s reload

        # Install crontab for cert renewal
        touch crontab.tmp \
            && echo "37 2 * * * certbot renew ${LE_RENEW_OPTIONS} --post-hook 'nginx -s reload' && ${LE_RENEW_CRON_COMMAND} > /dev/null 2>&1" > crontab.tmp \
            && crontab crontab.tmp \
            && rm crontab.tmp

        # Start crond
        /usr/sbin/crond
    ) &

    # Start nginx
    echo "Starting NGINX..."
    nginx -g "daemon off;"
else
    echo "ERROR: please provide KEYCLOAK_HOST, KEYCLOAK_PORT, KEYCLOAK_DOMAIN, LE_EMAIL"
fi