#!/usr/bin/env nextflow

process fragmentation {

    input:
    path fasta
    path crap_fasta

    output:
    path 

    script:
    """
    #!/usr/bin/env python

    from pyteomics.parser import cleave
    from Bio import SeqIO

    fastas = ["${crap_fasta}", "${fasta}"]
    peptides = set()

    for fasta in fastas:
        for record in SeqIO.parse(fasta, "fasta"):
            seq = str(record.seq)
            
            peptides.update(cleave(sequence=seq, rule=r"(?<=[A-Z])", missed_cleavages=12, min_length=8, max_length=12))

    print(len(peptides))
    """
    }
