include { FASTQC }              from        "./modules/fastqc.nf"
include { CAT_FILE }            from        "./modules/cat_file.nf"
include { MAP_BAM }             from        "./modules/map_bam.nf"
include { MARKDUPLICATES }      from        "./modules/markduplicates.nf"
include { BAM_INDEX }           from        "./modules/bam_index.nf"

workflow MAPPING{
    take:
    input_channel                                                                      // [rg_id, sample_name, library_id, lane, platform, machine, orient, object, path]
    reference_channel                                                                  // [bwa_ref]

    main:

    // Cat fastq file
    input_channel.map{ [it[7],it[0],it[2],it[4],it[5],it[6],it[-1]] }                  // [object, rg_id, library_id, platform, machine, orient, path]
                    .groupTuple(by: [0,1,2,3,4,5], sort: true)
                    .branch{
                        cat: it[-1].size() > 1                                         // [object, rg_id, library_id, platform, machine, orient, [path1, path2]]
                        non_cat: true                     
                            return it.flatten()                                        // [object, rg_id, library_id, platform, machine, orient, path]
                    }
                    .set{cat_filter}

    
    CAT_FILE(
        cat_filter.cat                                       
    )

    // Combine raw input
    raw_input = cat_filter.non_cat
                           .concat(CAT_FILE.out)                                        // [object, rg_id, library_id, platform, machine, orient, path]

    // Fastqc
    FASTQC(
        raw_input.map{
            [it[1], it[2], it[-1]]
        }                                                                               // [val(rg_id), val(library_id), path(fastq_path)]
    )


    MAP_BAM(
        raw_input.groupTuple(by: [0,1,2,3,4], sort:true)                                // [object, rg_id, library_id, platform, machine, orient, path]
                    .map{
                        it[0..4] + [it[-1]]                                             // [object, rg_id, library_id, platform, machine, [path1, path2]]
                    }.combine(reference_channel)                                               // [object, rg_id, library_id, platform, machine, [path1, path2], bwa_ref]
                                                                         
                                                                                        
    )

    MARKDUPLICATES{
        MAP_BAM.out.sorted                                                              // [val(object), val(rg_id), val(library_id), path("${rg_id}_${library_id}.pe.sorted.bam")]
    }

    BAM_INDEX{
        MARKDUPLICATES.out.dedup_bam                                                    // [val(object), val(rg_id), val(library_id), path("${rg_id}_${library_id}.dedup.bam")]
    }

    emit:
    from_mapping   = MARKDUPLICATES.out.dedup_bam
                                    .combine(
                                        BAM_INDEX.out.dedup_bai, by: [0,1,2]
                                    )                                                   //  [val(object), val(rg_id), val(library_id), path(dedup_bam), path(dedup_bai)] 

}