#!/bin/sh

set -e

sed -i "s/dc=my-domain,dc=com/dc=example,dc=org/" /etc/openldap/slapd.ldif
ln -s /opt/guacamole/ldap/guacConfigGroup.ldif /etc/openldap/schema
sed -i "s/^include: file:\/\/\/etc\/openldap\/schema\/nis.ldif$/&\ninclude: file:\/\/\/etc\/openldap\/schema\/guacConfigGroup.ldif/" /etc/openldap/slapd.ldif
/usr/sbin/slapadd -n 0 -F /etc/openldap/slapd.d -l /etc/openldap/slapd.ldif
for i in /docker-entrypoint-initdb.d/*.ldif
do
	/usr/sbin/slapadd -n 1 -F /etc/openldap/slapd.d -l "$i"
done
chown -R ldap:ldap /etc/openldap/slapd.d
exec /usr/sbin/slapd -d ${DEBUG_LEVEL:-None} -h "ldap:/// ldaps:///" -F /etc/openldap/slapd.d
