#! /bin/bash

# Create input file for fastqc_run_parallel.pbs

fastq=./Fastq
outdir=./fastQC/
logdir=./fastQC/


inputs=./Inputs/fastqc.inputs
rm -rf ${inputs}

mkdir -p ${outdir} PBS_logs


fastq=$(ls ./Fastq/*.f*q.gz)
fastq=($fastq)


for fastq in ${fastq[@]}
do
	prefix=$(basename $fastq | sed 's/.gz$//')
	log=${logdir}/${prefix}.log
	printf "${fastq},${outdir},${log}\n" >> ${inputs}
done

printf "`wc -l < ${inputs}` fastQC task input lines writen to ${inputs}\n"
