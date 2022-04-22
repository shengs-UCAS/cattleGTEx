#!/bin/bash

module load r
trans_vcf="~/eQTL/trans"

 
wk_dir="Trans_eQTL_fit_GRM_mlma"


cd ${trans_orig}

tissue=$1
cd ${wk_dir}
mkdir ${tissue}
cd ${tissue}

plink --vcf ${trans_vcf}/${tissue}/${tissue}.filtered0.vcf --make-bed --double-id --chr-set 29 --out ${tissue}_GRM_input #${tissue}.filtered0.vcf is the vcf file used for trans-eQTL mapping
gcta64 --bfile ${tissue}_GRM_input --autosome-num 29 --make-grm --thread-num 10 --out ${tissue}_geno_grm

######################################################################
###run the trans-eQTL analysis
###Format the phenotype (gene expression) and the covariance.
rm *.tmp
Rscript trans_eQTL_mlm_mlma_adjust_cis_eQTL_format_phenotype.r ${tissue}
mkdir output_mlm_corrected



#################Only for Muscle sample: use 100 arrays to run#############################
#write a script to divide the gene list into 100 bins.
split -l 300 gene_list.txt gene_list --additional-suffix=.tmp

Num_batch=`ls gene_list*.tmp | wc -l`

sbatch --array=1-${Num_batch} trans_eQTL_mlm_mlma_adjust_cis_eQTL_mlma.sh ${tissue}



