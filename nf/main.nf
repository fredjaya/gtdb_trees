nextflow.enable.dsl=2

include { 
    subset_taxa 
    alistat
    cat_stats
    id_train_test_loci
    arrange_loci
    estimate_Q
    test_loci_estimated_Q
    test_loci_existing_Q
} from "./processes.nf"

loci_ch = Channel.fromPath(params.loci)
taxa_list_ch = Channel.fromPath(params.taxa_list)
n_training_loci_ch = Channel.from(params.n_training_loci)

workflow {

    log.info"""
    baseDir = ${baseDir}
    outdir = ${params.outdir}
    loci = ${params.loci}
    taxa_list = ${params.taxa_list}
    n_training_loci = ${params.n_training_loci}
    """
   
    loci_ch.combine(taxa_list_ch) | 
        subset_taxa | 
        alistat | 
        groupTuple(by: 1) |
        cat_stats | 
        combine(n_training_loci_ch) |
        id_train_test_loci
        arrange_loci(id_train_test_loci.out[0]) |
        estimate_Q & test_loci_existing_Q

    /*
     * Having only a single iteration is impossible outside of testing,
     * but doesn't hurt to keep here I guess.
     */
    estimate_Q.out[0].map{ it -> 
        if( it[0].getClass() == sun.nio.fs.UnixPath) { 
            println "WARNING: Only a single iteration of Q estimated for ${it[1]}"
            return it
        } else { 
            return tuple(it[0][-2], it[1])
        }
    } | test_loci_estimated_Q
}   
