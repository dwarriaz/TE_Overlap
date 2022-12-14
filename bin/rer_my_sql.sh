#!/bin/bash
# wraps a MySQL query to generate the UCSC RMSK GTF required for tximport and further analyses
# tx ID naming matches reference fasta naming convention

## host: genome-mysql.cse.ucsc.edu
## -N = --skip-column-names
## -A = --no-auto-rehash
## -D = --database
## --batch = print as TSV, escape special characters

# awk:
## split the genoName column by '_' and store in object `a`
## print genoName column = if [ a[2] is empty ]; then print a[1]; else print a[2] .. print rest of columns as is
### this finds lines with chrX_IDv1_type naming and extracts the middle string
# needed to name the alt/patch/fix chromosomes according to gencode style


mysql --batch --user=genome --host=genome-mysql.cse.ucsc.edu -N -A -D hg38 -e \
	'select genoName,
		"hg38_rmsk",
		"exon",
		genoStart,
		genoEnd
		swScore,
		strand,
		".",
		concat("gene_id", " ", "\"", repName, "\"", ";", " ",
			"transcript_id", " ", "\"", repName,
			"_range=", genoName, ":", genoStart, "-", genoEnd,
			"_strand=", strand, "\"", ";")
		from rmsk' \
		| awk -F '\t' -v OFS='\t' '{split($1, a, /_/); print (a[2] == "") ? a[1] : a[2], $2, $3, $4, $5, $6, $7, $8, $9, $10}' | sed 's/v1/.1/; s/v2/.2/1'
