#!/usr/bin/perl
use Bio::DB::Fasta;
use strict;

my $fileIN = $ARGV[0];
my $nomeTipo = $ARGV[1];

open(IN, "<$fileIN") or die "Problema no Arquivo";

open(my $FASTANonLTRs, ">>:encoding(UTF-8)", "../../nonltr.fa");

my $sFile = Bio::DB::Fasta->new ("$fileIN");
my @ids = $sFile->get_all_primary_ids;

#GLOBAL VARIABLE
my $fullHeader;
my $fullSeq;
my $id;
my $FASTAOutPut;
#GLOBAL VARIABLE

foreach $id (@ids){
	$fullHeader = $sFile->header($id);
	$fullSeq = $sFile->get_Seq_by_id($id);

	$FASTAOutPut .= ">" . $fullHeader . " " . $nomeTipo . "\n";
	$FASTAOutPut .= $fullSeq->seq . "\n";
}

print $FASTANonLTRs $FASTAOutPut;

close($FASTANonLTRs);

exit 0;
