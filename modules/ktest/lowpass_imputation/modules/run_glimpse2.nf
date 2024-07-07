process RUN_GLIMPSE2{
    tag "$object:$rg_id:chr$chr"
    container "phinguyen2000/glimpse:v2.0.0-1"

    input:
    tuple val(chr), path(chunks_txt), path(split), val(object), val(rg_id), path(bamfile), path(baifile)

    output:
    tuple val(chr), val(object), val(rg_id), path("GLIMPSE_impute"), emit: impute_result

    """
    mkdir GLIMPSE_impute

    REF=$split/${chr}
    BAM=$bamfile

    while IFS="" read -r LINE || [ -n "\$LINE" ]; 
    do   
        printf -v ID "%02d" \$(echo \$LINE | cut -d" " -f1)
        IRG=\$(echo \$LINE | cut -d" " -f3)
        ORG=\$(echo \$LINE | cut -d" " -f4)
        CHR=\$(echo \${LINE} | cut -d" " -f2)
        REGS=\$(echo \${IRG} | cut -d":" -f 2 | cut -d"-" -f1)
        REGE=\$(echo \${IRG} | cut -d":" -f 2 | cut -d"-" -f2)
        OUT=GLIMPSE_impute/${rg_id}
        GLIMPSE2_phase \
                    --bam-file \${BAM} \
                    --reference \${REF}_\${CHR}_\${REGS}_\${REGE}.bin \
                    --output \${OUT}_\${CHR}_\${REGS}_\${REGE}.bcf
    done < $chunks_txt
    """
}