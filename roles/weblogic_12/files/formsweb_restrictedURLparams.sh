#!/bin/bash

function logdate {
  echo -n `date +%F" "%a" "%T"."%3N`' - '
}

BASE_DIR=/u01/app/centric/

find ${BASE_DIR} -type d -name templates | while read line; do
	logdate && echo "Verwerk templates in $line"
	find ${line} -name formsweb.cfg -type f -print -exec sed -i 's/^restrictedURLparams=pageTitle,HTMLbodyAttrs,HTMLbeforeForm,HTMLafterForm,log,userid/restrictedURLparams=pageTitle,HTMLbodyAttrs,HTMLbeforeForm,HTMLafterForm,log/g' {} \;
done

exit
