include { SPLIT_TEST }                 from      "./modules/split_test.nf"
include { SPLIT_REF }                  from      "./modules/split_ref.nf"

workflow SAMPLE_PREPARING {

    take:
    meta_ch                                         // ([val(key), path(sample_list_file), path(total_sample_list_file)])
    full_vcf_ch                                     // ([val(chr), path(full_vcf_file)])                                   
    known_site_files                                // ([[path(known_site_vcf), path(known_site_vcf_tbi)]])

    main:

    // Split test vcf
    if (params.ignore_split_test){
        split_test_in = Channel.empty()
    } else {
        split_test_in = full_vcf_ch.combine(meta_ch.map{[it[0], it[1]]})
                    .dump(tag: 'input_split_test1')                        
                    .combine(known_site_files)                               // ([val(chr), path(full_vcf_file), val(key), path(sample_list_file), [path(known_site_vcf), path(known_site_vcf_tbi)]])
                    .dump(tag: 'input_split_test')
    }
    
    SPLIT_TEST(split_test_in)
    
    // Split ref vcf
    if (params.ignore_split_ref){
        split_ref_in = Channel.empty()
    } else {
        split_ref_in = full_vcf_ch.combine(meta_ch)
                                   .combine(known_site_files)                   // ([val(chr), path(full_vcf_file), val(key), path(sample_list_file), path(total_sample_list_file), [path(known_site_vcf), path(known_site_vcf_tbi)]])
                                   .dump(tag: 'input_split_ref')
    }

    SPLIT_REF(split_ref_in)

    emit:
    test_ch           = SPLIT_TEST.out                                          // ([val(key), val(chr), [path(extract_vcf), path(extract_vcf_tbi)]])
    refs_ch           = SPLIT_REF.out                                           // ([val(key), val(chr), [path(ref_vcf), path(ref_vcf_tbi)]])

}