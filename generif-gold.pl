#!/usr/bin/perl -I /var/www/DocumentRoot-default/ruoyao/pGenN/script
use strict;
use DBI;
use textP;

my $driver = "mysql"; 
my $database = "UDIDGenes";
my $dsn = "DBI:$driver:database=$database";
my $userid = "rding";
my $password = "101dry!";

my $dbh = DBI->connect($dsn, $userid, $password ) or die $DBI::errstr;

open(F, "Generif/generifs_basic") or die("!");
open(Gold1, ">Generif/ara.txt");
open(Gold11, ">Generif/ara");
open(Gold2, ">Generif/maize.txt");
open(Gold22, ">Generif/maize");

my ($aratotal, $aratest, $maizetotal, $mazietest) = (0, 0, 0, 0);

while(my $line = <F>){
   chomp($line);
   my @item = split(/\t/, $line);
   
   if($item[0] eq 3702){
      my $sth = $dbh->prepare("SELECT UniprotID FROM UniProtKBIDs WHERE EntrezID = '$item[1]'");
      $sth->execute();
      if(my @row = $sth->fetchrow_array){
         
         print Gold1 "$item[0]\t$row[0]\t$item[2]\t$item[4]\n";
         $aratest++;
      }
      print Gold11 "$item[0]\t$item[1]\t$item[2]\t$item[4]\n";
      $aratotal++;
   }elsif($item[0] eq 4577){
      my $sth = $dbh->prepare("SELECT UniprotID FROM UniProtKBIDs WHERE EntrezID = '$item[1]'");
      $sth->execute();
      if(my @row = $sth->fetchrow_array){
         
         print Gold2 "$item[0]\t$row[0]\t$item[2]\t$item[4]\n";
         $mazietest++;
      }
      print Gold22 "$item[0]\t$item[1]\t$item[2]\t$item[4]\n";
      $maizetotal++;
   }
}
close(F);

print "$aratotal, $aratest, $maizetotal, $mazietest\n\n";

