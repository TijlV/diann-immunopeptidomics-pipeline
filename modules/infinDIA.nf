#!/usr/bin/env nextflow

process infinDIA {
    publishDir "${params.outDir}/infinDIA", mode: 'copy'
    container 'paretje/diann:2.3.2'

    input:
    // TO DO COMBINE LEN LIBS
    tuple path(dia_files), path(fasta), path(crap_fasta), path(lib)

    output:
    // TO DO ADAPT OUTPUT FILES
    path "reflib.parquet"

    script:
    """
    F_FILES=\$(for f in ${dia_files}/*.d; do echo -n "--f \$f "; done)

        /diann-2.3.2/diann-linux \\
         --threads ${params.threads} \\
        --verbose 1 \\
        --out report.parquet \\
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
        --mass-acc 10 \\
        --mass-acc-ms1 10 \\
        --mass-acc-cal 20 \\
        --min-fr-mz ${params.min_fr_mz} \\
        --max-fr-mz ${params.max_fr_mz} \\
        --min-pr-charge ${params.min_pr_charge} \\
        --max-pr-charge ${params.max_pr_charge} \\
        --min-pr-mz ${params.min_pr_mz_ref} \\
        --max-pr-mz ${params.max_pr_mz_ref} \\
        --min-pep-len 8 \\
        --max-pep-len 12 \\
        --var-mods ${params.var_mods} \\
        --var-mod ${params.var_mod} \\
        --proteoforms \\
        --rt-profiling \\
        --cut "**" \\
        --missed-cleavages 100 \\
        || true
    """
}
