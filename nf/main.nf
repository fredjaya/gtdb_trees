nextflow.enable.dsl=2

include { subset_taxa } from "./processes.nf"

locus_ch = Channel.fromPath(params.locus)
taxa_list_ch = Channel.fromPath(params.taxa_list)

workflow {

    log.info"""
    out_dir = ${params.out_dir}
    locus = ${params.locus}
    taxa_list = ${params.taxa_list} 
    """
    
    locus_ch.combine(taxa_list_ch) |
    subset_taxa
    
}
