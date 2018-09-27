#!/bin/bash

########################################################
# programma          : pwmo2twmo                       #
# auteur             : Geert van der Ploeg             #
# versie             : 02.00-00                        #
########################################################
# Datum       : Geschiedenis                           #
# ==========    ====================================== #
# 25-11-2008  : Initiele versie 01.00-00               #
# 01-06-2011  : Aangepast voor WmoNed schema           #
# 03-06-2013  : Aanpassing pwmo database               #
# 14-11-2013  : Aanpassing gebruik datapump            #
# 20-04-2015  : Aangepast voor vnd-db07                #
# 13-05-2016  : Wachtwoord user test uit bestand lezen #
######################################################## 

function logdate {
  echo -n `date +%F" "%a" "%T"."%3N`' - '
}

if [ -z "$ORACLE_HOME" ]; then source ~/.bash_profile; fi

EXPORTDIR_PWMO=/mnt/nfs_autofs/backup/vnd-db08/export

DATA_PUMP_DIR=/backup/export

EXPORTFILE=pwmo_dp.dmp
EXPORTLOG=pwmo_dp.log

IMPORTLOG=twmo_imp_dp.log

WACHTWOORD_USER_WMONED=`cat /beheer/passwords/twmo_wmoned.pw`

logdate && echo "#### PWMO2TWO ####"

if [ -f "$EXPORTDIR_PWMO/$EXPORTFILE" ]
then
	logdate && echo "Verplaats export pwmo naar deze server"
	logdate && mv -v $EXPORTDIR_PWMO/$EXPORTFILE $DATA_PUMP_DIR
	logdate && mv -v $EXPORTDIR_PWMO/$EXPORTLOG $DATA_PUMP_DIR
else
	logdate && echo "Geen export aanwezig van productie database"
        logdate && echo "Script stopt nu"
        exit
fi

EXPDATE=`date -r $DATA_PUMP_DIR/$EXPORTLOG '+%F %k:%M'`
TODAY=`date +%F`
YESTERDAY_8_PM_IN_SECONDS=`date +%s --date="$TODAY -1 days + 20 hours"`
EXPORTFILE_TIMESTAMP_IN_SECONDS=`date +%s -r $DATA_PUMP_DIR/$EXPORTLOG`

logdate && echo "Datum export van pwmo: $EXPDATE"
#echo "YESTERDAY_8_PM_IN_SECONDS:" $YESTERDAY_8_PM_IN_SECONDS
#echo "MYFILE_TIMESTAMP_IN_SECONDS:" $EXPORTFILE_TIMESTAMP_IN_SECONDS

VAR=`echo "$EXPORTFILE_TIMESTAMP_IN_SECONDS > $YESTERDAY_8_PM_IN_SECONDS" | bc`
#echo "VAR:" $VAR
if test ${VAR} -eq 1
then
        logdate && echo "Export is jonger dan gisteravond 20 uur"
else
        logdate && echo "Export is OUDER dan gisteravond 20 uur"
        logdate && echo "Geen import uitvoeren"
        logdate && echo "Script stopt nu"
        exit
fi

VAL=`grep -c 'is voltooid bij' $DATA_PUMP_DIR/$EXPORTLOG`
if test ${VAL} -eq 1
then
        logdate && echo -n "Status export van pwmo: " && grep 'is voltooid bij' $DATA_PUMP_DIR/$EXPORTLOG

else
        logdate && echo "Status export van pwmo: is voltooid met fout(en)"
        logdate && echo "Geen import uitvoeren"
        logdate && echo "Script stopt nu"
        exit
fi

export ORACLE_SID=`ps -ef | awk -F"ora_smon_" '/ora_smon_twmo/ && !/awk/ {print $2}'`
if [ -z $ORACLE_SID ]; then
        logdate && echo "TWMO database is NIET beschikbaar"
        logdate && echo "Script stopt nu"
        exit
fi
# export ORACLE_SID=twmo1
export ORAENV_ASK=NO
logdate && echo -n "Oraenv output: " && . oraenv

logdate && echo Controleer hoeveel sessies via user WMONED geconnect zijn
RETURN=`sqlplus -s '/ as sysdba' <<EOF
SET HEADING OFF
SET NEWPAGE NONE
SET FEEDBACK OFF
select count(*) from gv\\$session where username='WMONED';
EOF`

logdate && echo Feedback SQL: $RETURN

if test ${RETURN} == 0
then
	logdate && echo "User WMONED is niet geconnect"
else
	logdate && echo "User WMONED is geconnect en kan niet gedropt worden"
	logdate && echo "Script stopt nu"
	exit
fi

logdate && echo Drop user WMONED
RETURN=`sqlplus -s '/ as sysdba' <<EOF
SET HEADING OFF
SET NEWPAGE NONE

DROP USER WMONED CASCADE;

EOF`

logdate && echo Feedback SQL: $RETURN


logdate && echo Start Import met log: $DATA_PUMP_DIR/$IMPORTLOG
impdp \"/ as sysdba\" directory=DATA_PUMP_DIR schemas=wmoned dumpfile=pwmo_dp.dmp logfile=twmo_imp_dp.log > /dev/null 2>&1

logdate && echo "Import gereed"

VAL=`grep 'Taak' $DATA_PUMP_DIR/$IMPORTLOG`
logdate && echo Status $DATA_PUMP_DIR/$IMPORTLOG: $VAL

logdate && echo Unlock user WMONED en set password
RETURN=`sqlplus -s '/ as sysdba' <<EOF
SET HEADING OFF
SET NEWPAGE NONE

alter user wmoned account unlock;
alter user wmoned identified by $WACHTWOORD_USER_WMONED;

EOF`

logdate && echo Feedback SQL: $RETURN

RETURN=`sqlplus -s '/ as sysdba' <<EOF
SET HEADING OFF
SET NEWPAGE NONE

select count(*) from dba_objects where status = 'INVALID';

EOF`

logdate && echo Aantal invalid objects in database: $RETURN

logdate && echo Statistieken verzamelen voor schema WMONED
RETURN=`sqlplus -s '/ as sysdba' <<EOF
SET HEADING OFF
SET NEWPAGE NONE

EXECUTE DBMS_STATS.GATHER_SCHEMA_STATS('WMONED',DBMS_STATS.AUTO_SAMPLE_SIZE);

EOF`

logdate && echo Feedback SQL: $RETURN

logdate && echo Einde script
