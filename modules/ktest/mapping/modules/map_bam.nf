process MAP_BAM{
    tag "$object:$rg_id"

    container "phinguyen2000/mapping:v0.1.0"
    memory { 30.GB * task.attempt }
    cpus   { 8 * task.attempt }

    input:
    tuple val(object), val(rg_id), val(library_id), val(platform), val(machine), path(fastq_path), path(bwa_ref)

    output:
    tuple val(object), val(rg_id), val(library_id), path("${rg_id}_${library_id}.pe.sorted.bam"), emit: sorted
    """
    threads=20
    bwa mem -t \$threads\
            -R "@RG\\tID:${rg_id}\\tLB:${library_id}\\tPL:${platform}\\tPM:${machine}\\tSM:${rg_id}"\
            -M ${bwa_ref[0]} \
            $fastq_path | samtools sort -@\$threads -o ${rg_id}_${library_id}.pe.sorted.bam

    """
}