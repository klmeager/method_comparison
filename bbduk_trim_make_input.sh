#!/bin/bash

#make input for trimming
#split fastq
#apply different adapters to genewiz vs KCCG data
#all end in _R1.fastq.gz or _R2.fastq.gz

gw_fa=./MGI_adapters_plus_universal.fa
custom_adapters=./Inputs/Azenta_adapters.fa

config=./Inputs/samples.config

inputs=./Inputs/bbduk_trim.inputs
rm -f $inputs

outdir=./Fastq_lanesplit_trimmed
mkdir -p ${outdir} 


awk 'NR>1' ${config} | while read LINE
do
	ID=$(echo $LINE | awk '{print $1}')
	centre=$(echo $LINE | awk '{print $3}')
	
	if [[ $centre == 'MGI' ]]
	then
		adapters=$gw_fa
	else
		adapters=$custom_adapters
	fi
	
	fastq_pairs=( $(ls -1 ./Fastq_laneSplit/*${ID}*_R1.fastq.gz | sed 's/_R1\.fastq\.gz//') )
	
	for (( i = 0; i < ${#fastq_pairs[@]}; i++ ))
	do

		printf "${fastq_pairs[$i]},${adapters},${outdir}\n" >> $inputs
	
	done
done
