#!/usr/bin/env nextflow

process infinDIA {
    publishDir "${params.outDir}/infinDIA", mode: 'copy'
    container 'paretje/diann:2.3.2'

    input:
    tuple path(dia_files), path(fasta), path(crap_fasta), path(lib)

    output:
    path "reflib.parquet"
    path "reflib.parquet.skyline.speclib"
    path "infinDIA-first-pass.manifest.txt"
    path "infinDIA-first-pass.parquet"
    path "infinDIA-first-pass.pr_matrix.tsv"
    path "infinDIA-first-pass.site_report.parquet"
    path "infinDIA-first-pass.stats.tsv"
    path "infinDIA-first-pass.UniMod_312_sites_90.tsv"
    path "infinDIA-first-pass.UniMod_312_sites_99.tsv"
    path "infinDIA.gg_matrix.tsv"
    path "infinDIA.log.txt"
    path "infinDIA.manifest.txt"
    path "infinDIA.parquet"
    path "infinDIA.pg_matrix.tsv"
    path "infinDIA.pr_matrix.tsv"
    path "infinDIA.protein_description.tsv"
    path "infinDIA.site_report.parquet"
    path "infinDIA.stats.tsv"
    path "infinDIA.UniMod_312_sites_90.tsv"
    path "infinDIA.UniMod_312_sites_99.tsv"
    path "infinDIA.unique_genes_matrix.tsv"

    script:
    """
    F_FILES=\$(for f in ${dia_files}/*${params.file_suffix}; do echo -n "--f \$f "; done)

        /diann-2.3.2/diann-linux \\
         --threads ${params.threads} \\
        --verbose 1 \\
        --out infinDIA.parquet \\
        --qvalue ${params.qvalue} \\
        --matrices \\
        \$F_FILES \\
        --lib ${lib} \\
        --min-corr ${params.min_corr} \\
        --corr-diff ${params.corr_diff} \\
        --time-corr-only \\
        --out-lib reflib.parquet \\
        --fasta "${crap_fasta}" \\
        --fasta "${fasta}" \\
        --pre-search \\
        --pre-filter \\
        --mass-acc ${params.mass_acc_ref} \\
        --mass-acc-ms1 ${params.mass_acc_ms1_ref} \\
        --mass-acc-cal ${params.mass_acc_cal_ref} \\
        --min-fr-mz ${params.min_fr_mz} \\
        --max-fr-mz ${params.max_fr_mz} \\
        --min-pr-charge ${params.min_pr_charge} \\
        --max-pr-charge ${params.max_pr_charge} \\
        --min-pr-mz ${params.min_pr_mz_lib} \\
        --max-pr-mz ${params.max_pr_mz_lib} \\
        --min-pep-len ${params.min_pep_len} \\
        --max-pep-len ${params.max_pep_len} \\
        --var-mods ${params.var_mods} \\
        --var-mod ${params.var_mod} \\
        --proteoforms \\
        --rt-profiling \\
        --gen-spec-lib \\
        --reanalyse \\
        --cut "**" \\
        --missed-cleavages 100 \\
        || true
    """
}
