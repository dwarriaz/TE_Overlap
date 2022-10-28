#!/bin/bash

bed_file=$1
base=$2

echo "base is $base"
echo "bed file is $bed_file"

python3 bed_compatible_overwriTE.py $bed_file $base

./novel_transcript_TE.sh $base 

