# drug-sceqtl: Analysis scripts and reproducibility notes

## Overview and scope

This repository contains available R scripts used in the Mendelian randomization (MR) components of the study *Identification of potential immune cell-specific therapeutic targets for head and neck cancer: A Mendelian randomization analysis integrating single-cell eQTL data with druggable genes*.

The scripts cover (1) an eQTLGen-based MR screening stage, (2) extraction of gene-specific GTEx eQTL data and subsequent MR analyses, and (3) extraction of immune-cell-specific OneK1K sc-eQTL data and subsequent MR analyses. They are provided to document the available analytical workflow and facilitate inspection and partial reproduction. **They do not constitute a complete, independently verified end-to-end reproduction pipeline.**

The deposited scripts contain study-specific Windows file paths and expect input files and LD-pruned exposure datasets to have been prepared beforehand. The original commands used to generate all LD-pruned inputs and some other computational settings are not included in this repository. Some original inputs and intermediate files are also not deposited here. This documentation does not claim that missing parameters, scripts, or data have been recovered.

## Files and workflow

| Script | Purpose | Principal input(s) | Principal output(s) |
| --- | --- | --- | --- |
| `1_eqtl(1).R` | eQTLGen-based initial MR screening | `druggable_eqtl.txt`; `eqtlclump/<gene>.txt`; FinnGen outcome file | Per-gene harmonized data, MR odds ratios, sensitivity results, figures for the selected associations |
| `gtex1(1).R` | Extract GTEx eQTL rows for selected genes | `Whole_Blood.v10.eQTLs.txt.gz`; `eQTLGeneqtl_result.txt` | `no_clump/<gene>.txt` |
| `gtex2(1).R` | MR on prepared GTEx gene-level exposure datasets | `eQTLGeneqtl_result.txt`; `clump/<gene>.txt`; FinnGen outcome file | Per-gene harmonized data, MR results, sensitivity results, figures |
| `sceqtl1(1).R` | Extract selected gene-by-immune-cell OneK1K sc-eQTL records | `gene_id.txt`; `cell_id.txt`; `scQTL/<cell>.txt.gz` | `no_clump/<gene>_<cell>.txt`; `gene_cell_id.txt` |
| `sceqtl3.R` | MR on prepared immune-cell-specific gene exposure datasets | `gene_cell_id.txt`; `clump/<gene>_<cell>_expo_rt.txt`; FinnGen outcome file | Per-gene/cell harmonized data, MR results, sensitivity results, figures |

The original scripts do **not** generate all required LD-pruned exposure files. Preparation of those files is a separate prerequisite, not a step documented or reproduced by the current code.

## Software dependencies

The manuscript reports the following software environment for its statistical analyses:

- **R:** 4.2.2
- **TwoSampleMR:** 0.5.7 (reported for MR analyses)
- **PLINK:** 1.9 (reported for LD pruning; the underlying LD-pruning commands are not supplied here)

The deposited scripts directly load the following R packages:

- `TwoSampleMR` — exposure/outcome import, harmonization, MR estimation, tests, and plotting functions
- `ggplot2` — plot export
- `foreach` — iteration over genes and cell types using `%do%`
- `data.table` — input and output of larger eQTL tables (GTEx and sc-eQTL extraction scripts)

The MR scripts also call `run_mr_presso()`, for which additional MR-PRESSO-related functionality/dependencies may be required in the installed environment. **Exact historical versions of `ggplot2`, `foreach`, `data.table`, and any MR-PRESSO dependency have not been verified and are not reported as known.** An `renv.lock` file or historical `sessionInfo()` record is not available.

Users can inspect their own R environment with:

```r
R.version.string
packageVersion("TwoSampleMR")
packageVersion("ggplot2")
packageVersion("foreach")
packageVersion("data.table")
sessionInfo()
```

A locally installed R 4.2.2 environment with TwoSampleMR 0.5.7 is the documented starting point, but current package availability and runtime compatibility have not been validated by the authors through a fresh end-to-end execution of this repository.

## Data sources

| Data source | Use | Location / reference |
| --- | --- | --- |
| eQTLGen | Blood eQTL data for initial gene screening | https://www.eqtlgen.org/ |
| GTEx | Complementary eQTL analysis; script names `Whole_Blood.v10.eQTLs.txt.gz` | https://gtexportal.org/ |
| OneK1K | Immune-cell-resolved sc-eQTL exposures | https://onek1k.org/ |
| FinnGen Release 12 | HNC GWAS outcome, `C3_HEAD_AND_NECK_EXALLC` | https://r12.finngen.fi/ |

The FinnGen outcome file expected by the deposited MR scripts is named `finngen_R12_C3_HEAD_AND_NECK_EXALLC.gz`. The scripts specify 382,691 as the total outcome sample size (3,942 cases and 378,749 controls, as described in the manuscript). In the sc-eQTL MR script, exposure sample size is set to 982, corresponding to the source OneK1K cohort sample count reported in the manuscript; this should not be interpreted as the exact number of cells or donors contributing to every individual gene-by-cell-type association.

**Input access:** Input data must be obtained from the relevant original data provider, subject to its download, access, and usage requirements. The present repository does not provide a bundled raw-data archive or guarantee that the original file formats and historical releases remain directly downloadable under the same names.

## Required input files and columns

These are the names/columns **expected by the source code**. They describe the required structure, not a claim that the exact historical files are supplied or recoverable.

### `1_eqtl(1).R` — initial eQTLGen MR

- `druggable_eqtl.txt`: tab-separated text with header column `id`, listing gene identifiers.
- `eqtlclump/<gene>.txt`: preprocessed, LD-pruned tab-separated exposure file containing `SNP`, `beta`, `se`, `A1`, `A2`, `eaf`, `p`, `n`.
- `finngen_R12_C3_HEAD_AND_NECK_EXALLC.gz`: outcome association file containing `rsids`, `beta`, `sebeta`, `alt`, `ref`, `af_alt`, `pval`.

### `gtex1(1).R` — GTEx extraction

- `Whole_Blood.v10.eQTLs.txt.gz`: the GTEx input table; the script requires the column `external_gene_name` to match the gene identifiers in the selection list.
- `eQTLGeneqtl_result.txt`: tab-separated text with an `id` column.
- `no_clump/`: an existing output directory for extracted per-gene tables.

### `gtex2(1).R` — GTEx MR

- `eQTLGeneqtl_result.txt`: tab-separated text with `id`.
- `clump/<gene>.txt`: a precomputed and appropriately formatted exposure file containing `rsids2`, `beta`, `se`, `A1`, `A2`, `eaf`, `p`, `n`.
- `finngen_R12_C3_HEAD_AND_NECK_EXALLC.gz`: same FinnGen outcome columns as above.

### `sceqtl1(1).R` — OneK1K extraction

- `gene_id.txt`: tab-separated text with `id` (selected gene identifiers).
- `cell_id.txt`: tab-separated text with `id` (selected immune-cell identifiers).
- `scQTL/<cell>.txt.gz`: a cell-specific sc-eQTL file with at least a `GENE` column for filtering.
- `no_clump/`: an existing output directory.
- Output list: `gene_cell_id.txt`, containing an `id` column (a concatenated `<gene>_<cell>` identifier).

### `sceqtl3.R` — OneK1K MR

- `gene_cell_id.txt`: tab-separated text with `id`.
- `clump/<gene>_<cell>_expo_rt.txt`: a precomputed exposure file with `RSID`, `beta`, `se`, `A1`, `A2`, `A2_FREQ_ONEK1K`, `P_VALUE`.
- `finngen_R12_C3_HEAD_AND_NECK_EXALLC.gz`: same FinnGen outcome columns as above.

The scripts assume directory layouts that include `result/`, `clump/` or `eqtlclump/`, `no_clump/`, and/or `scQTL/` as appropriate. These directories and external input files are not included in the repository.

## How to inspect and attempt to reproduce the available analyses

1. Download or clone this repository and inspect the scripts. Install a compatible version of R and the packages listed above.
2. Obtain the original publicly available or permission-controlled input datasets and construct the gene and cell selection tables as required by each script. Check identifiers, allele conventions, and column headers against the scripts.
3. Prepare the relevant preprocessed/LD-pruned exposure tables in the expected `eqtlclump/` or `clump/` directories. **The precise original LD-clumping command, reference panel, and complete derivation of these input files are not provided in this repository; therefore this prerequisite cannot be reproduced exactly from these scripts alone.**
4. **Before executing any script**, replace each hard-coded `setwd("G:/drug_sceQTL/...")` path with the actual local working directory, put input files in the correct relative subfolders, and create output directories (including `result/` where needed). The script `sceqtl3.R` uses the current working directory and has no explicit `setwd()` call.
5. **For the eQTLGen branch**, inspect/run `1_eqtl(1).R` only after preparing `druggable_eqtl.txt`, the gene-specific `eqtlclump/` inputs, and the FinnGen outcome file.
6. **For the GTEx branch**, run `gtex1(1).R` to extract gene-specific inputs; after an external LD-pruning/preparation step, inspect/run `gtex2(1).R` for MR analyses.
7. **For the immune-cell-specific branch**, run `sceqtl1(1).R` to extract gene–cell pairs; after an external LD-pruning/preparation step, inspect/run `sceqtl3.R` for MR analyses.
8. Review the outputs produced in per-gene `result/<id>/` directories: `harmonise.txt`, `OR.txt`, `pleiotropy.txt`, `heterogeneity.txt`, `singlesnpOR.txt`, `presso.txt`, and plots such as `scatter.pdf`, `forest.pdf`, `sensitivity-analysis.pdf`, and `funnelplot.pdf` when the relevant functions execute successfully.

**Execution caveats:** The scripts are archival analysis code, not a validated software package. `1_eqtl(1).R` uses a conditional selection based on `result_or$pval[3]`; this index depends on the method ordering returned by `mr()` and should not be assumed to denote the IVW result in every installed environment. The MR scripts call functions that can be inapplicable or fail for small numbers of instruments. Existing calls to plot-export functions and directory creation may also require adaptation to the locally installed software environment. Consequently, a successful end-to-end execution is **not guaranteed**, and no fresh reproduction run is claimed here.

## Main parameters visible in the available MR scripts

- Exposure/outcome alignment: `harmonise_data(..., action = 2)`.
- Instrument-strength selection: per-SNP calculation of `R2` and `f`, followed by filtering at `f > 10`.
- Directionality filtering: `steiger_filtering()`.
- MR estimation: `mr()`; effect-estimate conversion: `generate_odds_ratios()`.
- Additional calls: `mr_pleiotropy_test()`, `mr_heterogeneity()`, `mr_singlesnp()`, `mr_leaveoneout()`, and `run_mr_presso(..., NbDistribution = 1000)`.
- Default method configuration used by `mr()` and package-dependent function behavior should be checked against the installed TwoSampleMR version.

The provided scripts do not resolve any discrepancies between historical descriptions of LD-clumping thresholds in the manuscript. Such details must be checked against original records rather than inferred from these files.

## Relation to supplementary materials and omitted analytical stages

Selected intermediate analytical results are reported in the manuscript's supplementary tables. This repository does not currently contain all intermediate data or complete code for differential-expression analysis, SMR/HEIDI analysis, scTenifoldKnk-based computational perturbation, DSigDB enrichment, or molecular docking. In particular, the scTenifoldKnk input cell composition, exact numbers of analyzed cells and donors, and certain network construction/subsampling/random seed settings could not be retrospectively recovered. These findings are therefore interpreted as exploratory computational predictions.

The repository supports documentation and inspection of the available MR-related code, rather than complete computational reproducibility for every analysis described in the publication.
