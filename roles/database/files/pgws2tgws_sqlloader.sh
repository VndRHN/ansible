#!/bin/bash
if [ -z "$ORACLE_HOME" ]; then source ~/.bash_profile; fi

WACHTWOORD_USER_TEST=`cat /beheer/passwords/tgws_test.pw`

export ORACLE_SID=`ps -ef | awk -F"ora_smon_" '/ora_smon_tgws/ && !/awk/ {print $2}'` && [ -z $ORACLE_SID ] && exit
export ORAENV_ASK=NO
echo -n "Oraenv output: " && . oraenv

RETURN=`sqlplus -s test/$WACHTWOORD_USER_TEST@tgws <<EOF
SET HEADING OFF
SET NEWPAGE NONE

CREATE TABLE LOG_PGWS2TGWS (TEXT  VARCHAR2(255 CHAR));
GRANT SELECT,INSERT ON TEST.LOG_PGWS2TGWS TO VDL_APPLICATIEBEHEER;

EOF`

echo Feedback SQL: $RETURN

sqlldr test/$WACHTWOORD_USER_TEST@tgws control=/beheer/scripts/pgws2tgws_sqlloader.ctl log=/beheer/log/pgws2tgws_sqlloader.log
