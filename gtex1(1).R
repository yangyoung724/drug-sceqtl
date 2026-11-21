

library(data.table)
library(foreach)

setwd("G:/drug_sceQTL/3_GTXeqtl/1_step1")

all_dfd=fread("Whole_Blood.v10.eQTLs.txt.gz")


genelist=read.table("eQTLGeneqtl_result.txt",header = T,sep = "\t")

genelist1=as.vector(genelist$id)


foreach(i=genelist1, .errorhandling = "pass") %do%{
  
  myeqtl=all_dfd[all_dfd$external_gene_name==i,]
  
  fwrite(myeqtl,file = paste0("no_clump/",i,".txt"),sep = "\t",quote = F)
}
