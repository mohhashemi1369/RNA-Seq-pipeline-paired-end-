#!/bin/bash
set -euo pipefail
mkdir pairedproject
wget -P ~/pairedproject ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR031/SRR031714/SRR031714_1.fastq.gz
wget -P ~/pairedproject ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR031/SRR031714/SRR031714_2.fastq.gz
fastqc ~/pairedproject/SRR031714_1.fastq.gz ~/pairedproject/SRR031714_2.fastq.gz 
java -jar ~/Trimmomatic-0.40/trimmomatic-0.40.jar PE \
     ~/pairedproject/SRR031714_1.fastq.gz ~/pairedproject/SRR031714_2.fastq.gz \
     ~/pairedproject/SRR031714_1.TRIMMED.PAIRED.fastq.gz ~/pairedproject/SRR031714_1.TRIMMED.UNPAIRED.fastq.gz \
     ~/pairedproject/SRR031714_2.TRIMMED.PAIRED.fastq.gz ~/pairedproject/SRR031714_2.TRIMMED.UNPAIRED.fastq.gz \
    TRAILING:15 SLIDINGWINDOW:4:25 
fastqc ~/pairedproject/SRR031714_1.TRIMMED.PAIRED.fastq.gz ~/pairedproject/SRR031714_2.TRIMMED.PAIRED.fastq.gz
wget -P ~/pairedproject  https://genome-idx.s3.amazonaws.com/hisat/bdgp6_tran.tar.gz 
tar -xvf ~/pairedproject/bdgp6_tran.tar.gz -C ~/pairedproject
hisat2 -q -x ~/pairedproject/bdgp6_tran/genome_tran \
    -1 ~/pairedproject/SRR031714_1.TRIMMED.PAIRED.fastq.gz -2 ~/pairedproject/SRR031714_2.TRIMMED.PAIRED.fastq.gz \
    -S ~/pairedproject/drosophila-OUTPUT.sam --rns-strandness RF
samtools view -b ~/pairedproject/drosophila-OUTPUT.sam > ~/pairedproject/drosophila-OUTPUT.bam 
samtools sort ~/pairedproject/drosophila-OUTPUT.bam -o ~/pairedproject/drosophila-OUTPUT.SORTED.bam 
samtools index ~/pairedproject/drosophila-OUTPUT.SORTED.bam

