#1 - Counting DNA Nucleotides
countBases <- function(dnaseq){
  #returns nucleotide counts in this order - A C G T
  dnaseq.vector = strsplit(dnaseq, "")[[1]]#should split between each character
  counts = as.data.frame(table(dnaseq.vector))
  print(counts[,"Freq"])
}
#countBases("AGCTTTTCATTCTGACTGCAACGGGCAATATGTCTCTGTGTGGATTAAAAAAAGAGTGTCTGATAGCAGC")
#[1] 20 12 17 21


#2 - Transcribing DNA into RNA
UforT <- function(dnaseq){
  gsub("T", "U", dnaseq)
}
#UforT("GATGGAACTTGACTACGTAAATT")
#"GAUGGAACUUGACUACGUAAAUU"


#3 - Complementing a Strand of DNA
revComp <- function(dnaseq){
  #dnaseq.vector = strsplit(dnaseq, "") - moving to end; performance?
  dnaseq = gsub("A", "-", dnaseq)#ugly - come up with something nicer
  dnaseq = gsub("T", "A", dnaseq)
  dnaseq = gsub("-", "T", dnaseq)
  
  dnaseq = gsub("C", "-", dnaseq)
  dnaseq = gsub("G", "C", dnaseq)
  dnaseq = gsub("-", "G", dnaseq)
  
  dnaseq.vector = strsplit(dnaseq, "")[[1]]
  rc = rev(dnaseq.vector)
  print(paste(rc, collapse = ""))
}
#revComp("AAAACCCGGT")
#ACCGGGTTTT


#4 - Rabbits and Recurrence Relations
recRabbits <- function(nkstring){
  INITIAL = 1
  
  input = strsplit(nkstring, " ")[[1]]
  n = as.integer(input[1]); k = as.integer(input[2])
  
  rabbits = integer()
  rabbits[1] = INITIAL
  rabbits[2] = INITIAL#avoid zero index issue in loop; rabbits mature this month
  
  for (month in 3:n){
    rabbits[month] = rabbits[month - 1] + k*rabbits[month - 2]#month delay in offspring reproducing
  }
  
  options(scipen = 20)#avoids scientific notation, which Rosalind rejects
  return (rabbits[n])
}
#recRabbits("5 3")
#[1] 19


#5 - Computing GC Content
compareGC <- function(path){#returning different answer when not passed as argument?????
  input = readChar(path, file.info(path)$size)
  input.flattened = gsub("\n|\t|\r|\v|\f", "", input)#stripping all whitespace - messes up percentage otherwise
  samples = strsplit(input.flattened, ">")[[1]][-1]#first element empty from leading >
  
  lenID = nchar("Rosalind_xxxx")
  
  ID = sapply(1:length(samples), function(x){ substr(samples[x], 1, lenID) })
  seq = sapply(1:length(samples), function(y){ substr(samples[y], lenID + 1, nchar(samples[y])) })
  
  pGC = sapply(1:length(samples), function(n){ pGC[n] = percentGC(seq[n]) })
  
  samples.df = data.frame(ID = ID, seq = seq, pGC = pGC, stringsAsFactors = FALSE)
  maxGC = samples.df[which.max(samples.df$pGC),]#will grab first if there is a tie
  
  cat(maxGC[1, "ID"], maxGC[1, "pGC"], sep = "\n")
}
percentGC <- function(dnastr){
  dna.vector = strsplit(dnastr, "")[[1]]
  gc = grepl("G|C", dna.vector)
  percent = (sum(gc, na.rm = TRUE)/length(dna.vector)) * 100
  return(percent)
}
#compareGC(">Rosalind_6404
# CCTGCGGAAGATCGGCACTAGAATAGCCAGAACCGTTTCTCTGAGGCTTCCGGCCTTCCC
# TCCCACTAATAATTCTGAGG
# >Rosalind_5959
# CCATCGGTAGCGCATCCTTAGTCCAATTAAGTCCCTATCCAGGCGCTCCGCCGAAGGTCT
# ATATCCATTTGTCAGCAGACACGC
# >Rosalind_0808
# CCACCCTCGTGGTATGGCTAGGCATTCAGGAACCGGAGAACGCTTCAGACCAGCCCGGAC
# TGGGAACCTGCGGGCAGTAGGTGGAAT")
# Rosalind_0808
# 60.91954


#6 - Counting point mutations
hammingDistance <- function(path){
  input = readChar(path, file.info(path)$size)
  input.split = strsplit(input, "\n")[[1]]
  s = input.split[1]; t = input.split[2]
  s.split = strsplit(s, "")[[1]]; t.split = strsplit(t, "")[[1]]
  
  match = sapply(1:length(s.split), function(x){ s.split[x] == t.split[x] })
  
  length(s.split) - sum(match)
}
#GAGCCTACTAACGGGAT
#CATCGTAATGACGGCCT
#[1] 7

