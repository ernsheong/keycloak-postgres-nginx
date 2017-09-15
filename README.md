# keycloak-postgres-nginx

Docker configuration for Keycloak + Nginx + Postgres with Let's Encrypt support.

Easily setup a standalone node for [Keycloak](http://www.keycloak.org) server so you can worry less about authentication and worry more about your application features.

## Usage

1. Modify the variables in the `.env` file.

1. For `LE_OPTIONS`, choose either `--staging` or `--keep-until-expiring`, not both. (TODO: debug options failure)

1. For dev purposes: `docker-compose -f docker-compose-self-signed.yml up`

1. For production: `docker-compose -f docker-compose-lets-encrypt.yml up`

## License

MIT License.
