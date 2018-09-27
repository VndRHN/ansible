#!/bin/bash

####################################################
# programma          : reset_management_packs.sh   #
# auteur             : Mike Andreoli               #
# versie             : 00.00-00                    #
####################################################
# Datum       : Geschiedenis                       #
# ==========    ================================== #
# 19-03-2014  : Initiele versie: copie van         #
#                      set_passwd_all_databases    #
# 13-06-2016  : GP - gebruik van argument
####################################################

function logdate {
  echo -n `date +%F" "%a" "%T"."%N | awk -F "." '{ print $1"." substr($2,1,3)}'`' - '
}

if [ -z "$ORACLE_HOME" ]; then source ~/.bash_profile; fi

if [ ! $1 ]
then
        echo "Usage: `basename $0` DIAGNOSTIC+TUNING"
        echo "       `basename $0` NONE"
        exit 99
fi

PACKS=$1

ps -ef | awk -F"ora_smon_" '/ora_smon_/ && !/awk/ {print $2}' | while read DBSID
do
        logdate && echo "################# Reset management pack gebruik voor instance $DBSID #################"
        export ORACLE_SID=$DBSID
        export ORAENV_ASK=NO
        logdate && echo -n "Oraenv output: " && . oraenv
        logdate && echo Management pack usage $PACKS
        RETURN=`sqlplus -s / as sysdba <<EOF
set HEADING OFF
set NEWPAGE NONE

alter system set control_management_pack_access='$PACKS' scope=both;

EOF`
        logdate && echo Feedback SQL: $RETURN
done
exit

