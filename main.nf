#!/usr/bin/env nextflow

include { lib_creation } from './modules/lib_creation.nf'
// include { ref_lib_creation } from './modules/ref_lib_creation.nf'
include { diann_run1 } from './modules/diann_run1.nf'
// include { diann_run2 } from './modules/diann_run2.nf'

workflow {
    // make z1/z2/z3 libraries
    lib_out_ch = Channel.from(params.lib_ranges)
        | map {it -> [it.min_pr_mz, it.max_pr_mz, it.charge, params.fasta, params.crap_fasta]}
        | lib_creation

    // make MHC prediction librarby

    // run DIA-NN with 3 different libs --> create run1 libs
     diann_run1_ch = lib_out_ch
        | map { charge, lib_file -> [charge, params.dia_files, params.fasta, params.crap_fasta, lib_file, params.ref_lib] }

    diann_run1(diann_run1_ch)

    // perform 2nd DIA-NN run using run1 libs

}
