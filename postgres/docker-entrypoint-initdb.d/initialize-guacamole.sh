#!/bin/bash

set -e

psql -U "$POSTGRES_USER" << EOF
CREATE USER $POSTGRES_GUACAMOLE_USER WITH PASSWORD '$POSTGRES_GUACAMOLE_PASSWORD';
CREATE DATABASE $POSTGRES_GUACAMOLE_DB WITH OWNER $POSTGRES_GUACAMOLE_USER;
EOF
psql -d "$POSTGRES_GUACAMOLE_DB" -U "$POSTGRES_GUACAMOLE_USER" < /opt/guacamole/postgresql/schema/001-create-schema.sql
sed -e "s/guacadmin/${GUACAMOLE_ADMIN_USER:=admin}/g" -e "s/CA458A7D494E3BE824F5E1E175A1556C0F8EEF2C2D7DF3633BEC4A29C4411960//" -e "s/FE24ADC5E11E2B25288D1704ABE67A79E342ECC26064CE69C5B3177795A82264//" /opt/guacamole/postgresql/schema/002-create-admin-user.sql | psql -d "$POSTGRES_GUACAMOLE_DB" -U "$POSTGRES_GUACAMOLE_USER"
for i in $GUACAMOLE_GROUPS
do
	echo "INSERT INTO guacamole_entity (name,type) VALUES ('${i%:*}','USER_GROUP');" | psql -d "$POSTGRES_GUACAMOLE_DB" -U "$POSTGRES_GUACAMOLE_USER"
	entity_id=$(echo "SELECT entity_id FROM guacamole_entity WHERE name = '${i%:*}';" | psql -Atd "$POSTGRES_GUACAMOLE_DB" -U "$POSTGRES_GUACAMOLE_USER")
	echo "INSERT INTO guacamole_user_group (entity_id,disabled) VALUES ($entity_id,false);" | psql -d "$POSTGRES_GUACAMOLE_DB" -U "$POSTGRES_GUACAMOLE_USER"
	IFS=","
	for j in ${i##*:}
	do
		if [[ "$j" =~ ^(ADMINISTER|CREATE_((CONNECTION|USER)(_GROUP)?|SHARING_PROFILE))$ ]]
		then
			echo "INSERT INTO guacamole_system_permission (entity_id,permission) VALUES ('$entity_id','$j');" | psql -d "$POSTGRES_GUACAMOLE_DB" -U "$POSTGRES_GUACAMOLE_USER"
		fi
	done
done
IFS=" "
for i in $GUACAMOLE_CONNECTIONS
do
	if [[ "$i" =~ ^(kubernetes|ssh|rdp|telnet|vnc)://[^?]+(\?([^=]+=[^&]+)(&([^=]+=[^&]+))*)?$ ]]
	then
		connection_name=$(echo "$i" | sed -n "s/^\(kubernetes\|ssh\|rdp\|telnet\|vnc\):\/\/\([^?]\+\).*$/\2/p")
		protocol="${i%%://*}"
		echo "INSERT INTO guacamole_connection (connection_name,protocol) VALUES ('$connection_name','$protocol');" | psql -d "$POSTGRES_GUACAMOLE_DB" -U "$POSTGRES_GUACAMOLE_USER"
		connection_id=$(echo "SELECT connection_id FROM guacamole_connection WHERE connection_name = '$connection_name';" | psql -Atd "$POSTGRES_GUACAMOLE_DB" -U "$POSTGRES_GUACAMOLE_USER")
		IFS="&"
		for j in $(echo "$i" | sed -n "s/^\(kubernetes\|ssh\|rdp\|telnet\|vnc\):\/\/[^?]\+?\(.*\)$/\2/p")
		do
			echo "INSERT INTO guacamole_connection_parameter (connection_id,parameter_name,parameter_value) VALUES ($connection_id,'${j%%=*}','${j#*=}');" | psql -d "$POSTGRES_GUACAMOLE_DB" -U "$POSTGRES_GUACAMOLE_USER"
		done
	fi
done
