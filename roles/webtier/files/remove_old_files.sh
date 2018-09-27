# Op lx75 moet dit script door root worden uitgevoerd. Root is owner van de access_logs
find /u01/app/oracle/Middleware/Oracle_WT1/instances/    -type f   -name 'access_log.*' -mtime +70        -exec rm {} \;
