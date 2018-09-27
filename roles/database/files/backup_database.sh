#!/bin/bash

######################################################################################
# programma          : backup_database.sh                                            #
# auteur             : Geert van der Ploeg                                           #
# versie             : 01.06-00                                                      #
######################################################################################
# Datum       : Geschiedenis                                                         #
# ==========    ==================================================================== #
# 07-08-2008  : Initiele versie 01.00-00                                             #
# 28-05-2008  : Aangepast voor RAC 01.01-00                                          #
# 20-08-2008  : fuctie logdate toegevoegd                                            #
# 05-12-2012  : Aangepast voor RAC 11.2 (01.02-00)                                   #
# 16-01-2013  : Snapshot controlfile op shared-disk                                  #
# 01-10-2015  : Toon laatste SCN uit list backup                                     #
# 25-01-2016  : Naamgeving variablen aangepast                                       #
# 25-01-2016  : Snapshot controlfile naar nieuwe directorie                          #
#										     #
######################################################################################

function logdate {
  echo -n `date +%F" "%a" "%T"."%3N`' - '
}

if [ -z "$ORACLE_HOME" ]; then source ~/.bash_profile; fi

RETENTION_DAYS=3

CATALOGDB=rmancat
CATALOGUSER=rman
CATALOGPASS=rman

RMAN_BASE_DIR=/backup/rman
RMAN_BACKUP_SNAPCF_DIRECTORY="$RMAN_BASE_DIR"/snapshot_controlfile
RMAN_BACKUP_DIR="$RMAN_BASE_DIR"/backups
RMAN_LOGS_DIR="$RMAN_BASE_DIR"/logs

DATE=`date +%Y%m%d_%H%M`

logdate && echo "#### RMAN BACKUP ORACLE_SID $ORACLE_SID ####"

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
                        SECONDS=0

			logdate && echo Instance $ORACLE_SID draait

			export ORAENV_ASK=NO
			logdate && echo -n "Oraenv output: " && . oraenv

			# Vraag DB_NAME uit database op
			export DB_NAME=`echo "select lower(name) name from v\\$database;" | sqlplus -s / as sysdba | grep -v NAME | egrep -i "^[a-z]"`

			# Vraag DBID uit database op
			export DBID=`echo "select to_char(DBID) dbid from v\\$database;" | sqlplus -s / as sysdba | grep -v DBID | egrep -i "^[0-9]"`

			# Controleer of backupdirectorie voor de database bestaat, zoniet maak deze dan aan
			
			RMAN_BACKUP_DIR_DBNAME=${RMAN_BACKUP_DIR}/${DB_NAME}
			if [ -d $RMAN_BACKUP_DIR_DBNAME ]
			then
				logdate && echo Backupdirectory bestaat: $RMAN_BACKUP_DIR_DBNAME 
				#do nothing
			else
				mkdir $RMAN_BACKUP_DIR_DBNAME
				logdate && echo Backupdirectory aangemaakt: $RMAN_BACKUP_DIR_DBNAME
			fi

			LOGFILE=$RMAN_LOGS_DIR/$DB_NAME'_'$DATE'_backup_database'.log

			# verwijder snapcf.f van oude locatie
			if [ -f $RMAN_BACKUP_DIR_DBNAME/snapcf.f ]
			then 
                           logdate && echo Verwijder bestand op oude locatie: $RMAN_BACKUP_DIR_DBNAME/snapcf.f
			   rm $RMAN_BACKUP_DIR_DBNAME/snapcf.f
			fi

			# verwijder autobackups als RMAN ze niet heeft verwijderd
			find $RMAN_BACKUP_DIR_DBNAME -type f -name 'c-*' -mtime +$RETENTION_DAYS -exec rm {} \;

			logdate && echo "Start RMAN zonder Catalog met logging: $LOGFILE"
			logdate && echo "en start voor database $DB_NAME via instance $ORACLE_SID"

			logdate && echo -n "RMAN output: " &&
rman TARGET / NOCATALOG log=$LOGFILE<<EOF

run {
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF $RETENTION_DAYS DAYS;
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '$RMAN_BACKUP_DIR_DBNAME/rman_%U_%T_%d';
CONFIGURE DEVICE TYPE DISK BACKUP TYPE TO COMPRESSED BACKUPSET PARALLELISM 1;
CONFIGURE SNAPSHOT CONTROLFILE NAME TO '$RMAN_BACKUP_SNAPCF_DIRECTORY/snapcf_$DB_NAME.f';

CONFIGURE CONTROLFILE AUTOBACKUP ON;
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '$RMAN_BACKUP_DIR_DBNAME/%F';
# Tip van Wierd CONFIGURE DEVICE TYPE DISK BACKUP TYPE TO COMPRESSED BACKUPSET;

CROSSCHECK BACKUP OF CONTROLFILE;
CROSSCHECK BACKUP OF DATABASE;
CROSSCHECK ARCHIVELOG ALL;
CROSSCHECK BACKUPSET; # 12-11-2008 Bas
CROSSCHECK COPY;      # 12-11-2008 Bas

CATALOG START WITH '$RMAN_BACKUP_DIR_DBNAME/' NOPROMPT;

DELETE NOPROMPT EXPIRED BACKUP;   # 12-11-2008 Bas
DELETE NOPROMPT EXPIRED COPY;     # 12-11-2008 Bas
DELETE NOPROMPT EXPIRED ARCHIVELOG ALL;

BACKUP CURRENT CONTROLFILE;
BACKUP DATABASE PLUS ARCHIVELOG DELETE INPUT;

DELETE NOPROMPT FORCE OBSOLETE;
}
exit
EOF
		
			echo #nieuwe regel

			logdate && echo "RMAN gereed voor database $DB_NAME via instance $ORACLE_SID"

			logdate && echo "list backup;"| rman target / | tail -n 10 | grep SCN | cut -d: -f2- | awk '{ print $2" "$3 }'

			logdate && echo `grep -c -i ora- $LOGFILE` " ORA meldingingen uit $LOGFILE"

######   #######   #####   #     #  #     #   #####          #####      #     #######     #     #        #######   #####
#     #  #        #     #   #   #   ##    #  #     #        #     #    # #       #       # #    #        #     #  #     #
#     #  #        #          # #    # #   #  #              #         #   #      #      #   #   #        #     #  #
######   #####     #####      #     #  #  #  #              #        #     #     #     #     #  #        #     #  #  ####
#   #    #              #     #     #   # #  #              #        #######     #     #######  #        #     #  #     #
#    #   #        #     #     #     #    ##  #     #        #     #  #     #     #     #     #  #        #     #  #     #
#     #  #######   #####      #     #     #   #####          #####   #     #     #     #     #  #######  #######   #####


			#logdate && echo Controleer of de RMAN catalog database beschikbaar is
			RETURN=`sqlplus -s $CATALOGUSER/$CATALOGPASS@$CATALOGDB <<EOF
SET HEADING OFF
SET NEWPAGE NONE
SET FEEDBACK OFF
SELECT TO_CHAR(1) FROM DUAL;
EOF`

			echo #nieuwe regel

			DATE=`date +%Y%m%d_%H%M`
			LOGFILE=$RMAN_LOGS_DIR/$DB_NAME'_'$DATE'_resync_catalog'.log

			#if test "${#RETURN}" -eq 1 and "${RETURN}" -eq 1
            if [ ${#RETURN} -eq 1 ] && [ "${RETURN}" = "1" ]    # lengte is 1 en waarde is 1
			then
				logdate && echo "RMAN catalog database $CATALOGDB is beschikbaar"
			else
				logdate && echo "RMAN catalog database $CATALOGDB is NIET beschikbaar"

                echo #nieuwe regel
                duration=$SECONDS
                logdate && echo "$(($duration / 60)) minuten en $(($duration % 60)) seconden verstreken."
                echo #nieuwe regel
				exit
			fi

			#logdate && echo Controleer of de database geregistreerd is.

			RETURN=`sqlplus -s $CATALOGUSER/$CATALOGPASS@$CATALOGDB <<EOF
SET HEADING OFF
SET NEWPAGE NONE
SET FEEDBACK OFF
SELECT TO_CHAR(COUNT(DBID)) FROM RC_DATABASE WHERE DBID=('${DBID}');
EOF`

			if test ${RETURN} -eq 1
			then
				logdate && echo "Database $DB_NAME is reeds geregistreerd"
			else
				logdate && echo "Database $DB_NAME is nog niet geregistreerd"
				logdate && echo "Registreer database"
				logdate && echo "REGISTER DATABASE;" | rman target / catalog $CATALOGUSER/$CATALOGPASS@$CATALOGDB
				logdate && echo "Registratie gereed"
			fi

			logdate && echo "Resync met catalog"

			logdate && echo -n "RMAN output: " &&
rman TARGET / CATALOG $CATALOGUSER/$CATALOGPASS@$CATALOGDB log=$LOGFILE<<EOF
resync catalog;
exit
EOF
			echo #nieuwe regel
			logdate && echo "Einde Resync met Catalog voor database $DB_NAME via instance $INST_NAME"
			logdate && echo `grep -c -i ora- $LOGFILE` " ORA meldingingen uit $LOGFILE"
			echo #nieuwe regel
			duration=$SECONDS
			logdate && echo "$(($duration / 60)) minuten en $(($duration % 60)) seconden verstreken."
			echo #nieuwe regel
		fi
	fi
fi
