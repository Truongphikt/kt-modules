# [[PRS-74](https://ktest-dattn.atlassian.net/browse/PRS-74)] Imputation module
Impute variants from VCF files by VCF references

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
    <td class="tg-lboi">split_vcf_ch</td>
    <td class="tg-lboi">
      - <span style="font-style:italic">key</span>: Key from higher hierarchical structure (set `null` if run pipeline independently) <br>
      - <span style="font-style:italic">chr</span>: Chromosome number (1,2,3,...) <br>
      - <span style="font-style:italic">split_vcf</span>: VCF file for imputation <br>
      - <span style="font-style:italic">split_vcf_tbi</span>: Index of VCF file <br>
    </td>
    <td>[val(key), val(chr), path(split_vcf), path(split_vcf_tbi)]</td>
  </tr>
  <tr>
    <td class="tg-lboi">split_vcf_ch</td>
    <td class="tg-lboi">
      - <span style="font-style:italic">key</span>: Key from higher hierarchical structure (set `null` if run pipeline independently) <br>
      - <span style="font-style:italic">chr</span>: Chromosome number (1,2,3,...) <br>
      - <span style="font-style:italic">split_vcf</span>: VCF file, imputation's reference <br>
      - <span style="font-style:italic">split_vcf_tbi</span>: Index of VCF file <br>
    </td>
    <td>[val(key), val(chr), [path(ref_vcf), path(ref_vcf_tbi)]]</td>
  </tr>
<tbody>
