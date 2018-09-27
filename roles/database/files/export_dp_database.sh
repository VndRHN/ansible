#!/bin/bash

####################################################
# programma          : export_dp_database.sh       #
# auteur             : Geert van der Ploeg         #
####################################################
# Datum       : Geschiedenis                       #
# ==========    ================================== #
# 15-10-2007  : Initiele versie 01.00-00           #
# 28-05-2008  : Aangepast voor RAC 01.01-00        #
# 20-08-2008  : export NLS aangepast               #
#             : fuctie logdate toegevoegd          #
# 05-12-2012  : aangepast voor RAC 11.2            #
# 09-05-2014  : kleine verbeteringen               #
# 13-06-2016  : argument optie toegevoegd          #
#################################################### 

function logdate {
  echo -n `date +%F" "%a" "%T"."%3N`' - '
}

if [ -z "$ORACLE_HOME" ]; then source ~/.bash_profile; fi

EXPORT_DIR=/backup/export

# als het script gestart wordt met een argument, dan krijgt ORACLE_SID die waarde
if [ ${#1} -gt 0 ]; then
        echo $1
        export ORACLE_SID=$1
fi

logdate && echo "#### EXPORT ORACLE_SID $ORACLE_SID ####"

# Controleer of variable ORACLE_SID gevuld is.
if test ${#ORACLE_SID} -eq 0
then
	logdate && echo ORACLE_SID is leeg
	exit
else
	logdate && echo ORACLE_SID = $ORACLE_SID
	# Controleer of gevonden SID een ASM instance betreft, zoniet dan mag er ge-exporteerd/gebackupt worden
	ASM=`echo $ORACLE_SID | grep -c ASM`
	if test ${ASM} -eq 1
	then
		logdate && echo Betreft ASM: geen export/backup
		exit
	else
		# Controleer of Instance up is
		INSTANCE_UP=`ps -ef | egrep -v grep | grep -c ora_pmon_$ORACLE_SID$`
		if test ${INSTANCE_UP} -eq 0
		then
			logdate && echo Instance $ORACLE_SID draait niet
			exit
		else
			logdate && echo Instance $ORACLE_SID draait

			export ORAENV_ASK=NO
			logdate && echo -n "Oraenv output: " && . oraenv

			# Vraag DB_NAME uit database op
			export DB_NAME=`echo "select lower(name) NAME from v\\$database;" | sqlplus -s / as sysdba | grep -v NAME | grep '[A-Za-z]'`

			logdate && echo "Definieer DIRECTORY DATA_PUMP_DIR voor data pump"
RETURN=`sqlplus -s '/ as sysdba' <<EOF
SET HEADING OFF
SET NEWPAGE NONE

CREATE OR REPLACE DIRECTORY DATA_PUMP_DIR AS '${EXPORT_DIR}';

EOF`
logdate && echo Feedback SQL: $RETURN

if [ -f "${EXPORT_DIR}/${DB_NAME}_dp.dmp" ]
then
			logdate && echo -n "Verwijder oude dump: " && rm -v ${EXPORT_DIR}/${DB_NAME}_dp.dmp
fi
			logdate && echo "De export start met deze gegevens:"
			logdate && echo "ORACLE_HOME = ${ORACLE_HOME}"
			logdate && echo "ORACLE_SID = ${ORACLE_SID}"
			logdate && echo "DB_NAME = ${DB_NAME}"
			logdate && echo "Start export met logging: ${EXPORT_DIR}/${DB_NAME}_dp.log"

			expdp \'/ as sysdba\' directory=DATA_PUMP_DIR full=y dumpfile=${DB_NAME}_dp.dmp logfile=${DB_NAME}_dp.log exclude=statistics
		fi

		logdate && echo "Export gereed voor database $DB_NAME via instance $ORACLE_SID"
		echo #nieuwe regel
		
	fi
fi
