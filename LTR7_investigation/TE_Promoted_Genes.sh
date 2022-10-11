#!/bin/bash  

## This script will take a Transposable Element name and reurn a set of genes that positionally indicate that 
## the given Transposable Element has some influence in the gene list's promoter region.

## Usage: MYSQL must be previously installed, Command Line: ./TE_Promoted_Genes.sh > {User Defined output file}

echo "Enter the Transposable Element name: " 

read gene

gene_name=$gene

gene="\"$gene\""


# This first MYSQL query will pull of the genomic coordinates associated with the Transposable Element of interest.
# It will pull the positions from the UCSC Human Genome Browser track, Repeat Masker or rmsk in the table schema

mysql --batch --user=genome --host=genome-mysql.cse.ucsc.edu -N -A -D hg38 -e \
'select *
    from rmsk
    where repName='$gene';' \
    > ${gene_name}_Genomic_Positions.tsv



# These while loops will find the names of genes associated with the poisitons found in the Genomic_Positions.tsv 

# Positive Stranded Genes
while read chrom repStart repEnd; do 

    chrom_config=$chrom

    chrom="\"$(echo $chrom)\""
    

    name=$(mysql --batch --user=genome --host=genome-mysql.cse.ucsc.edu -N -A -D hg38 -e \
    'select name,
        name2
        from ncbiRefSeq
        where chrom = '$chrom' and txStart between '$repStart' and '$(($repStart+($repEnd - $repStart)+1500))';')

    if [[ ! -z $name ]]; then
    #    echo $chrom_config $repStart $repEnd $name $gene_name
        echo $name
    fi


done < <(cut -d$'\t' -f6,7,8 ${gene}_Genomic_Positions.tsv) >> ${gene_name}_Dependent_Gene_List.bed

# Negative Stranded Genes

strand="'-'"

while read chrom repStart repEnd; do 

    chrom_config=$chrom
    chrom="\"$(echo $chrom)\""

    #echo $chrom , $repStart, $repEnd
    #echo $strand

    mysql --batch --user=genome --host=genome-mysql.cse.ucsc.edu -N -A -D hg38 -e \
    'select name,
        name2
        from ncbiRefSeq
        where chrom = '$chrom' and strand = '$strand' and txEnd between '$(($repStart-1500))' and '$((($repEnd-$repStart)+$repStart))';'
        | name=(cut -d$'\t' -f1 ${gene_name}_Genomic_Positions.tsv) 

    if [[ -z $name ]]; then
        echo $chrom_config $repStart $repEnd $name $gene_name
    fi
    

done < <(cut -d$'\t' -f6,7,8 ${gene}_Genomic_Positions.tsv) >> ${gene_name}_Dependent_Gene_List.bed






