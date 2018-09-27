#!/bin/bash
if [ -z "$ORACLE_HOME" ]; then source ~/.bash_profile; fi

export ORACLE_SID=+ASM
export ORAENV_ASK=NO
. oraenv > /dev/null 2>&1

sqlplus -s / as sysasm <<EOF
set lines 1000
select * from v\$resource_limit where RESOURCE_NAME = 'processes';
exit
EOF

unset ORAENV_ASK
