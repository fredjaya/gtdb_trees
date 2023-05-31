# Nested aquificota  

Estimation of Q-matrices for each taxonomic rank within the aquificota phylum.  

100 training, 20 test loci.  

Parameters configured in `nextflow.config`.  

Run workflow:  
```
nextflow run ~/GitHub/gtdb_trees/nf/main.nf
```  

Next steps: Parse all test BICs and compare between estimated_Q and existing_Q!

So far all estimated_Q are a better fit than existing_Qs!
