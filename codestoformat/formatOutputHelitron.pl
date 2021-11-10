#!/usr/bin/perl
use Bio::DB::Fasta;
use strict;

my $fileIN = $ARGV[0];
my $strandOrientation = $ARGV[1];

open(my $GFFHelitrons, ">>:encoding(UTF-8)", "../helitrons.gff3");
#open(my $FASTAHelitrons, ">>:encoding(UTF-8)", "../helitrons.fa");

open(IN, "<$fileIN") or die "Problema no Arquivo";

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
#GLOBAL VARIABLE

sub funcaoMontaGFFHeader{
	$subHeader = shift;
	my $HeaderLineFormatted;

	@allRecords = split(/#/, $subHeader);

	#BUSCAR CHROMOSSOMO OU SCAFF OU CONTIG
	@allRecords[0] =~ s|(.+)_|$1|;
	$HeaderLineFormatted = @allRecords[0];

	@allRecords = split(/( |_|;|-|=)/, @allRecords[1]);

	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "PlanTE";
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "RC/Helitron";
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= (@allRecords[2]-1);
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= @allRecords[4];
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= ".";
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= $strandOrientation;	
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= ".";
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "Software=HelitronScanner;Length=" . @allRecords[8] . "bps" . "\n";

	return $HeaderLineFormatted;
}

my $chrHelitron;

sub funcaoMontaFASTAHeader{
	$subHeader = shift;
	my $HeaderLineFormatted;

	@allRecords = split(/#/, $subHeader);

	#BUSCAR CHROMOSSOMO OU SCAFF OU CONTIG
	@allRecords[0] =~ s|(.+)_|$1|;
	$chrHelitron = @allRecords[0];

	@allRecords = split(/( |_|;|-|=)/, @allRecords[1]);

	$HeaderLineFormatted .= "RC/Helitron";
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= $chrHelitron;
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= (@allRecords[2]-1);
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= @allRecords[4];
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= $strandOrientation;	
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "Software=HelitronScanner;Superfamily=Helitron;Length=" . @allRecords[8] . "bps" . "\n";

	return $HeaderLineFormatted;
}

foreach $id (@ids){
	$fullHeader = $sFile->header($id);
	$fullSeq = $sFile->get_Seq_by_id($id);

	$GFFOutPut .= funcaoMontaGFFHeader($fullHeader);

	$FASTAHeaderOutPut = funcaoMontaFASTAHeader($fullHeader);

	$FASTAOutPut .= ">" . $FASTAHeaderOutPut;
	$FASTAOutPut .= $fullSeq->seq . "\n";
}

print $GFFHelitrons $GFFOutPut;
#print $FASTAHelitrons $FASTAOutPut;

close($GFFHelitrons);
#close($FASTAHelitrons);

exit 0;
