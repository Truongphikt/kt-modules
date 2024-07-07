process MERGE_SAMPLE{
    tag "$object:chr$chr"
    container "phinguyen2000/gatk_tabix_bcftools"

    input:
    tuple val(chr), val(object), val(sample_ids), path(ligated_bcf_files), path(ligated_bcf_csi_files)

    output:
    tuple val(chr), val(object), path("${chr}_merged_glimpse.vcf.gz"), path("${chr}_merged_glimpse.vcf.gz.tbi"), emit: merged_glimpse
    
    """
    mkdir vcf
    for input_file in `ls *.bcf`; do 
        name=`basename \$input_file .bcf`
        bcftools convert -Oz -o vcf/\${name}.vcf.gz \$input_file
        tabix -p vcf vcf/\${name}.vcf.gz
    done

    bcftools merge vcf/*vcf.gz \
            -Oz -o ${chr}_merged_glimpse.vcf.gz
    
    tabix -p vcf ${chr}_merged_glimpse.vcf.gz
    """
}