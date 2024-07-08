process JOINING{
    tag "$key:$object:#sample::${num_vcf_file}"

    container "phinguyen2000/gatk_tabix:v0.1.0"
    memory   { 20.GB * task.attempt }
    cpus     { 5 * task.attempt }

    input:
    tuple val(key), val(object), val(rg_ids), path(variants_vcfs), path(variants_vcf_tbis), path(folder_ref), val(genome_name)


    output:
    tuple val(key), val(object), path("${key_string}_${object}_joint_genotyped.vcf.{gz,gz.tbi}"), emit: cohort_vcf

    script:
    variant_option = ""
    for (file in variants_vcfs){
        variant_option += "--variant " + file.getName() + " "
    }

    num_vcf_file = rg_ids.size()
    key_string = key ? key.join("-") : key

    """
    gatk CombineGVCFs \
        -R "$folder_ref/$genome_name" \
        $variant_option \
        -O ${key_string}_${object}_cohort.vcf.gz
    gatk GenotypeGVCFs \
        -R "$folder_ref/$genome_name" \
        -V ${key_string}_${object}_cohort.vcf.gz \
        -O ${key_string}_${object}_joint_genotyped.vcf.gz
    """
}