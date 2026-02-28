#!/usr/bin/env nextflow
include { emperical_lib_creation_len } from './modules/emperical_lib_creation.nf'
include { lib_creation } from './modules/lib_creation.nf'
include { infinDIA } from './modules/infinDIA.nf'
include { diann_run1 } from './modules/diann_run1.nf'
include { diann_run2 } from './modules/diann_run2.nf'

workflow {
    if ( params.generate_libs ) {
        // Make z1/z2/z3 libraries
        lib_creation_ch = channel.from(params.lib_ranges)
            .map { it -> [it.min_pr_mz, it.max_pr_mz, it.charge, params.fasta, params.crap_fasta] }

        lib_creation(lib_creation_ch)
        lib_out_ch = lib_creation.out

        // Make empirical library
        emperical_lib_creation_len(params.fasta, params.crap_fasta)
        ref_lib = emperical_lib_creation_len.out
    }
    else {
        lib_files_with_charge = params.lib_ranges.collect { range -> [range.charge, file(params["lib_z${range.charge}"])] } 
        lib_out_ch = channel.from(lib_files_with_charge)
    }

    // Make calibration librarby
    infiniDIA_ch = emperical_lib_creation_len.out
        .map { path -> [params.dia_files, params.fasta, params.crap_fasta, path] }
    
    infinDIA(infiniDIA_ch)

    // DIA-NN run 1
    diann_run1_ch = lib_out_ch
        .combine(ref_lib)
        .map { charge, lib_file, ref_lib_file ->
            [charge, params.dia_files, params.fasta, params.crap_fasta, lib_file, ref_lib_file]
        }
    
    diann_run1(diann_run1_ch)
    
    // DIA-NN run 2
    diann_run1_out = diann_run1.out
        .groupTuple()

    diann_run1_libs = diann_run1_out
        .map { files -> files.find { f -> f.toString().contains('_lib.parquet') } }

    diann_run2_ch = diann_run1_libs
        .toList()
        .map { libs -> [params.dia_files, params.fasta, params.crap_fasta, libs[0], libs[1], libs[2]] }

    diann_run2(diann_run2_ch)
}
