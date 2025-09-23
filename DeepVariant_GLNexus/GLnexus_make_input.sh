#! /bin/bash

# Create input file for GLNexus joint genotyping

gvcf_dir=./gVCF
inputs=./Inputs/GLnexus.inputs

rm -rf ${inputs}

mkdir GLnexus

find ./gVCF -type f -name "*.g.vcf.gz" > ${inputs}