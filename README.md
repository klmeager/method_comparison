# Counting Sheep (Variants): A Tale of Bioinformatic Pipelines

This repository contains workflows, scripts, and benchmarking results from a methods comparison project evaluating short variant and structural variant calling pipelines for **ovine whole genome sequencing (WGS)** data. The project is part of my PhD research on **molecular characterisation of inherited diseases in livestock**, conducted at the University of Sydney and Elizabeth Macarthur Agricultural Institute (NSW DPIRD).

---

## Project Overview

Over the past few decades, the cost of next-generation sequencing has fallen dramatically, making whole genome sequencing (WGS) increasingly accessible for research. This has enabled larger numbers of affected animals to be sequenced, creating exciting opportunities for genetic discovery. However, each genome produces hundreds of gigabytes of data, driving up the demand for computational resources and technical expertise to process and analyse it efficiently.

In parallel, a wide range of new bioinformatic tools and workflows have emerged. In human genetics, these can be benchmarked against highly validated “gold standard” datasets such as the Platinum Genomes, Genome in a Bottle, and the 1000 Genomes Project. These references make it straightforward to assess accuracy and decide on best-practice pipelines. In livestock and other non-model species, no such resources exist, making it far harder to determine which pipelines provide the most accurate, efficient, and reproducible results.

Pipeline choice has real consequences. Tools differ not only in their sensitivity and accuracy but also in the technical expertise required to run them and the computational resources they consume. These trade-offs become especially important when local clusters cannot handle the scale of modern datasets (e.g. Artemis requiring upgrades), forcing researchers to seek allocations on national high-performance computing infrastructure such as **NCI Gadi**.

This project directly compared six variant calling pipelines for ovine WGS. By running them side-by-side on the same cohort of animals, we assessed how pipeline choice influences variant discovery, runtime, reproducibility, and scalability, with the goal of providing practical recommendations for non-model animal genomics research.

Specifically, we evaluated **six workflows** across a cohort of 25 sheep genomes, comparing them on:

- **Accuracy and validity** of variant calls  
- **Runtime and computational efficiency** on the [NCI Gadi supercomputer](https://nci.org.au)  
- **Ease of use and reproducibility**  
- **Scalability for large cohorts**

---

## Workflows Evaluated

We compared six variant calling pipelines on 25 ovine whole genome sequences:

1. **BWA-MEM2 → GATK**  
   - Standard short-read alignment with BWA-MEM2  
   - Variant calling with GATK HaplotypeCaller (interval-based)  
   - Serves as a baseline “best practices” workflow  

2. **BWA-MEM2 → GATK + Bootstrapping**  
   - Same as (1), but incorporates a bootstrapped “known variants” resource  
   - Enables Base Quality Score Recalibration (BQSR) in the absence of truth sets  
   - More computationally intensive  

3. **DragMap → GATK**  
   - DragMap alignment (hardware-accelerated mapping)  
   - Variant calling with GATK HaplotypeCaller  
   - Compared for runtime vs sensitivity trade-offs relative to BWA-MEM2  

4. **DragMap → Dragen**  
   - DragMap alignment  
   - Variant calling with Illumina Dragen software  
   - Evaluated for accuracy and efficiency compared to other pipelines  

5. **BWA-MEM2 → DeepVariant**  
   - BWA-MEM2 alignment  
   - Variant calling with Google DeepVariant (CNN-based)  
   - Tested for reproducibility and sensitivity against GATK  

6. **DragMap → DeepVariant**  
   - DragMap alignment  
   - Variant calling with DeepVariant   

---

## HPC Usage

All workflows were run on **NCI Gadi**, leveraging:  
- Scatter–gather parallelism (fastq chunking, interval chunking)  
- Normal and hugemem queues for memory-intensive steps  
- Scalable job submissions across 1–10 nodes  

Resource usage was carefully tracked (CPU hours, SU, memory, walltime). 

## Key Findings (preliminary)

- All six pipelines successfully produced VCFs across 25 ovine WGS samples.  
- **BWA-MEM2 + DeepVariant + GLNexus** was the most **efficient and scalable workflow**, balancing accuracy with compute cost.  
- GATK HaplotypeCaller (interval-based calling with GenomicDBImport) produced high-quality calls but was **far more resource-intensive** on Gadi.  
- Pipeline choice significantly influenced **variant counts and overlap**:  
  - Some variants were unique to certain callers.  
  - DeepVariant consistently identified variants missed by GATK.  
  - DragMap alignment offered faster runtimes but fewer total variants compared to BWA-MEM2.  
- Structural variant pipelines (Manta, Smoove, Tiddit + Survivor) were feasible but required careful merging and interpretation.  

### Practical Outcomes
- Identified a **preferred WGS pipeline for ovine studies**:  
  `BWA-MEM2 → DeepVariant → GLNexus`  
- Provided a baseline for benchmarking non-model species where no “truth set” exists.  
- Established a reproducible HPC workflow for future livestock datasets.

