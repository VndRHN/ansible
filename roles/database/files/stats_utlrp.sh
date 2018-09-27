#!/bin/bash

####################################################
# programma          : stats_utlrp.sh              #
# auteur             : Geert van der Ploeg         #
# versie             : 01.10-00                    #
####################################################
# Datum       : Geschiedenis                       #
# ==========    ================================== #
# 13-02-2015  : Initiele versie 01.00-00           #
# 01-03-2016  : database onafhankelijk gemaakt     #
#################################################### 

function logdate {
  echo -n `date +%F" "%a" "%T"."%3N`' - '
}

if [ -z "$ORACLE_HOME" ]; then source ~/.bash_profile; fi

if [ ! $1 ]
then
        echo "Usage: `basename $0` ORACLE_SID"
        exit 99
fi

ps -ef | awk -F"ora_smon_" '/ora_smon_'$1'$/ && !/awk/ {print $2}' | while read DBSID
do
        logdate && echo "##################### stats_utlrp ######################"

        SECONDS=0
        export ORACLE_SID=$DBSID
        export ORAENV_ASK=NO
        logdate && echo -n "Oraenv output: " && . oraenv

        logdate && echo -n "ORACLE_SID: " && printenv ORACLE_SID

        logdate && echo UTLRP draaien
RETURN=`sqlplus -s  "/ as sysdba" <<EOF
set HEADING OFF
set NEWPAGE NONE
@?/rdbms/admin/utlrp
EOF`
        logdate && echo Feedback SQL: $RETURN


        logdate && echo Database statistieken draaien
RETURN=`sqlplus -s  "/ as sysdba" <<EOF
set HEADING OFF
set NEWPAGE NONE
EXECUTE DBMS_STATS.GATHER_DATABASE_STATS(DBMS_STATS.AUTO_SAMPLE_SIZE);
EOF`
        logdate && echo Feedback SQL: $RETURN
        duration=$SECONDS
        logdate && echo "$(($duration / 60)) minuten en $(($duration % 60)) seconden verstreken."
        logdate && echo "########################################################"

done
exit
