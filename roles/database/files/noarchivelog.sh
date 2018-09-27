printenv ORACLE_SID
sqlplus -s / as sysdba <<EOF
archive log list;
shutdown immediate
startup mount
alter database noarchivelog;
alter database open;
archive log list;
EOF
