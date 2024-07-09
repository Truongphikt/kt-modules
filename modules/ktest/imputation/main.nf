include { IMPUTATION }                           from                 "$projectDir/imputation.nf"

workflow{
    split_vcf = Channel.fromPath(params.split_vcf)
                        .splitCsv(skip: 1, sep: '\t')                   // [val(chr), path(split_vcf), path(split_vcf_tbi)]
    
    imputation_reference = Channel.fromPath([
        "$params.project/PRS-54/PRS-95",
        "$params.database/Variant_Calling/hg38/gmap_b38",
        "$parmas.project/VariantCalling/test_pipeline/imputation/Results/refs"
    ])                                                                  // [path(mvcf), path(gmap), path(refs)]
    
    IMPUTATION(
        split_vcf,
        imputation_reference
    )

    // EMIT
    // IMPUTATION.out.imputation_dose_vcf                               // [val(chr), path("chr${chr}_imputation.dose.vcf.gz"]
}