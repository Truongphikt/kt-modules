process EXTRACT_SITE{
    tag "chr$chr"

    container "phinguyen2000/bcftools:v0.1.0"

    input:
    tuple val(chr), path(panel_vcf), path(panel_vcf_tbi)

    output:
    tuple val(chr), path("${chr}_nogen.vcf.gz"), path("${chr}_nogen.vcf.gz.csi"), emit: nogen_vcf

    """
    bcftools view -G -Oz -o ${chr}_nogen.vcf.gz $panel_vcf
    bcftools index -f ${chr}_nogen.vcf.gz
    """
}