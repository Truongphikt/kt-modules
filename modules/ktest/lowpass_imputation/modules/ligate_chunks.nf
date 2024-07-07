process LIGATE_CHUNKS{
    tag "$object:$rg_id:chr$chr"
    container "phinguyen2000/glimpse:v2.0.0-1"

    input:
    tuple val(chr), val(object), val(rg_id), path(impute_result), val(region)

    output:
    tuple val(chr), val(object), val(rg_id), path("${rg_id}_${chr}_ligated.bcf"), path("${rg_id}_${chr}_ligated.bcf.csi"), emit: ligate_result
    
    """

    LST=list.chr${chr}.txt
    ls -1v GLIMPSE_impute/${rg_id}_${region}_*.bcf > \${LST}

    OUT=${rg_id}_${chr}_ligated.bcf
    GLIMPSE2_ligate --input \${LST} --output \$OUT
    """
}