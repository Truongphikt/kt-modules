process SPLIT_REF{
    tag "${key}:chr${chr}"
    container "phinguyen2000/bcftools:77bc7f3"

    memory   { 20.GB * task.attempt   }
    cpus     { 5     * task.attempt   }

    input:
    tuple val(chr), path(full_vcf_file), val(key), path(list_sample_file), path(total_sample_file), path(known_site_files)

    output:
    tuple val(key), val(chr), path("${key_string}_chr${chr}_ref.vcf.{gz,gz.tbi}"), emit: ref_vcf

    script:
    key_string = key.join("-")

    """
    ## ref uncorelated samples
    bcftools view ${full_vcf_file} \
                -S ${total_sample_file} |\
                bcftools view -S ^${list_sample_file} |\
                sed 's/chr//g' |\
                bcftools annotate --remove INFO |\
                bcftools +fill-tags |\
                bgzip > ${key_string}_chr${chr}_temp.vcf.gz
                
    ## annotate dbSNP ID
    bcftools index -t ${key_string}_chr${chr}_temp.vcf.gz
    bcftools annotate --annotations ${known_site_files[0]} \
                      --columns ID ${key_string}_chr${chr}_temp.vcf.gz | bgzip \
                      > ${key_string}_chr${chr}_ref.vcf.gz
                    
    ## clean tem vcf
    rm -f ${key_string}_chr${chr}_temp.vcf.gz
    rm -f ${key_string}_chr${chr}_temp.vcf.gz.tbi

    ## Index vcf file
    bcftools index -t ${key_string}_chr${chr}_ref.vcf.gz
    """
}