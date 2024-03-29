#' Statistical significance of overlapping peaks
#'
#' This function calculates the statistical significance of overlapping/
#' non-overlapping peaks against a reference peak file. If the reference peak
#' file has the BED6+4 format (peak called by MACS2), the function generates a
#' series of box plots showing the distribution of q-values for sample peaks 
#' that are overlapping and non-overlapping with the reference. 
#' If the reference peak file does not have the BED6+4 format, the function uses 
#' \link[ChIPseeker]{enrichPeakOverlap}
#' from \pkg{ChIPseeker} package to calculate the statistical significance of
#' overlapping peaks only. In this case, please provide an annotation file as
#' a TxDb object.
#' @param reference A reference peak file as GRanges object.
#' @param peaklist A list of peak files as GRanges object.
#' Files must be listed and named using \code{list()}.
#' E.g. \code{list("name1"=file1, "name2"=file2)}.
#' If not named, default file names will be assigned.
#' @param txdb A TxDb annotation object from Bioconductor. This is
#' required only if the reference file does not have BED6+4 format.
#' @inheritParams EpiCompare
#' @inheritParams check_workers
#' @inheritParams base::signif
#' @inheritParams ChIPseeker::enrichPeakOverlap
#' @returns A named list. 
#' \itemize{
#' \item{"plot"}{boxplot/barplot showing the statistical significance of
#' overlapping/non-overlapping peaks.}
#' \item{"data"}{Plot data.}
#' } 
#'
#' @importMethodsFrom IRanges subsetByOverlaps
#' @import GenomicRanges
#' @importFrom methods is
#' @importFrom stats quantile
#' @importFrom data.table data.table rbindlist
#' @importFrom ChIPseeker enrichPeakOverlap
#' @import ggplot2
#'
#' @export
#' @examples
#' ### Load Data ###
#' data("encode_H3K27ac") # example peakfile GRanges object
#' data("CnT_H3K27ac") # example peakfile GRanges object
#' data("CnR_H3K27ac") # example peakfile GRanges object 
#' ### Create Named Peaklist & Reference ###
#' peaklist <- list('CnT'=CnT_H3K27ac, "CnR"=CnR_H3K27ac)
#' reference <- list("ENCODE"=encode_H3K27ac) 
#' out <- overlap_stat_plot(reference = reference,
#'                          peaklist = peaklist,
#'                          workers = 1) 
overlap_stat_plot <- function(reference,
                              peaklist,
                              txdb = NULL,
                              interact = FALSE,
                              nShuffle = 50,
                              digits = 4,
                              workers = check_workers()){
  
  # devoptera::args2vars(overlap_stat_plot)
  message("--- Running overlap_stat_plot() ---")
  workers <- check_workers(workers = workers)
  # define variables
  qvalue <- tSample <- p.adjust <- NULL;
  # check that peaklist is named, if not, default names assigned
  peaklist <- check_list_names(peaklist)
  #### Validate reference list ####
  reference <- prepare_reference(reference = reference,
                                 max_elements = 1, 
                                 as_list = FALSE)
  reference <- clean_granges(reference)
  
  #### check if the file has BED6+4 format ####
  if(ncol(GenomicRanges::elementMetadata(reference)) %in% c(6,7)){
    main_df <- NULL
    # for each peakfile, obtain overlapping and unique peaks
    for (i in seq_len(length(peaklist))){
      # reference peaks found in sample peaks
      overlap <- IRanges::subsetByOverlaps(x = reference,
                                           ranges = peaklist[[i]])
      # reset names of metadata
      n <- 4
      my_label <- NULL
      for (l in seq_len(ncol(GenomicRanges::elementMetadata(overlap)))){
        label <- paste0("V",n)
        my_label <- c(my_label, label)
        n <- n + 1
      }
      colnames(GenomicRanges::mcols(overlap)) <- my_label

      # reference peaks not found in sample peaks
      unique <- IRanges::subsetByOverlaps(x = reference,
                                          ranges = peaklist[[i]],
                                          invert = TRUE)
      # reset names of metadata
      n <- 4
      my_label <- NULL
      for (l in seq_len(ncol(GenomicRanges::elementMetadata(unique)))){
        label <- paste0("V",n)
        my_label <- c(my_label, label)
        n <- n + 1
      }
      colnames(GenomicRanges::mcols(unique)) <- my_label
      # if no overlap, set q-value as 0 to avoid error
      # else, obtain q-value from field V9
      overlap_qvalue <- overlap$V9
      if (length(overlap) == 0) overlap_qvalue <- 0
      # create data frame of q-values for overlapping peaks
      sample <- names(peaklist)[i]
      group <- "overlap"
      overlap_df <- data.table::data.table(overlap_qvalue, sample, group)
      colnames(overlap_df) <- c("qvalue", "sample", "group")
      #
      unique_qvalue <- unique$V9
      if(length(unique) == 0){
        unique_qvalue <- 0
      }
      # create data frame of q-values for unique peaks
      group <- "unique"
      unique_df <- data.table::data.table(unique_qvalue, sample, group)
      colnames(unique_df) <- c("qvalue", "sample", "group")
      # combine two data frames
      sample_df <- data.table::rbindlist(list(overlap_df, unique_df))
      main_df <- data.table::rbindlist(list(main_df, sample_df))
    }
    # find value at 95th percentile
    max_val <- stats::quantile(main_df$qvalue, 0.95)
    # remove values greater than 95th quantile
    main_df <- main_df[qvalue<max_val,]

    # create paired boxplot for each peak file (sample)
    plt <- ggplot2::ggplot(main_df,
                                   ggplot2::aes(x=sample,
                                                y=qvalue,
                                                fill=group)) +
      ggplot2::geom_boxplot(outlier.shape = NA) +
      # ggplot2::scale_fill_viridis_d(alpha = .75, option = "magma") +
      ggplot2::labs(x="Sample",y="-log10(q-value)",fill="Sample") +
      ggplot2::theme_bw() +
      ggplot2::theme(axis.text.x =ggplot2::element_text(angle = 270,
                                                        vjust = 0,
                                                        hjust=0)) +
      ggplot2::coord_flip()
    if(isTRUE(interact)){
      plt <- as_interactive(plt, add_boxmode = TRUE)
    } 
    message("Done.")
    return(list(plot=plt, 
                data=main_df))
    
    #### for files not in BED6+4 format ####
    } else{
      # calculate significance of overlapping peaks using enrichPeakOverlap() 
      overlap_result <- ChIPseeker::enrichPeakOverlap(queryPeak = reference,
                                                      targetPeak = peaklist,
                                                      TxDb = txdb,
                                                      nShuffle = nShuffle,
                                                      pAdjustMethod = "BH",
                                                      chainFile = NULL,
                                                      mc.cores = workers,
                                                      verbose = FALSE)
      overlap_result$tSample <- names(peaklist) # set names with sample names
      percent_overlap <- c()
      # for each peakfile, calculate percentage overlap
      for (i in seq_len(nrow(overlap_result))){
        percent <- overlap_result[i,5]/overlap_result[i,3]*100
        percent_overlap <- c(percent_overlap, percent)
      }
      # add percentage overlap to a column
      overlap_result$percent_overlap <- percent_overlap 
      # create bar plot showing percentage overlap
      # and statistical significance of overlapping peaks
      plt <- ggplot2::ggplot(data=overlap_result,
                              ggplot2::aes(x=tSample,
                                           y=percent_overlap, 
                                           fill=p.adjust)) +
          ggplot2::geom_bar(stat="identity") + 
          ggplot2::theme_bw() +
          ggplot2::labs(x="Sample",y="Percentage overlap (%)",
                        fill="q-value") +
          ggplot2::scale_fill_viridis_c(alpha = .75, option = "magma") +
          ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45,
                                                             vjust = 1,
                                                             hjust = 1)) +
          ggplot2::ylim(0,100) +
          ggplot2::coord_flip()
      #### Add labels ####
      if(isFALSE(interact)){
        ## Only add labels when not interactive,
        ## to avoid plotly warning message 
        ## about not being able to translate the label/text geom
        plt <- plt + ggplot2::geom_label(
          ggplot2::aes(label=paste0("q-value=",
                                    signif(p.adjust,digits = digits))),
          position=ggplot2::position_dodge(width=0.9),
          fill=ggplot2::alpha("black",.8),
          color="white")
      }
      # return both plot and data frame
      message("Done.")
      if(isTRUE(interact)){
        plt <- as_interactive(plt, add_boxmode = TRUE)
      } 
      return(list(plot=plt, 
                  data=overlap_result))
  }
}
