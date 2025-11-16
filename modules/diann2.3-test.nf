#!/usr/bin/env nextflow

process diann23test {
    publishDir "test/", mode: 'copy'
    container 'diann_docker'

    input:
    val dia_files
    val min_pr_mz
    val max_pr_mz
    val min_charge
    val max_charge
    path fasta
    path crap_fasta

    output:
    path("reflib.predicted.speclib")

    script:
    """
    F_FILES=\$(for f in ${dia_files}/*.d; do echo -n "--f \$f "; done)

    /diann-2.3.0/diann-linux \\
        --threads ${params.threads} \\
        --verbose 1 \\
        --out report.parquet \\
        --qvalue ${params.qvalue} \\
        --matrices \\
        \$F_FILES \\
        --min-corr ${params.min_corr} \\
        --corr-diff ${params.corr_diff} \\
        --time-corr-only \\
        --out-lib reflib.parquet \\
        --gen-spec-lib \\
        --predictor \\
        --fasta "${crap_fasta}" \\
        --fasta "${fasta}" \\
        --pre-search \\
        --pre-filter \\
        --mass-acc 10 \\
        --mass-acc-ms1 10 \\
        --mass-acc-cal 20 \\
        --min-fr-mz ${params.min_fr_mz} \\
        --max-fr-mz ${params.max_fr_mz} \\
        --min-pep-len ${params.min_pep_len} \\
        --max-pep-len ${params.max_pep_len} \\
        --min-pr-mz ${min_pr_mz} \\
        --max-pr-mz ${max_pr_mz} \\
        --min-pr-charge ${min_charge} \\
        --max-pr-charge ${max_charge} \\
        --var-mods ${params.var_mods} \\
        --var-mod ${params.var_mod} \\
        --proteoforms \\
        --rt-profiling \\
        --cut "**" \\
        --missed-cleavages 100
    """
}
