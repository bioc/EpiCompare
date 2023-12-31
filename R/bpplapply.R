#' Wrapper for \link[BiocParallel]{bplapply}
#' 
#' Wrapper function for \link[BiocParallel]{bplapply} that automatically
#' handles issues with \pkg{BiocParallel} related to different OS platforms.
#' @param apply_fun Iterator function to use. 
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
                      apply_fun=parallel::mclapply,
                      workers=check_workers(), 
                      progressbar=workers>1,
                      verbose=workers==1,
                      use_snowparam=TRUE,
                      register_now=FALSE,
                      ...){
    
    #### Select method ####
    if(any(attr(apply_fun,"package")=="BiocParallel")){
        check_dep("BiocParallel")
        BPPARAM <- get_bpparam(workers = workers,
                               progressbar = progressbar,
                               use_snowparam = use_snowparam,
                               register_now = register_now)
        if(isFALSE(verbose)) FUN <- function(FUN){suppressMessages(FUN)}
        apply_fun(X = X, 
                  FUN = FUN, 
                  BPPARAM = BPPARAM, 
                  ...)
    } else {
        if(environmentName(environment(apply_fun))=="parallel"){
            check_dep("parallel")
        }
        if(isFALSE(verbose)) FUN <- function(FUN){suppressMessages(FUN)}
        apply_fun(FUN = FUN,  
                  X,
                  ...)
    } 
}
