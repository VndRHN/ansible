#!/bin/bash

#####################################################################
# programma          : invalid_objects.sh                           #
# auteur             : Geert van der Ploeg                          #
# versie             : 01.00-00                                     #
#####################################################################
# Datum       : Geschiedenis                                        #
# ==========    ====================================================#
# 05-01-2017  : Initiele versie 01.00-00                            #
##################################################################### 

if [[ ${#ORACLE_SID} = 0 ]]; then
    echo "ORACLE_SID is niet gedefinieerd"
    exit
fi

echo 
echo invalid objects in database: $ORACLE_SID

sqlplus -s / as sysdba <<EOF
col c1 heading 'owner' format a15
col c2 heading 'name' format a40
col c3 heading 'type' format a12

select
   owner       c1,
   object_type c3,
   object_name c2
from
   dba_objects
where
   status != 'VALID'
order by
   owner,
   object_type;

EOF
