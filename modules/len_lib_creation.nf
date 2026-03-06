#!/usr/bin/env nextflow

process len_lib_creation {
    publishDir "${params.outDir}/libs", mode: 'copy'
    container 'paretje/diann:2.3.2'

    input:
    tuple val(len), path(fasta), path(crap_fasta)

    output:
    tuple val(len), path("lib_len${len}.predicted.speclib")

    script:
    """
    /diann-2.3.2/diann-linux \\
        --threads ${params.threads} \\
        --verbose 1 \\
        --out report_len${len}.parquet \\
        --qvalue ${params.qvalue} \\
        --matrices \\
        --min-corr ${params.min_corr} \\
        --corr-diff ${params.corr_diff} \\
        --time-corr-only \\
        --out-lib lib_len${len}.parquet \\
        --gen-spec-lib \\
        --predictor \\
        --fasta "${crap_fasta}" \\
        --fasta "${fasta}" \\
        --fasta-search \\
        --min-fr-mz ${params.min_fr_mz} \\
        --max-fr-mz ${params.max_fr_mz} \\
        --min-pr-charge ${params.min_pr_charge} \\
        --max-pr-charge ${params.max_pr_charge} \\
        --min-pr-mz ${params.min_pr_mz_lib} \\
        --max-pr-mz ${params.max_pr_mz_lib} \\
        --min-pep-len ${len} \\
        --max-pep-len ${len} \\
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
