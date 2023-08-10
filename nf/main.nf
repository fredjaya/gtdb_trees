nextflow.enable.dsl=2

include { 
    subset_taxa 
    alistat
    cat_stats
    id_train_test_loci
    arrange_loci
    estimate_Q_unconstrained
    estimate_Q_constrained
    test_loci_estimated_Q
    test_loci_existing_Q
} from "./processes.nf"

workflow {

    log.info"""
    baseDir             = ${baseDir}
    outdir              = ${params.outdir}
    loci                = ${params.loci}
    taxa_list           = ${params.taxa_list}
    n_training_loci     = ${params.n_training_loci}
    unconstrained       = ${params.unconstrained}
    existing            = ${params.existing}
    constraint_tree     = ${params.constraint_tree}
    n_threads           = ${params.n_threads}
    executor            = ${params.executor}
    """
    if ( !params.loci ) {
        println "Please specify --loci \"path/to/loci/*.faa\""
        exit 0
    }
    if ( !params.taxa_list ) {
        println "Please specify --taxa_list \"path/to/taxa/lists/*.txt\""
        exit 0
    }
    if ( !params.unconstrained & !params.existing & !params.constraint_tree) {
        println "Choose at least one of --unconstrained, --existing, or --constraint_tree [*.tree]"
        exit 0
    }
 
    loci_ch = Channel.fromPath(params.loci)
    taxa_list_ch = Channel.fromPath(params.taxa_list)
    n_training_loci_ch = Channel.from(params.n_training_loci)

    loci_ch.combine(taxa_list_ch) | 
        subset_taxa | 
        alistat | 
        groupTuple(by: 1) |
        cat_stats | 
        combine(n_training_loci_ch) |
        id_train_test_loci

        arrange_loci(id_train_test_loci.out[0])

        /*
         * Note: in the following steps, the path to training/testing loci are
         * hardcoded because they are deterministic, and the estimate_q.py
         * script takes absolute paths as input.
         * 
         * The only thing arrange_loci.out emits is ${taxa}. Any other channel
         * could be used here, but arrange_loci is used as it is the last
         * process used.
         */ 

        if ( params.unconstrained ) {
            arrange_loci.out | estimate_Q_unconstrained
        }

        if ( params.constraint_tree ) {
            constraint_tree_ch = Channel.from(params.constraint_tree)
            // Add concat_loci
            arrange_loci.out.combine(constraint_tree_ch) | 
                estimate_Q_constrained
        }
        if ( params.existing )  {
            arrange_loci.out | test_loci_existing_Q
        }

    /*
     * Having only a single iteration is impossible outside of testing,
     * but doesn't hurt to keep here I guess.
    estimate_Q.out[0].map{ it -> 
        if( it[0].getClass() == sun.nio.fs.UnixPath) { 
            println "WARNING: Only a single iteration of Q estimated for ${it[1]}"
            return it
        } 
        else { 
            return tuple(it[0][-2], it[1])
        }
    } | test_loci_estimated_Q
     */
}   
