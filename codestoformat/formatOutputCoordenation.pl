#!/usr/bin/perl
use Bio::DB::Fasta;
use List::Util qw(max);
#use strict;

my $fileIN1 = $ARGV[0];
my $fileIN2 = $ARGV[1];
my $fileIN3 = $ARGV[2];

open(my $vetorOriginal, "<$fileIN1") or die "Problema no Arquivo";
open(my $vetorIntersect, "<$fileIN2") or die "Problema no Arquivo";

open(my $GFFFormatado, ">:encoding(UTF-8)", "TEAnnotationFinal-" . $fileIN3 . ".gff3");
open(my $GFFFormatadoCompleto, ">:encoding(UTF-8)", "TEAnnotationCompleto-" . $fileIN3 . ".gff3");

#GLOBAL VARIABLE
my @lineHashRecordsEach;
my @lineDadosRecordsEach;
my $lineHashEsq;
my $lineDadosEsq;
my $lineDadosDir;
my %hash;
my $explodeFuturo;
my $lineVetorHash;
my $lineVetorDados;
my $vetorElementosDados;
my $vetorElementosDadosAux;
my $lineVetorDadosAux;
my $countOverlap = 0;
my $countTotalExclusao = 0;
my $count = 0;
my $controleUltimoRegistro = 0;
my $vetorDados;
my $vetorIntersectSplitted;
my @lineRecordsEach;
my $strRecord;
#GLOBAL VARIABLE

sub montarArray{
	my @args = @_;
	while ($lineVetorDados = <$vetorIntersect>){
		$vetorElementosDados .= $lineVetorDados;
		$count += 1;
	}
	$vetorElementosDados .= "####";
}

print "\n ------------ \n";
print "\n CRIA VETOR \n";
print "\n ------------ \n";

montarArray(0);

@vetorIntersectSplitted = (split(/\n/, $vetorElementosDados));
#print scalar @lineHashEsq;die;
$count = 0;
$countAux = 0;
while ($lineVetorOriginal = <$vetorOriginal>){
	
	#ESTRUTURA DE CONTROLE
	if($lineVetorOriginal eq "####"){
		last;
	}

	@lineVetorOriginalSplitted = split(/\t/, $lineVetorOriginal);

	$lineDadosEsq = $lineVetorOriginalSplitted[0] . "\t" . $lineVetorOriginalSplitted[1] . "\t" . $lineVetorOriginalSplitted[2] . "\t". $lineVetorOriginalSplitted[3] . "\t";
	$lineDadosEsq .= $lineVetorOriginalSplitted[4] . "\t" . $lineVetorOriginalSplitted[5] . "\t" . $lineVetorOriginalSplitted[6] . "\t". $lineVetorOriginalSplitted[7] . "\t";
	$lineDadosEsq .= $lineVetorOriginalSplitted[8];

	for (my $i=0 ; $i<$lineVetorOriginalSplitted[9]; $i++){
		@lineRecordsEach = split(/\t/, $vetorIntersectSplitted[$countAux]);
		$strRecord .= $lineRecordsEach[9] . "\t" . $lineRecordsEach[10] . "\t" . $lineRecordsEach[11] . "\t". $lineRecordsEach[12] . "\t";
		$strRecord .= $lineRecordsEach[13] . "\t" . $lineRecordsEach[14] . "\t" . $lineRecordsEach[15] . "\t". $lineRecordsEach[16] . "\t";
		$strRecord .= $lineRecordsEach[17] . "--";
		$explodeFuturo .= $strRecord;
		$strRecord = "";
		$countAux+=1;
	}
	$explodeFuturo = substr $explodeFuturo, 0, -2;
	$hash{$lineDadosEsq} = $explodeFuturo;
	$count+=1;

	$explodeFuturo = "";
	$strRecord = "";
}

print "\n ---------- \n";
print "\n FORMATANDO \n";
print "\n ---------- \n";

$count = 0;
my @explodeItens;
my @explodeItensAux;
my %hashSoftware;
my %hashTipo;
my $newOutputScored;
my $ninethTwoColumn;
my $ninethOneColumn;
my $tenthColumn;
my $registrosSobreposicoes;
my $identificacaoSoftwares;
my $confiancaClassificacao = 0;
my $GFFOutPutFinal;
my $GFFOutPutCompleto;
my $highest;
#FAZER CALCULO DE CONFIABILIDADE BASEADO EM OVERLAP POR 1) Reliable Annotation (x/7) E POR 2) Reliable Classification 2:3
foreach my $key (keys %hash){

	$count+=1;
	#my $value = $hash{$key};
  	#print "$key costs $value\n";
	
	@lineHashRecordsEach = split(/--/, $hash{$key});
	#print $count . " - " . @lineHashRecordsEach . "\n";
	#die;

	%hashSoftware = ();
	%hashTipo = ();
	$classificaMaiorRegistro = 0;
	$gffTmp="";
	$teste = 0;
	foreach my $nextItem (@lineHashRecordsEach) {
		@explodeItens = split(/\t/, $nextItem);
		$hashTipo{@explodeItens[2]}+=1;

		if ($classificaMaiorRegistro < (@explodeItens[4] - @explodeItens[3])){
			$classificaMaiorRegistro = (@explodeItens[4] - @explodeItens[3]);
			$gffTmp = @explodeItens[0] . "\t" . @explodeItens[1] . "\t" . @explodeItens[2] . "\t" . "#_#" . "\t";
			$gffTmp .= "#__#" . "\t" . @explodeItens[5] . "\t" . @explodeItens[6] . "\t" . @explodeItens[7] . "\t";
			$gffTmp .= "---------" . @explodeItens[8];
		} elsif ($classificaMaiorRegistro eq (@explodeItens[4] - @explodeItens[3])){
			$teste = 1;
			$gffTmp .= "\n" . @explodeItens[0] . "\t" . @explodeItens[1] . "\t" . @explodeItens[2] . "\t" . "#_#" . "\t";
			$gffTmp .= "#__#" . "\t" . @explodeItens[5] . "\t" . @explodeItens[6] . "\t" . @explodeItens[7] . "\t";
			$gffTmp .= "---------" . @explodeItens[8];
		}

		@explodeItens = split(/;/, @explodeItens[8]);
		@explodeItens = split(/=/, @explodeItens[0]);
		$hashSoftware{@explodeItens[1]}+=1;
	}

	$confiancaClassificacao = 0;
	foreach my $tipoKey (keys %hashTipo){
		my $value = $hashTipo{$tipoKey};
		$confiancaClassificacao +=1;
	}
	
	$identificacaoSoftwares = 0;
	$registrosSobreposicoes = 0;
	$highestSoftware = 0;
	foreach my $scoreKey (keys %hashSoftware){
		my $value = $hashSoftware{$scoreKey};
		$registrosSobreposicoes += $value;
		$identificacaoSoftwares+=1;

		if($highestSoftware < $value){
			$highestSoftware = $value;
		}
	}

	@explodeItensAux = split(/\t/, $key);

	$ninethTwoColumn = "TEScore=" . ($confiancaClassificacao == 1 ? 1 : substr(((1/$registrosSobreposicoes)*$highestSoftware), 0, 5)) . ";";
	$ninethOneColumn = "TE-Score=" . substr($identificacaoSoftwares/7, 0, 5) . ";";

	$tenthColumn = "ReliableAnnotation=" . substr(($identificacaoSoftwares/7), 0, 5) . "(" . $identificacaoSoftwares . ")";

	$gffTmp =~ s/#_#/@explodeItensAux[3]/g;
	$gffTmp =~ s/#__#/@explodeItensAux[4]/g;
	$gffTmp =~ s/---------/$ninethOneColumn/g;

	foreach my $itemGff (split(/\n/, $gffTmp)){
		@explodeItensAux = split(/\t/, $itemGff);
		$gffTmp = @explodeItensAux[0] . "\t" . @explodeItensAux[1] . "\t" . @explodeItensAux[2] . "\t" . @explodeItensAux[3] . "\t";
		$gffTmp .= @explodeItensAux[4] . "\t" . @explodeItensAux[5] . "\t" . @explodeItensAux[6] . "\t" . @explodeItensAux[7] . "\t";
		$highestSoftware = @explodeItensAux[4] - @explodeItensAux[3];

		#FAZ O COMPLETO PARA ESTATISTICA DE SOFTWARE;
		$GFFOutPutCompleto .= $gffTmp . $ninethTwoColumn . $tenthColumn . "\n";

		@explodeItensAux = split(/;/, @explodeItensAux[8]);
		$gffTmp .= @explodeItensAux[0] . ";" . @explodeItensAux[1] . ";Length=" . $highestSoftware . "bps";

		$GFFOutPutFinal .= $gffTmp . "\n";
	}
	#$GFFOutPutCompleto .= $newOutputScored . $ninethOneColumn . $tenthColumn . $ninethTwoColumn . "\n";
}

print $GFFFormatado $GFFOutPutFinal;

print $GFFFormatadoCompleto $GFFOutPutCompleto;
#print $FASTARepeatScout $FASTAOutPut;

close($GFFFormatado);
close($GFFFormatadoCompleto);
#close($FASTARepeatScout);

print "\n --------- \n";
print "\n FORMATADO \n";
print "\n --------- \n";

exit 0;
