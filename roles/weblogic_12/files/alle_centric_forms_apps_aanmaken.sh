#!/bin/bash

# 2016-06-02 - Geert van der Ploeg

function logdate {
  echo -n `date +%F" "%a" "%T"."%3N`' - '
}

# controleer of package expect geïnstalleerd is
EXPECT_INSTALLED=`whereis expect | grep -c bin/expect`
if [ "$EXPECT_INSTALLED" = "0" ]
then
    logdate && echo "Package Expect is niet geïnstalleerd."
    exit
fi

# controleer of tnsnames.ora gevuld is
TNSNAMES=/u01/app/oracle/middleware/instances/formsreports/config/tnsnames.ora
TNSNAMES_ENTRIES=`grep -c -v ^# $TNSNAMES`
if [ "$TNSNAMES_ENTRIES" = "0" ]
then
    logdate && echo "tnsnames.ora heeft geen entries, kopieer tnsnames.ora van een andere weblogic server naar $TNSNAMES"
    exit
fi


# opschonen /u01/app/centric
cd /u01/app/centric
rm -r */*/config/*
rm -r */*/diag/*
rm -r */*/temp/*
rm -r */*/webutil/*
rm -r */*/mvwr/*wls*
rm */*/setup/wldt/wldt_*.env
rm -r */*/setup/wldt/logs/*
rm -r */*/setup/wldt/temp/*


find /u01/app/centric/ -type d -name wldt | sort | while read FORMS_WLDT
do
     logdate && echo $FORMS_WLDT
     cd $FORMS_WLDT
     /home/ora11gas/bin/create_centric_application.sh 
done
exit
