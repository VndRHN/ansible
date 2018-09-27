#!/bin/bash

export BRON_DIR=/mnt/nfs_autofs/backup
export DOEL_DIR=/u01/data/backup
export AANTAL_DAGEN=1

# opschonen doel locatie: verwijder lege directories
find $DOEL_DIR -depth -type d -empty -delete

# opschonen doel locatie: verwijder alle bestanden die ouder zijn dan 'AANTAL_DAGEN'
find $DOEL_DIR -mtime +$AANTAL_DAGEN -type f -exec rm -f {} \;

# synchroniseer alle bestanden die nieuwer zijn dan 'AANTAL_DAGEN'
cd $BRON_DIR
find . -mtime -$AANTAL_DAGEN -type f -print0 | rsync -0avz --files-from=- $BRON_DIR $DOEL_DIR  |& tee /beheer/log/rsync_nas_naar_vnd-rman_`date +%Y%m%d"_"%H%M`.log

# find:
#   -mtime +3 will match files 3 days old, and older.
#   -type f will find only files.
#   -print0 will print results with a null at the end, safer in case of strange characters in the filenames.

# rsync:
#   -0 uses null as a separation.
#   -v verbose, to see what's going on.
#   --files-from=- receive file list from the standard input.
#
# https://ubuntuforums.org/showthread.php?t=1837771
