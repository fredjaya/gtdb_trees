nextflow.enable.dsl=2
process subset_taxa {
    publishDir "${params.outdir}/${taxa_list.baseName}/00_subset_taxa/"

    input:
        tuple path(locus), path(taxa_list)

    output:
        tuple path("${locus}_subtaxa"), val("${taxa_list.baseName}")

    script:
    """
    faSomeRecords.py --fasta $locus --list $taxa_list --outfile ${locus}_subtaxa
    """

}

process remove_empties {

    publishDir "${params.outdir}/${taxa_list.baseName}/00_subset_taxa/"

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

    publishDir "${params.outdir}/${taxa}/01_alistat/"
    
    input:
        tuple path(locus_subtaxa), val(taxa)

    output:
        tuple path("${locus_subtaxa}_alistat"), val("${taxa}")

    script:
    """
    alistat ${locus_subtaxa} 6 -b | tail -n1 > ${locus_subtaxa}_alistat
    """

}

process cat_stats {

    publishDir "${params.outdir}/${taxa}/01_alistat/"

    input:
        tuple path(alistats), val(taxa)

    output:
        tuple path("${taxa}_alistats.csv"), val(taxa)

    script:
    """
    cat $alistats > ${taxa}_alistats.csv
    """

}

process id_train_test_loci {

    publishDir "${params.outdir}/${taxa}/02_loci_assignment", saveAs: { filename -> "${taxa}_${filename}"}

    input:
        tuple path(combined_stats), val(taxa), val(n_training_loci)

    output:
        tuple path("training_loci.txt"), path("testing_loci.txt"), val(taxa)
        path "completeness.png"

    script:
    """
    subset_loci_ca.R $combined_stats $n_training_loci
    """

}

process arrange_loci {

    input:
        tuple path(training_loci), path(testing_loci), val(taxa)

    output:
        val taxa

    shell:
    '''
    LOCIDIR="!{params.outdir}/!{taxa}/00_subset_taxa/"
    PUBLISHDIR="!{params.outdir}/!{taxa}/03_subset_loci/"
    mkdir -p ${PUBLISHDIR}/training_loci ${PUBLISHDIR}/testing_loci

    for fasta in ${LOCIDIR}/*; do
        if grep `basename $fasta` !{training_loci}; then
            cp -P $fasta ${PUBLISHDIR}/training_loci
        elif grep `basename $fasta` !{testing_loci}; then
            cp -P $fasta ${PUBLISHDIR}/testing_loci
        else
            echo "$fasta not found. Possibly Ca == 0"
        fi
    done
    '''

}

process estimate_Q {

    publishDir "${params.outdir}/${taxa}/04_Q_train/"

    input:
        val taxa

    output:
        tuple path("Q.bac_locus_i*"), val(taxa)
        path "i*.parstree"
        path "i*.model.gz"
        path "i*.best_scheme.nex"
        path "i*.best_scheme"
        path "i*.treefile"
        path "i*.log"
        path "i*.iqtree"
        path "i*.ckp.gz"
        path "i*.best_model.nex"
        path "Q.bac_locus_i*"
        path "i*.GTR20.treefile"
        path "i*.GTR20.log"
        path "i*.GTR20.iqtree"
        path "i*.GTR20.ckp.gz"
        path "i*.GTR20.best_model.nex"
        path "F.bac_locus_i*"

    script:
    """
    estimate_q.py --loci ${params.outdir}/${taxa}/03_subset_loci/training_loci/
    """      
}

process test_loci_estimated_Q {

    publishDir "${params.outdir}/${taxa}/05_Q_test_loci"

    input:
        tuple path(estimated_Q), val(taxa)

    output:
        path "Q.bac_locus_i*.parstree"
        path "Q.bac_locus_i*.model.gz"
        path "Q.bac_locus_i*.best_scheme.nex"
        path "Q.bac_locus_i*.best_scheme"
        path "Q.bac_locus_i*.treefile"
        path "Q.bac_locus_i*.log"
        path "Q.bac_locus_i*.iqtree"
        path "Q.bac_locus_i*.ckp.gz"
        path "Q.bac_locus_i*.best_model.nex"

    script:
    """
    iqtree2 -seed 1 -T 4 -mset ${estimated_Q} -S ${params.outdir}/${taxa}/03_subset_loci/testing_loci/ -pre ${estimated_Q}
    """

}

process test_loci_existing_Q {

    publishDir "${params.outdir}/${taxa}/05_Q_test_loci"

    input:
        val(taxa)

    output:
        path "existing_Q.parstree"
        path "existing_Q.model.gz"
        path "existing_Q.best_scheme.nex"
        path "existing_Q.best_scheme"
        path "existing_Q.treefile"
        path "existing_Q.log"
        path "existing_Q.iqtree"
        path "existing_Q.ckp.gz"
        path "existing_Q.best_model.nex"

    script:
    """
    iqtree2 -seed 1 -T 4 -S ${params.outdir}/${taxa}/03_subset_loci/testing_loci/ -m MFP -pre existing_Q
    """

}

process test_loci_all_mset {
    /*
     * This tests all existing and new Qs at the same time.
     * Currently unused as existing and new Qs to be tested separately
     * to observe effect of new models on locus trees.
     */
    
    publishDir "${params.outdir}/${taxa}/05_Q_test_loci"

    input:
        tuple path(estimated_Q), val(taxa)

    output:
        path "Q.bac_locus_i*.parstree"
        path "Q.bac_locus_i*.model.gz"
        path "Q.bac_locus_i*.best_scheme.nex"
        path "Q.bac_locus_i*.best_scheme"
        path "Q.bac_locus_i*.treefile"
        path "Q.bac_locus_i*.log"
        path "Q.bac_locus_i*.iqtree"
        path "Q.bac_locus_i*.ckp.gz"
        path "Q.bac_locus_i*.best_model.nex"

    script:
    """
    iqtree2 -seed 1 -T 4 -m MFP -pre test_mset_all \
        -S ${params.outdir}/03_subset_loci/${taxa}/testing_loci/ \
        -mset "${estimated_Q},Blosum62,cpREV,Dayhoff,DCMut,FLAVI,FLU,HIVb,HIVw,JTT,JTTDCMut,LG,mtART,mtMAM,mtREV,mtZOA,mtMet,mtVer,mtInv,PMB,Q.bird,Q.insect,Q.mammal,Q.pfam,Q.plant,Q.yeast,rtREV,VT,WAG"
    """

}
