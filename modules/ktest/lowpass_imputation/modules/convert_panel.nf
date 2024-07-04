process CONVERT_PANEL{
    tag "chr$chr"

    container "phinguyen2000/glimpse:v2.0.0-1"

    input:
    tuple val(chr), path(ref_vcf), path(ref_vcf_tbi), path(chunks_txt), path(gmap_b38)

    output:
    tuple val(chr), path("split"), emit: split

    """
    mkdir split

    while IFS="" read -r LINE || [ -n "\$LINE" ];
    do
    printf -v ID "%02d" \$(echo \$LINE | cut -d" " -f1)
    IRG=\$(echo \$LINE | cut -d" " -f3)
    ORG=\$(echo \$LINE | cut -d" " -f4)

    GLIMPSE2_split_reference --reference $ref_vcf \
                            --map $gmap_b38/chr${chr}.b38.gmap.gz \
                            --input-region \${IRG} \
                            --output-region \${ORG} \
                            --output split/${chr}
    done < $chunks_txt
    """
}