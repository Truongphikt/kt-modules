# Lowpass Imputation module
## 1. Input channels

<table class="tg" style="undefined;table-layout: fixed; width: 721px">
<colgroup>
<col style="width: 142px">
<col style="width: 579px">
<col style="width: 579px">
</colgroup>
<thead>
  <tr>
    <th class="tg-0pky"><span style="font-weight:bold">Channel</span></th>
    <th class="tg-0pky"><span style="font-weight:bold">Value</span></th>
    <th class="tg-0pky"><span style="font-weight:bold">Example</span></th>
  </tr>
</thead>
<tbody>
  <tr>
    <td class="tg-lboi">Pannel channel</td>
    <td class="tg-lboi">
      - <span style="font-style:italic">chr</span>: Order number of chromosome (1&rarr;22) <br>
      - <span style="font-style:italic">ref_vcf</span>: Path of reference VCF file <br>
      - <span style="font-style:italic">ref_vcf_tbi</span>: Path of *.tbi Index file of reference file
    </td>
    <td>[val(chr), path(ref_vcf), path(ref_vcf_tbi)]<br/><br/><img src="https://github.com/KTest-VN/lowpass_imputation/assets/141545014/2e7cb090-f255-4595-9d2f-a86dd859fae6" alt="Pannel channel"></td>
  </tr>
  <tr>
    <td class="tg-0lax">Bamfiles channel</td>
    <td class="tg-0lax">
      - <span style="font-style:italic">object</span>: Object of sequences (human, shrimp, fish, etc.) <br>
      - <span style="font-style:italic">rg_id</span>: Group ID / Sample ID <br>
      - <span style="font-style:italic">bam_file</span>: Path of bam file, after duplicate. <br>
      - <span style="font-style:italic">bai_file</span>: Path of *.bai file, index file of bam file.
    </td>
    <td>[val(object), val(rg_id), path(bam_file), path(bai_file)]<br/><br/><img src="https://github.com/KTest-VN/lowpass_imputation/assets/141545014/d94166ca-97d9-4aae-aae7-bce381d9fcb1" alt="Reference channel">
</td>
  </tr>
  <tr>
    <td class="tg-0lax">Reference channel</td>
    <td class="tg-0lax">
      - <span style="font-style:italic">gmap_b38</span>: <a href="https://ktest-dattn.atlassian.net/browse/PRS-72">gmap b38 phasing reference</a> for GLIMPSE chunking<br>
    </td>
    <td>[gmap_b38]<br/><br/><img src="https://github.com/KTest-VN/lowpass_imputation/assets/141545014/9eb4c85a-798a-4713-a8ea-e0a7ee5b8312" alt="Reference channel"></td>
  </tr>
</tbody>
</table>


## 2. Output channels (VOID)


## 3. Processes

<table class="tg" style="undefined;table-layout: fixed; width: 721px">
	<colgroup>
		<col style="width: 142px" />
		<col style="width: 579px" />
		<col style="width: 579px" />
    <col style="width: 579px" />
	</colgroup>
	<thead>
		<tr>
			<th class="tg-0pky"><span style="font-weight: 400;">Process</span></th>
			<th class="tg-0pky"><span style="font-weight: 400;">Input Channel</span></th>
			<th class="tg-0pky"><span style="font-weight: 400;">Output Channel</span></th>
      			<th class="tg-0pky"><span style="font-weight: 400;">Description</span></th>
			<th class="tg-0pky"><span style="font-weight: 400;">Tool</span></th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td class="tg-lboi">EXTRACT_SITE</td>
			<td class="tg-lboi"><p>[val(chr), path(panel_vcf), path(panel_vcf_tbi)]</p></td>
			<td><p>[val(chr), path(nogen_vcf), path(nogen_vcf_csi)]</p></td>
      			<td>Extract position information of SNPs in reference VCF file</td>
			<td>bcftools v1.19 (using htslib 1.19)</td>
		</tr>
		<tr>
			<td class="tg-0lax">CHUNKING</td>
			<td class="tg-0lax">[val(chr), path(nogen_vcf), path(nogen_vcf_csi), path(gmap_b38), val(region)]</td>
			<td>[val(chr), path(chunks_txt)]</td>
      			<td>Chunking reference sequences into multiple sequences, which are used to impute </td>
			<td>GLIMPSE2_chunk v2.0.0</td>
		</tr>
		<tr>
			<td class="tg-0lax">CONVERT_PANEL</td>
			<td class="tg-0lax">[val(chr), path(ref_vcf), path(ref_vcf_tbi), path(chunks_txt), path(gmap_b38)]</td>
			<td>[val(chr), path(split)]</td>
      			<td>Create binary reference panels for quick reading time</td>
			<td>GLIMPSE2_split_reference v2.0.0</td>
		</tr>
    		<tr>
			<td class="tg-0lax">SPLIT_BAM</td>
			<td class="tg-0lax">[val(chr), val(object), val(rg_id), path(dedup_bam), path(dedup_bai), val(region)]</td>
			<td>[val(chr), val(object), val(rg_id), path(bamfile), path(baifile)]</td>
      			<td>Seperate bam file according chromosomes</td>
			<td>samtools v1.7.0</td>
		</tr>
   		 <tr>
			<td class="tg-0lax">RUN_GLIMPSE2</td>
			<td class="tg-0lax">[val(chr), path(chunks_txt), path(split), val(object), val(rg_id), path(bamfile), path(baifile)]</td>
			<td>[val(chr), val(object), val(rg_id), path(impute_result)]</td>
      			<td>Imputation and phasing</td>
			<td>GLIMPSE2_phase v2.0.0</td>
		</tr>
   		<tr>
			<td class="tg-0lax">LIGATE_CHUNKS</td>
			<td class="tg-0lax">[val(chr), val(object), val(rg_id), path(impute_result), val(region)]</td>
			<td>[val(chr), val(object), val(rg_id), path(ligated_bcf), path(ligated_bcf_csi)]</td>
      			<td>Ligatation of multiple phased BCF/VCF files into a single whole chromosome file</td>
			<td>GLIMPSE2_ligate v2.0.0</td>
		</tr>
    		<tr>
			<td class="tg-0lax">MERGE_SAMPLE</td>
			<td class="tg-0lax">[val(chr), val(object), [val(sample_id1), val(sample_id2), ...], [path(ligated_bcf1), path(ligated_bcf2), ...], [path(ligated_bcf_csi1), path(ligated_bcf_csi2), ...]]</td>
			<td>[val(chr), val(object), path(merged_glimpse_vcf_gz), path(merged_glimpse_vcf_gz_tbi)]</td>
      			<td>Merge VCF files by chromosomes</td>
			<td>bcftools v1.19 (using htslib 1.19.1) <br/> tabix v1.19.1</td>
		</tr>
	</tbody>
</table>
