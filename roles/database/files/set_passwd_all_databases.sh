#!/bin/bash

####################################################
# programma          : set_passwd_all_databases.sh #
# auteur             : Geert van der Ploeg         #
# versie             : 03.00-00                    #
####################################################
# Datum       : Geschiedenis                       #
# ==========    ================================== #
# 09-08-2012  : Initiele versie 01.00-00           #
# 03-06-2013  : Gebruikt smon proces ipv oratab    #
# 26-05-2016  : Wachtwoorden uit file lezen        #
#################################################### 

function logdate {
  echo -n `date +%F" "%a" "%T"."%3N`' - '
}

if [ -z "$ORACLE_HOME" ]; then source ~/.bash_profile; fi

WACHTWOORD_USER_SYS=`cat /beheer/passwords/sys.pw`
WACHTWOORD_USER_SYSTEM=`cat /beheer/passwords/system.pw`

ps -ef | awk -F"ora_smon_" '/ora_smon_/ && !/awk/ {print $2}' | while read DBSID
do
        logdate && echo "################# Wijzig wachtwoorden voor instance $DBSID #################"
        export ORACLE_SID=$DBSID
        export ORAENV_ASK=NO
        logdate && echo -n "Oraenv output: " && . oraenv
        logdate && echo Wijzig wachtwoord voor users sys en system
        RETURN=`sqlplus -s / as sysdba <<EOF
set HEADING OFF
set NEWPAGE NONE

alter user sys identified by $WACHTWOORD_USER_SYS;
alter user system identified by $WACHTWOORD_USER_SYSTEM;

EOF`
        logdate && echo Feedback SQL: $RETURN
done
exit
