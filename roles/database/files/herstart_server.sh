#!/bin/bash

function logdate {
  echo -n `date +%F" "%a" "%T"."%3N`' - '
}


# Script kan alleen gebruiken als user root
# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

HOUR=$(date +"%k")

if [ $HOUR -ge 21 -o $HOUR -lt 7 ] ; then # Dit script functioneert alleen tussen 21 uur en 7 uur
	export WACHTTIJD_VOOR_BLACKOUT_EN_HERSTART=`echo $[ ( $RANDOM % 10 )  + 1 ]`
	logdate && echo Wacht $WACHTTIJD_VOOR_BLACKOUT_EN_HERSTART minuten
	sleep "$WACHTTIJD_VOOR_BLACKOUT_EN_HERSTART"m

	# oem blackout instellen reboot - blackout duurt een half uur
	EMCTL="/u01/app/oracle/product/12.1/agent/agent_inst/bin/emctl"
	if [ -f $EMCTL ]; # controleer of er een oem agent geinstalleerd is
	then
	        logdate && echo "oem blackout instellen voor reboot host `hostname` - blackout duurt een half uur"

		logdate && echo -n "EMCTL output: " &&
		su - oracle -c '/u01/app/oracle/product/12.1/agent/agent_inst/bin/emctl start blackout `hostname` -nodelevel -d 0 00:30'
	fi

	logdate && echo "wacht 5 minuten"
	sleep 5m

	logdate && echo "herstart server"
	/sbin/reboot
else
	logdate && echo Dit script functioneert alleen tussen 21 uur en 7 uur
fi # HOUR


