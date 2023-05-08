nextflow.enable.dsl=2

process subset_taxa {

    publishDir "${params.outdir}/${taxa_list.baseName}"

    input:
        tuple path(locus), path(taxa_list)

    output:
        tuple path("${locus}_subtaxa"), val("${taxa_list.baseName}")

    script:
    """
    faSomeRecords.py --fasta $locus --list $taxa_list --outfile ${locus}_subtaxa
    """

}

process alistat {

    publishDir "${params.outdir}/alistat/${taxa_list}"
    
    input:
        tuple path(locus_subtaxa), val(taxa_list)

    output:
        tuple path("${locus_subtaxa}_alistat"), val("${taxa_list}")

    script:
    """
    alistat ${locus_subtaxa} 6 -b | tail -n1 > ${locus_subtaxa}_alistat
    """

}

process cat_stats {

    publishDir "${params.outdir}/alistat/"

    input:
        tuple path(alistats), val(taxa_list)

    output:
        tuple path("${taxa_list}_alistats.csv"), val(taxa_list)

    script:
    """
    cat $alistats > ${taxa_list}_alistats.csv
    """

}

process id_train_test_loci {

    publishDir "${params.outdir}/alistat/", saveAs: { filename -> "${taxa_list}_${filename}"}

    input:
        tuple path(combined_stats), val(taxa_list), val(n_training_loci)

    output:
        path "training_loci.txt"
        path "testing_loci.txt"
        path "completeness.png"


    script:
    """
    subset_loci_ca.R $combined_stats $n_training_loci
    """

}
