#!/bin/bash  
  
# Read the user input   
  
#declare -a gene_list

echo "Enter the gene name: "  
read gene_list  

declare -a gene_list

for gene in "${gene_list[@]}"
do 
    gene="\"$(echo $gene)\""

    ## This line above will simply add quotes to the gene name for query compatibility

    mysql --batch --user=genome --host=genome-mysql.cse.ucsc.edu -N -A -D hg38 -e \
    'select name,
        chrom,
        strand,
        txStart,
        txEnd,
        cdsStart,
        cdsEnd,
        exonCount,
        concat("\"",exonStarts, "\""),
        concat("\"",exonEnds, "\""),
        name2
        from ncbiRefSeq
        where name2= '$gene';' \
        | sed 's/\t/,/g' > test.csv
    
    start=$(head -1 test.csv | cut -d',' -f4)   
    stop=$(head -1 test.csv | cut -d',' -f5)
    chrom=$(head -1 test.csv | cut -d',')

    start=$(($start + 1500))
    stop=$(($stop + 500))

    range=$(echo \($start..$stop\))
    echo $range

    mysql --batch --user=genome --host=genome-mysql.cse.ucsc.edu -N -A -D hg38 -e \
    'select *
        from rmsk
        where genoStart between '$start' and '$stop';' \
        | sed 's/\t/,/g' > repeat.csv
    
    ##range notation must be in the format (lower..upper), do the math in bash

## for promoter 1,500 upstream and 3' 500 downstream
done



