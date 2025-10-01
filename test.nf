#!/usr/bin/env nextflow

include { fragmentation } from './modules/fragmentation.nf'

workflow {
    fragmentation(params.fasta, params.crap_fasta)
}