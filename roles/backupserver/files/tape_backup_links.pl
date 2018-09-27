#!/usr/bin/perl -w 

#
# Script gemaakt om link structuur aan te maken t.b.v de tape backup.
# In de today directory staat een link structuur van alles van de afgelopen 24 uur.
# Arcserv volgt de link structuur en maakt een tape backup. 
#
# Versie historie
# aangemaakt 20-jun-2018     HvdB
#


my $source="/mnt/nfs_autofs/backup/";
my $target="/u01/data/backup/";
my $today_dir= $source . "today/";
my $days=1;
my @backup_systems;
my $dir;
my $source_path;
my $target_path;
my $finddir;
my @dir_list;
my $dir_concat;
my $link_source;
my $link_target;
my @link_list;
my $today_files;

#main
{
#
# get list of systems for tape backup
#
printf(">> Read list of systems for tape backup \n");
printf("Current list of systems: \n");
open(SYSTEMS,"</beheer/scripts/systems_for_tape_backup.txt");
while (<SYSTEMS>) 
{
 $dir=$_;
 chomp($dir);
 unless ( $dir=~ m/#/) 
  { 
  $dir=~ s/\s+$//g;
  printf(">> $dir \n");
  push(@backup_systems,$dir)}
}
close(SYSTEMS);
#
#
# create directory structure in today directory if the directory not exists
#
printf(">> Create dir structure for today backup dir \n");
$finddir=` cd $source ; find . -type d`;
@dirlist=split("\n",$finddir);
foreach $dir (@dirlist)
{
 $dir =~ s/.//;
 $dir_concat= $today_dir. $dir;
 unless ( $dir=~ m/today/) 
 {
   unless ( -d $dir_concat )
   {  system("mkdir -v $dir_concat \n");}
 }
}

#
# remove link structure 
#
printf(">> Remove links  \n" );
system("find /mnt/nfs_autofs/backup/today -type l -exec rm {} \\; ");
system("find /mnt/nfs_autofs/backup/today/software -type l -exec rm {} \\; ");
  
#
# create link structure for the systems placed in backup_dir.txt
# 
printf(">> Build link structure for today \n");
foreach $dir (@backup_systems)
{
 $source_path=$source . $dir;
 $target_path=$today_dir . $dir;
 $today_files=`cd $source_path ; find . -mtime -$days -type f `;
 @today_files=split("\n",$today_files);
 foreach $link_source( @today_files)
 {
 $link_source=~ s /.//;
 system("ln -s ". $source_path .$link_source ." ". $target_path.$link_source ." \n ");
 }
}
system("rsync -av /mnt/nfs_autofs/software  /mnt/nfs_autofs/backup/today ");

}







