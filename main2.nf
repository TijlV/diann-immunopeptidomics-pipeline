#!/usr/bin/env nextflow

include { diann23test } from './modules/diann2.3-test.nf'
include { diann_run1 } from './modules/diann_run1.nf'

workflow {
    lib_files_with_charge = params.lib_ranges.collect { range -> [range.charge, file(params["lib_z${range.charge}"])] }
        lib_out_ch = channel.from(lib_files_with_charge)

    diann23test(params.dia_files, params.min_pr_mz_ref, params.max_pr_mz_ref, params.min_pr_charge, params.max_pr_charge, params.fasta, params.crap_fasta)
    ref_lib = diann23test.out

    // DIA-NN run 1
    diann_run1_ch = lib_out_ch
        .combine(ref_lib)
        .map { charge, lib_file, ref_lib_file ->
            [charge, params.dia_files, params.fasta, params.crap_fasta, lib_file, ref_lib_file]
        }
    
    diann_run1(diann_run1_ch)
}
