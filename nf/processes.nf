nextflow.enable.dsl=2

process subset_taxa {

    publishDir "${params.outdir}/00_subset_taxa/${taxa_list.baseName}"

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

    publishDir "${params.outdir}/01_alistat/${taxa_list}"
    
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

    publishDir "${params.outdir}/01_alistat/"

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

    publishDir "${params.outdir}/02_loci_assignment", saveAs: { filename -> "${taxa_list}_${filename}"}

    input:
        tuple path(combined_stats), val(taxa_list), val(n_training_loci)

    output:
        tuple path("training_loci.txt"), path("testing_loci.txt"), val(taxa_list)
        path "completeness.png"

    script:
    """
    subset_loci_ca.R $combined_stats $n_training_loci
    """

}

process arrange_loci {

    input:
        tuple path(training_loci), path(testing_loci), val(taxa_list)

    output:
        val taxa_list

    shell:
    '''
    LOCIDIR="!{params.outdir}/00_subset_taxa/!{taxa_list}/"
    PUBLISHDIR="!{params.outdir}/03_subset_loci/!{taxa_list}"
    mkdir -p ${PUBLISHDIR}/training_loci ${PUBLISHDIR}/testing_loci

    for fasta in ${LOCIDIR}/*; do
        if grep `basename $fasta` !{training_loci}; then
            cp -P $fasta ${PUBLISHDIR}/training_loci
        elif grep `basename $fasta` !{testing_loci}; then
            cp -P $fasta ${PUBLISHDIR}/testing_loci
        else
            echo "Alignment not found"
            exit 1
        fi
    done
    '''

}

process estimate_Q {

    publishDir "${params.outdir}/04_Q_train/${taxa_list}"

    input:
        val taxa_list

    output:
        "i*/i*.parstree"
        "i*/i*.model.gz"
        "i*/i*.best_scheme.nex"
        "i*/i*.best_scheme"
        "i*/i*.trefile"
        "i*/i*.log"
        "i*/i*.iqtree"
        "i*/i*.ckp.gz"
        "i*/i*.best_model.nex"
        "i*/Q.bac_locus_i*"
        "i*/i*.GTR2O.treefile"
        "i*/i*.GTR2O.log"
        "i*/i*.GTR2O.iqtree"
        "i*/i*.GTR2O.ckp.gz"
        "i*/i*.GTR2O.best_model.nex"
        "i*/i*.F.bac_locus_i*"

    script:
    """
    estimate_q.py --loci ${params.outdir}/03_subset_loci/${taxa_list}/training_loci/
    """      
}
