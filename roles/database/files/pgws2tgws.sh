#!/bin/bash

########################################################
# programma          : pgws2tgws                       #
# auteur             : Geert van der Ploeg             #
########################################################
# Datum       : Geschiedenis                           #
# ==========    ====================================== #
# 25-11-2008  : Initiele versie 01.00-00               #
# 26-08-2013  : Aangepast voor lx61 en lx62            #
# 11-03-2014  : Aangepast voor vnd-db03                #
# 13-05-2016  : Wachtwoord user test uit bestand lezen #
######################################################## 

function logdate {
  echo -n `date +%F" "%a" "%T"."%3N`' - '
}

if [ -z "$ORACLE_HOME" ]; then source ~/.bash_profile; fi

EXPORTDIR_PGWS=/mnt/nfs_autofs/backup/vnd-db04/export

DATA_PUMP_DIR=/backup/export

EXPORTFILE=pgws_dp.dmp
EXPORTLOG=pgws_dp.log

IMPORTLOG=tgws_imp_dp.log

WACHTWOORD_USER_TEST=`cat /beheer/passwords/tgws_test.pw`
WACHTWOORD_USER_PKOCASUS=`cat /beheer/passwords/tgws_pkocasus.pw`
WACHTWOORD_USER_PKOEB=`cat /beheer/passwords/tgws_pkoeb.pw`

logdate && echo "#### PGWS2TGWS ####"

export ORACLE_SID=`ps -ef | awk -F"ora_smon_" '/ora_smon_tgws/ && !/awk/ {print $2}'`
if [ -z $ORACLE_SID ]; then
        logdate && echo "TGWS database is NIET beschikbaar"
        logdate && echo "Script stopt nu"
        exit
fi

export ORAENV_ASK=NO
logdate && echo -n "Oraenv output: " && . oraenv

logdate && echo Controleer hoeveel sessies via user TEST geconnect zijn
RETURN=`sqlplus -s '/ as sysdba' <<EOF
SET HEADING OFF
SET NEWPAGE NONE
SET FEEDBACK OFF
select count(*) from gv\\$session where username='TEST';
EOF`

logdate && echo Feedback SQL: $RETURN

if test ${RETURN} == 0
then
        logdate && echo "User TEST is niet geconnect"
else
        logdate && echo "User TEST is geconnect en kan niet gedropt worden"
        logdate && echo "Script stopt nu"
        exit
fi

if [ -f "$EXPORTDIR_PGWS/$EXPORTFILE" ]
then
	logdate && echo "Verplaats export pgws naar deze server"
	logdate && mv -v $EXPORTDIR_PGWS/$EXPORTFILE $DATA_PUMP_DIR
	logdate && mv -v $EXPORTDIR_PGWS/$EXPORTLOG $DATA_PUMP_DIR
else
        logdate && echo "Geen export aanwezig van productie database"
        logdate && echo "Script stopt nu"
        exit
fi

EXPDATE=`date -r $DATA_PUMP_DIR/$EXPORTLOG '+%F %k:%M'`
TODAY=`date +%F`
YESTERDAY_8_PM_IN_SECONDS=`date +%s --date="$TODAY -1 days + 20 hours"`
EXPORTFILE_TIMESTAMP_IN_SECONDS=`date +%s -r $DATA_PUMP_DIR/$EXPORTLOG`

logdate && echo "Datum export van pgws: $EXPDATE"
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
	logdate && echo -n "Status export van pgws: " && grep 'is voltooid bij' $DATA_PUMP_DIR/$EXPORTLOG
 
else
	logdate && echo "Status export van pgws: is voltooid met fout(en)"
	logdate && echo "Geen import uitvoeren"
	logdate && echo "Script stopt nu"
	exit
fi

logdate && echo Drop users TEST, PKOCASUS, PKOEB
RETURN=`sqlplus -s '/ as sysdba' <<EOF
SET HEADING OFF
SET NEWPAGE NONE

DROP USER TEST CASCADE;
DROP USER PKOCASUS CASCADE;
DROP USER PKOEB CASCADE;

EOF`

logdate && echo Feedback SQL: $RETURN

logdate && echo Start Import met log: $DATA_PUMP_DIR/$IMPORTLOG
impdp \"/ as sysdba\" directory=DATA_PUMP_DIR schemas=PROD,PKOCASUS,PKOEB dumpfile=$EXPORTFILE logfile=$IMPORTLOG remap_schema=PROD:TEST exclude=package:"in\('GWS_DDS_BERICHT'\,'GWS_DDS_TERUGM'\,'GWS_VUL_FREEZE'\,'GWS_DDS_NHR'\)" exclude=db_link exclude=index:"in\('SZCLIENTI9'\,'SZCLIENTI10'\)" exclude=view:"in\('DDS_KTMBER_VW'\,'DDS_KTMKEN_VW'\,'DDS_INFORMR_VW'\)"  > /dev/null 2>&1

logdate && echo "Import gereed"

VAL=`grep 'Taak' $DATA_PUMP_DIR/$IMPORTLOG`
logdate && echo Status $DATA_PUMP_DIR/$IMPORTLOG: $VAL

logdate && echo Set password voor users TEST, PKOCASUS, PKOEB
RETURN=`sqlplus -s '/ as sysdba' <<EOF
SET HEADING OFF
SET NEWPAGE NONE

alter user test account unlock;
alter user test identified by $WACHTWOORD_USER_TEST;
alter user pkocasus identified by $WACHTWOORD_USER_PKOCASUS;
alter user pkoeb identified by $WACHTWOORD_USER_PKOEB;

EOF`

logdate && echo Feedback SQL: $RETURN

logdate && echo Connectstrings en logische URLs aanpassen in database schema PKOCASUS
RETURN=`sqlplus -s '/ as sysdba' <<EOF
SET HEADING OFF
SET NEWPAGE NONE

UPDATE PKOCASUS.PKO_DBCONNECTIE
   SET CONNECTSTRING =
          'xE95gwLhqfQJTCPIzLxQuC8/V1uNSOTHWQ06w/fy+9Ww46TeL0c+Ljeu9wVjjb2qVYDB2ZH22vNaW+boh1fTMGKk47bEiBL3ilm/FQCsDWHcogcFOgNBk0mChtZxljyquifkXG67hrky0nNeJ9GPEU+gkzESqvEx0Q2La4g7DULV7lhZ0WrWeN0arNnljpD2Vh+4kL8955xzK9TfFRzN2pGhgFn4oqvQtPd2Ej2Zw5orHWqtw77zdEJJuKixDhykAtpb1cU+pBTAzbLzOk2oAw=='
 WHERE CONN_ID = 'GWSDB';
 
UPDATE PKOCASUS.PKO_DBCONNECTIE
   SET CONNECTSTRING =
          'xE95gwLhqfQJTCPIzLxQuAg9uYc7O+W6g0Np2x0/UnMR9wolJ/yEQ31V5uCxBuP7bRZhVCYouOHSTuYChcHHlIWtCGVSeHq7XY7Wh73S38Ewv3UHhoBx5kguEPr9bNXSeWubo+RT3CgWmqANt/K6RKZVvCCiuUIEqLUNkO1OXC0hogm8WV4aUGN4FbJXPI5V/lfzWxe0wjoWTzWeEPY5BCF1mxXrBLlImOh6VxboEPDz2iv9hOfIiaCt7CE2GD8C'
 WHERE CONN_ID = 'KLUWER';

UPDATE PKOCASUS.PKO_DBCONNECTIE
   SET CONNECTSTRING =
          'xE95gwLhqfQJTCPIzLxQuC8/V1uNSOTHWQ06w/fy+9Ww46TeL0c+Ljeu9wVjjb2qVYDB2ZH22vNaW+boh1fTMNUw1yrdGtO6wXpuhCTpzwmeS2msevAXNcZv34BAbbEZC23sTEYvpo7cb2WNDFuGct8tjsGoxguzoWrtQeyoZuXq0Bn81fAITovjzk+JM2o2yEqjwRgB6a5TQeMT/oYNk6WubpIGvhjg3JlGa5TCnDEOOIF52U1MCoUVrUO5oxj+NWkjfLVFVLqaoJaGRRXOene6MJ/7sWwgC9/FQ8LUxYI='
 WHERE CONN_ID = 'PKOEB';

UPDATE PKOCASUS.PKO_LOG_URL
   SET URL = 'http://vnd-gws:8080/wmoatall/test/veenendaal/GWS_KPL_S'
 WHERE LOG_URL_ID = 'GWS_KPL_S';

UPDATE PKOCASUS.PKO_LOG_URL
   SET URL = 'http://vnd-gws:85/public/'
 WHERE LOG_URL_ID = 'WIZ_URL';

COMMIT;

EOF`

logdate && echo Feedback SQL: $RETURN

logdate && echo Parameters aanpassen in database schema TEST
RETURN=`sqlplus -s '/ as sysdba' <<EOF
SET HEADING OFF
SET NEWPAGE NONE

UPDATE TEST.szwp
   SET wp_programma = REPLACE (UPPER (wp_programma), '\PROD\', '\TEST\')
 WHERE UPPER (wp_programma) <> REPLACE (UPPER (wp_programma), '\PROD\', '\TEST\');

UPDATE TEST.szwp
   SET wp_data = REPLACE (UPPER (wp_data), '\PROD\', '\TEST\')
 WHERE UPPER (wp_data) <> REPLACE (UPPER (wp_data), '\PROD\', '\TEST\');

UPDATE TEST.szwp
   SET wp_data = REPLACE (wp_data, ':84', ':85')
 WHERE module = 'KEYS' AND wp_data <> REPLACE (wp_data, ':84', ':85');

UPDATE TEST.szsysdata
   SET dot_db_connect = 'tgws',
       dot_db_user = 'test',
       dot_db_password =
           'F547607BEA0803447529FD79881259A386ADB1EA1BF3C764F37FA1F8D28954162358F435D7737513221B7F2481D63F2BE54D59F11BC39C5C01F8BCB545411B2AC2BAB8A7A8717470D2A2B76F15C6295D'
 WHERE dot_db_connect IS NOT NULL;

UPDATE TEST.szsyspko
   SET pko_exec = 'http://vnd-gws:95/main.aspx', pko_config = 'instellingen'
 WHERE pko_exec IS NOT NULL;

UPDATE TEST.dc_functie
   SET koppelingsdata = REPLACE (LOWER(koppelingsdata), 'pmdu', 'tmdu')
 WHERE LOWER(koppelingsdata) <> REPLACE (LOWER(koppelingsdata), 'pmdu', 'tmdu');


UPDATE TEST.ITRTPROJ 
   set U_VERSION='(', OMSCHRYVING='Testsleutel', SLEUTEL='14523816385818493bd24a40.09250820', STS_REC=1, DD_STS_REC=to_date('24-01-17','DD-MM-RR');


COMMIT;

EOF`

logdate && echo Feedback SQL: $RETURN


logdate && echo ALTER VIEW TEST.INDANTWOORD_VW COMPILE
RETURN=`sqlplus -s test/$WACHTWOORD_USER_TEST@tgws <<EOF
SET HEADING OFF
SET NEWPAGE NONE

ALTER VIEW TEST.INDANTWOORD_VW COMPILE;

EOF`

logdate && echo Feedback SQL: $RETURN

logdate && echo COMPILE_SCHEMA PUBLIC
RETURN=`sqlplus -s test/$WACHTWOORD_USER_TEST@tgws <<EOF
SET HEADING OFF
SET NEWPAGE NONE

begin dbms_utility.compile_schema( 'PUBLIC', FALSE ); end;
/

EOF`

logdate && echo Feedback SQL: $RETURN

RETURN=`sqlplus -s '/ as sysdba' <<EOF
SET HEADING OFF
SET NEWPAGE NONE

select count(*) from dba_objects where status = 'INVALID';

EOF`

logdate && echo Aantal invalid objects in database: $RETURN

logdate && echo Statistieken verzamelen voor schema TEST
RETURN=`sqlplus -s '/ as sysdba' <<EOF
SET HEADING OFF
SET NEWPAGE NONE

EXECUTE DBMS_STATS.GATHER_SCHEMA_STATS('TEST',DBMS_STATS.AUTO_SAMPLE_SIZE);

EOF`

logdate && echo Feedback SQL: $RETURN

logdate && echo Einde script
