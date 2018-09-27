#!/bin/bash
if [ -z "$ORACLE_HOME" ]; then source ~/.bash_profile; fi

export ORACLE_SID=+ASM
export ORAENV_ASK=NO
. oraenv > /dev/null 2>&1

/u01/app/grid/11.2.0/gridinfra_1/bin/asmcmd lsdg

unset ORAENV_ASK
