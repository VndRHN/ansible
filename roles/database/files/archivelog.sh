#!/bin/bash

if [ ! $1 ]
then
	echo "Usage: `basename $0` ORACLE_SID"
	exit 99
fi

ps -ef | awk -F"ora_smon_" '/ora_smon_'$1'/ && !/awk/ {print $2}' | while read DBSID
do
        export ORACLE_SID=$DBSID
        export ORAENV_ASK=NO
        echo -n "Oraenv output: " && . oraenv

	printenv ORACLE_SID

sqlplus -s / as sysdba <<EOF
archive log list;
shutdown immediate
startup mount
alter database archivelog;
alter database open;
archive log list;
EOF

done
