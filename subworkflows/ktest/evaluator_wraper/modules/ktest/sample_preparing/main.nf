include { SAMPLE_PREPARING }             from         "./sample_preparing.nf" 

workflow {
    meta_ch                    = channel.fromPath("${params.samplesheet}")
                                        .splitCsv( header: false, sep: "\t", skip: 1 )             // ([val(key), path(sample_list_file), path(total_sample_list_file)])
                                        .dump(tag: 'meta_ch')

    full_vcf_ch                = channel.fromPath("${params.vcf_full_sample_pattern}")
                                        .map{it -> [(it =~ /_chr([^\.]+)/)[0][1], it]}             // ([val(chr), path(full_vcf_file)])
                                        .dump(tag: 'full_vcf_ch')
    
    
    known_site_files           = channel.fromPath("${params.known_site_pattern}")
                                        .collect().map{[it]}                                        // ([[path(known_site_vcf), path(known_site_vcf_tbi)]])
                                        .dump(tag: 'known_site_files')
    
    SAMPLE_PREPARING(
        meta_ch,
        full_vcf_ch,
        known_site_files
    )
                     
}