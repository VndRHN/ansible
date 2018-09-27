find /backup/ovm_export_db     -name '*.log'        -mtime +60     -exec rm {} \;
find /backup/ovm_export_db     -name '*.tar.gz'     -mtime +60     -exec rm {} \;
