process CHUNKING{
    tag "chr$chr"

    container "phinguyen2000/glimpse:v2.0.0-2"

    input:
    tuple val(chr), path(nogen_vcf), path(nogen_vcf_csi), path(gmap_b38), val(region)

    output:
    tuple val(chr), path("chunks.${chr}.txt"), emit: chunks_txt

    """
    window_mb=4
    loop_count=1

    window_step=2
    loop_max=10

    while true; do

        if  [[ \$loop_count -gt \$loop_max ]]; then
            echo "Reach over \${loop_max}th."
            exit 1
        fi

        GLIMPSE2_chunk            	--window-mb \$window_mb            \
                                    --sequential \
                                    --input $nogen_vcf \
                                    --region ${region} \
                                    --output chunks.${chr}.txt \
                                    --map $gmap_b38/chr${chr}.b38.gmap.gz

        evaluate=`overfinder chunks.${chr}.txt`

        if  [[ \$evaluate == "Fine" ]]; then
            echo "In \${loop_count}th Loop: Fine"
            exit 0
        elif [[ \$evaluate == "Overlapping" ]]; then
            echo "In \${loop_count}th Loop: Overlapping"
            window_mb=\$(( window_mb + window_step ))
            loop_count=\$(( loop_count + 1 ))
        fi
    done
    """
}