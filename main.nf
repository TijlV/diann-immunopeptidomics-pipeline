include { emperical_lib_creation_len } from './modules/emperical_lib_creation.nf'
include { len_lib_creation } from './modules/len_lib_creation.nf'
include { infinDIA } from './modules/infinDIA.nf'
include { diann_run1 } from './modules/diann_run1.nf'
include { diann_mbr_run } from './modules/diann_mbr_.nf'

workflow {
    // Make empirical library
    emperical_lib_creation_len(params.fasta, params.crap_fasta)

    // Make libraries splitting by lenght
    lib_out_ch = channel.from(params.lib_ranges_len)
        .map { len -> [len, params.fasta, params.crap_fasta] }
    len_lib_creation(lib_out_ch)

    // Make infiniDIA reference library
    infiniDIA_ch = emperical_lib_creation_len.out
        .map { path -> [params.dia_files, params.fasta, params.crap_fasta, path] }
    
    infinDIA(infiniDIA_ch)

    // DIA-NN run per length
    diann_run1_ch = len_lib_creation.out
        .combine(infinDIA.out)
        .map { len, lib_file, ref_lib_file ->
            [len, params.dia_files, params.fasta, params.crap_fasta, lib_file, ref_lib_file]
        }
    diann_run1(diann_run1_ch)

    // DIA-NN MBR run
    diann_run1_libs = diann_run1.out
        .map { _len, _parquet, lib, _log, _manifest, _gg, _pg, _pr, _prot, _stats, _site, _genes -> lib }
        .collect()
        .map { libs -> [params.dia_files, params.fasta, params.crap_fasta, libs] }
    diann_mbr_run(diann_run1_libs)
}