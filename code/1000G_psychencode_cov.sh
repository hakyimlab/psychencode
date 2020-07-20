#!/bin/bash
#PBS -N covariances_job
#PBS -S /bin/bash
#PBS -l walltime=06:00:00
#PBS -l mem=4gb
#PBS -l nodes=1:ppn=1
#PBS -o /scratch/t.med.scmi/covariances_job.log
#PBS -e /scratch/t.med.scmi/covariances_job.err



module load gcc/6.2.0
module load python/3.5.3

python3 /home/t.med.scmi/MetaXcan/software/M01_covariances_correlations.py \
--weight_db /gpfs/data/im-lab/nas40t2/sabrina/psychencode/psychencode.db \
--input_folder /scratch/t.med.scmi/1000G_hg37_dosage \
--delimiter $'\t' \
--covariance_output /gpfs/data/im-lab/nas40t2/sabrina/psychencode/psychencode.txt.gz
