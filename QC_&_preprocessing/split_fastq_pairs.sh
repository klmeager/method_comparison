#!/bin/bash 

#Split each fastq pair into 10,000,000 lines (2 500 000 reads)

fqpair=`echo $1 | cut -d ',' -f 1`
file=$(basename $fqpair)
#((NCPUS--)) #fastp optimal allowing 1 extra CPU overhead for 8 and 16 CPU runs but not for 4 CPU runs

outdir=./Fastq_split_pairs/
log_paired=./Fastq_split_pairs/${file}_paired.log

fq1=$(ls ${fqpair}_R1*.f*q.gz)
fq2=$(ls ${fqpair}_R2*.f*q.gz)


fastp -i ${fq1} \
	-I ${fq2} \
	-AGQL \
	-w $NCPUS \
	-S 10000000 \
	-d 0 \
	--out1 ${outdir}/${file}_R1.fastq.gz \
	--out2 ${outdir}/${file}_R2.fastq.gz 2>${log_paired}
