#!/bin/bash  
  
# Read the user input   
gene="\"LTR7\""

mysql --batch --user=genome --host=genome-mysql.cse.ucsc.edu -N -A -D hg38 -e \
'select *
    from rmsk
    where repName='$gene';' \
    > Data_for_Sree.tsv




while read field1 field2; do 

    field1="\"$(echo $field1)\""

    mysql --batch --user=genome --host=genome-mysql.cse.ucsc.edu -N -A -D hg38 -e \
    'select name2
        from ncbiRefSeq
        where chrom = '$field1' and txStart between '$field2' and '$(($field2+1000))';'

done < <(cut -d$'\t' -f6,7 Data_for_Sree.tsv) 
