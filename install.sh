#!/bin/bash

# run it as a database admin user

DATABASE=$1

# set it to a user that can authenticate locally with username/password
DBUSER=authenticator

DBPASSWORD=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c32)

psql -c "CREATE DATABASE \"$DATABASE\""
psql -c "CREATE ROLE $DBUSER NOINHERIT LOGIN PASSWORD '$DBPASSWORD'";

JWT_SECRET=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c32)

sed -e "s/SECRET_PLACEHOLDER/$JWT_SECRET/" \
    -e "s/USER_PLACEHOLDER/$DBUSER/" \
    -e "s/PASSWORD_PLACEHOLDER/$DBPASSWORD/" \
    orders_api.conf.template > orders_api.conf

psql $DATABASE -c "ALTER DATABASE \"$DATABASE\" SET \"app.jwt_secret\" TO '$JWT_SECRET';"

sed -e "s/AUTH_PLACEHOLDER/$DBUSER/" 000_initial_grant.sql | psql $DATABASE

psql $DATABASE < 001_pgcrypto.sql

psql $DATABASE < 002_db_init_schema.sql

psql $DATABASE < 003_init_schema_api.sql
