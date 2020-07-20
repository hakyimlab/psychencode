#!/bin/bash
#PBS -N job_1000g_conversion
#PBS -S /bin/bash
#PBS -l walltime=72:00:00
#PBS -l nodes=1:ppn=1
#PBS -l mem=32gb
#PBS -o logs_hg37_to_pred/${PBS_JOBNAME}.o${PBS_JOBID}.log
#PBS -e logs_hg37_to_pred/${PBS_JOBNAME}.e${PBS_JOBID}.err
#PBS -t 1-22
########################################################################################################################
#CRI submission dandruff
cd $PBS_O_WORKDIR

module load gcc/4.9.4
module load bcftools/1.4.0
module load python/3.6.0
########################################################################################################################


filter_and_convert ()
{
#echo -ne "varID\t" | gzip > $3
#bcftools view $1 -S $2 --force-samples -Ou |  bcftools query -l | tr '\n' '\t' | sed 's/\t$/\n/' | gzip >> $3

#The first python inline script will check if a variant is blacklisted
#[ -f $3 ] && rm $3
NOW=$(date +%Y-%m-%d/%H:%M:%S)
echo "Starting at $NOW"
bcftools +fill-tags $1 -Ou | bcftools query -f '%CHROM\t%ID\t%POS\t%REF\t%ALT\t%MAF[\t%GT]\n' | \
awk '
{
for (i = 1; i <=6; i ++) {
    printf("%s",$i)
    if (i < 6) {
        printf("\t")
    }

}
for (i = 7; i <= NF; i++) {
    if ( substr($i, 0, 1) == ".") {
        printf("\tNA")
    } else if ($i ~ "[0-9]|[0-9]") {
        n = split($i, array, "|")
        printf("\t%d",(array[1]>0)+(array[2]>0))
    } else {
        #printf("%s",$i)
        printf("Unexpected: %s",$i)
        exit 1
    }
}
printf("\n")
}
' | gzip > $2



NOW=$(date +%Y-%m-%d/%H:%M:%S)
echo "Ending at $NOW"
}
#PBS_ARRAYID=22
INPUT=/scratch/t.med.scmi/1000G_hg37/ALL.chr${PBS_ARRAYID}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz
OUTPUT=/scratch/t.med.scmi/1000G_hg37_dosage/chr${PBS_ARRAYID}.txt.gz
[ -d /scratch/t.med.scmi/1000G_hg37_dosage ] || mkdir -p /scratch/t.med.scmi/1000G_hg37_dosage

filter_and_convert $INPUT $OUTPUT

