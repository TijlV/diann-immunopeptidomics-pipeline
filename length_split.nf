include { empirical_lib_creation } from './modules/empirical_lib_creation.nf'
include { len_lib_creation } from './modules/len_lib_creation.nf'
include { infinDIA } from './modules/infinDIA.nf'
include { diann_run1 } from './modules/diann_run1.nf'
include { diann_mbr_run } from './modules/diann_mbr_run.nf'

workflow {
    if (params.generate_libs) {
        // Generate empirical lib
        empirical_lib_creation(params.fasta, params.crap_fasta)
        empirical_lib_ch = empirical_lib_creation.out

        // Generate per-length libs
        lib_out_ch = channel.from(params.lib_ranges_len)
            .map { len -> [len, params.fasta, params.crap_fasta] }
        len_lib_creation(lib_out_ch)
        len_libs_ch = len_lib_creation.out
    } 
    else {
        // Retrieve existing empirical lib
        empirical_lib_ch = channel.fromPath("${params.empirical_lib}/*.predicted.speclib")
            .first()

        // Retrieve existing per-length libs
        len_libs_ch = channel.fromPath("${params.len_libs}/lib_len*.predicted.speclib")
            .map { path ->
                def len = path.name.toString().find(/(?<=lib_len)\d+/)?.toInteger()
                [len, path]
            }
    }
    
    // infiniDIA run
    infiniDIA_ch = empirical_lib_ch
        .map { path -> [params.dia_files, params.fasta, params.crap_fasta, path] }

    infinDIA(infiniDIA_ch)

    // DIA-NN run per length
    diann_run1_ch = len_libs_ch
        .combine(infinDIA.out)
        .map { len, lib_file, ref_lib_file ->
            [len, params.dia_files, params.fasta, params.crap_fasta, lib_file, ref_lib_file]
        }
    diann_run1(diann_run1_ch)

    // DIA-NN MBR run
    diann_run2_ch = diann_run1.out
        .map { _len, _parquet, lib, _log, _manifest, _gg, _pg, _pr, _prot, _stats, _site, _genes -> lib }
        .collect()
        .map { libs -> [params.dia_files, params.fasta, params.crap_fasta, libs] }
    diann_mbr_run(diann_run2_ch)
}