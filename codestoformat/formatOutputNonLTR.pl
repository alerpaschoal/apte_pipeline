#!/usr/bin/perl
use Bio::DB::Fasta;
use strict;

my $fileIN1 = $ARGV[0];
my $fileIN2 = $ARGV[1];

open(my $GFFNonLTR, ">:encoding(UTF-8)", "../../NonLTR.gff3");
#open(my $FASTANonLTR, ">:encoding(UTF-8)", "../../NonLTR.fa");

open(my $file1, "<$fileIN1") or die "Problema no Arquivo";
open(my $file2, "<$fileIN2") or die "Problema no Arquivo";

my $sFile = Bio::DB::Fasta->new ("$fileIN2");
my @ids = $sFile->get_all_primary_ids;

#GLOBAL VARIABLE
my $subHeader;
my @allRecords;
my $fullHeader;
my $fullSeq;
my $lineRecords;
my $GFFOutPut;
my $FASTAHeaderOutPut;
my $FASTAOutPut;
my @idTipo;
#GLOBAL VARIABLE

sub funcaoMontaGFFHeader{
	$subHeader = shift;
	my $HeaderLineFormatted;

	@allRecords = split(/\t/, $subHeader);

	@idTipo = split(/=/, @allRecords[8]);

	@idTipo = split(/ /, $sFile->header(@idTipo[1]));

	$HeaderLineFormatted = @allRecords[0];
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "PlanTE";
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "LINE/" . @idTipo[1];
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= @allRecords[3];
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= @allRecords[4];
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= ".";
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= ".";
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= ".";
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "Software=MGEScan-nonLTR;Length=" . (@allRecords[4] - @allRecords[3]) . "bps;Description=" . @idTipo[0] . "\n";

	return $HeaderLineFormatted;
}

sub funcaoMontaFASTAHeader{
	$subHeader = shift;
	my $HeaderLineFormatted;

	@allRecords = split(/\t/, $subHeader);

	@idTipo = split(/=/, @allRecords[8]);

	@idTipo = split(/ /, $sFile->header(@idTipo[1]));

	$HeaderLineFormatted .= @idTipo[1];
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= @allRecords[0];
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= @allRecords[3];
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= @allRecords[4];
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= ".";
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "Software=MGEScan-nonLTR;Superfamily=" . @idTipo[1] . ";Length=" . (@allRecords[4] - @allRecords[3]) . "bps;Description=" . @idTipo[0] . "\n";

	return $HeaderLineFormatted;
}

my $i=0;
while ($lineRecords = <$file1>){
	if ($i>0){
		chomp($lineRecords);
		$GFFOutPut .= funcaoMontaGFFHeader($lineRecords);
		$FASTAHeaderOutPut = funcaoMontaFASTAHeader($lineRecords);

		@allRecords = split(/\t/, $lineRecords);
		@idTipo = split(/=/, @allRecords[8]);
		@idTipo = split(/ /, $sFile->header(@idTipo[1]));
		$fullSeq = $sFile->get_Seq_by_id(@idTipo[0]);
		$FASTAOutPut .= ">" . $FASTAHeaderOutPut;
		$FASTAOutPut .= $fullSeq->seq . "\n";
	}
	$i+=1;
}

print $GFFNonLTR $GFFOutPut;
#print $FASTANonLTR $FASTAOutPut;

close($GFFNonLTR);
#close($FASTANonLTR);

exit 0;
