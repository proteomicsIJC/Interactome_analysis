#### Get the data and clean protein groups----
# Get wd
library(rstudioapi)
setwd(dirname(getActiveDocumentContext()$path)) 

# Get functions
source("./functions/generate.bait.R")

# Get the Protein groups data
proteins <- read.table("proteinGroups.txt", header = TRUE, sep = "\t")

# Remove contaminants, decoy sequences and only identified by site proteins
proteins <- proteins[proteins$Potential.contaminant != "+", ]
proteins <- proteins[proteins$Reverse != "+", ]
proteins <- proteins[proteins$Only.identified.by.site != "+", ]

# Get a smaller version of Protein Groups to work better
cnames <- c("^Majority.protein.IDs$", "^Protein.names$", "^Gene.names$", "^Sequence.length$", "^MS.MS.count.")
proteins.1 <- proteins[, unlist(lapply(cnames, function(x) grep(x, colnames(proteins))))]
#----

### Creating files for SAINT analysis----
# bait.file, this is a meta data and should look like this:
# Use the in-built, function generate.bait to create this data.set
#    IP.name Bait T_C
#    MOFWT1  MOF   T
#    MOFWT2  MOF   T
#    MOFWT3  MOF   T
#    CTRL1  IgG   C
#    CTRL2  IgG   C
#    CTRL3  IgG   C
bait.file <- generate.bait()

# prey.file, it is the annotation data:
#       Protein.Name   Seq..Length    Gene.Name
#       Q9Y6J9          622           TAF6L
#       Q9Y6K1          912           DNMT3A
#       Q9Y6M1          599           IGF2BP2
#       Q9Y6V7          483           DDX49
#       Q9Y6X4          670           FAM169A
#       Q9Y6X9;Q86VD1  1032           MORC2;MORC1
prey.file <- data.frame("Protein Name" = proteins.1$Majority.protein.IDs, "Seq. Length" = proteins.1$Sequence.length, "Gene Name" = proteins.1$Gene.names)

# interaction.file, created using the bait and prey file
#   MOFWT1	MOF	A0A075B6Q5	0
#   MOFWT1	MOF	A0A0A0MS14	3
#   MOFWT1	MOF	A0A0B4J1X5	0
#   MOFWT1	MOF	A5YKK6	0
#   MOFWT1	MOF	A6NHQ2	5
#   MOFWT1	MOF	A6NHR9	14
#   MOFWT1	MOF	A6NIH7	2
#   MOFWT1	MOF	P62834;P61224;A6NIZ1	1
#   MOFWT1	MOF	A6NJ78;P0C7V9	1
#   MOFWT1	MOF	A8MW92	0
#   MOFWT1	MOF	P62308;A8MWD9	1
if.ipname <- as.character(rep(bait.file$IP.name, each = nrow(prey.file)))
if.baitname <- as.character(rep(bait.file$Bait, each = nrow(prey.file)))
if.preyname <- as.character(rep(prey.file$Protein.Name, nrow(bait.file)))
interaction.file <- cbind(if.ipname, if.baitname, if.preyname)

if.spc <- c()
for (i in 1:nrow(bait.file)) {
  p <- proteins[, grep(paste("MS.MS.count.", as.character(bait.file$IP.name[i]), sep = ""), colnames(proteins.1))]
  if.spc <- c(if.spc, p) 
}

interaction.file <- cbind.data.frame(interaction.file, if.spc)
#----

### Write the data----
write.table(bait.file, "bait.txt", sep = "\t", col.names = FALSE, row.names = FALSE, quote = FALSE)
write.table(prey.file, "prey.txt", sep = "\t", col.names = FALSE, row.names = FALSE, quote = FALSE)
write.table(interaction.file, "interaction.txt", sep = "\t", col.names = FALSE, row.names = FALSE, quote = FALSE)
#----