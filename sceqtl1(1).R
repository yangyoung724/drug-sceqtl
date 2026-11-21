

library(data.table)
library(foreach)

geneid=read.table("gene_id.txt",header = T,sep = "\t")
cellid=read.table("cell_id.txt",header = T,sep = "\t")
geneid1=as.vector(geneid$id)
cellid2=as.vector(cellid$id)
#i=geneid1[1]
j=cellid2[1]
idre=data.frame()
foreach(j=cellid2, .errorhandling = "pass") %do%{
  foreach(i=geneid1, .errorhandling = "pass") %do%{
    mydata=fread(file = paste0("scQTL/",j,".txt.gz"))
    mygeneqtl=subset(mydata,mydata$GENE==i)
    
    fwrite(mygeneqtl,file = paste0("no_clump/",i,"_",j,".txt"),quote = F,sep = "\t")
    idre=rbind(idre,paste0(i,"_",j))
    
  }
}
colnames(idre)="id"
write.table(idre,"gene_cell_id.txt",sep = "\t",row.names = F,quote = F)
