process CAT_FILE{
    tag "$rg_id"

    container "ubuntu:rolling"
    memory { 20.GB * task.attempt }
    cpus   { 4 * task.attempt }

    input:
    tuple val(object),
            val(rg_id), 
            val(library_id), 
            val(platform), 
            val(machine), 
            val(orient), 
            path(fastq_files)

    output:
    tuple val(object),
          val(rg_id), 
          val(library_id), 
          val(platform), 
          val(machine), 
          path("${library_id}_${rg_id}_cat_${orient}.fastq.gz") 

    """
    cat ${fastq_files} > ${library_id}_${rg_id}_cat_${orient}.fastq.gz

    for filename in `ls *.gz`; do 
        read_num=\$(zcat \$filename | echo \$((`wc -l`/4)))
        echo "\$filename has: \$read_num reads"
    done
    """
}