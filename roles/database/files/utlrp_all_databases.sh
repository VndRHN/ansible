#!/bin/bash

####################################################
# programma          : utlrp_all_databases         #
# auteur             : Geert van der Ploeg         #
# versie             : 01.00-00                    #
####################################################
# Datum       : Geschiedenis                       #
# ==========    ================================== #
# 09-08-2012  : Initiele versie 01.00-00           #
#################################################### 

function logdate {
  echo -n `date +%F" "%a" "%T"."%3N`' - '
}

ps -ef | awk -F"ora_smon_" '/ora_smon_/ && !/awk/ {print $2}' | while read DBSID
do
        logdate && echo "################# utlrp uitvoeren voor instance $DBSID #################"
        export ORACLE_SID=$DBSID
        export ORAENV_ASK=NO
        logdate && echo -n "Oraenv output: " && . oraenv
        RETURN=`sqlplus -s / as sysdba <<EOF
set HEADING OFF
set NEWPAGE NONE

@?/rdbms/admin/utlrp.sql

EOF`
        logdate && echo Feedback SQL: $RETURN
done
exit
