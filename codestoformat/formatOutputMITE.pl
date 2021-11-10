#!/usr/bin/perl
use Bio::DB::Fasta;
use strict;

my $fileIN = $ARGV[0];

open(IN, "<$fileIN") or die "Problema no Arquivo";

open(my $GFFMITE, ">>:encoding(UTF-8)", "../MITE.gff3");
#open(my $FASTAMITE, ">>:encoding(UTF-8)", "../MITE.fa");

my $sFile = Bio::DB::Fasta->new ("$fileIN");
my @ids = $sFile->get_all_primary_ids;

#GLOBAL VARIABLE
my $subHeader;
my @allRecords;
my $fullHeader;
my $fullSeq;
my $lineRecords;
my $id;
my $GFFOutPut;
my $FASTAHeaderOutPut;
my $FASTAOutPut;
my $tamanhoSequencia;
my @i = split(/(_|\.)/, $fileIN);
#GLOBAL VARIABLE

sub funcaoMontaGFFHeader{
	$subHeader = shift;
	$tamanhoSequencia = shift;
	my $HeaderLineFormatted;

	@allRecords = split(/(_| )/, $subHeader);

	$HeaderLineFormatted = @allRecords[2];
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "PlanTE";
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "MITE";
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= @allRecords[4];
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= @allRecords[4] + $tamanhoSequencia;
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= ".";
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= ".";	
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= ".";
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "Software=MITEHunter;Length=" . $tamanhoSequencia . "bps;Description=" . @allRecords[6] . ";MITEFamily=" . @i[4] . "\n";

	return $HeaderLineFormatted;
}

sub funcaoMontaFASTAHeader{
	$subHeader = shift;
	$tamanhoSequencia = shift;
	my $HeaderLineFormatted;

	@allRecords = split(/(_| )/, $subHeader);

	$HeaderLineFormatted .= "MITE";
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= @allRecords[2];
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= @allRecords[4];
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= @allRecords[4] + $tamanhoSequencia;
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= ".";
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "Software=MITEHunter;Superfamily=MITE;Length=" . $tamanhoSequencia . "bps;Description=" . @allRecords[6] . ";MITEFamily=" . @i[4] . "\n";

	return $HeaderLineFormatted;
}

foreach $id (@ids){
	$fullHeader = $sFile->header($id);
	$fullSeq = $sFile->get_Seq_by_id($id);

	$GFFOutPut .= funcaoMontaGFFHeader($fullHeader, length($fullSeq->seq));

	$FASTAHeaderOutPut = funcaoMontaFASTAHeader($fullHeader, length($fullSeq->seq));

	$FASTAOutPut .= ">" . $FASTAHeaderOutPut;
	$FASTAOutPut .= $fullSeq->seq . "\n";
}

print $GFFMITE $GFFOutPut;
#print $FASTAMITE $FASTAOutPut;

close($GFFMITE);
#close($FASTAMITE);

exit 0;
