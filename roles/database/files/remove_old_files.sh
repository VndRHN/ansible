find /beheer/log                                      -type f  -name '*.log'                             -mtime +20  -exec rm --verbose {} \;
find /backup/rman/logs                                -type f  -name '*.log'                             -mtime +10  -exec rm --verbose {} \;

find /u01/app/oracle/admin                            -type f  -name '*.trc'                             -mtime +70  -exec rm --verbose {} \;
find /u01/app/oracle/admin                            -type f  -name '*.aud'                             -mtime +20  -exec rm --verbose {} \;
find /u01/app/oracle/diag/*/*/*/trace                 -type f  -name '*.tr*'                             -mtime +30  -exec rm --verbose {} \;

find /u01/app/oracle/diag/rdbms/*/*/alert             -type f  -name 'log_*.xml'                         -mtime +20  -exec rm --verbose {} \;
find /u01/app/oracle/diag/rdbms/*/*/incident/incdir_* -type f  -name '*.tr*'                             -mtime +70  -exec rm --verbose {} \;
find /u01/app/oracle/diag/tnslsnr/*/*/alert           -type f  -name 'log_*.xml'                         -mtime +20  -exec rm --verbose {} \;
find /u01/app/oracle/product/11.2.0/*/ctx/log         -type f  -name 'mozard_minutenrun_indexing_log_*'  -mtime +7  -exec rm --verbose {} \;

find /u01/app/grid/11.2.0/gridinfra_1/rdbms/audit     -type f   -name '*.aud'                            -mtime +20  -exec rm --verbose {} \;
