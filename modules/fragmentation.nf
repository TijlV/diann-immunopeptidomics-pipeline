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

    # Use the input files provided to the process
    fastas = ["$fasta", "$crap_fasta"]
    aa = {'A','C','D','E','F','G','H','I','K','L','M','N','P','Q','R','S','T','V','W','Y'}
    peptides = set()

    for fasta in fastas:
        for record in SeqIO.parse(fasta, "fasta"):
            seq = str(record.seq)
            peptides.update(cleave(sequence=seq, rule=r"(?<=[A-Z])", missed_cleavages=12, min_length=8, max_length=12))

    print(f"There were {len(peptides)} peptides generated")

    with open("peptides.txt", "w", encoding="utf-8") as f:
        saved = 0
        for peptide in peptides:
            if set(peptide).issubset(aa):
                saved += 1
                f.write(f"{peptide}\\n")

    print(f"There were {saved} peptides saved")
    """
}
