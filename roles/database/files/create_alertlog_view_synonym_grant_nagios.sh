#!/bin/bash

#####################################################################
# programma          : create_alertlog_view_synonym_grant_nagios.sh #
# auteur             : Geert van der Ploeg                          #
# versie             : 02.00-00                                     #
#####################################################################
# Datum       : Geschiedenis                                        #
# ==========    ====================================================#
# 13-03-2015  : Initiele versie 01.00-00                            #
##################################################################### 

function logdate {
  echo -n `date +%F" "%a" "%T"."%N | awk -F "." '{ print $1"." substr($2,1,3)}'`' - '
}

ps -ef | awk -F"ora_smon_" '/ora_smon_/ && !/awk/ {print $2}' | while read DBSID
do
        logdate && echo "################# Maak view alertlog aan voor instance $DBSID #################"
        export ORACLE_SID=$DBSID
        export ORAENV_ASK=NO
        logdate && echo -n "Oraenv output: " && . oraenv
        logdate && echo create_alertlog_view_synonym_grant_nagios
        RETURN=`sqlplus -s / as sysdba <<EOF
set HEADING OFF
set NEWPAGE NONE

create or replace view v_\\$alert_log as select * from x\\$dbgalertext;
create or replace public synonym v\\$alert_log for sys.v_\\$alert_log;
grant select on v\\$alert_log to NAGIOS;


EOF`
        logdate && echo Feedback SQL: $RETURN
done
exit
