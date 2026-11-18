# Genome Annotation Course – *Arabidopsis thaliana* accession Geg-14

This repository contains the scripts used to annotate a *de novo* genome assembly of the *Arabidopsis thaliana* accession **Geg-14**. The pipeline covers:

1. **Transposable element (TE) annotation**: EDTA, TEsorter, TE density and TE age (divergence) analyses.
2. **Gene annotation**: MAKER, InterProScan, AED-based quality filtering, BUSCO, AGAT.
3. **Functional annotation and comparative genomics**: BLASTP against UniProt/TAIR10, GENESPACE pangenome and synteny analysis against TAIR10 and three other accessions (Etna-2, Altai-5, Are-6).


---

## Repository layout

```
genome_annotation_course/
├── scripts/               # All analysis scripts (numbered in run order)
├── maker_*.ctl            # MAKER control files (opts, bopts, exe, evm)
├── data/                  # Input assembly and transcriptome (symlinks)
├── output/
│   ├── EDTA/              # TE library and TE annotation
│   ├── LTR_full_length/   # TEsorter classification of intact LTR-RTs
│   ├── MAKER/             # MAKER run; final/ holds renamed + filtered annotation
│   ├── comparisons/       # BLASTP results, functional annotation, GENESPACE
│   └── TE_divergence_age.tsv
├── busco_proteins/        # BUSCO on longest-isoform proteins
├── busco_transcripts/     # BUSCO on longest-isoform transcripts
├── plots/                 # All figures (PDF/PNG)
├── logs/                  # SLURM stdout/stderr
└── results/               # Folders for curated results
```

Only `scripts/`, `plots/` and this README are tracked by git; data, outputs and logs are excluded through `.gitignore`.

---

## Pipeline

 The project root is hard-coded as `WORKDIR=/data/users/jli/genome_annotation_course` in most scripts; change it if you run the pipeline elsewhere.

### 0. Setup

| Script | Description |
|---|---|
| `0_folder structure.sh` | Creates the project folder structure. |

### 1. TE annotation

| Script | Tool | Description |
|---|---|---|
| `01-run_EDTA.sh` | EDTA v2.3.0 | Builds a TE library and annotates the genome (`--sensitive 1 --anno 1 --wholeelement 1`, TAIR10 CDS to remove gene-derived sequences). |
| `02-run_TEsorter_full_length_LTRs.sh` | TEsorter 1.3.0 | Classifies intact LTR retrotransposons to clade level with the `rexdb-plant` database. |
| `03-full_length_LTRs_identity_copy.R` | R | Merges LTR identity (from the EDTA GFF) with TEsorter clades and plots the identity distribution per Copia/Gypsy clade. |
| `04_run_circlize.sh` → `04-annotation_circlize.R` | samtools, circlize | Indexes the assembly and draws circos plots of TE superfamily density over the 20 longest scaffolds. |
| `05_run_seqkit.sh` | SeqKit, TEsorter | Extracts Copia and Gypsy sequences from the TE library and classifies them into clades. |
| `06_run_parseRM.sh` | parseRM.pl | Removes zero-length hits from the RepeatMasker output and computes the divergence landscape. |
| `07_run_divplot.sh` → `06-plot_div.R` | R / ggplot2 | Plots the TE landscape (Mbp per divergence bin) and estimates insertion ages with T = K / 2r (r = 8.22e-9). Helitrons and the CEN180-like satellite `TE_00000198` are excluded. |

### 2. Gene annotation

| Script | Tool | Description |
|---|---|---|
| `08_run_maker.sh` | MAKER 3.01.03 (MPI) | Evidence-based gene prediction using Trinity transcripts (`est2genome=1`), TAIR10 + UniProt proteins (`protein2genome=1`), the EDTA TE library for masking, and AUGUSTUS (`arabidopsis` model). |
| `09_merge_gff.sh` | gff3_merge, fasta_merge | Merges the per-contig MAKER output into a GFF3 and protein/transcript FASTA files. |
| `10_rename.sh` | – | Copies the merged files into `output/MAKER/final/`. |
| `11_id_mapping.sh` | maker_map_ids | Renames genes with the accession prefix `Geg` (e.g. `Geg0000001`). |
| `12_run_interproscan.sh` | InterProScan 5.70 | Pfam domain search with GO terms and InterPro lookup. |
| `13_exam_AED.sh` | ipr_update_gff, AED_cdf_generator.pl | Adds InterProScan results to the GFF and computes the cumulative AED distribution. |
| `13-plot_AED.py` | matplotlib | Plots the AED cumulative distribution. |
| `14_filter_gff.sh` | quality_filter.pl | Keeps gene models with AED < 1 and/or a Pfam domain, and only gene/mRNA/exon/CDS/UTR features. |
| `15_extract_mrna.sh` | SeqKit | Extracts the proteins and transcripts of the filtered models. |
| `16_get_longest.sh` | awk | Keeps the longest isoform per gene. |
| `17_run_busco.sh` | BUSCO 5.4.2 | Completeness of longest proteins and transcripts (`brassicales_odb10`). |
| `17-plot_busco_genome_vs_proteins.py` | matplotlib | Compares BUSCO results of the genome assembly and the annotated proteins. Requires the Flye BUSCO summary in the project root. |
| `18_run_AGAT.sh` | AGAT 1.4.1 | Summary statistics of the final annotation. |

### 3. Functional annotation and comparative genomics

| Script | Tool | Description |
|---|---|---|
| `19_run_blastp.sh` | BLAST+ 2.15.0 | BLASTP of the filtered proteins against UniProt Viridiplantae (reviewed) and TAIR10 (e-value 1e-5); keeps the best hit per query. |
| `20_add_uniprotfunction.sh` | maker_functional_fasta/gff | Adds UniProt-based functional descriptions to the protein FASTA and GFF3. |
| `21_prepare_data.sh` | awk, sed | Builds GENESPACE BED and peptide inputs for Geg_14, TAIR10, Etna_2, Altai_5 and Are_6. |
| `23_run_genespace.sh` → `22_genespace.R` | GENESPACE | Runs orthology/synteny inference and saves the TAIR10-referenced pangenome matrix. |
| `25_run_pangenenome.sh` → `24_process_pangenome.R` | R / tidyverse | Classifies pan-gene entries as core, accessory or accession-specific, and plots presence frequency and copy-number comparisons. |
| `27_run_map.sh` → `26_syntenymap.R` | GENESPACE | Riparian synteny plots: Geg_14 vs TAIR10 (raw and with reversed scaffolds flipped) and all five genomes. |

---

## Key results

**Final gene annotation** (AGAT, `filtered.genes.renamed.gff3`):

| Metric | Value |
|---|---|
| Genes | 27,386 |
| mRNAs | 30,079 |
| Mean exons per mRNA | 5.5 |
| Single-exon genes | 6,585 |
| Total CDS length | 36.8 Mb |


---

## Figures (`plots/`)

| File | Content |
|---|---|
| `01_LTR_Copia_Gypsy_cladelevel.pdf`, `02_LTR_Copia_Gypsy_global.pdf` | Identity distribution of intact LTR-RTs per clade |
| `02-TE_density.pdf` | Circos plots of TE superfamily density |
| `TE_landscape.pdf` , `TE_landscape_plot.pdf | TE divergence landscape |
| `04_BUSCO_genome_vs_proteins.pdf` | BUSCO: genome assembly vs annotated proteins |
| `05_AED_cumulative_distribution.pdf` | Cumulative AED distribution of MAKER gene models |
| `pangenome_presence_frequency.pdf` | Pan-gene presence frequency across the five genomes |
| `copy_variable_core_comparison.pdf` | Core gene copy-number comparison |
| `my_accession_vs_TAIR10.pdf`, `my_accession_vs_TAIR10_oriented.pdf`, `all_genomes_TAIR10.pdf` | Riparian synteny plots |

---

## Software

Containers are located in `/data/courses/genome_annotation_resources/2026/containers/`.

- `EDTA_v2.3.0_TIRLearner4.sif`
- `TEsorter_1.3.0.sif`
- `Annotation_analysis_R4.4.sif`
- `MAKER_3.01.03.sif`
- `InterProScan_5.70.sif`
- `AGAT_v1.4.1.sif`
- `genespace_latest.sif`

Cluster modules:

- `BUSCO/5.4.2-foss-2021a`
- `BLAST+/2.15.0-gompi-2021a`
