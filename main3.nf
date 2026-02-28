include { emperical_lib_creation_len } from './modules/emperical_lib_creation.nf'
include { lib_creation_len } from './modules/lib_creation_len.nf'
include { infinDIA } from './modules/infinDIA.nf'
include { diann_run1_len } from './modules/diann_run1_len.nf'
include { diann_run2_len } from './modules/diann_run2_len.nf'

workflow {
    // Make empirical library
    emperical_lib_creation_len(params.fasta, params.crap_fasta)

    // Library ranges
    // TO DO ADD TO CONFIG
    lib_ranges_len = [8, 9, 10, 11, 12]

    // Make libraries splitting by lenght
    lib_out_ch = channel.from(lib_ranges_len)
        .map { len -> [len, params.fasta, params.crap_fasta] }
    lib_creation_len(lib_out_ch)

    // TO DO REMOVE AND COMBINE PREV LIBS
    // Make infiniDIA reference library
    infiniDIA_ch = emperical_lib_creation_len.out
        .map { path -> [params.dia_files, params.fasta, params.crap_fasta, path] }
    
    infinDIA(infiniDIA_ch)

    // DIA-NN run 1 — combine per-length lib with ref lib
    diann_run1_ch = lib_creation_len.out
        .combine(infinDIA.out)
        .map { len, lib_file, ref_lib_file ->
            [len, params.dia_files, params.fasta, params.crap_fasta, lib_file, ref_lib_file]
        }
    diann_run1_len(diann_run1_ch)

    // DIA-NN run 2 — collect all per-length libs
    diann_run1_libs = diann_run1_len.out
        .map { _len, _parquet, lib, _log, _manifest, _gg, _pg, _pr, _prot, _stats, _site, _genes -> lib }
        .collect()
        .map { libs -> [params.dia_files, params.fasta, params.crap_fasta, libs] }
    diann_run2_len(diann_run1_libs)
}