nextflow.enable.dsl=2

include { 
    subset_taxa 
    alistat
    cat_stats
    id_train_test_loci
} from "./processes.nf"

locus_ch = Channel.fromPath(params.locus)
taxa_list_ch = Channel.fromPath(params.taxa_list)
n_training_loci_ch = Channel.from(params.n_training_loci)

workflow {

    log.info"""
    baseDir = ${baseDir}
    outdir = ${params.outdir}
    locus = ${params.locus}
    taxa_list = ${params.taxa_list}
    n_training_loci = ${params.n_training_loci}
    """
    
    locus_ch.combine(taxa_list_ch) | 
        subset_taxa | 
        alistat | 
        groupTuple(by: 1) |
        cat_stats | 
        combine(n_training_loci_ch) |
        id_train_test_loci
}   
