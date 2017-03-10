#' Plot synapses on a neuron in different colours by partner
#'
#' **main** Required; the skeleton ID of the neuron in CATMAID. Can accept a vector with multiple SKIDs.  
#' **partners** Required unless plotting autapses; the skeleton ID (or a vetor of multiple skids) of the partner neurons to plot synapses for.  
#' **io** Which synapses to plot on the main neuron - "input", "output", "both", or "autapse".  Defaults to "both".  
#'    If plotting autapses; the `partners` parameter must be left blank, and only one `main` neuron should be provided.  
#' **cols** The colour(s) to use when plotting the partner synapses.  
#'    If a vector of colour names is provided, the colours will be applied to the partner neurons in the order specified,
#'    repeating from the beginning if there are more neurons than colours.  Will generate a rainbow of colours if not provided.  
#' **ncols** The colour(s) to use when plotting the main neuron(s).  
#'    Behaves the same way as cols.  Defaults to black.  
#' **pointsize** The size of point to use when plotting synapses.  
#'    Note that this is a character expansion value, not a pixel value.  Defaults to 1.  
#' **inputchar** The 'text' to use when plotting input synapses.  Defaults to "\U25CF" (a unicode circle).  
#' **outputchar** The 'text' to use when plottint output synapses.  defaults to "\U25B2" (a unicode triangle).  
#'
#'
colour_synapses_by_partner <- function(main, partners = NULL, io = "both", cols = NULL, neuroncols = "black", pointsize = 1, inputchar = "\U25CF", outputchar = "\U25B2"){
  if (is.null(partners) && io != "autapse"){
    stop("Partners must be provided unless io is set as 'autapse'")
  }
  if(io == "autapse" && length(main) > 1){
    warning("Autapse plotting might not behave as intended with more than one 'main' neuron")
  }
  
  require(catmaid)
  all = read.neurons.catmaid(c(main, partners))
  main.neuron = all[main]
  partners.neurons = all; partners.neurons[main] = NULL
  
  input = INTERNAL_create_conn_DF()
  output = INTERNAL_create_conn_DF()
  
  if (io == "input" || io == "both"){
    input = catmaid_get_connectors_between(partners, main)#returning NULL if no results
    if (is.null(input)) input = INTERNAL_create_conn_DF()#blegh
  }
  if (io == "output" || io == "both"){
    output = catmaid_get_connectors_between(main, partners)
    if (is.null(output)) output = INTERNAL_create_conn_DF()
  }
  if (io == "autapse"){
    input = catmaid_get_connectors_between(main, main)
    if (is.null(input)) {
      warning("The specified neuron does not have any autapses")
      input = INTERNAL_create_conn_DF()
    }
  }
  if (!io %in% c("both", "input", "output", "autapse")){
    warning("Paremeter io must be set to 'both', 'input', 'output', or 'autapse' for this function to work properly.")
  }
  
  nopen3d(windowRect = c(0, 0, 1200, 750))
  plot3d(main.neuron, soma = TRUE, col = rep(neuroncols, length.out = length(main)), WithNodes = FALSE)#add pass-through params?

  if (is.null(partners)) partners = main; partners.neurons = main.neuron #in case of autapse plotting
  
  if (is.null(cols)) cols = rainbow(length(partners))#if colours aren't specified, generate a rainbow of colours to use
  if (length(cols) < length(partners)) cols = rep(cols, length.out = length(partners))#if there are colours specified, but not as many as partners, loop through them

  partners.connections = lapply(1:length(partners), function(x){ INTERNAL_select_connections(partners[x], input, output) })
  
  lapply(1:length(partners.connections), function(x){ 
          texts3d(xyzmatrix(partners.connections[[x]]$input_connections[,c("post_node_x", "post_node_y", "post_node_z")]), texts = inputchar, useFreeType = TRUE, family = "sans", font = 5, col = cols[x], cex = pointsize)
          texts3d(xyzmatrix(partners.connections[[x]]$output_connections[,c("pre_node_x", "pre_node_y", "pre_node_z")]), texts = outputchar, useFreeType = TRUE, family = "sans", font = 5, col = cols[x], cex = pointsize)
        })
  
  partners.names = catmaid_get_neuronnames(partners)
  
  legend3d("topright", legend = partners.names, col = cols, pch = 15, inset = c(0.02))#in front of neuron would be nice, and expanded to distinguish input/output
  #occasionally shows up huge???
  #also, neuron shows up in legend even if it has no connectors plotted - sort this out if time

  
}


INTERNAL_select_connections <- function(x, input, output){
  input.df = subset(input, pre_skid == x)
  output.df = subset(output, post_skid == x)
  ret = list(x, input.df, output.df)
  names(ret) = c("skid", "input_connections", "output_connections")
  invisible(ret)
}


INTERNAL_create_conn_DF <- function(){
  conn_DF = data.frame(pre_skid = integer(0),
                       post_skid = integer(0),
                       connector_id = integer(0),
                       pre_node_id = integer(0),
                       post_node_id = integer(0),
                       connector_x = numeric(0),
                       connector_y = numeric(0),
                       connector_z = numeric(0),
                       pre_node_x = numeric(0),
                       pre_node_y = numeric(0),
                       pre_node_z = numeric(0),
                       post_node_x = numeric(0),
                       post_node_y = numeric(0),
                       post_node_z = numeric(0),
                       pre_confidence = integer(0),
                       pre_user = integer(0),
                       post_confidence = integer(0),
                       post_user = integer(0))
}
