#!/bin/bash

function logdate {
  echo -n `date +%F" "%a" "%T"."%3N`' - '
}

SOURCE_DIR[0]=/u01/app/centric/
BACKUP_DIR[0]=/backup/forms
BACKUP_FILE_TAR[0]=forms_`hostname -s`_week`date +%V`.tar.gz
BACKUP_FILE_LOG[0]=forms_`hostname -s`_week`date +%V`.log

SOURCE_DIR[1]=/u01/app/oracle/middleware/instances/formsreports/config/
BACKUP_DIR[1]=/backup/tnsnames
BACKUP_FILE_TAR[1]=tnsnames_`hostname -s`_week`date +%V`.tar.gz
BACKUP_FILE_LOG[1]=tnsnames_`hostname -s`_week`date +%V`.log

for index in ${!SOURCE_DIR[*]}
do
	SOURCE_DIR[$index]=`echo ${SOURCE_DIR[$index]} | sed 's#/$##'` # remove trailing slash from path
	BACKUP_DIR[$index]=`echo ${BACKUP_DIR[$index]} | sed 's#/$##'` # remove trailing slash from path

	logdate && echo backup ${SOURCE_DIR[$index]} naar tarball met logging: ${BACKUP_DIR[$index]}/${BACKUP_FILE_LOG[$index]}
	tar -zcvf ${BACKUP_DIR[$index]}/${BACKUP_FILE_TAR[$index]} --exclude=lost+found --exclude=dms_metrics_*.shm -C ${SOURCE_DIR[$index]}/ . > ${BACKUP_DIR[$index]}/${BACKUP_FILE_LOG[$index]} 2>&1
done

logdate && echo backup gereed

exit
