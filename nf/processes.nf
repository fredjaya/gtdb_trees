nextflow.enable.dsl=2

process subset_taxa {

    publishDir "${params.out_dir}/${taxa_list.baseName}"

    input:
        tuple path(locus), path(taxa_list)

    output:
        path "${locus}_subtaxa"

    script:
    """
    faSomeRecords.py --fasta $locus --list $taxa_list --outfile ${locus}_subtaxa
    """

}
