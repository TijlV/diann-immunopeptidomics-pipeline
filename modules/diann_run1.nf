#!/usr/bin/env nextflow

process diann_run1 {
    publishDir "${params.outDir}/z${charge}", mode: 'copy'
    container 'paretje/diann:2.2.0'

    input:
    tuple val(charge), path(dia_files), path(fasta), path(crap_fasta), path(lib), path(ref_lib)

    output:
    tuple val(charge), path("z${charge}/diann_report_z${charge}.parquet"), path("z${charge}/diann_z${charge}_DIA.parquet")

    script:
    """
    F_FILES=\$(for f in ${dia_files}/*.d; do echo -n "--f \$f "; done)

    /diann-2.2.0/diann-linux \\
        --threads ${params.threads} \\
        --verbose 1 \\
        --out diann_report_z${charge}.parquet \\
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
        --out-lib diann_z${charge}_DIA.parquet
    """
}
