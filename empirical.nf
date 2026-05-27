#!/usr/bin/env nextflow

include { empirical_lib_creation } from './modules/empirical_lib_creation'
include { infinDIA } from './modules/infinDIA'
include { empirical_diann_run } from './modules/empirical_diann_run'

workflow {
    if (params.generate_libs) {
        // Generate empirical lib
        empirical_lib_creation(params.fasta, params.crap_fasta)
        empirical_lib_ch = empirical_lib_creation.out
    }
    else {
        // Retrieve existing empirical lib
        empirical_lib_ch = channel.fromPath("${params.empirical_lib}/*.predicted.speclib")
            .first()
    }

    // infinDIA run to refine the empirical library
    infinDIA_ch = empirical_lib_ch
        .map { lib -> [params.dia_files, params.fasta, params.crap_fasta, lib] }
    infinDIA(infinDIA_ch)

    // DIA-NN run
    empirical_diann_ch = empirical_lib_ch
        .combine(infinDIA.out)
        .map { lib, ref_lib -> [params.dia_files, params.fasta, params.crap_fasta, lib, ref_lib] }
    empirical_diann_run(empirical_diann_ch)
}
