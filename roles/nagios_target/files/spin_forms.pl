#!/usr/bin/perl

 use strict;
 use warnings;


    my $pidstat=`pidstat -w`;
    my @process_list;
    my @fld;
    my $line;
    my $status=0;

#main
{
  @process_list=split('\n',$pidstat);
  foreach $line(@process_list)
  {
    @fld=split(' ',$line);
    if (defined($fld[0]))
    {
      if (($fld[0] ne "Linux") && ($fld[4] ne "nvcswch/s" ))
      {
        if (scalar($fld[4])> 5)
        {
          printf("CRITICAL Spinning process with pid $fld[2] \n"); exit(2) ;
          $status=1;
        }
                                                                                                   }
    }
}
if  ($status ==0) {printf("OKE no spinning forms processes \n") ;exit(0);}
}
#

