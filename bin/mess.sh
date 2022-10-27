#!/bin/bash  
  
# Read the user input   
  
#declare -a gene_list

echo "Enter the gene name: "  
read -a gene_list  

declare -a gene_list

mkdir output

echo 'isoform,gene_name,insertion_name,chrom,start,stop,instrand,genstrand,classification,overlap_count' > output/TE_Overlap.csv

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
        | sed 's/\t/,/g' > output/${gene_config}.csv
    
    start=$(head -1 output/${gene_config}.csv | cut -d',' -f4)   
    stop=$(head -1 output/${gene_config}.csv | cut -d',' -f5)
    chrom=$(head -1 output/${gene_config}.csv | cut -d',' -f2)
    genoStrand=$(head -1 output/${gene_config}.csv | cut -d',' -f3)
    genoStrand_config="'$genoStrand'"
    chrom_config="\"$(echo $chrom)\""



    mysql --batch --user=genome --host=genome-mysql.cse.ucsc.edu -N -A -D hg38 -e \
    'select *
        from rmsk
        where genoName = '$chrom_config' and genoStart between '$start' and '$stop';' \
        | sed 's/\t/,/g' > output/${gene_config}_repeats.csv
    
    python3 overwriTE.py -Gene output/${gene_config}.csv -Repeats output/${gene_config}_repeats.csv > checkingout.txt

    if [[ $genoStrand_config == "'+'" ]]; then
        mysql --batch --user=genome --host=genome-mysql.cse.ucsc.edu -N -A -D hg38 -e \
        'select *
            from rmsk
            where genoName = '$chrom_config' and genoStart between '$(($start-1500))' and '$start';' \
            > output/temp.tsv 
    
    
        while read repStart repEnd repStrand repName; do 
            
            printf "%s_Promoter_Region,%s,%s_range=%s:%s-%s_strand=+,%s,%s,%s,%s,%s,promoter,%s" $gene_config $gene_config $repName $chrom $repStart $repEnd $chrom $repStart $repEnd $repStrand $genoStrand $(($repEnd-$repStart))
        done < <(cut -d$'\t' -f7,8,10,11 output/temp.tsv) >> output/TE_Overlap.csv
        rm output/temp.tsv
    fi
    
    if [[ $genoStrand_config == "'-'" ]]; then
        mysql --batch --user=genome --host=genome-mysql.cse.ucsc.edu -N -A -D hg38 -e \
        'select *
            from rmsk
            where genoName = '$chrom_config' and genoStart between '$stop' and '$(($stop+1500))';' \
            > output/temp.tsv 
    
    
        while read repStart repEnd repStrand repName; do 
            
            printf "%s_Promoter_Region,%s,%s_range=%s:%s-%s_strand=-,%s,%s,%s,%s,%s,promoter,%s\n" $gene_config $gene_config $repName $chrom $repStart $repEnd $chrom $repStart $repEnd $repStrand $genoStrand $(($repEnd-$repStart))
        done < <(cut -d$'\t' -f7,8,10,11 output/temp.tsv) >> output/TE_Overlap.csv
        rm output/temp.tsv
    fi

done

grep -v 0,1,2,3,4,5,6,7,8,9 output/TE_Overlap.csv > output/trim_TE_Overlap.csv






