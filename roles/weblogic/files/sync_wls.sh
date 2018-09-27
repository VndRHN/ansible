#!/bin/bash

#Status OPMN
$ORACLE_HOME/opmn/bin/opmnctl status

#Stop OPMN
$ORACLE_HOME/opmn/bin/opmnctl stopall

#MIRROR:
#Starten op vnd-wls02:
rsync -e ssh -avz --delete --exclude=*-wls* ora11gas@vnd-wls01:/u01/app/centric/* /u01/app/centric/


#Start OPMN
$ORACLE_HOME/opmn/bin/opmnctl startall

#Status OPMN
$ORACLE_HOME/opmn/bin/opmnctl status

