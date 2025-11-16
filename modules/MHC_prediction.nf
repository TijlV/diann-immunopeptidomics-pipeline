#!/usr/bin/env nextflow

process MHC_prediction {
    input:
    val mixMHC_path
    val alleles
    path peptides
    val threshold

    output:
    path "output.fasta"

    script:
    """
    # Do the MHC predictions
    $mixMHC_path -i $peptides -o predicted_peptides.txt -a $alleles

    # Only save top xx peptides
    grep -v '^#' predicted_peptides.txt | awk '\$4 < $threshold {print \$1}' > output.txt

    # Convert to fasta
    awk 'NR > 1 {print ">peptide_"NR"\\n"\$0}' output.txt > output.fasta
    """
}
