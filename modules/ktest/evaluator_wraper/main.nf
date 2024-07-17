include { SAMPLE_PREPARING     }     from './modules/ktest/sample_preparing/sample_preparing.nf'
include { IMPUTATION_EVALUATOR }     from './modules/Imputation_evaluator/imputation_evaluator.nf'
include { SEPERATE_COHORT      }     from './modules/Seperate_cohort/seperate_cohort.nf'

process COLLECT_SAMPLE_BY_POP{

    container "phinguyen2000/bcftools:77bc7f3"

    memory   { 5.GB  * task.attempt   }
    cpus     { 2     * task.attempt   }
    
    input:
    tuple val(key), val(sample_ids)

    output:
    tuple val(key), path("${key_string}_pop.txt")

    script:
    key_string = key.join("-")

    """
    for sample_id in `echo "${sample_ids.join(' ')}"`; do
        echo \$sample_id >> ${key_string}_pop.txt
    done
    """
}

process MERGE_VCF {
    tag "$array_type:$chr:$sub_pop"

    container "phinguyen2000/vcftools:2664f2f"

    memory   { 5.GB  * task.attempt   }
    cpus     { 2     * task.attempt   }

    input:
    tuple val(sample_ids), val(array_type), val(chr), path(vcf_files), path(tabix_files), val(sub_pop)

    output:
    tuple val(array_type), val(sub_pop), val(chr), path("${array_type}_${sub_pop}_chr${chr}_merged.vcf.{gz,gz.tbi}")

    """
    vcf-merge ${vcf_files.join(" ")}| bgzip > ${array_type}_${sub_pop}_chr${chr}_merged.vcf.gz
    tabix -p vcf ${array_type}_${sub_pop}_chr${chr}_merged.vcf.gz
    """
}


workflow {
    params.sample_sheet             = "/home/ktest2/project/PRS/PRS-140/PRS-191/run/aDat_code/data_sheet.csv"
    params.metadata                 = "/home/ktest2/project/PRS/PRS-132/PRS-203/data/2504_infos.csv"
    params.total_sample_list_file   = "/home/ktest2/project/PRS/PRS-132/PRS-203/data/prepare_true/2504_samples.txt"

    full_vcf_ch                = channel.fromPath("${params.vcf_full_sample_pattern}")
                                        .map{it -> [(it =~ /_chr([^\.]+)/)[0][1], it]}             // ([val(chr), path(full_vcf_file)])
                                        .dump(tag: 'full_vcf_ch')
    
    
    known_site_files           = channel.fromPath("${params.known_site_pattern}")
                                        .collect().map{[it]}                                        // ([[path(known_site_vcf), path(known_site_vcf_tbi)]])
                                        .dump(tag: 'known_site_files')

    meta_ch  = channel.fromPath(params.metadata)
                        .splitCsv(header: false, skip: 1, sep: '\t')
                        .map{[it[5], it[0]]}                                                        // ([val(sup_code), val(sample_id)])
                                                                        

    input_ch = meta_ch.map{[[it[0]], it[1]]}.groupTuple(by: 0)                                      // ([[val(sup_code)], [val(sample_id), ...]])

    COLLECT_SAMPLE_BY_POP(input_ch.dump(tag: "input_ch"))

    // Prepare sample by population
    SAMPLE_PREPARING(
        COLLECT_SAMPLE_BY_POP.out
                             .combine(channel.fromPath(params.total_sample_list_file)),    // ([[val(sup_code)], path(sub_pop), path(total_sample)])
        full_vcf_ch,
        known_site_files
    )

    // Seperate samples
    sample_sheet_ch   =  channel.fromPath(params.sample_sheet)
                                .splitCsv(header: false, skip: 1)                          // ([val(array_type), val(chr), path(impute_vcf_file)])

    array_type_ch     =  sample_sheet_ch.map{it[0]}.unique()
                                
    SEPERATE_COHORT(
        sample_sheet_ch.map{ [[it[0],it[1]], it[2]] }                                      // ([[val(array_type), val(chr)], path(impute_vcf_file)])
    )

    // Collect sample by superpopulation code
    collect_ch   =  SEPERATE_COHORT.out.indiv_vcf_ch                       // ([[val(array_type), val(chr)], val(sample_id), [path(individual_vcf_file), path(individual_vcf_file_tbi)]])
                                    .map{[it[1], it[0], it[2]]}            // ([val(sample_id), [val(array_type), val(chr)], [path(individual_vcf_file), path(individual_vcf_file_tbi)]])
                                    .combine(meta_ch, by: 0)               // ([val(sample_id), [val(array_type), val(chr)], [path(individual_vcf_file), path(individual_vcf_file_tbi)], val(sup_code)])
                                    .map{it.flatten()}                     // ([val(sample_id), val(array_type), val(chr), path(individual_vcf_file), path(individual_vcf_file_tbi), val(sup_code)])
                                    .groupTuple(by: [1,2,-1])              // ([[val(sample_id),...], val(array_type), val(chr), [path(individual_vcf_file),...], [path(individual_vcf_file_tbi),...], val(sup_code)])

    MERGE_VCF(collect_ch)

    // Evaluate

    true_ch    = SAMPLE_PREPARING.out.test_ch                              // ([val(sup_code), val(chr), [path(extract_vcf), path(extract_vcf_tbi)]])
                                 .map{ [it[1], it[0], it[2]] }             // ([val(chr), val(sup_code), [path(extract_vcf), path(extract_vcf_tbi)]])
                                 .combine(array_type_ch)                   // ([val(chr), val(sup_code), [path(extract_vcf), path(extract_vcf_tbi)], val(array_type)])
                                 .map{[it[0], [it[1], it[3]], it[2]]}      // ([val(chr), [val(sup_code), val(array_type)], [path(extract_vcf), path(extract_vcf_tbi)]])
                                 .dump(tag: 'true_ch')

    imputed_ch = SAMPLE_PREPARING.out.refs_ch                              // ([val(key), val(chr), [path(ref_vcf), path(ref_vcf_tbi)]])
                                 .map{ [it[1], it[0], it[2]] }             // ([val(chr), val(key), [path(ref_vcf), path(ref_vcf_tbi)]])
                                 .dump(tag: 'imputed_ch')
    
    imputed_ch = MERGE_VCF.out                                             // ([val(array_type), val(sup_code), val(chr), [path(impute_vcf), path(impute_tabix)]])
                          .map{ [it[2], [it[1], it[0]], it[3]] }           // ([val(chr), [val(sup_code), val(array_type)], [path(impute_vcf), path(impute_tabix)]])
    
    maf_ref    = channel.fromPath(params.maf_file_pattern)
                        .map{[(it =~ /(\d+)_maf/)[0][1], it]}              // ([val(chr), path(maf_file)])
                        .dump(tag: 'maf_ref')

    IMPUTATION_EVALUATOR(
        imputed_ch,
        true_ch,
        maf_ref
    )

}