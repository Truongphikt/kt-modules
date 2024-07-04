process CALL_VARIANTS{
    tag "$key:$object:$rg_id"

    container "phinguyen2000/gatk_tabix:v0.1.0"
    memory   { 20.GB * task.attempt }
    cpus     { 5 * task.attempt }
    input:
    tuple val(key), val(object), val(rg_id), path(recal_bam), path(folder_ref), val(genome_name)


    output:
    tuple val(key), val(object), val(rg_id), path("${key_string}_${object}_${rg_id}.variants.recal.vcf.{gz,gz.tbi}"), emit: variants_recal_vcf

    script:
    key_string = key ? key.join("-") : key

    """
    gatk  --java-options "-Xmx4g" HaplotypeCaller \
           -R "$folder_ref/$genome_name" \
           -I "$recal_bam" \
           -O "${key_string}_${object}_${rg_id}.variants.recal.vcf.gz"\
           -ERC GVCF
    """
}