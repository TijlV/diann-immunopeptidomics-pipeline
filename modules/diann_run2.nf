#!/usr/bin/env nextflow

process diann_run2 {
    publishDir "${params.outDir}/emperical", mode: 'copy'
    container 'paretje/diann:2.2.0'

    input:
    tuple path(dia_files), path(fasta), path(crap_fasta), path(lib1), path(lib2), path(lib3)

    output:
    path "diann_emperical_DIA.parquet"
    path "diann_emperical_DIA.site_report.parquet"
    path "diann_emperical_DIA.pr_matrix.tsv"
    path "diann_emperical_DIA.pg_matrix.tsv"
    path "diann_emperical_DIA.gg_matrix.tsv"
    path "diann_emperical_DIA.unique_genes_matrix.tsv"
    path "diann_emperical_DIA.manifest.txt"
    path "diann_emperical_DIA.stats.tsv"
    path "diann_emperical_DIA.log.txt"

    script:
    """
    F_FILES=\$(for f in ${dia_files}/*.d; do echo -n "--f \$f "; done)

    /diann-2.2.0/diann-linux \\
        --threads ${params.threads} \\
        --verbose 1 \\
        --out diann_report_emperical.parquet \\
        --qvalue ${params.qvalue} \\
        --matrices \\
        --reannotate \\
        --xic \\
        \$F_FILES \\
        --lib ${lib1} \\
        --lib ${lib2} \\
        --lib ${lib3} \\
        --out "diann_emperical_DIA.parquet" \\
        --fasta ${crap_fasta} \\
        --fasta ${fasta} \\
        --met-excision \\
        --var-mod ${params.var_mod} \\
        --min-pep-len ${params.min_pep_len_2} \\
        --max-pep-len ${params.max_pep_len_2} \\
        --min-pr-mz ${params.min_pr_mz_2} \\
        --max-pr-mz ${params.max_pr_mz_2} \\
        --min-pr-charge ${params.min_pr_charge} \\
        --max-pr-charge ${params.max_pr_charge} \\
        --cut K*,R* \\
        --missed-cleavages 1 \\
        --mass-acc ${params.mass_acc} \\
        --mass-acc-ms1 ${params.mass_acc_ms1} \\
        --rt-profiling \\
        --species-genes \\
        --species-ids
    """
}
