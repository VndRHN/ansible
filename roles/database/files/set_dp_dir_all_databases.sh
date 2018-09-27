#!/bin/bash

####################################################
# programma          : set_dp_dir__all_databases.sh#
# auteur             : Hans vd Broek 		   #
# versie             : 01.00.00                    #
####################################################
# Datum       : Geschiedenis                       #
# ==========    ================================== #
# 07-08-2018  : Initiele versie 01.00-00           #
#################################################### 

function logdate {
  echo -n `date +%F" "%a" "%T"."%3N`' - '
}

EXPORT_DIR=/backup/export

if [ -z "$ORACLE_HOME" ]; then source ~/.bash_profile; fi


ps -ef | awk -F"ora_smon_" '/ora_smon_/ && !/awk/ {print $2}' | while read DBSID
do
        logdate && echo "################# set data_pump_dir $DBSID #################"
        export ORACLE_SID=$DBSID
        export ORAENV_ASK=NO
        logdate && echo -n "Oraenv output: " && . oraenv
        logdate && echo Wijzig DATA_PUMP directory
        RETURN=`sqlplus -s / as sysdba <<EOF
set HEADING OFF
set NEWPAGE NONE
CREATE OR REPLACE DIRECTORY DATA_PUMP_DIR AS '${EXPORT_DIR}';
EOF`
        logdate && echo Feedback SQL: $RETURN
done
exit
