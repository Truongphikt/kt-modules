process FASTQC{
    tag "$rg_id"

    container "phinguyen2000/fastqc_v0.12.1:v0.1.0"
    memory { 30.GB * task.attempt }
    cpus   { 16 * task.attempt }


    input:
    tuple val(rg_id), val(library_id), path(fastq_path)


    """
    fastqc --threads 20 $fastq_path
    """
}