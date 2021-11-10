#!/usr/bin/perl
use strict;
use Bio::DB::Fasta;

my $fileIN1 = $ARGV[0];
my $fileIN2 = $ARGV[1];
#my $fileIN3 = $ARGV[2];

open(my $GFFRetriever, ">:encoding(UTF-8)", "../LTR_Retriever.gff3");
#open(my $FASTARetriever, ">:encoding(UTF-8)", "../LTR_Retriever.fa");

#my $sFile = Bio::DB::Fasta->new ("$fileIN3");
#my @ids = $sFile->get_all_primary_ids;

#GLOBAL VARIABLE
my $subHeader;
my @allRecords;
my @allGroupRecords;
my @allAuxRecords;
my @allAux;
my $fullHeader;
my $fullSeq;
my $lineRecords;
my $GFFOutPut;
my $FASTAHeaderOutPut;
my $FASTAOutPut;
my $familyID;
my $familyTE;
my $memberID;
my %LTRsClasses;
my $lineGroupRecords;
my $j;
my $id;
#GLOBAL VARIABLE

sub funcaoMontaGFFHeader{
	$subHeader = shift;
	$familyTE = shift;
	$familyID = shift;
	$memberID = shift;
	my $HeaderLineFormatted;

	@allRecords = split(/\t/, $subHeader);
	@allAux = split(/\//, $familyTE);

	$HeaderLineFormatted = @allRecords[0];
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "PlanTE";
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "LTR/" . ucfirst(@allAux[1]);
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= @allRecords[3];
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= @allRecords[4];
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= ".";
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= @allRecords[6];
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= @allRecords[7];
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "Software=LTRRetriever;Length=" . (@allRecords[4] - @allRecords[3]) . "bps;Repeat_Family=RL" . ucfirst(@allAux[1]) . "_" . $familyID . "_" . $memberID . ";FamilyInfo=" . @allRecords[8] . "\n";

	return $HeaderLineFormatted;
}

sub funcaoMontaFASTAHeader{
	$subHeader = shift;
	$familyTE = shift;
	$familyID = shift;
	$memberID = shift;
	my $HeaderLineFormatted;

	@allRecords = split(/\t/, $subHeader);
	@allAux = split(/\//, $familyTE);

	$HeaderLineFormatted .= "LTR/" . ucfirst(@allAux[1]);
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= @allRecords[0];
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= @allRecords[3];
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= @allRecords[4];
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= @allRecords[6];
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "Software=LTRRetriever;Superfamily=" . ucfirst(@allAux[1]) . ";Software=RepeatScout;Length=" . (@allRecords[4] - @allRecords[3]) . "bps;Repeat_Family=RL" . ucfirst(@allAux[1]) . "_" . $familyID . "_" . $memberID . ";FamilyInfo=" . @allRecords[8] . "\n";

	return $HeaderLineFormatted;
}

open(IN2, "<$fileIN2") or die "Problema no Arquivo";
open(IN1, "<$fileIN1") or die "Problema no Arquivo";

my @arrayItens;
while (<IN1>) {
	chomp $_;
	if(!($_ =~ m/##/)){
		push (@arrayItens, $_);
	}
}

my $idFasta;
my $groupString;
my $gffString;

while ($lineGroupRecords = <IN2>){
	chomp $lineGroupRecords;
	$j=1;
	@allGroupRecords = split(/\t/, $lineGroupRecords);
	$LTRsClasses{@allGroupRecords[2]}++;

	for $lineRecords (@arrayItens){
		chomp $lineRecords;
		@allAuxRecords = split(/\t/, $lineRecords);

		$groupString = "" . @allGroupRecords[1];
		$gffString = "" . @allAuxRecords[8];

		if( ($groupString eq $gffString) ){
			$GFFOutPut .= funcaoMontaGFFHeader($lineRecords, @allGroupRecords[2], $LTRsClasses{@allGroupRecords[2]}, $j);
			#$FASTAHeaderOutPut = funcaoMontaFASTAHeader($lineRecords, @allGroupRecords[2], $LTRsClasses{@allGroupRecords[2]}, $j);

			#$idFasta = @allAuxRecords[0] . ":" . @allAuxRecords[3]."-".@allAuxRecords[4]."(".@allAuxRecords[6].")";
			#$fullSeq = $sFile->get_Seq_by_id($idFasta);
			#$FASTAOutPut .= ">" . $FASTAHeaderOutPut;
			#$FASTAOutPut .= $fullSeq->seq . "\n";

			$j+=1;
		}
	}
}
print $GFFRetriever $GFFOutPut;
#print $FASTARetriever $FASTAOutPut;
close(IN1);
close(IN2);
close($GFFRetriever);
#close($FASTARetriever);

exit 0;
