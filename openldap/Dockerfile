ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION}

RUN apk add openldap openldap-back-mdb openldap-clients && \
    install -o ldap -g ldap -d /etc/openldap/slapd.d && \
    rm /etc/openldap/slapd.conf && \
    mkdir /docker-entrypoint-initdb.d

COPY --chown=root:root --chmod=755 ./entrypoint.sh /

EXPOSE 389/tcp
EXPOSE 636/tcp

ENTRYPOINT /entrypoint.sh
