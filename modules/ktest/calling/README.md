# Calling module

Calling variants from mark duplicated bam file ([PRS-62](https://ktest-dattn.atlassian.net/browse/PRS-62)).

------------------
# 1. Usages
Input params (view `conf/input.config`): 
- `from_mapping_csv` path of sample sheet

Calling params (view `conf/calling.config`):

- `folder_ref`: the path of the folder contains reference genome
- `genome_name`: file name of fasta genome reference laid in folder_ref
- `human_knownsite_vcf`: Known-sites reference for BASE_RECALIBRATOR process in module Calling.


# 2. Channels
## 2.1 Input channels

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
    <td class="tg-lboi">from_mapping</td>
    <td class="tg-lboi">
      - <span style="font-style:italic">key</span>: key from higher hierarchical structure (e.g. null, 'arrayA_batch4', ...) <br>
      - <span style="font-style:italic">rg_id</span>: Group ID / Sample ID <br>
      - <span style="font-style:italic">object</span>: Which object's sequence? e.g. human, shrimp, ...<br>
      - <span style="font-style:italic">dedup_bam</span>: Path of bam file, after duplicate<br>
      - <span style="font-style:italic">dedup_bai</span>: Path of *.bai file, index file of bam file.<br>
    </td>
    <td>([val(key), val(rg_id), val(object), path(dedup_bam), path(dedup_bai)])<br/>
  </tr>
</tbody>
</table>

## 2.2 Reference channels

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
    <td class="tg-0lax">calling_reference</td>
    <td class="tg-0lax">
      - <a href="https://ktest-dattn.atlassian.net/browse/PRS-93">folder_ref</a>: Folder contains reference genome and indexing *.{fa, fa.fai, dict}. <br>
      - genome_ref: file name of fasta genome reference laid in folder_ref. (e.g. Homo_sapiens.GRCh38.dna.primary_assembly.fa) <br>
      - <a href="https://ktest-dattn.atlassian.net/browse/PRS-96">human_knownsite_vcf</a>: Known-sites reference for BASE_RECALIBRATOR process in module Calling.
    </td>
    <td>
	    ([folder_ref, genome_ref, human_knownsite_vcf])
    </td>

  </tr>
</tbody>
</table>

## 2.3. Output channels

<table class="tg" style="undefined;table-layout: fixed; width: 792px">
<colgroup>
<col style="width: 202px">
<col style="width: 590px">
<col style="width: 590px">
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
    <td class="tg-lboi">split_vcf</td>
    <td class="tg-lboi"><span style="font-weight:400;font-style:normal">
      - </span><span style="font-style:italic">object</span>: Which object's sequence? e.g. human, shrimp, ...<br>
      - <span style="font-style:italic">chr</span>: Order number of chromosome (1→22)
      - <span style="font-style:italic">split_vcf</span>: Cohort vcf file after split by chromosome and its index<br>
    </td>
    <td>[val(object), val(chr), [path(split_vcf), path(split_vcf_tbi)]]<br/></td>
  </tr>
</tbody>
</table>

## 2.4. Processes

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
		</tr>
	</thead>
	<tbody>
		<tr>
			<td class="tg-lboi">DRAFT_CALLING</td>
			<td class="tg-lboi">[val(key), al(object), val(rg_id), path(dedup_bam), path(dedup_bai), path(folder_ref), val(genome_name)]</td>
			<td>[val(key), val(object), val(rg_id), path(raw_variants_vcf)</td>
      <td>Draft variant calling</td>
		</tr>
    <tr>
			<td class="tg-lboi">DRAFT_JOIN</td>
			<td class="tg-lboi">[val(key), val(object), path(raw_variants_vcf), path(folder_ref), val(genome_name)]</td>
			<td>[val(key), val(object), path(joint_genotyped_draft{vcf.gz,vcf.gz.idx})]</td>
      <td>Join draft variant VCF files into a draft cohort VCF file</td>
		</tr>
    <tr>
			<td class="tg-lboi">BASE_RECALIBRATOR</td>
			<td class="tg-lboi">[val(object), val(rg_id), path(dedup_bam), path(dedup_bai), val(joint_genotyped_draft_vcf), val(genome_name), path(human_knownsite_vcf)]</td>
			<td>[val(object), val(rg_id), path(recal_data_table)]</td>
      <td>Statistic impute and Overwrite original reported quality score in each mismatch with reference</td>
		</tr>
    <tr>
			<td class="tg-lboi">APPLY_BQSR</td>
			<td class="tg-lboi">[val(key), val(object), val(sample_id), path(dedup_bam), path(dedup_bai), path(recal_data_table), path(folder_ref), val(genome_name)]</td>
			<td>[val(key), val(object), val(sample_id), path(recal_bam)]</td>
      <td>Apply base quality score recalibration</td>
		</tr>
    <tr>
			<td class="tg-lboi">CALL_VARIANTS</td>
			<td class="tg-lboi">[val(key), val(object), val(rg_id), path(recal_bam)]</td>
			<td>[val(key), val(object), val(rg_id), path(recal_vcf)]</td>
      <td>Call germline SNPs and indels via local re-assembly of haplotypes</td>
		</tr>
    <tr>
			<td class="tg-lboi">JOINING</td>
			<td class="tg-lboi">[val(key), val(object), val(rg_id), path(variants_vcf), path(folder_ref), val(genome_name)</td>
			<td>[val(key), val(object), path(joint_genotyped{vcf.gz,vcf.gz.tbi})]</td>
      <td>Join variant VCF files into a draft cohort VCF file</td>
		</tr>
    <tr>
			<td class="tg-lboi">SPLIT_CHR</td>
			<td class="tg-lboi">[val(key), val(object), path(joint_genotyped), val(chr)</td>
			<td>[val(key), val(object), val(chr), path(split_vcf{vcf.gz,vcf.gz.tbi})]</td>
      <td>Split the cohort vcf file by chromosome</td>
		</tr>
</table>
