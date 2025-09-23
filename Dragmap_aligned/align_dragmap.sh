#!/bin/bash

fastq=`echo $1 | cut -d ',' -f 1`
sample=`echo $1 | cut -d ',' -f 2`
seq_centre=`echo $1 | cut -d ',' -f 3`
library=`echo $1 | cut -d ',' -f 4`
platform=`echo $1 | cut -d ',' -f 5`
flowcell=`echo $1 | cut -d ',' -f 6`
lane=`echo $1 | cut -d ',' -f 7`
ref=`echo $1 | cut -d ',' -f 8`

fq1=$(ls ${fastq}*R1*fastq.gz)
fq2=$(ls ${fastq}*R2*fastq.gz)

prefix=$(basename ${fastq})
rgid=${flowcell}.${lane}_${sample}_${library}

mkdir -p /scratch/ki31/sheep/Dragmap/Align_split/${prefix}/ # private dir for sorting gives better I/O than jobfs or samtools tmp flag
mkdir -p /scratch/ki31/sheep/Dragmap/Align_split/Temp
temp=/scratch/ki31/sheep/Dragmap/Align_split/Temp
bam=/scratch/ki31/sheep/Dragmap/Align_split/${prefix}/${prefix}.namesort.bam 
err=./Dragmap_error_capture/${prefix}.err
log=./Dragmap_logs/${prefix}.log

rm -rf $bam $err $log


#---------------------------------------------------------------
# Align one read group with dragmap, write READ ID sorted BAM output with samtools

dragen-os \
	-r $ref \
	-1 $fq1 \
	-2 $fq2  \
	--RGID ${rgid} \
	--RGSM ${sample} \
	--num-threads ${NCPUS} \
	2> ${log} \
	| samtools sort \
	-@ 2 \
	-n \
	-O BAM \
	-T ${temp} \
	-o ${bam}  -


#---------------------------------------------------------------
# Reheader (optional, but recommended)  
# Added PU, PL, LB and CN (params absent from dragmap) 

header=${bam}.header
samtools view -H ${bam} > ${header}
old_rg_id=$(grep "@RG" ${header})
new_rg_id="@RG\tID:${flowcell}.${lane}_${sample}_${library}\tPL:${platform}\tPU:${flowcell}.${lane}\tSM:${sample}\tLB:${sample}_${library}\tCN:${seq_centre}"
sed -i "s/${old_rg_id}/${new_rg_id}/"  ${header}
samtools reheader -P ${header} ${bam} > ${bam}-reheader
mv ${bam}-reheader ${bam}
rm ${header}

# Check on the output:

if ! samtools quickcheck ${bam}
then 
        printf "Corrupted or missing BAM\n" > ${err}  
fi

#---------------------------------------------------------------
# Move BAM out of its private directory and tidy up 

mv ${bam} /scratch/ki31/sheep/Dragmap/Align_split/${prefix}.namesort.bam 
rmdir /scratch/ki31/sheep/Dragmap/Align_split/${prefix}

#---------------------------------------------------------------

