include { DRAFT_CALLING }                       from        "./modules/draft_calling.nf"
include { DRAFT_JOIN }                          from        "./modules/draft_join.nf"
include { BASE_RECALIBRATOR }                   from        "./modules/base_recalibrator.nf"
include { APPLY_BQSR }                          from        "./modules/apply_bqsr.nf"
include { CALL_VARIANTS }                       from        "./modules/call_variants.nf"
include { JOINING }                             from        "./modules/joining.nf"
include { SPLIT_CHR }                           from        "./modules/split_chr.nf"

workflow CALLING{
    take:
    from_mapping                                                                                    // ([val(key), val(object), val(rg_id), path(dedup_bam), path(dedup_bai)])
    calling_reference                                                                               // ([path(folder_ref), val(genome_ref_name), [human_knownsite_vcf, human_knownsite_vcf_tbi]])

    main:                                                                                 
    // Split branch human object and others
    from_mapping.branch{
                    human: it[1] == 'human'
                        return it + [["/dev/null"]]                                                 // ([val(key), val(object), val(rg_id), path(dedup_bam), path(dedup_bai), [path(null_file)]])
                    others: true                                                                    // ([val(key), val(object), val(rg_id), path(dedup_bam), path(dedup_bai)])
                }.set{ human_selector }
    
    //===============IF NOT BEING HUMAN OBJECT==================
    DRAFT_CALLING{
        human_selector.others                                                                       // ([val(key), val(object), val(rg_id), path(dedup_bam), path(dedup_bai)])
                    .combine(calling_reference.map{it[0,1]})                                        // ([val(key), val(object), val(rg_id), path(dedup_bam), path(dedup_bai), path(folder_ref), val(genome_name)])                                                  
    }

    DRAFT_JOIN{
        DRAFT_CALLING.out.raw_variants_vcf                                                          // ([val(key), val(object), val(rg_id), path(raw_variants_vcf_gz)])
                    .groupTuple(by: [0,1])                                                          // ([val(key), val(object), [val(rg_id), ...], [path(raw_variants_vcf_gz), ...]])  
                    .combine(calling_reference.map{it[0,1]})                                        // ([val(key), val(object), [val(rg_id), ...], [path(raw_variants_vcf_gz),...], path(folder_ref), val(genome_name)]) 
    }                                                                                                


    non_human_pkg = from_mapping.combine(
                    DRAFT_JOIN.out.joint_genotyped_draft,
                    by: [0,1]                                                                       // ([val(key), val(object), val(rg_id), path(dedup.bam), path(dedup.bai), [path(cohort_draft_vcf), path(cohort_draft_vcf_idx)]])
                )                                                                         
    //==========================================================
    BASE_RECALIBRATOR{
        human_selector.human
                    .concat(non_human_pkg)                                                          // ([val(key), val(object), val(rg_id), path(dedup.bam), path(dedup.bai), [path(cohort_draft_vcf), path(cohort_draft_vcf_idx)]])
                    .combine(calling_reference.map{it[0..2]})                                       // ([val(key), val(object), val(rg_id), path(dedup.bam), path(dedup.bai), [path(cohort_draft_vcf), path(cohort_draft_vcf_idx)], path(folder_ref), val(genome_name), path(human_knownsite_vcf)])
                                                                                                    
    }

    APPLY_BQSR(
        from_mapping.combine(
                    BASE_RECALIBRATOR.out.recal_data_table, by:[0,1,2]                              // ([val(key), val(object), val(rg_id), path(dedup.bam), path(dedup.bai), path(recal_data_table)])
                    ).combine(calling_reference.map{it[0,1]})                                       // ([val(key), val(object), val(rg_id), path(dedup.bam), path(dedup.bai), path(recal_data_table), path(folder_ref), val(genome_name)])
    )

    CALL_VARIANTS(
        APPLY_BQSR.out.recal_bam                                                                    // ([val(key), val(object), val(rg_id), path(recal_bam)])
                    .combine(calling_reference.map{it[0,1]})                                        // ([val(key), val(object), val(rg_id), path(recal_bam), path(folder_ref), val(genome_name)])          
    )

    JOINING(
        CALL_VARIANTS.out.variants_recal_vcf                                                        // ([val(key), val(object), val(rg_id), [path(variants_recal_vcf_gz), path(variants_recal_vcf_gz_tbi)]])
                        .map{it.flatten()}                                                          // ([val(key), val(object), val(rg_id), path(variants_recal_vcf_gz), path(variants_recal_vcf_gz_tbi)])
                        .groupTuple(by: [0,1])                                                      // ([val(key), val(object), [rg_id1, rg_id2, ...], [path(variants_recal_vcf_gz),...)], [path(variants_recal_vcf_gz_tbi), ...]])
                        .combine(calling_reference.map{it[0,1]})                                    // ([val(key), val(object), [rg_id1, rg_id2, ...], [path(variants_recal_vcf_gz),...)], [path(variants_recal_vcf_gz_tbi), ...], path(folder_ref), val(genome_name)])             
                    
    )

    // Split by chromosomes 
    SPLIT_CHR(
        JOINING.out.cohort_vcf                                                                      // ([val(key), val(object), [path(joint_genotyped_vcf_gz), path(joint_genotyped_vcf_gz_tbi)]])
                    .combine(Channel.of(1..22).map{it.toString()})                                  // ([val(key), val(object), [path(joint_genotyped_vcf_gz), path(joint_genotyped_vcf_gz_tbi)], val(chr)])
    )

    emit:
    split_vcf = SPLIT_CHR.out.split_vcf                                                             // ([val(key), val(object), val(chr), [path(split_vcf), path(split_vcf_tbi)]])
}