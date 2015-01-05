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




my %uniprot = ();
my ($prop, $species, $speciesf, $id, $id_valid, $fullset, $shortset, $locus, $exset, $flag) = ();
open(FILE, "/var/www/DocumentRoot-default/ruoyao/Dic-make/Plant/DATA/TEMP/UniProtARA.dat") or die ("File does not exsit!");
while(my $line = <FILE>){

   chomp($line);
   
   if($line =~ /Contains|Includes/){
      $flag = "1";
   }elsif($line =~ /^GN|^AC|^OS/){
      $flag = "0";
   }
   next if($flag eq "1");
   
   if($line =~ /^AC/){                    ### AC
   
      next if($id_valid eq "f");
      
      if($line =~ /^AC\s+([^ \;]+)\;/){
         $id = $1;
      }else{
         print "AC error: $line\n";    
      }
      $id_valid = "f";
      
   }elsif($line =~ /Full\=(.+)\;/){        ### FULL_NAME
      $id_valid = "t";
      $uniprot{$id} .= "$1<br>";

   }elsif($line =~ /Short\=([^\=]+)\;[^0-9]/){
      $id_valid = "t";
      $uniprot{$id} .= "$1<br>";
   }elsif($line =~ /Short\=([^\=]+)\;$/){
      $id_valid = "t";
      $uniprot{$id} .= "$1<br>";
   }elsif($line =~ /^GN/){                       ### GN
      $id_valid = "t";
      if($line =~ /Synonyms\=/){
         if($line =~ /Name\=([^\=]+)\;[^0-9].*Synonyms\=([^\;]+)\;/){
            $uniprot{$id} .= "$1<br>";
            my $set = $2;
            
            
            my @GN = split(/\,/, $set);
            foreach my $gn (@GN){
               $gn =~ s/^\s+|\s+$//;
               $gn =~ s/^At|^AT\-|\-?At$//;
               next if((length($gn) eq 1) or ($gn =~ /^[0-9]+$/));
               $uniprot{$id} .= "$gn<br>";
            }
            
         }
      }else{
         if($line =~ /Name\=([^\=]+)\;[^0-9]/){
            $uniprot{$id} .= "$1<br>"; 
         }elsif($line =~ /Name\=([^\=]+)\;/){
            $uniprot{$id} .= "$1<br>";
         }
      }
   }
}
close(FILE);

open(FILE, "/var/www/DocumentRoot-default/ruoyao/Dic-make/Plant/DATA/TEMP/UnreviewedARA.dat") or die ("File does not exsit!");
while(my $line = <FILE>){

   chomp($line);
   
   if($line =~ /Contains|Includes/){
      $flag = "1";
   }elsif($line =~ /^GN|^AC|^OS/){
      $flag = "0";
   }
   next if($flag eq "1");
   
   if($line =~ /^AC/){                    ### AC
   
      next if($id_valid eq "f");
      
      if($line =~ /^AC\s+([^ \;]+)\;/){
         $id = $1;
      }else{
         print "AC error: $line\n";    
      }
      $id_valid = "f";
      
   }elsif($line =~ /Full\=(.+)\;/){        ### FULL_NAME
      $id_valid = "t";
      $uniprot{$id} .= "$1<br>";

   }elsif($line =~ /Short\=([^\=]+)\;[^0-9]/){
      $id_valid = "t";
      $uniprot{$id} .= "$1<br>";
   }elsif($line =~ /Short\=([^\=]+)\;$/){
      $id_valid = "t";
      $uniprot{$id} .= "$1<br>";
   }elsif($line =~ /^GN/){                       ### GN
      $id_valid = "t";
      if($line =~ /Synonyms\=/){
         if($line =~ /Name\=([^\=]+)\;[^0-9].*Synonyms\=([^\;]+)\;/){
            $uniprot{$id} .= "$1<br>";
            my $set = $2;
            
            
            my @GN = split(/\,/, $set);
            foreach my $gn (@GN){
               $gn =~ s/^\s+|\s+$//;
               $gn =~ s/^At|^AT\-|\-?At$//;
               next if((length($gn) eq 1) or ($gn =~ /^[0-9]+$/));
               $uniprot{$id} .= "$gn<br>";
            }
            
         }
      }else{
         if($line =~ /Name\=([^\=]+)\;[^0-9]/){
            $uniprot{$id} .= "$1<br>"; 
         }elsif($line =~ /Name\=([^\=]+)\;/){
            $uniprot{$id} .= "$1<br>";
         }
      }
   }
}
close(FILE);

my $beyond = 0;
open(F, "Generif/aramiss.txt") or die("!");
open(R, ">Generif/aramiss.html");
print R "<style>body {font-size:1.1em;} table {border:1px;width:96%;border-collapse:collapse;margin:20px;} td {border:1px solid gray;padding:5px;} th{width:25%;}</style><br>";
print R "<style type=\"text/css\">  a{text-decoration:none}</style>\n"; 
while(my $line = <F>){

   chomp($line);
   $total++;
   my @item = split(/\t/, $line);
   
   my $got = "f";
   
   my $sth = $dbh->prepare("SELECT text FROM PMID_text WHERE pmid = '$item[2]'");
   $sth->execute(); 
   if(my @row = $sth->fetchrow_array){
      $row[0] =~ s/\n/\<br\>/g;
      print R "<table><tr><td>$item[1]<br>$uniprot{$item[1]}</td></tr><tr><td>$item[3]</td></tr><tr><td>PMID$item[2]<br>$row[0]</td></tr></table>";
      
      unless($row[0] =~ /arabidopsis/i){
         $beyond++;
      }
   }else{
      print "error!!!\n\n";
   }
}
close(F);
close(R);

print "$beyond\n\n";
