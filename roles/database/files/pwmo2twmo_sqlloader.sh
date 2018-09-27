#!/bin/bash
if [ -z "$ORACLE_HOME" ]; then source ~/.bash_profile; fi

WACHTWOORD_USER_WMONED=`cat /beheer/passwords/twmo_wmoned.pw`

export ORACLE_SID=`ps -ef | awk -F"ora_smon_" '/ora_smon_twmo/ && !/awk/ {print $2}'` && [ -z $ORACLE_SID ] && exit
export ORAENV_ASK=NO
echo -n "Oraenv output: " && . oraenv

RETURN=`sqlplus -s wmoned/$WACHTWOORD_USER_WMONED <<EOF
SET HEADING OFF
SET NEWPAGE NONE

DROP TABLE LOG_PWMO2TWMO;
CREATE TABLE LOG_PWMO2TWMO (TEXT  VARCHAR2(255 CHAR));

EOF`

echo Feedback SQL: $RETURN

sqlldr wmoned/$WACHTWOORD_USER_WMONED control=/beheer/scripts/pwmo2twmo_sqlloader.ctl log=/beheer/log/pwmo2twmo_sqlloader.log
