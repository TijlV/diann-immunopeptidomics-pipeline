#!/usr/bin/env nextflow

process empirical_diann_run {
    publishDir "${params.outDir}/empirical", mode: 'copy'
    container 'paretje/diann:2.3.2'

    input:
    tuple path(dia_files), path(fasta), path(crap_fasta), path(lib), path(ref_lib)

    output:
    path "diann_empirical_DIA.parquet"
    path "diann_empirical_DIA.site_report.parquet"
    path "diann_empirical_DIA.pr_matrix.tsv"
    path "diann_empirical_DIA.pg_matrix.tsv"
    path "diann_empirical_DIA.gg_matrix.tsv"
    path "diann_empirical_DIA.unique_genes_matrix.tsv"
    path "diann_empirical_DIA.manifest.txt"
    path "diann_empirical_DIA.stats.tsv"
    path "diann_empirical_DIA.log.txt"
    path "diann_empirical_DIA.protein_description.tsv"

    script:
    """
    F_FILES=\$(for f in ${dia_files}/*${params.file_suffix}; do echo -n "--f \$f "; done)

    /diann-2.3.2/diann-linux \\
        --threads ${params.threads} \\
        --verbose 1 \\
        --out diann_empirical_DIA.parquet \\
        --qvalue ${params.qvalue} \\
        --matrices \\
        --xic \\
        --reannotate \\
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
        --out-lib diann_empirical_DIA_lib.parquet \\
        --met-excision \\
        --min-pep-len ${params.min_pep_len_2} \\
        --max-pep-len ${params.max_pep_len_2} \\
        --min-pr-mz ${params.min_pr_mz_2} \\
        --max-pr-mz ${params.max_pr_mz_2} \\
        --min-pr-charge ${params.min_pr_charge_2} \\
        --max-pr-charge ${params.max_pr_charge_2} \\
        --cut K*,R* \\
        --missed-cleavages 1 \\
        --mass-acc ${params.mass_acc_2} \\
        --mass-acc-ms1 ${params.mass_acc_ms1_2} \\
        --species-genes \\
        --species-ids \\
        --reanalyse
    """
}
