#!/usr/bin/env nextflow

process fragmentation {

    input:
    path fasta
    path crap_fasta

    output:
    path "peptides.txt"

    script:
    """
    #!/usr/bin/env python

    from pyteomics.parser import cleave
    from Bio import SeqIO

    fastas = ["/public/compomics2/tijl/diaBacterialEpitopes/data/crap.fasta", "/public/compomics2/tijl/diaBacterialEpitopes/data/EGD_human.fasta"]
    allowed_aa = ['A','C','D','E','F','G','H','I','K','L','M','N','P','Q','R','S','T','V','W','Y']
    peptides = set()

    for fasta in fastas:
        for record in SeqIO.parse(fasta, "fasta"):
            seq = str(record.seq)
            
            peptides.update(cleave(sequence=seq, rule=r"(?<=[A-Z])", missed_cleavages=12, min_length=8, max_length=12))

    print(f"There were {len(peptides)} peptides generated")

    with open("peptides.txt", "w", encoding="utf-8") as f:
        saved = 0
        for peptide in peptides:
            if all(aa in allowed_aa for aa in peptide):
                saved += 1
                f.write(f"{peptide}\n")

    print(f"There were {saved} peptides saved")

    """
    }
