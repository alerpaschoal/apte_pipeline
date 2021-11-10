The following tutorial will use A. thaliana to represent the work and codes used to extract and map the Transposable Elements reported in the article:

* This tutorial assumes that all the software used for the analysis is installed. To check the instructions, facilities and installations, access:

- LTR_retriever: https://github.com/oushujun/LTR_retriever
- MGEScan non-ltr: https://mgescan.readthedocs.io/en/latest/nonltr.html
- RepeatMasker: http://www.repeatmasker.org/RMDownload.html
- RepeatModeler: http://www.repeatmasker.org/RepeatModeler
- RepeatScout: https://bix.ucsd.edu/repeatscout
- MITEHunter: http://target.iplantcollaborative.org/mite_hunter.html
- HelitronScanner: https://sourceforge.net/projects/helitronscanner
- PASTEClassifier: https://urgi.versailles.inra.fr/Tools/PASTEClassifier

Also, for automation purposes, some scripts have been developed that are in the "scripts" folder and will be demonstrated step by step with the results of each output of the software above.

1 - After making the annotation using LTR_retriever, you should see a number of files, there are examples in "athaliana / ltr_retriever", of this github. The command below will format in .gff3 for future treatment.

    1 - To use LTR_retriever:
        installation_path/./ltr_finder Arabidopsis_thaliana.TAIR10.dna.toplevel.fa -w0 > output 
        installation_path/./LTR_retriever -threads 10 -genome Arabidopsis_thaliana.TAIR10.dna.toplevel.fa -infinder output

    2 - To format the output:
        - Make sure to be at athaliana folder
        
        //code
            cd ltrretriever
        grep -v '^#' Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.out.gff > formatItem.gff
        awk -F"\t" {'print $9"\t"$3'} formatItem.gff | sort | uniq -c | sort -k1rg > ltrfamilies.txt
        awk -F" " '{print $1"\t"$2"\t"$3}' ltrfamilies.txt > ltrfamily.txt
        perl ../../codestoformat/formatOutputRetriever.pl Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.out.gff ltrfamily.txt
        //code

        - A LTR_Retriever.gff3 file will be generated.

2 - The output of MGEScan non-ltr is sorted by folder, the TE class being respective, and inside it will contain the sequences that the methodology found, there are examples in "athaliana / non-ltr". Thus, in this structure we run a script from the "script" folder to properly format the output.

    1 - To use MGEScan non-ltr:
        mgescan nonltr ./athali --output=./athali/resultNonLTR

    2 - To format the output:
        - Make sure to be at athaliana folder

        //code
        cd resultNonLTR
        cd info
        cd full
        #generates the output MGEScan non-ltr into fasta files.
        ls -d */ | while read d
        do
            cd $d
            perl ../../../../../codestoformat/generatingFastaNonLTR.pl ${d////}.dna ${d////}
            cd ..
        done
        #generates MGEScan non-ltr a output in .gff3.  
        cd ..
        perl ../../../codestoformat/formatOutputNonLTR.pl nonltr.gff3 nonltr.fa
        //code

        - A NonLTR.gff3 file will be generated.

3 - With this RepeatMasker methodology, using any library. It will report some files to you, following this structure, we will use a script to format the output and structure the information we have from the output.
    
    1 - To use RepeatMasker:
        installation_path/RepeatMasker -lib RepbaseLibrary.fa -gff -cutoff 250 -nolow -div 60 Arabidopsis_thaliana.TAIR10.dna.toplevel.fa

    2 - To format the output:
        - Make sure to be at athaliana folder

        //code
        cd repeatmasker
        perl ../../codestoformat/formatOutputRepeatMaskerGFF.pl Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.out
        //code

        - A RepeatMasker.gff3 file will be generated.

4 - RepeatModeler is a strategy that identifies consensus sequences within the target genome. The result is a "library" that will be used later with the RepeatMasker methodology, there are examples in "athaliana / repeatmodeler". This step is divided into two parts.
    
    1 - To use RepeatModeler:
        perl installation_path/RepeatModeler/BuildDatabase -name Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
        perl installation_path/RepeatModeler/RepeatModeler -database Arabidopsis_thaliana -engine ncbi -pa 20
        installation_path/RepeatMasker/RepeatMasker -lib *-families.fa -gff -cutoff 250 -nolow -div 60 Arabidopsis_thaliana.TAIR10.dna.toplevel.fa

    2 - To format the output:
        - Make sure to be at athaliana folder

        //code
        cd repeatmodeler
        perl ../../codestoformat/formatOutputRepeatModelerGFF.pl Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.out
        //code

        - A RepeatModeler.gff3 file will be generated.

5 - RepeatScout is a methodology similar to RepeatModeler, the output steps are similar. A "library" is generated, which we then pass to the RepeatModeler for mapping the entire genome, there are examples in "athaliana / repeatscout".
    
    1 - To use RepeatScout:
        installation_path/build_lmer_table -sequence Arabidopsis_thaliana.TAIR10.dna.toplevel.fa -freq Arabidopsis_thaliana.freq
        installation_path/RepeatScout -sequence Arabidopsis_thaliana.TAIR10.dna.toplevel.fa -output Arabidopsis_thaliana.rs -freq Arabidopsis_thaliana.freq
        cat Arabidopsis_thaliana.rs | installation_path/filter-stage-1.prl > filtered.fasta
        installation_path/RepeatMasker -lib filtered.fasta Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
        cat filtered.fasta | installation_path/filter-stage-2.prl --cat Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.out > filtered2.fasta
        ## Using the library to run RepeatMasker:
        installation_path/RepeatMasker -pa 4 -s -lib filtered2.fasta -nolow -no_is -gff Arabidopsis_thaliana.TAIR10.dna.toplevel.fa

    2 - To format the output:
        - Make sure to be at athaliana folder

        - part 1
            //code
            cd repeatscout
            perl ../../codestoformat/formatOutputRepeatScoutGFF.pl Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.out
            //code

            - A RepeatScout.gff3 file will be generated.

        - part 2
            //code
            cat repeatscout/*.fasta > RepeatScout.fa
            awk '/^[>;]/ { if (seq) { print seq }; seq=""; print } /^[^>;]/ { seq = seq $0 } END { print seq }' RepeatScout.fa > RepeatScout_formated.fasta fold -w 60 RepeatScout_formated.fasta > uniqueRepeatScout.fa
            //code 

            - Here, you will need to run PASTEClassifier (Topic 8). It will generate a file "ProjectName.classif"

        - part 3
            - Some manipulation file will be required.
            //code
            sed 's/R=//g' repeatscout/RepeatScout.gff3 > repeatscout/RepeatScoutR.gff3
            sort -k3,3V repeatscout/RepeatScoutR.gff3 > repeatscout/RepeatScoutOrdered.gff3
            perl ../codestoformat/formatOutputUniqueScout.pl ProjectName.classif repeatscout/RepeatScoutOrdered.gff3
            //code

            - A RepeatScout.gff3 file will be generated.

6 - MITEHunter is a strategy that searches the genome and builds consensus only for TE of the MITE type. These results are given in "groups" that later are used for formatting script.

    1 - To use MITEHunter:
        perl installation_path/MITE_Hunter_manager.pl -i Arabidopsis_thaliana.TAIR10.dna.toplevel.fa -c 6 -n 6 -S 12345678

    2 - To format the output:
        - Make sure to be at athaliana folder

        //code
        cd mitehunter
        for filename in *.fa; do
            perl ../..//codestoformat/formatOutputMITE.pl ${filename}
        done
            //code

        - A MITE.gff3 file will be generated.

7 - HelitronScanner works in a similar way to MITEHunter, and it is also necessary to use a script to format it for future manipulation of these records.
    
    1 - To use HelitronScanner:
        java -jar installation_path/HelitronScanner/HelitronScanner.jar scanHead -lf installation_path/TrainingSet/head.lcvs -bs 5000000 -g Arabidopsis_thaliana.TAIR10.dna.toplevel.fa -th 6 -o installation_path/head.helitronscanner.out   
        java -jar installation_path/HelitronScanner/HelitronScanner.jar scanHead -lf installation_path/TrainingSet/head.lcvs -bs 5000000 -g Arabidopsis_thaliana.TAIR10.dna.toplevel.fa -th 6 --rc -o installation_path/head2.helitronscanner.out 
        java -jar installation_path/HelitronScanner/HelitronScanner.jar scanTail -lf installation_path/TrainingSet/tail.lcvs -bs 5000000 -g Arabidopsis_thaliana.TAIR10.dna.toplevel.fa -th 6 -o installation_path/tail.helitronscanner.out  
        java -jar installation_path/HelitronScanner/HelitronScanner.jar scanTail -lf installation_path/TrainingSet/tail.lcvs -bs 5000000 -g Arabidopsis_thaliana.TAIR10.dna.toplevel.fa -th 6 --rc -o installation_path/tail2.helitronscanner.out    
        java -jar installation_path/HelitronScanner/HelitronScanner.jar pairends -hs installation_path/head.helitronscanner.out -ts installation_path/tail.helitronscanner.out -o installation_path/pairends  
        java -jar installation_path/HelitronScanner/HelitronScanner.jar pairends -hs installation_path/head2.helitronscanner.out -ts installation_path/tail2.helitronscanner.out -o installation_path/pairends2   
        java -jar installation_path/HelitronScanner/HelitronScanner.jar draw -p installation_path/pairends -g Arabidopsis_thaliana.TAIR10.dna.toplevel.fa -o installation_path/output --pure --ext --flanking  
        java -jar installation_path/HelitronScanner/HelitronScanner.jar draw -p installation_path/pairends2 -g Arabidopsis_thaliana.TAIR10.dna.toplevel.fa -o installation_path/output_reverse --pure --ext --flanking

    2 - To format the output:
        - Make sure to be at athaliana folder

        //code
        cd helitronscanner
        perl ../../codestoformat/formatOutputHelitron.pl output.ext.hel.fa +
        perl ../../codestoformat/formatOutputHelitron.pl output_reverse.ext.hel.fa -
        //code

        - A Helitrons.gff3 file will be generated.

8 - With PASTEClassifier, we label the strings that are identified by RepeatScout, since it builds the strings by stretching smaller strings. Before passing this "library" through RepeatMasker, a set of scripts is used to format and obtain results accordingly.
    
    1 - To use PASTEClassifier:
        ./PASTEClassifier.py -i uniqueRepeatScout.fa -C PASTEClassifier.cfg >& PASTEC.log

    2 - To format the output:
        - A file "ProjectName.classif" will be generated and used at Topic 5, part 3.

- After all these processing and automated scripts you will need to unify all these notes in a single file. To do this use:
        - Make sure to be at athaliana folder

        //code
        cat LTR_Retriever.gff3 RepeatModeler.gff3 RepeatMasker.gff3 NonLTR.gff3 MITE.gff3 Helitrons.gff3 RepeatScout.gff3 > TEAnnotation.asd
        #### Remove some remaining TEs
        sed -e 's/\?//g' TEsannotation.asd > TEAnnotation.gff3
        sed -i '' "/SSR/d" TEAnnotation.gff3
        sed -i '' "/Satellite/d" TEAnnotation.gff3
        sed -i '' "/Simple_repeat/d" TEAnnotation.gff3
        sed -i '' "/Other\/Composite/d" TEAnnotation.gff3
        //code

- In this way, we obtain the total set of TEs, however they still contain annotation overlap and redundancy. To work around this problem, we developed a script that calculates the overlap and removes duplications without losing information (cpp.01). Partial overlays are treated in such a way that you do not lose part of the sequence or give preference to one or the other. Partial sequences are extracted in order to preserve the smallest (Start Sequence) and largest (End Sequence) geonumeric position of the overlap.
    - Make sure to be at athaliana folder

            //code 
            mv TEAnnotation.gff3 original_TEAnnotation.gff3
            sort -k1,1 -k4,4n original_TEAnnotation.gff3 > teste1.gff3
            bedtools merge -i teste1.gff3 -s -c 7,1 -o distinct,count > ts.bed
            awk -F"\t" '{print $1 "\t" "." "\t" "." "\t" $2+1 "\t" $3 "\t" "." "\t" $4 "\t" "." "\t" "." "\t" $5}' ts.bed > ts.gff3
            sed -e 's/SINE2/SINE/g' original_TEAnnotation.gff3 > teste1.gff3
            sed -e 's/|/\//g' teste1.gff3 > teste2.gff3
            sed -e 's/tRNA-L1/tRNA/g' teste2.gff3 > teste1.gff3
            sed -e 's/Ginger2-TDD/Ginger/g' teste1.gff3 > teste2.gff3
            sed -e 's/MULE-MuDR/MuLE-MuDR/g' teste2.gff3 > teste1.gff3
            sed -e 's/RTE-BovB/RTE/g' teste1.gff3 > teste2.gff3
            sed -e 's/noCat/Unknown/g' teste2.gff3 > teste1.gff3
            sed -e 's/SINE\/TRIM/TRIM/g' teste1.gff3 > teste2.gff3
            sed -e 's/Transposable/Unknown/g' teste2.gff3 > teste1.gff3
            sed -e 's/rRNA/SINE\/rRNA/g' teste1.gff3 > teste2.gff3
            sed -e 's/snRNA/SINE\/snRNA/g' teste2.gff3 > teste1.gff3
            bedtools intersect -a ts.gff3 -b teste1.gff3 -wa -wb -s > intersect.gff3
            perl ../codestoformat/formatOutputCoordenation.pl ts.gff3 intersect.gff3 1
            //code

    - Two files will be generated "TEAnnotationlFinal-1.gff3" and "TEAnnotationCompleto-1.gff3". Basically both have the same content.

- With all those steps you will be able to retrieve a complete TE annotation from any genome you want.
