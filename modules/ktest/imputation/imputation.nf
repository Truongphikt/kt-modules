process PHASING{
    tag "Chr $chr"

    container "phinguyen2000/shapeit4:v0.1.0"
    memory  40.GB
    cpus 5

    input:
    tuple val(chr), path(split_vcf), path(split_vcf_tbi), path(gmap), path(refs)

    output:
    tuple val(chr), path("chr${chr}_phasing.vcf.gz"), emit: phasing_vcf

    """
    shapeit4 --input $split_vcf \
            --map $gmap/chr${chr}.b38.gmap.gz \
            --reference $refs/chr${chr}_ref.vcf.gz \
            --region ${chr} \
            --thread 20 \
            --output chr${chr}_phasing.vcf.gz
    """
}

process IMPUTE{
    tag "Chr $chr"

    container "phinguyen2000/minimac4:v1.0.3"
    memory '40 GB'
    cpus 20

    input:
    tuple val(chr), path(phasing_vcf), path(mvcf)

    output:
    tuple val(chr), path("chr${chr}_imputation.dose.vcf.gz"),    emit: imputation_dose_vcf


    """
    minimac4 --refHaps $mvcf/chr${chr}_reference.m3vcf.gz \
            --ChunkLengthMb 200 \
            --ChunkOverlapMb 20 \
            --haps $phasing_vcf \
            --prefix "chr${chr}_imputation" \
            --ignoreDuplicates \
            --cpus 20 \
            --vcfBuffer 1100
    """
}

workflow IMPUTATION{
    take:
    split_vcf                                                             // [val(chr), path(split_vcf), path(split_vcf_tbi)]
    imputation_reference                                                  // [path(mvcf), path(gmap), path(refs)]

    main:
    // Phasing haplotype
    PHASING(
        split_vcf.combine(
            imputation_reference.map{it[1..2]}
        )                                                                 // [val(chr), path(split_vcf), path(split_vcf_tbi), path(gmap), path(refs)]
    )

    // Imputation missing snps
    IMPUTE(
        PHASING.out.phasing_vcf.combine(
                                    imputation_reference.map{it[0]}
                                )                                         // [val(chr), path(phasing_vcf), path(mvcf)]
    )
}