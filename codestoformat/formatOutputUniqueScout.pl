#!/usr/bin/perl
use Bio::DB::Fasta;
use strict;

my $fileIN1 = $ARGV[0];
my $fileIN2 = $ARGV[1];

open(my $GFFRepeatScoutPiler, ">:encoding(UTF-8)", "RepeatScout.gff3");

#GLOBAL VARIABLE
my $subHeader;
my @allRecords;
my @allRecordsAux;
my @allLineRecord;
my $fullHeader;
my $fullSeq;
my $lineRecords;
my $GFFOutPut;
my $tipeTE;
my $TEClass;
my $TEOrder;
my $lineRecordsFile1;
my $lineRecordsFile2;
my @allRecordsPiler;
my @allRecordsRepeatScout;
my @allRecordsRepeatScoutFASTA;
my @splitFASTA;
my @splitGFF3;
my $tamanhoVetor;
my $i = 1;
my $HeaderLineFormatted;
#GLOBAL VARIABLE

#save RepeatScout in array
open(my $file2, "<$fileIN2") or die "Problema no Arquivo";
while ($lineRecordsFile2 = <$file2>) {
	push @allRecordsRepeatScout, $lineRecordsFile2;
}
close($file2);
#save RepeatScout in array

#save RepeatScout FASTA Reference in array
open(my $file1, "<$fileIN1") or die "Problema no Arquivo";
while ($lineRecordsFile2 = <$file1>) {
	push @allRecordsRepeatScoutFASTA, $lineRecordsFile2;
}
close($file1);
#save RepeatScout FASTA Reference in array

print "\n\nINCIO FORMATACAO FINAL\n\n";

print "FASTA: " . scalar @allRecordsRepeatScoutFASTA . " | GFF3: " . scalar @allRecordsRepeatScout . "\n\n";

$tamanhoVetor = scalar @allRecordsRepeatScoutFASTA;
my $tipoTE;
my $posicaoAtualGFF = 0;
#format only RepeatScout
foreach $lineRecordsFile2 (@allRecordsRepeatScoutFASTA) {
	@splitFASTA = split(/\t/, $lineRecordsFile2);
	$tipoTE = @splitFASTA[5];
	@splitFASTA = split(/=/, @splitFASTA[0]);

	for (my $i=$posicaoAtualGFF; $i < scalar @allRecordsRepeatScout; $i++){
		@splitGFF3 = split(/\t/, @allRecordsRepeatScout[$i]);
		if(@splitFASTA[1] == @splitGFF3[2]){
			$HeaderLineFormatted .= @splitGFF3[0] . "\t" . @splitGFF3[1] . "\t"  . $tipoTE;
			$HeaderLineFormatted .= "\t" . @splitGFF3[3] . "\t" . @splitGFF3[4] . "\t" . @splitGFF3[5];
			$HeaderLineFormatted .= "\t" . @splitGFF3[6] . "\t" . @splitGFF3[7] . "\t" . @splitGFF3[8];
			$posicaoAtualGFF+=1;
		}else{
			last;
		}
	}
	print $tamanhoVetor . " - " . $i . "\n";
	$i+=1;
}
#format only RepeatScout

print $GFFRepeatScoutPiler $HeaderLineFormatted;
close ($GFFRepeatScoutPiler);

exit 0;
