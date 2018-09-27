find /u01/app/oracle/middleware/instances/formsreports/diagnostics/logs/OHS/ohs1                  -type f     -name 'access_log.*'           -mtime +7         -exec rm {} \;
find /u01/app/oracle/middleware/user_projects/domains/frdomain/servers/WLS_FORMS/logs             -type f     -name 'access.log*'            -mtime +7         -exec rm {} \;
find /u01/app/oracle/middleware/instances/formsreports/EMAGENT/emagent_formsreports/sysman/log    -type f     -name 'emagent.trc.*'          -mtime +7         -exec rm {} \;
