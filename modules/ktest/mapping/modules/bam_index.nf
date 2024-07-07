process BAM_INDEX{
    tag "$rg_id"

    container "quay.io/biocontainers/picard:3.1.1--hdfd78af_0"
    memory { 30.GB * task.attempt }
    cpus   { 5 * task.attempt }

    input:
    tuple val(object), val(rg_id), val(library_id), path(dedup_bam)

    output:
    tuple val(object), val(rg_id), val(library_id), path("${rg_id}_${library_id}.dedup.bai"), emit: dedup_bai

    """
    picard  BuildBamIndex INPUT=$dedup_bam\
    """
}