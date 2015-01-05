#!/usr/bin/perl -I /var/www/DocumentRoot-default/ruoyao/pGenN/script
use strict;
use DBI;
use textP;

my $driver = "mysql"; 
my $database = "pGenN";
my $dsn = "DBI:$driver:database=$database";
my $userid = "rding";
my $password = "101dry!";

my $dbh = DBI->connect($dsn, $userid, $password ) or die $DBI::errstr;

my ($TPnum, $nopreprocess, $total, $miss) = 0;


open(G, "Generif/gene2pubtator") or die("!");
my %genenorm = ();
while(my $line = <G>){
   chomp($line);
   my @item = split(/\t/, $line);
   
   $genenorm{$item[0]} .= "~$item[1]~"
}


open(F, "Generif/ara") or die("!");
while(my $line = <F>){

   chomp($line);
   $total++;
   my @item = split(/\t/, $line);
   
   my $got = "f";
   
   if($genenorm{$item[2]} =~ /~$item[1]~/){
      $TPnum++;
   }else{
      $miss++;
   }
   
}
close(F);
print "$total\t$TPnum\t$nopreprocess\t$miss\n";

