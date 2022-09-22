#' Wrapper for \link[BiocParallel]{bplapply}
#' 
#' Wrapper function for \link[BiocParallel]{bplapply} that automatically
#' handles issues with \pkg{BiocParallel} related to different OS platforms.
#' @param verbose Print messages. 
#' @inheritParams get_bpparam 
#' @inheritParams BiocParallel::bplapply
#' @inheritDotParams BiocParallel::bplapply
#' @returns (Named) list.
#' 
#' @export
#' @examples
#' X <- stats::setNames(seq_len(length(letters)), letters)
#' out <- bpplapply(X, print) 
bpplapply <- function(X, 
                      FUN, 
                      workers=1, 
                      progressbar=workers>1,
                      verbose=workers==1,
                      use_snowparam=TRUE,
                      register_now=FALSE,
                      ...){
    
    requireNamespace("BiocParallel")
    BPPARAM <- get_bpparam(workers = workers,
                           progressbar = progressbar,
                           use_snowparam = use_snowparam,
                           register_now = register_now)
    if(isFALSE(verbose)) FUN <- function(FUN){suppressMessages(FUN)}
    BiocParallel::bplapply(X = X, 
                           FUN = FUN, 
                           BPPARAM = BPPARAM, 
                           ...)
}