#!/bin/bash

###################################################################
# programma          : backup_all_databases.sh                    #
# auteur             : Geert van der Ploeg                        #
# versie             : 02.00-00                                   #
###################################################################
# Datum       : Geschiedenis                                      #
# ==========    ================================================= #
# 09-08-2012  : Initiele versie 01.00-00                          #
# 06-12-2012  : Aangepast voor RAC 11.2                           #
# 06-12-2012  : Log toegevoegd                                    #
# 03-06-2013  : Gebruikt smon proces ipv oratab                   #
# 15-10-2013  : NB DBA.nl aangepast voor gebruik                  #
#               op single instance db server                      #
# 15-01-2016  : Random timeout toegevoegd voordat backup start    #
################################################################### 

if [ -z "$ORACLE_HOME" ]; then source ~/.bash_profile; fi

export SCRIPTDIR=/beheer/scripts
export LOGDIR=/beheer/log
export WACHTTIJD_VOOR_EERSTE_BACKUP=`echo $[ ( $RANDOM % 60 )  + 1 ]`

function logdate {
  echo -n `date +%F" "%a" "%T"."%3N`' - '
}

logdate && echo Wacht $WACHTTIJD_VOOR_EERSTE_BACKUP minuten
sleep "$WACHTTIJD_VOOR_EERSTE_BACKUP"m

ps -ef | awk -F"ora_smon_" '/ora_smon_/ && !/awk/ {print $2}' | sort | while read DBSID
do
        logdate && echo "################# Backup voor instance $DBSID #################"
        export DB_NAME=$DBSID
        export ORACLE_SID=$DBSID
        export ORAENV_ASK=NO
        logdate && echo -n "Oraenv output: " && . oraenv
        logdate && echo Backup database $DB_NAME
        # START het script backup script
        bash $SCRIPTDIR/backup_database.sh > $LOGDIR/backup_database_$DB_NAME.log 2>&1 &
        ## Wacht 600 seconden voordat de volgende backup start
        ##sleep 600
		export WACHTTIJD_TUSSEN_BACKUPS=`echo $[ ( $RANDOM % 20 )  + 1 ]`
		logdate && echo Wacht $WACHTTIJD_TUSSEN_BACKUPS minuten
        sleep "$WACHTTIJD_TUSSEN_BACKUPS"m
done
exit
