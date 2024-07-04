process BASE_RECALIBRATOR{
    tag "$key:$object:$rg_id"

    container "phinguyen2000/gatk_tabix:v0.1.0"
    memory   { 20.GB * task.attempt }
    cpus     { 5 * task.attempt }

    input:
    tuple val(key), val(object), 
          val(rg_id), path(dedup_bam), 
          path(dedup_bai), path(joint_genotyped_draft_vcf), 
          path(folder_ref), val(genome_name),
          path(human_knownsite_vcf)
    output:
    tuple val(key), val(object), val(rg_id), path("${key_string}_${rg_id}.recal_data.table"), emit: recal_data_table

    script:
    if (joint_genotyped_draft_vcf.getName() == 'null'){
        known_site = "${human_knownsite_vcf[0]}"
    }else{
        known_site = joint_genotyped_draft_vcf[0]
    }
    key_string = key ? key.join("-") : key

    """
    gatk BaseRecalibrator \
        -I $dedup_bam \
        -R "$folder_ref/$genome_name" \
        --known-sites $known_site \
        -O ${key_string}_${rg_id}.recal_data.table
    """
}