#!/usr/bin/env nextflow

process lib_creation {
    publishDir "${params.outDir}/libs", mode: 'copy'
    container 'paretje/diann:2.2.0'

    input:
    tuple val(min_pr_mz), val(max_pr_mz), val(charge), path(fasta), path(crap_fasta)

    output:
    tuple val(charge), path("lib_z${charge}.predicted.speclib")

    script:
    """
    /diann-2.2.0/diann-linux \\
        --threads ${params.threads} \\
        --verbose 1 \\
        --out report_z${charge}.parquet \\
        --qvalue ${params.qvalue} \\
        --matrices \\
        --min-corr ${params.min_corr} \\
        --corr-diff ${params.corr_diff} \\
        --time-corr-only \\
        --out-lib lib_z${charge}.parquet \\
        --gen-spec-lib \\
        --predictor \\
        --fasta "${crap_fasta}" \\
        --fasta "${fasta}" \\
        --fasta-search \\
        --min-fr-mz ${params.min_fr_mz} \\
        --max-fr-mz ${params.max_fr_mz} \\
        --min-pep-len ${params.min_pep_len} \\
        --max-pep-len ${params.max_pep_len} \\
        --min-pr-mz ${min_pr_mz} \\
        --max-pr-mz ${max_pr_mz} \\
        --min-pr-charge ${charge} \\
        --max-pr-charge ${charge} \\
        --cut K*,R* \\
        --missed-cleavages 1 \\
        --var-mods ${params.var_mods} \\
        --var-mod ${params.var_mod} \\
        --proteoforms \\
        --rt-profiling \\
        --cut "**" \\
        --missed-cleavages 100
    """
}
