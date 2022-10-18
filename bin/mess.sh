#!/bin/bash  
  
# Read the user input   
  
#declare -a gene_list

echo "Enter the gene name: "  
read gene_list  

declare -a gene_list

for gene in "${gene_list[@]}"
do 
    gene_config=$gene
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
        from wgEncodeGencodeBasicV41
        where name2= '$gene';' \
        | sed 's/\t/,/g' > ${gene_config}.csv
    
    start=$(head -1 ${gene_config}.csv | cut -d',' -f4)   
    stop=$(head -1 ${gene_config}.csv | cut -d',' -f5)
    chrom=$(head -1 ${gene_config}.csv | cut -d',' -f2)

    chrom="\"$(echo $chrom)\""

    start=$(($start + 1500))
    stop=$(($stop + 500))

    range=$(echo \($start..$stop\))
    echo $range

    mysql --batch --user=genome --host=genome-mysql.cse.ucsc.edu -N -A -D hg38 -e \
    'select *
        from rmsk
        where genoName = '$chrom' and genoStart between '$start' and '$stop';' \
        | sed 's/\t/,/g' > ${gene_config}_repeats.csv
    
    
done

python3 overwriTE.py -Gene ${gene_config}.csv -Repeats ${gene_config}_repeats.csv



