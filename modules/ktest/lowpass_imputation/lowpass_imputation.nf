#!/usr/bin/env nextflow

include { EXTRACT_SITE }                             from                            "./modules/extract_site.nf"
include { CHUNKING }                                 from                            "./modules/chunking.nf"
include { CONVERT_PANEL }                            from                            "./modules/convert_panel.nf"
include { SPLIT_BAM }                                from                            "./modules/split_bam.nf"
include { RUN_GLIMPSE2 }                             from                            "./modules/run_glimpse2.nf"
include { LIGATE_CHUNKS }                            from                            "./modules/ligate_chunks.nf"
include { MERGE_SAMPLE }                             from                            "./modules/merge_sample.nf"

workflow LOWPASS_IMPUTATION{
    take:
    panel_vcf                                                        // [val(chr), path(ref_vcf), path(ref_vcf_tbi)]
    bamfiles                                                         // [val(object), val(rg_id), path(dedup_bam), path(dedup_bai)]  
    reference_channel                                                // [path(gmap_b38)]
    params_ch                                                        // [val(chr_format)]

    main:
    
    panel_vcf.map{ [(it[0] =~ /\d+/)[0]] }
        .combine(params_ch.map{it[0]})                               // [val(chr), val(chr_format)]
        .map{ [it[0], chooseRegion(it[1], it[0])] }                    
        .set { region_param }                                        // [val(chr), val(region)]


    EXTRACT_SITE(
        panel_vcf.map{ [(it[0] =~ /\d+/)[0]] + it[1..-1]}            // [val(chr), path(panel_vcf), path(panel_vcf_tbi)]
    )

    CHUNKING(
        EXTRACT_SITE.out.nogen_vcf                                   // [val(chr), path(nogen_vcf), path(nogen_vcf_csi)]
                    .combine(
                        reference_channel                            // [val(chr), path(nogen_vcf), path(nogen_vcf_csi), path(gmap_b38)]
                    ).combine(
                        region_param, by: 0
                    )                                                // [val(chr), path(nogen_vcf), path(nogen_vcf_csi), path(gmap_b38), val(region)]
    )
    CONVERT_PANEL(
        panel_vcf.map{ [(it[0] =~ /\d+/)[0]] + it[1..-1]}
                .combine(
                    CHUNKING.out.chunks_txt,
                    by: 0                                                    // [val(chr), path(ref_vcf), path(ref_vcf_tbi), path(chunks_txt)]
                ).combine(
                    reference_channel                                        // [val(chr), path(ref_vcf), path(ref_vcf_tbi), path(chunks_txt), path(gmap_b38)]
                )
    )
    
    SPLIT_BAM(
        Channel.of(1..22)                                            // [1, 2, 3, ..., 22]
                .map{ it.toString() }                                // ['1', '2', '3', ..., '22']
                .combine(
                    bamfiles                                         // [val(object), val(rg_id), path(dedup_bam), path(dedup_bai)] 
                ).combine(
                    region_param, by: 0
                )                                                    // [val(chr), val(object), val(rg_id), path(dedup_bam), path(dedup_bai), val(region)]
    )

    RUN_GLIMPSE2(
        CHUNKING.out.chunks_txt                                      // [val(chr), path(chunks_txt)]
                .combine(
                    CONVERT_PANEL.out.split, by:0                    // [val(chr), path(chunks_txt), path(split)]
                ).combine(
                    SPLIT_BAM.out.split_bam, by:0                    // [val(chr), path(chunks_txt), path(split), val(object), val(rg_id), path(bamfile), path(baifile)]
                )                                                  
    )
    
    LIGATE_CHUNKS(
        RUN_GLIMPSE2.out.impute_result                               // [val(chr), val(object), val(rg_id), path(impute_result)]
                        .combine(
                            region_param, by: 0
                        )                                            // [val(chr), val(object), val(rg_id), path(impute_result), val(region)]
    )

    MERGE_SAMPLE(
        LIGATE_CHUNKS.out.ligate_result                              // [val(chr), val(object), val(sample_id), path(ligated_bcf), path(ligated_bcf_csi)]
                    .groupTuple(by: [0,1])                           // [val(chr), val(object), [val(sample_id1), val(sample_id2), ...], [path(ligated_bcf1), path(ligated_bcf2), ...], [path(ligated_bcf_csi1), path(ligated_bcf_csi2), ...]]
    )


}

String chooseRegion(String chr_format, String chr){
    region = ""
    if (chr_format == "Numeric"){
        region = chr
    }else if(chr_format == "Alphanumeric"){
        region = "chr" + chr
    }else{
        error "Unknown chromosome format."
    }

    return region
}