watch "ps -ef | grep -v grep | grep -c smon_ && echo && ps -ef | grep -v grep | grep smon_ | cut -d_ -f3 | sort"
