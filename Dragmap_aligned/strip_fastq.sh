#! /bin/bash

fastq=`echo $1 | cut -d ',' -f 1`
out=`echo $1 | cut -d ',' -f 2`

zcat ${fastq} | awk '{if (NR % 4 == 1) sub(/\/[12]$/, "", $0); print}' | pigz > ${out}
