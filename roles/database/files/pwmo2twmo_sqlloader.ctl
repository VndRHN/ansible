load data
 infile '/beheer/log/pwmo2twmo.log'
 TRUNCATE into table LOG_PWMO2TWMO
 ( TEXT char(255) )
