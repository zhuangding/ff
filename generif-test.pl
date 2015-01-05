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

open(F, "Generif/ara.txt") or die("!");
open(N, ">Generif/nocover.txt");
open(Miss, ">Generif/aramiss.txt");
while(my $line = <F>){

   chomp($line);
   $total++;
   my @item = split(/\t/, $line);
   
   my $got = "f";
   
   my $sth = $dbh->prepare("SELECT GeneName, UniProtID FROM Gene WHERE pmid = '$item[2]'");
   $sth->execute(); 
   if(my @row = $sth->fetchrow_array){
      if($row[1] eq $item[1]){
         $TPnum++;
         $got = "t";
         next;
      }
   }else{
      $nopreprocess++;
      print N "$item[2]\n";
      next;
   }
   
   while(my @row = $sth->fetchrow_array){
      if($row[1] eq $item[1]){
         $TPnum++;
         $got = "t";
         last;
      }
   }
   if($got eq "f"){
      print Miss "$line\n";
      $miss++;
   }
}
close(F);
close(N);
close(Miss);
print "$total\t$TPnum\t$nopreprocess\t$miss\n";

