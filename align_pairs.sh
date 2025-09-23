#!/bin/bash

#align trimmed split pairs

fastq=`echo $1 | cut -d ',' -f 1`
sample=`echo $1 | cut -d ',' -f 2`
seq_centre=`echo $1 | cut -d ',' -f 3`
library=`echo $1 | cut -d ',' -f 4`
platform=`echo $1 | cut -d ',' -f 5`
flowcell=`echo $1 | cut -d ',' -f 6`
lane=`echo $1 | cut -d ',' -f 7`
ref=`echo $1 | cut -d ',' -f 8`


fq1=${fastq}_R1*fastq.gz
fq2=${fastq}_R2*fastq.gz


prefix=$(basename ${fastq})
 

#---------------------------------------------------------------
#Align pairs:
out=./Align_split/${prefix}_paired.nameSorted.bam 
err=./Align_split_error_capture/${prefix}_paired.err
log=./BWA_logs/${prefix}_paired.log

rm -rf $out $err $log

bwa-mem2 mem \
	-M \
	-t $NCPUS \
	-K 1000000\
	$ref \
	-R "@RG\tID:${flowcell}.${lane}_${sample}_${library}\tPL:${platform}\tPU:${flowcell}.${lane}\tSM:${sample}\tLB:${sample}_${library}\tCN:${seq_centre}" \
	$fq1 \
	$fq2 \
	2> ${log} \
	| samtools sort -n -@ ${NCPUS} -o ${out}  -

#Multiple checks on the output:
if ! samtools quickcheck ${out}
then 
        printf "Corrupted or missing BAM\n" > ${err}  
fi

test=$(tail -1 ${log} | awk '$0~/^\[main\] Real time/')
if [[ ! $test ]]
then 
	printf "Error in BWA log\n" >> ${err}
fi

if ! grep -q "M::mem_process_seqs" ${log}
then 
	printf "Error in BWA log\n" >> ${err}
fi
