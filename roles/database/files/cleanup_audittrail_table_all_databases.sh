#!/bin/bash

##################################################################
# programma          : cleanup_audittrail_table_all_databases.sh #
# auteur             : Geert van der Ploeg                       #
# versie             : 01.00-00                                  #
##################################################################
# Datum       : Geschiedenis                                     #
# ==========    ==============================================   #
# 04-05-2018  : Initiele versie 01.00-00                         #
##################################################################

function logdate {
  echo -n `date +%F" "%a" "%T"."%3N`' - '
}

if [ -z "$ORACLE_HOME" ]; then source ~/.bash_profile; fi

ps -ef | awk -F"ora_smon_" '/ora_smon_/ && !/awk/ {print $2}' | while read DBSID
do
        logdate && echo "################# Audit trail tabel (SYS.AUD$) opschonen voor instance $DBSID #################"
        export ORACLE_SID=$DBSID
        export ORAENV_ASK=NO
        logdate && echo -n "Oraenv output: " && . oraenv
        logdate && echo Audit trail tabel opschonen
        RETURN=`sqlplus -s / as sysdba <<EOF
set HEADING OFF
set NEWPAGE NONE

DELETE FROM SYS.AUD$
      WHERE NTIMESTAMP# <
                SYSDATE - INTERVAL '2' YEAR;
COMMIT;

EOF`
        logdate && echo Feedback SQL: $RETURN
done
exit
