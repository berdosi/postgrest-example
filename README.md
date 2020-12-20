# Orders API

Create an minimal API using PostgREST for a webshop.
_This is a toy project to learn PostgREST, unlikely to be production-ready anytime soon._

## Pre-install

Create `order_api.conf`, and make it writable by the PostgreSQL superuser.

```Shell
touch order_api.conf
sudo chown postgres order_api.conf
```

## Install

Run install.sh as the PostgreSQL superuser. Add the name of the database to be created as an argument.

```Shell
sudo -u postgres ./install.sh orders
```

## Post-install

Remove write rights of PostgreSQL superuser.

Change ownership to the one running PostgREST. In this example, it is _johnnie_.

```Shell
sudo chown johnnie order_api.conf
```

## Run

`postgrest order_api.conf`
