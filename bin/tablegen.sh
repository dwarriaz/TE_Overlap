#!/bin/bash

mysql --batch --user=genome --host=genome-mysql.cse.ucsc.edu -N -A -D hg38 -e \
	'select repName
		from rmsk' \
		| sort | uniq -dc 

