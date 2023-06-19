#!/bin/bash

set -e

declare -A options
for i in ${!PASSWORD_@}
do
	login=$(echo -n "${i,,}" | tail -c +10)
	if ! id "$login" > /dev/null 2> /dev/null
	then
		adduser -D "$login"
	fi
	echo -e "${!i}\n${!i}" | passwd "$login" > /dev/null
	if [ "${!i}" ]
	then
		options[PermitEmptyPasswords]="yes"
	fi
done
if [ -n "${PASSWORD_ROOT+x}" ]
then
	options[PermitRootLogin]="yes"
fi
/usr/bin/ssh-keygen -A
exec /usr/sbin/sshd -De$(for i in ${!options[@]};do echo -n " -o $i=${options[$i]}";done)
