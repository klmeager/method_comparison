#!/bin/bash

#Create input text file for parallel fast splitting

rm -f Inputs/split_fastq.inputs

ls ./Fastq_final/*.f*q.gz | sed 's/_R1.*\|_R2.*\|_R1_*\|_R2_*\|.R1.*\|.R2.*//' | uniq > Inputs/split_fastq.inputs

tasks=`wc -l < Inputs/split_fastq.inputs`
printf "Number of fastq pairs to split: ${tasks}\n"
