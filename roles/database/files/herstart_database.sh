#!/bin/sh

######################################################################################
# programma          : herstart_database.sh                                          #
# auteur             : Johan Clerx           		                             #
# versie             : 01.00-00                                                      #
######################################################################################
# Datum       : Geschiedenis                                                         #
# ==========    ==================================================================== #
# 09-05-2018  : Initiele versie 01.00-00                                             #
######################################################################################

if [ $# -eq 0 ]
then
        echo "Er is geen database opgegeven om te herstarten!"
        exit 0
else
	export ORACLE_SID=$1
	printenv ORACLE_SID
	sqlplus -s / as sysdba <<EOF
	shutdown immediate
	startup
	alter database open;
EOF
fi
