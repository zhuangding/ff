#!/usr/bin/perl
use DBI;
use strict;

my $path = "/var/www/DocumentRoot-default/ruoyao/pGenN-demo";

my $driver = "mysql"; 
my $database = "pGenN";
my $dsn = "DBI:$driver:database=$database";
my $userid = "rding";
my $password = "101dry!";

my $dbh = DBI->connect($dsn, $userid, $password ) or die $DBI::errstr;

my %pmid = ();
open (F, "$path/text.txt");
while(my $line = <F>){
   chomp($line);
   if($line =~ /^([0-9]+)~@~(.+)$/){
      if(exists($pmid{$1})){
         $pmid{$1} .= "~~~$2";
      }else{
         $pmid{$1} = $2;
      }
   }
}
close(F);


open (R, ">$path/result.html");
print R "<style>body {font-size:1.1em;} table {border:1px;width:96%;border-collapse:collapse;margin:20px;} td {border:1px solid gray;padding:5px;} th{width:25%;}</style><br>";
print R "<style type=\"text/css\">  a{text-decoration:none}</style>\n"; 
while(my ($key, $val) = each(%pmid)){
   
   print R "<table><tr><td>\n";
   
   my $sth = $dbh->prepare("SELECT pmid, text FROM PMID_text WHERE pmid = '$key'");
   $sth->execute();
   
   if(my @row = $sth->fetchrow_array){
      
      print R "<table>\n";
      print R "<tr><td></td><td>$row[0]</td></tr>\n";
      my @sentence = split(/\n/, $row[1]);
      my $linenum = 0;
      foreach my $sentence (@sentence){
         $sentence =~ s/\<fam\>|\<\/fam\>|\<pro\>|\<\/pro\>//g;
         
         my @name = split(/~~~/, $val);
         foreach my $nameid (@name){
            $nameid =~ /^([^~]+)~@~(.+)$/;
            my ($name, $id) = ($1, $2);
            my $temp = $name;
            $temp =~ s/\-/\\\-/g;
            $sentence =~ s/$temp/\<div style\=\"color\:blue\;display\:inline\;\"\>$name\<\/div\>/g;
         }
         print R "<tr><td width = \"3%\">$linenum</td><td>$sentence</td></tr>\n";
         $linenum++;
      }
      print R "</table>\n";
      
      print R "<table>\n";
      print R "<tr><td width = \"20%\">Gene names</td><td width = \"40%\">Gold</td><td>pGenN</td></tr>\n";
      my @name = split(/~~~/, $val);
      foreach my $nameid (@name){

         $nameid =~ /^(.+)~@~(.*)~@~(.*)$/;
         my ($name, $gold) = ($1, $3);
         
         print R "<tr><td>$name</td><td>\n";
         
         if(length($gold) > 0){
            my $sth = $dbh->prepare("SELECT Species FROM ID_Species WHERE ID = '$gold'");
            $sth->execute();
   
            if(my @row = $sth->fetchrow_array){
               print R "$gold\t<div style=\"color:blue;display:inline;\">$row[0]</div><br>";
            }
         }
         print R "</td><td>\n";
         
         my @id = split(/\, /, $2);
         foreach my $id (@id){
            my $sth = $dbh->prepare("SELECT Species FROM ID_Species WHERE ID = '$id'");
            $sth->execute();
   
            if(my @row = $sth->fetchrow_array){
               print R "$id\t<div style=\"color:blue;display:inline;\">$row[0]</div><br>";
            }
         }
         
         
         
         print R "</td></tr>\n";
      }
      print R "</table>\n";
   }
   print R "</td></tr></table>\n";
}
close(R);






