nextflow.enable.dsl=2

include { 
    get_subtree
} from "./processes.nf"

workflow {

    log.info"""
    == DIRECTORIES ==
    baseDir             = ${baseDir}
    outdir              = ${params.outdir}
    == INPUT FILES ==
    loci                = ${params.loci}
    taxa_list           = ${params.taxa_list}
    gtdb_tree           = ${params.gtdb_tree}
    == INPUT PARAMETERS ==
    n_training_loci     = ${params.n_training_loci}
    k_max               = ${params.k_max}
    == JOB SPECS ==
    n_threads           = ${params.n_threads}
    executor            = ${params.executor}
    """
 
    loci_ch = Channel.fromPath(params.loci)
    taxa_list_ch = Channel.fromPath(params.taxa_list)
    gtdb_tree_ch = Channel.fromPath(params.gtdb_tree)
    n_training_loci_ch = Channel.from(params.n_training_loci)

    
    gtdb_tree_ch
        .combine(taxa_list_ch) |
        get_subtree
}   
