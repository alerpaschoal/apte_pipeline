#!/usr/bin/perl
use Bio::DB::Fasta;
use strict;

my $fileIN1 = $ARGV[0];

open(my $file1, "<$fileIN1") or die "Problema no Arquivo";

#my $sFile = Bio::DB::Fasta->new ("$fileIN2");
#my @ids = $sFile->get_all_primary_ids;

open(my $GFFRepeatMasker, ">:encoding(UTF-8)", "../RepeatMasker.gff3");

#GLOBAL VARIABLE
my $subHeader;
my @allRecords;
my @allRecordsAux;
my @allLineRecord;
my $fullHeader;
my $fullSeq;
my $lineRecords;
my $GFFOutPut;
my $FASTAHeaderOutPut;
my $FASTAOutPut;
#GLOBAL VARIABLE

sub funcaoMontaGFFHeader{
	$subHeader = shift;
	my $HeaderLineFormatted;

	@allRecords = split(/( )/, $subHeader);

	$HeaderLineFormatted = @allRecords[10];
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "PlanTE";
	$HeaderLineFormatted .= "\t";
	#@allRecordsAux = split(/-/, @allRecords[20]);
	$HeaderLineFormatted .= @allRecords[22];
	$HeaderLineFormatted .= @allRecordsAux[0];
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= @allRecords[12];
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= @allRecords[14];
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= ".";
	$HeaderLineFormatted .= "\t";
	if(@allRecords[18] =~ m/C/){
		$HeaderLineFormatted .= "-";	
	}else{
		$HeaderLineFormatted .= "+";
	}
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= ".";
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "Software=RepeatMasker;Length=" . (@allRecords[14] - @allRecords[12]) . "bps;Description=" . @allRecords[20] . "\n";

	return $HeaderLineFormatted;
}

sub funcaoMontaFASTAHeader{
	$subHeader = shift;
	my $HeaderLineFormatted;
	
	@allRecords = split(/( )/, $subHeader);

	$HeaderLineFormatted = @allRecords[10];
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= @allRecords[20];
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= @allRecords[12];
	$HeaderLineFormatted .= "#";
	$HeaderLineFormatted .= @allRecords[14];
	$HeaderLineFormatted .= "#";
	if(@allRecords[18] =~ m/C/){
		$HeaderLineFormatted .= "-";	
	}else{
		$HeaderLineFormatted .= "+";
	}
	$HeaderLineFormatted .= "\t";
	$HeaderLineFormatted .= "Software=RepeatMasker;Superfamily=" . @allRecords[10] . ";Length=" . (@allRecords[14] - @allRecords[12]) . "bps;Description=" . @allRecords[20] . "\n";

	return $HeaderLineFormatted;
}

my $i=0;
while ($lineRecords = <$file1>){
	if ($i>2){
		$lineRecords =~ s/\h+/ /g;

		@allLineRecord = split(/( )/, $lineRecords);

		if(@allLineRecord[2] >= 250){
			$GFFOutPut .= funcaoMontaGFFHeader($lineRecords);
		}
		#$FASTAHeaderOutPut = funcaoMontaFASTAHeader($lineRecords);

		#@allRecords = split(/_/, $FASTAHeaderOutPut);
		#$fullSeq = $sFile->get_Seq_by_id(@allRecords[0]);
		#$FASTAOutPut .= ">" . $FASTAHeaderOutPut;
		#$FASTAOutPut .= $fullSeq->seq . "\n";
	}
	$i+=1;
}

print $GFFRepeatMasker $GFFOutPut;
#print $FASTARepeatScout $FASTAOutPut;

close($GFFRepeatMasker);
#close($FASTARepeatScout);

exit 0;
