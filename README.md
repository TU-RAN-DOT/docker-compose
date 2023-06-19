# docker-compose

This application specification contains a blueprint of a Guacamole instance connected via SAML to an LDAP-backed Identity Provider.

## Usage

The environment can be brought up by simply running `docker compose up -d`.

In order to be able to connect to the exposed web front-ends, the following FQDNs need to point to a loopback address:
- guacamole.example.org
- keycloak.example.org

This can either be achieved through the configuration of the local DNS server or through the addition of the following line in the file under `/etc/hosts`:

```
127.7.2.1	guacamole.example.org keycloak.example.org
```

In order to provide information about the status of the application, the included HAProxy is configured to serve its stats page. It can be reached by simply navigating to `localhost`.

A final word of caution: No persistence has been configured! This means that any changes made during runtime will be lost when removing the containers.
