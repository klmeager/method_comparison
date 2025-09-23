#!/bin/bash

#Trim the split fastq to remove adapter sequence identified on FastQC

prefix=`echo $1 | cut -d ',' -f 1`
adapters=`echo $1 | cut -d ',' -f 2`
outdir=`echo $1 | cut -d ',' -f 3`

fq1=$(ls ${prefix}*R1*f*gz)
fq2=$(ls ${prefix}*R2*f*gz)

basename=$(basename $prefix) 

bbduk.sh \
	in=${fq1} \
	in2=${fq2} \
	out1=${outdir}/${basename}_R1.paired.bbduk_trimmed.fastq.gz \
	out2=${outdir}/${basename}_R2.paired.bbduk_trimmed.fastq.gz \
	ref=${adapters} \
	ktrim=r k=23 mink=11 hdist=1 tpe tbo
