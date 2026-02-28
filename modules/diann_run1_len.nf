#!/usr/bin/env nextflow

process diann_run1_len {
    publishDir "${params.outDir}/len${len}", mode: 'copy'
    container 'paretje/diann:2.2.0'

    input:
    tuple val(len), path(dia_files), path(fasta), path(crap_fasta), path(lib), path(ref_lib)

    output:
    tuple val(len),
        path("diann_report_len${len}.parquet"),
        path("diann_len${len}_lib.parquet"),
        path("diann_report_len${len}.log.txt"),
        path("diann_report_len${len}.manifest.txt"),
        path("diann_report_len${len}.gg_matrix.tsv"),
        path("diann_report_len${len}.pg_matrix.tsv"),
        path("diann_report_len${len}.pr_matrix.tsv"),
        path("diann_report_len${len}.protein_description.tsv"),
        path("diann_report_len${len}.stats.tsv"),
        path("diann_report_len${len}.site_report.parquet"),
        path("diann_report_len${len}.unique_genes_matrix.tsv")

    script:
    """
    F_FILES=\$(for f in ${dia_files}/*.d; do echo -n "--f \$f "; done)
    
    /diann-2.2.0/diann-linux \\
        --threads ${params.threads} \\
        --verbose 1 \\
        --out diann_report_len${len}.parquet \\
        --qvalue ${params.qvalue} \\
        --matrices \\
        \$F_FILES \\
        --lib ${lib} \\
        --window ${params.window} \\
        --mass-acc ${params.mass_acc} \\
        --mass-acc-ms1 ${params.mass_acc_ms1} \\
        --rt-profiling \\
        --ref ${ref_lib} \\
        --var-mod ${params.var_mod} \\
        --rt-window-mul ${params.rt_window_mul} \\
        --rt-window-factor ${params.rt_window_factor} \\
        --min-cal ${params.min_cal} \\
        --min-class ${params.min_class} \\
        --mass-acc-cal ${params.mass_acc_cal} \\
        --time-corr-only \\
        --min-corr ${params.min_corr} \\
        --corr-diff ${params.corr_diff} \\
        --fasta ${crap_fasta} \\
        --fasta ${fasta} \\
        --proteoforms \\
        --gen-spec-lib \\
        --out-lib diann_len${len}_lib.parquet
    """
}
