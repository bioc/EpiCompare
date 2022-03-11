#' Generate Upset plot for overlapping peaks
#'
#' This function generates upset plot (UpSetR package) of overlapping peaks.
#'
#' @param peaklist A named list of peak files as GRanges object.
#' Objects listed using `list()` and named using `names()`.
#' If not named, default file names are assigned.
#'
#' @return Upset plot of overlapping peaks
#' @export
#' @examples
#' library(EpiCompare) # load EpiCompare
#' data("encode_H3K27ac") # load example data
#' data("CnT_H3K27ac") # load example data
#' peakfile <- list(encode_H3K27ac, CnT_H3K27ac) # create list
#' names(peakfile) <- c("ENCODE","CnT") # name list
#' overlap_upset_plot(peaklist = peakfile) # run function
overlap_upset_plot <- function(peaklist){
  # define variables
  value <- NULL
  # check that peaklist is named, if not, default names assigned
  peaklist <- EpiCompare::check_list_names(peaklist)
  # change metadata column names so it doesn't interfere
  for(i in 1:length(peaklist)){
    my_label <- make.unique(rep("name", ncol(peaklist[[i]]@elementMetadata)))
    colnames(peaklist[[i]]@elementMetadata) <- my_label
  }
  # erase name
  peaklist_names <- names(peaklist)
  names(peaklist) <- NULL
  # create merged dataset
  merged_peakfile <- do.call(c, peaklist)
  # calculate overlap and create data frame
  overlap_df <- NULL
  for(i in 1:length(peaklist)){
   overlap <- IRanges::findOverlaps(merged_peakfile, peaklist[[i]])
   sample_name <- rep(peaklist_names[i], length(overlap@to))
   df <- data.frame(peak=overlap@from, sample=sample_name)
   unique_df <- unique(df)
   overlap_df <- rbind(overlap_df, unique_df)
  }
  # adjust font size
  font_size = 1
  if(length(peaklist)>6){
    font_size = 0.65
  }

  # generate upset plot
  mutate <- dplyr::mutate(overlap_df, value = 1)
  spread <- tidyr::spread(mutate, sample, value, fill=0)
  upset_plot <- UpSetR::upset(spread, order.by = "freq",
                              mb.ratio = c(0.60, 0.40),
                              sets = peaklist_names,
                              number.angles = 30,
                              text.scale = c(1, 1, 1, font_size, font_size+0.15, font_size))
  return(upset_plot)
}