#!/usr/bin/env nextflow

include { lib_creation } from './modules/lib_creation.nf'
include { fragmentation } from './modules/fragmentation.nf'
include { MHC_prediction } from './modules/MHC_prediction.nf'
include { ref_lib_creation } from './modules/ref_lib_creation.nf'
include { diann_run1 } from './modules/diann_run1.nf'
include { diann_run2 } from './modules/diann_run2.nf'

workflow {
    if ( params.generate_libs ) {
        // Make z1/z2/z3 libraries
        lib_creation_ch = channel.from(params.lib_ranges)
            .map { it -> [it.min_pr_mz, it.max_pr_mz, it.charge, params.fasta, params.crap_fasta] }

        lib_creation(lib_creation_ch)
        lib_out_ch = lib_creation.out
    }
    else {
        lib_files_with_charge = params.lib_ranges.collect { range -> [range.charge, file(params["lib_z${range.charge}"])] } 
        lib_out_ch = channel.from(lib_files_with_charge)
    }

    // Make calibration librarby
    // Fragment the proteins
    fragmentation(params.fasta, params.crap_fasta)

    // Do MHC predictions
    MHC_prediction(params.mixMHC_path, params.alleles, fragmentation.out, params.threshold)

    // Generate calibration library
    ref_lib_creation(params.min_pr_mz_ref, params.max_pr_mz_ref, params.min_pr_charge, params.max_pr_charge, MHC_prediction.out)
    ref_lib = ref_lib_creation.out

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
        .map { files -> files.find { it.toString().contains('_lib.parquet') } }

    diann_run2_ch = diann_run1_libs
        .toList()
        .map { libs -> [params.dia_files, params.fasta, params.crap_fasta, libs[0], libs[1], libs[2]] }

    diann_run2(diann_run2_ch)
}
