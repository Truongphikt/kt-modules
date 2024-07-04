#!/usr/bin/env nextflow
include { MAPPING }          from            "./mapping.nf"

workflow{
    //INPUT CHANEL
    input_channel = Channel.fromPath("$params.samplesheet")
                            .splitCsv(skip: 1, sep: '\t')        
                            // [rg_id, sample_name, library_id, lane, platform, machine, orient, object, path]
    
    params.ref_pattern = "$params.ref_folder/*.{fa,fa.amb,fa.ann,fa.bwt,fa.fai,fa.pac,fa.sa}"

    reference_channel = Channel.fromPath(params.ref_pattern).collect().map{[it]}              // [bwa_ref]
    
    //MAPPING
    MAPPING(
        input_channel,
        reference_channel
    )

    //EMIT
    //MAPPING.out.from_mapping              // [val(object), val(rg_id), val(library_id), path(dedup_bam), path(dedup_bai)] 

}
