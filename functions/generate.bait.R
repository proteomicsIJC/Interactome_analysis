generate.bait <- function(treatment_name, control_names, treat_n, control_n){
  #IP
  treatment_vec <- paste(rep(treatment_name),1:treat_n ,sep = "_r")
  control_vec <-paste(rep(control_names),1:control_n ,sep = "_r")
  IP_vector <- c(treatment_vec, control_vec)
  #Baits
  Bait_vector <- c(
    c(rep(treatment_name, treat_n)),
    c(rep(control_names, control_n)))
  #T_C
  T_C_vector <- c(
    c(rep("T", treat_n)),
    c(rep("C",control_n)))
  
  bait.file <- data.frame("IP name" = IP_vector,"Bait" = Bait_vector,"T_C" = T_C_vector)
  return(bait.file)
}
