include { LOWPASS_IMPUTATION }              from            "./lowpass_imputation.nf"


workflow{
    pannels = Channel.fromPath(params.panels)
                    .splitCsv(skip: 1, sep: '\t')                                                         // [val(chr), path(ref_vcf), path(ref_vcf_tbi)]
    
    bamfiles = Channel.fromPath(params.bamfiles)                                                          // [val(object), val(sample_id), path(bam_file), path(bai_file)]
                    .splitCsv(skip: 1, sep: '\t') 
    
    reference_channel = Channel.fromPath(
                    "${params.database}/Variant_Calling/hg38/gmap_b38")                                   // [gmap_b38]
    
    params_ch = Channel.of([
        params.chr_format // Numeric(#) or Alphanumeric(chr#)                                             
    ])                                                                                                    // [val(chr_format)]  

    LOWPASS_IMPUTATION(
        pannels,
        bamfiles,
        reference_channel,
        params_ch
    )
}