process MARKDUPLICATES{
    tag "$object:$rg_id"

    container "phinguyen2000/gatk_tabix:v0.1.0"
    memory { 30.GB * task.attempt }
    cpus   { 10 * task.attempt }

    input:
    tuple val(object), val(rg_id), val(library_id), path(pe_sorted_bam)

    output:
    tuple val(object), val(rg_id), val(library_id), path("${rg_id}_${library_id}.dedup.bam"), emit: dedup_bam

    """
    gatk MarkDuplicates \
                -I $pe_sorted_bam \
                -O ${rg_id}_${library_id}.dedup.bam \
                -M ${rg_id}_${library_id}.dedup.metrics.txt
    """
}