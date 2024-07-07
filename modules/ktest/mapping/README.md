# Mapping module
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
    <td class="tg-lboi">Data channel</td>
    <td class="tg-lboi">- <span style="font-style:italic">rg_id</span>: Group ID / Sample ID <br>- <span style="font-style:italic">sample_name</span>: Name of sample<br>- <span style="font-style:italic">library_id</span>: Unique ID of library of sample<br>- <span style="font-style:italic">lane</span>: Lane on sequencer<br>- <span style="font-style:italic">platform</span>: Platform of sequencer (Illumina/MCI)<br>- <span style="font-style:italic">machine</span>: Name of the sequencer, e.g. Hiseq X<br>- <span style="font-style:italic">orient</span>: The orientation, forward or reverse (1 or 2)<br>- <span style="font-style:italic">object</span>: Which object's sequence? e.g. human, shrimp, ...<br>- path: Path of fastq files</td>
    <td>[rg_id, sample_name, library_id, lane, platform, machine, orient, object, path]<br/><br/><img src="https://github.com/KTest-VN/mapping/assets/141545014/b01cac19-1bf2-4cc0-884c-b6cbedcf2462" alt="Data channel"></td>
  </tr>
  <tr>
    <td class="tg-0lax">Reference channel</td>
    <td class="tg-0lax">- <a href="https://ktest-dattn.atlassian.net/browse/PRS-92">bwa</a>: Folder contains index set of the reference genome (Indexing by BWA)</td>
    <td>[bwa]<br/><br/><img src="https://github.com/KTest-VN/mapping/assets/141545014/77567dfd-891d-45df-b593-199ca060a389" alt="Reference channel"></td>

  </tr>
</tbody>
</table>


## 2. Output channels

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
    <td class="tg-lboi">from_mapping</td>
    <td class="tg-lboi"><span style="font-weight:400;font-style:normal">- </span><span style="font-style:italic">object</span>: Which object's sequence? e.g. human, shrimp, ...<br>- <span style="font-style:italic">rg_id</span>: Group ID / Sample ID <br>- library_id: Unique ID of library of sample<br>- <span style="font-style:italic">dedup_bam</span>: Bam file after mark duplicate<br>- <span style="font-style:italic">dedup_bai</span>: Bai file, index of bam file</td>
    <td>[val(object), val(rg_id), val(library_id), path(dedup_bam), path(dedup_bai)]<br/><br/><img src=https://github.com/KTest-VN/mapping/assets/141545014/7db4f63d-832c-41f2-b3f5-c8cce812416c>
</td>
  </tr>
</tbody>
</table>

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
		</tr>
	</thead>
	<tbody>
		<tr>
			<td class="tg-lboi">CAT_FILE</td>
			<td class="tg-lboi">[val(object), val(rg_id), val(library_id), val(platform), val(machine), val(orient), [val(path1), val(path2)]]</td>
			<td>[val(object), val(rg_id), val(library_id), val(platform), val(machine), val(orient), path(cat_orient_fastq_gz)</td>
      <td>Concate fastq files come from identical sample</td>
		</tr>
    <tr>
			<td class="tg-lboi">FASTQC</td>
			<td class="tg-lboi">[val(rg_id), val(library_id), path(fastq_path)]</td>
			<td>Comming...</td>
      <td>Run fastqc</td>
		</tr>
    <tr>
			<td class="tg-lboi">MAP_BAM</td>
			<td class="tg-lboi">[val(object), val(rg_id), val(library_id), val(platform), val(machine), path(fastq_path), path(bwa_ref)]</td>
			<td>[val(object), val(rg_id), val(library_id), path(pe_sorted_bam)]</td>
      <td>Mapping and sorting</td>
		</tr>
    <tr>
			<td class="tg-lboi">BAM_INDEX</td>
			<td class="tg-lboi">[val(object), val(rg_id), val(library_id), path(dedup_bam)]</td>
			<td>[val(object), val(rg_id), val(library_id), path(dedup_bai)]</td>
      <td>Indexing bam file</td>
		</tr>
	</tbody>
</table>
