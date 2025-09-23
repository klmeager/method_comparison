#!/bin/bash

fastq=`echo $1 | cut -d ',' -f 1`
outdir=`echo $1 | cut -d ',' -f 2`
log=`echo $1 | cut -d ',' -f 3`

fastqc --extract -o ${outdir} ${fastq} >> ${log} 2>&1

