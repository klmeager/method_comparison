#!/bin/bash


config=../Inputs/samples.config
script=./Scripts/deepvariant.pbs

# Collect sample IDs into array format
samples=($(awk 'NR>1 {print $1}' $config ))

# Submit each sample, providing sample ID to script with -v 
for sample in ${samples[@]}
do
	echo Submitting sample $sample
	
	job_name=${sample}-deepvariant
	o_log=./PBS_logs/${sample}_deepvariant_dragmap.o
	e_log=./PBS_logs/${sample}_deepvariant_dragmap.e
	
	qsub -N ${job_name} -o ${o_log} -e ${e_log}  -v sample="${sample}" ${script}
	
	sleep 2
done
