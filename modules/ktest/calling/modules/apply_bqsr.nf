process APPLY_BQSR{

    tag "$key:$object:$sample_id"

    container "phinguyen2000/gatk_tabix:v0.1.0"
    memory   { 20.GB * task.attempt }
    cpus     { 5 * task.attempt }

    input:
    tuple val(key), val(object), val(sample_id), path(dedup_bam), path(dedup_bai), path(recal_data_table), path(folder_ref), val(genome_name)


    output:
    tuple val(key), val(object), val(sample_id), path("${key_string}_${object}_${sample_id}.recal.bam"), emit: recal_bam

    script:
    key_string = key ? key.join("-") : key

    """
    gatk  ApplyBQSR \
            -R "$folder_ref/$genome_name" \
            -I $dedup_bam \
            -bqsr $recal_data_table\
            -O "${key_string}_${object}_${sample_id}.recal.bam"
    
    """

}