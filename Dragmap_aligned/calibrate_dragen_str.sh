#! /bin/bash

sample=`echo $1 | cut -d ',' -f 1`

gatk CalibrateDragstrModel \
    -R /scratch/ki31/sheep/Reference/ARS-UI_Ramb_v2.0_genomic.fasta \
    -I /scratch/ki31/sheep/Dragmap/Dedup_sort/${sample}.merged.dedup.coordsorted.bam \
    -str /scratch/ki31/sheep/Reference/str_table.tsv \
    -O ./Dragmap/Calibrated_model/${sample}_dragstr_model.txt