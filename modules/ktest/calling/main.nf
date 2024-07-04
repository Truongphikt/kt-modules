#!/usr/bin/env nextflow
include { CALLING }             from            "./calling.nf"

workflow{
    //INPUT CHANEL
    from_mapping      = channel.fromPath("$params.from_mapping_tsv")
                               .splitCsv(skip: 1, sep: '\t')                                                        // ([val(key), val(rg_id), val(object), path(dedup_bam), path(dedup_bai)]) 

    calling_reference = channel.fromPath("${params.folder_ref}")
                                .combine(channel.of("${params.genome_name}"))
                                .combine(channel.fromPath("${params.human_knownsite_vcf}").collect().map{[it]})     // ([path(folder_ref), val(genome_ref_name), [human_knownsite_vcf, human_knownsite_vcf_tbi])
    //CALLING
    CALLING(
        from_mapping,
        calling_reference
    )

    //EMIT
    //CALLING.split_vcf                                                                                             // ([val(key), val(object), val(chr), [path(split_vcf), path(split_vcf_tbi)]])

}
