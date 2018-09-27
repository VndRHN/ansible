#!/bin/bash
if [ -z "$ORACLE_HOME" ]; then source ~/.bash_profile; fi

WACHTWOORD_USER_PRODDDS=`cat /beheer/passwords/pdds0340_proddds.pw`

sqlplus -s proddds/$WACHTWOORD_USER_PRODDDS@pdds0340 @/beheer/scripts/dds_prs_mozard_rhenen.sql > /dev/null 2>&1
