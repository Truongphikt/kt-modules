process SPLIT_BAM{
    tag "$object:$rg_id:chr$chr"
    container "biocontainers/samtools:v1.7.0_cv4"

    input:
    tuple val(chr), 
            val(object), 
            val(rg_id), 
            path(dedup_bam, stageAs: "dedup.bam"), 
            path(dedup_bai, stageAs: "dedup.bai"), 
            val(region)

    output:
    tuple val(chr), val(object), val(rg_id), path("${rg_id}.bam"), path("${rg_id}.bam.bai"), emit: split_bam

    """
    samtools view -bo ${rg_id}.bam $dedup_bam $region
    samtools index ${rg_id}.bam
    """
}