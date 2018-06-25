#' Make a Mark input file
#'
#' Save a text file with extension .inp with the capture history formatted as
#' input for the program Mark from data with capture history with a column for
#' each capture session
#'
#' @param fn File name
#' @param h whether the .csv has headers
#' @param ids whether the first column is animals' ids
#' @param count the count of animals with each history
#' @return saves a .inp file and returns a character vector with the capture
#'   history
#' @export
make.mark.inp <- function(fn, h=FALSE, ids=TRUE, count=1) {
  make.cap.hist <- function(st, ids=TRUE, count=1) {
    if(ids) {
      id <- as.character(st[1])
      caps <- st[-1]
    } else {
      caps <- st
    }
    if(sum(caps > 1)) {
      warning("Some captures were greater than 1 and were replaced with 1")
      caps[caps>1] <- 1
    }
    det.hist <- paste(if(ids) paste0("/*", id, "*/"),
                      paste0(caps, collapse=""),
                      paste0(count, ";"))
    return(det.hist)
  }
  ####################################
  cap.hist <- read.csv(fn, header = h)
  title <- sub(".csv", "", fn)
  lns <-  apply(cap.hist, 1, FUN = make.cap.hist, ids=ids, count=count)
  writeLines(c(paste0("/*", title, "*/"), lns), con = paste0(title, ".inp"))
  return(c(paste0("/*", title, "*/"), lns))
}


#' Transform WP trapping database into mark capture history input file
#'
#' @param ndays The time difference between two trapping sessions to be
#'   considered independent
#' @param animal.ids the column header that identifies the animals' IDs
#' @param run the column header that identifies different trapping run within
#'   the same day
#' @inheritParams dot.plot
#' @return a list with an element for each \code{species} where each element is
#'   a list with the capture history for each session as elements
#' @export
trap2mark <- function(data, species="all", ndays=14,
                      animal.ids="M.chip.serial..", run="Run") {

  if(length(species) == 1) {
    if(species == "all") species <- unique(data[, "Species"])
  }
  sps <- vector("list", length = length(species))
  i <- 1
  for(sp in species) {
    sdat <- data[data[, "Species"] == sp,]
    t <- table(data[, animal.ids], data[, run], data[, "Date"])
    ndates <- dim(t)[3]
    dates <- as.Date(dimnames(t)[[3]])
    det <- vector(mode = "list", length = ndates)
    det.fin <- vector(mode = "list", length = ndates)
    for(d in seq_len(ndates)) {
      det[[d]] <- t[, ,d]
      det.checked <- apply(det[[d]], MARGIN = 2, "==", 0)
      det.summed <- apply(det.checked, 2, sum)
      det.fin[[d]] <- det[[d]][, !sapply(det.summed, "==", dim(det[[d]])[1])]
    }

    dates.diff <- diff(dates) < ndays
    split.ats <- which(dates.diff == F)

    if(length(split.ats) == 0) {
      split.ats <- ndates
      start.dates <- dates[1]
    } else {
      start.dates <- dates[c(1, split.ats)]
      split.ats <- c(split.ats, ndates)
    }

    det.session <- vector(mode = "list", length = length(split.ats))
    session.names <- vector(mode = "character", length = length(split.ats))
    start.at <- 1
    nsession <- 1
    for(split.at in split.ats) {
      det.session[[nsession]] <- do.call(cbind, args = det.fin[start.at:split.at])
      session.names[nsession] <- paste0(sp, dates[start.at])
      fn <- paste0(session.names[nsession], ".csv")
      write.csv(det.session[[nsession]][row.names(det.session[[nsession]]) != "-1",],
                file = fn, row.names = TRUE)
      make.mark.inp(fn, h = TRUE, ids = TRUE, count = 1)
      start.at <- split.at + 1
      nsession <- nsession + 1
    }
    names(det.session) <- session.names
    sps[[i]] <- det.session
  }
  names(sps) <- species
}