plot_gmr_matches <- function(matches, db){
  # Loosely based on Greg's nlscan(), this function plots skeleton/gmr pairs as specified by matches, allows the user to select pairs and returns them in a matrix

  plotting <- function(plotmatches,x,plotdb){ # Using a function within a function - is this a bit dotty?
    clear3d()
    plot3d(FCWB, alpha=0.1)
    nview3d("frontal")
    plot3d(plotdb[[plotmatches[x,1]]], col="black") # change based on whether mirroring or not!
    plot3d(gmrdps[[plotmatches[x,2]]], col="red")
    input = readline("Return to continue, s to select: ")
    if (input=='s'){
      selection = c(plotmatches[x,1],plotmatches[x,2])
      return(selection)
    }
  }
  
  nopen3d()
  results = apply(matrix(1:30), 1, function(x) plotting(plotmatches=matches,x,plotdb=db))
  output = matrix(unlist(results), ncol=2, byrow=T)
  return(output)
}