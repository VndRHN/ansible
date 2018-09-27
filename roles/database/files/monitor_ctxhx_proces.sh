#!/bin/bash

#  I 16 04 0035 - Mozard JOB Minutenrun hangt
#  
#  >>> Felix Kraneveld <felix@mozard.nl> 1-4-2016 14:39 >>>
#  
#  Het ctxhx proces doet het daadwerkelijke indexen van een document. Dat kan
#  blijven hangen op een document. Je moet dan juist NIET de job killen waaruit
#  dit draait. Je moet alleen het ctxhx process killen op de server (op systeem
#  niveau kill -9 etc.). De job gaat dan gewoon verder.
#  
#  ctxhx start voor ieder document dat een index nodig heeft, het start en stopt
#  over het algemeen dus heel vaak en heel snel, over het algemeen zie je zo'n
#  proces niet tenzij het blijft hangen. Het kan ook meerdere keren in een run
#  blijven hangen. 
#  
#  Op het moment dat je ctxhx kilt registreert de job het document als 'corrupt'
#  en loopt verder (en slaat de volgende keer het document over). Kill je de job
#  waaruit dit proces start dan blijf je het probleem houden, de job krijgt een
#  rollback en registreert niets. 
#  
#  De enige juiste handeling is dus de minuterun job gewoon laten lopen en ctxhx killen!
#  Het handmatig logging script draai je eigenlijk nooit, alleen als er geen
#  ctxhx proces is en de run ergens anders op fout gaat.
#  
#  Bijgevoegd nog een scriptje wat je kunt laten draaien om ctxhx automatisch te
#  killen als hij langer dan 10min actief is. Die laat je iedere 5min met cron lopen.
#  
#  Gr. Felix

if ps -eo pid,etime,comm | awk '$2~/^[1-9][0-9]+:[0-6][0-9]$+/ && $3~/ctxhx/'
then
  ps -eo pid,etime,comm | awk '$2~/^[1-9][0-9]+:[0-6][0-9]$+/ && $3~/ctxhx/ { print $1 }' | xargs kill -9
fi

