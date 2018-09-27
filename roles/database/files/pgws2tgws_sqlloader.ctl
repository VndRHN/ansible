load data
 infile '/beheer/log/pgws2tgws.log'
 TRUNCATE into table LOG_PGWS2TGWS
 ( TEXT char(255) )
