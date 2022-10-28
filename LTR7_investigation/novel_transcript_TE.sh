#!/bin/bash  

while IFS=, read -r chrom rangeStart rangeEnd; do 

chrom="\"$(echo $chrom)\""

mysql --batch --user=genome --host=genome-mysql.cse.ucsc.edu -N -A -D hg38 -e \
	'select *
        from rmsk
        where genoName = '$chrom' and genoStart between '$rangeStart' and '$rangeEnd';'

done < <(cat $1.csv |  tr ',' '\t' | cut -f1,2,3) #>> $1.output.tsv
