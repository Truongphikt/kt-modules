process SPLIT_CHR{
    tag "$key:$object:chr$chr"

    container "phinguyen2000/bcftools:v0.1.0"
    memory   { 20.GB * task.attempt }
    cpus     { 5 * task.attempt }

    input:
    tuple val(key), val(object), path(joint_genotyped), val(chr)

    output:
    tuple val(key), val(object), val(chr), path("${key_string}_${object}_chr${chr}_split.vcf.{gz,gz.tbi}"), emit: split_vcf

    script:
    key_string = key ? key.join("-") : key

    """
    bcftools view --regions "$chr" -O z -o "${key_string}_${object}_chr${chr}_split.vcf.gz" ${joint_genotyped[0]}
    bcftools index -t ${key_string}_${object}_chr${chr}_split.vcf.gz
    """
}