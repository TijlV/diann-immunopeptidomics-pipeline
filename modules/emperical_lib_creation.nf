#!/usr/bin/env nextflow

process emperical_lib_creation_len {
    publishDir "${params.outDir}/libs", mode: 'copy'
    container 'paretje/diann:2.3.2'

    input:
    path fasta
    path crap_fasta

    output:
    path("infindia_ref_lib.predicted.speclib")

    script:
    """
    /diann-2.3.2/diann-linux \\
        --threads ${params.threads} \\
        --verbose 1 \\
        --out report.parquet \\
        --qvalue ${params.qvalue} \\
        --matrices \\
        --min-corr ${params.min_corr} \\
        --corr-diff ${params.corr_diff} \\
        --time-corr-only \\
        --out-lib infindia_ref_lib.parquet \\
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
        --min-pep-len ${params.min_pep_len} \\
        --max-pep-len ${params.max_pep_len} \\
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
