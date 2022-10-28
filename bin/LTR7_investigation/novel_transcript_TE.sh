#!/bin/bash  

while IFS=, read -r chrom rangeStart rangeEnd; do 

    chrom="'$chrom'"
    
    mysql --batch --user=genome --host=genome-mysql.cse.ucsc.edu -N -A -D hg38 -e \
    'select *
        from rmsk
        where genoName = '$chrom' and genoStart between '$rangeStart' and '$rangeEnd';'

done < <(cut -d',' -f1,2,3 query.csv) >> Novel_Transcript.tsv
