#!/usr/bin/perl -I /var/www/DocumentRoot-default/ruoyao/pGenN/script
use strict;
use LWP::Simple;
use textP;

my $path = $ARGV[0];

my %dupli = ();

my %labeltype = ();

open (PMID, "Generif/nocover_arabidopsis.txt");
open (PMID1, ">Generif/nocover.txt");
while(my $pmid = <PMID>){
   chomp($pmid);
   next if(exists($dupli{$pmid}));
   $dupli{$pmid} = 1;

   my $baseurl = "http://130.14.29.110/entrez/eutils/efetch.fcgi";
   my $url=sprintf("%s?db=pubmed&retmode=text&rettype=medline&id=%s",$baseurl, $pmid);
   my $record = get($url);

   unless(defined $record){
      print "Error: failed get PMID $pmid\n$url\n\n";
      next;
   } 
   
   my ($label,%record) = ("UNKNOWN");
   for my $line (grep !/^\W*$/, split /\n/, $record){
      if($line =~ s/^(\S+)\s*- //){
         $label=$1;
         $labeltype{$label} = 1;
         push @{$record{$label}}, $line;
      }else{ 
         if(exists($record{$label})){
            $record{$label}[ $#{$record{$label}} ] .= $line;
         }
      }
   }

   if(! defined $record{PMID}){
      printf(stderr "error: PMID is not defined in $pmid.\n\n");
      exit;
   }

   my $flag = "f";
   for my $label (grep defined $record{$_}, ("PMID", "TI", "AB", "MH")){
      for my $txt (@{$record{$label}}) {
         $txt =~ s/\s+/ /g; 
         if($label eq "MH"){
            if($txt =~ /arabidopsis/i){
               $flag = "t";
            }
         }
      }
   }
   if($flag eq "f"){
      print PMID1 "$pmid\n";
   }
}
close(PMID);
close(PMID1);
