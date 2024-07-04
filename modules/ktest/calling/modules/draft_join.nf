process DRAFT_JOIN{
    tag "$key:$object: #sample::${num_vcf_file}"

    container  "phinguyen2000/gatk_tabix:v0.1.0"
    memory   { 20.GB * task.attempt }
    cpus     { 5 * task.attempt }
    
    input:
    tuple val(key), val(object), val(rg_ids), path(raw_variants_vcf), path(folder_ref), val(genome_name)

    output:
    tuple val(key), val(object), path("${key_string}_joint_genotyped.draft.vcf.{gz,gz.tbi}"), emit: joint_genotyped_draft

    script:
    variant_option = ""
    for (file in raw_variants_vcf){
        variant_option += "--variant " + file.getName() + " "
    }
    num_vcf_file = rg_ids.size()
    key_string = key ? key.join("-") : key

    """
    gatk IndexFeatureFile \
        -I "$raw_variants_vcf"
       
    gatk CombineGVCFs \
        -R "$folder_ref/$genome_name" \
        $variant_option \
        -O ${key_string}_cohort.draft.vcf.gz

    gatk GenotypeGVCFs \
        -R "$folder_ref/$genome_name" \
        -V ${key_string}_cohort.draft.vcf.gz \
        -O ${key_string}_joint_genotyped.draft.vcf.gz
    """
}