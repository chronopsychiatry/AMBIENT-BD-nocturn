#' Otsu threshold
#'
#' Computes a threshold for a vector of values using Otsu's method. This implies that the distribution is bimodal, which is not checked here.
#' For ideas on checking bimodality, see e.g. https://universeofdatascience.com/how-to-determine-if-data-are-unimodal-or-multimodal-in-r/
#' Code adapted from the EBImage package (https://github.com/aoles/EBImage/blob/devel/R/otsu.R)
#' Note that thresholding is dependent on the binning of the distribution.
#' Here the "hist.default" function uses the "Sturges" method to determine optimal binwidth.
#' @param vector The vector of values to threshold
#' @returns The computed Otsu threshold
#' @export
#' @examples
#' thr <- otsu(example_epochs$distance_mean)
otsu <- function(vector) {
  h <- hist.default(vector, plot = FALSE)

  counts <- as.double(h$counts)
  mids <- as.double(h$mids)
  len <- length(counts)
  w1 <- cumsum(counts)
  w2 <- w1[len] + counts - w1
  cm <- counts * mids
  m1 <- cumsum(cm)
  m2 <- m1[len] + cm - m1
  var <- w1 * w2 * (m2 / w2 - m1 / w1)^2

  # find the left- and right-most maximum and return the threshold value in between
  maxi <- which(var == max(var, na.rm = TRUE))
  (mids[maxi[1]] + mids[maxi[length(maxi)]]) / 2
}
