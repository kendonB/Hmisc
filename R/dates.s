## round.chron <- function(x, units=c("minutes", "hours", "days", "months", "years")) {
##   if(missing(units)) {
##     return(floor(unclass(x)))
##   }

##   units <- match.arg(units)

##   time.units <- c("minutes", "hours", "days")
##   date.units <- c("months", "years")
  
##   if(units %in% time.units && !inherits(x, what=c('dates', 'times'))) {
##     stop("when 'units' is 'minutes', or 'hours' 'x' must be of class 'times' or 'dates'")
##   }
  
##   if(units %in% date.units  && !inherits(x, what=c('dates'))) {
##     stop("when 'units' is 'days', 'months', or 'years' 'x' must be of class 'dates'")
##   }

##   attribs <- attributes(x)

##   switch(units,
##          minutes = x + times('0:0:30', format='h:m:s')
##          hours = x + times('0:30:0', format='h:m:s')
##          days = x + times('12:0:0', format='h:m:s')
##          months = x + dates(paste('0:0',nlevels(days)/2,sep=':'), format='y:m:d')
##          years = x + dates(paste('0:

##   time <- c(seconds(x), minutes(x), hours(x), as.integer(days(x)),
##             as.integer(months(x)), as.integer(as.character(years(x))))

##   max.time <- c(59,59,23,nlevels(days),nlevels(months
##   set <- switch(units,
##          minutes = if(time[1] >= 30) {
##            if(time[4,
##          hours = time[2]/30 >= 1,
##          days = if(time[3]/12 >= 1) { 
##            if(time[4] == nlevels(days)) {
##              if(time[5] == nlevels(months)) {
##                time[6] <- time[6] + 1
##                5
##              } else {
##                time[5] <- time[5] + 1
##                4
##              }
##            } else {
##              time[4] <- time[4] + 1
##              3
##            }
##          },
## }
.checkRoundChron <- function(x, units) {
  given <- list(dates=NULL, times=NULL)

  if(is(x, 'chron')) {
    given[c("dates", "times")] <- TRUE
  } else if(is(x, 'dates')) {
    if(any(units %in% c("seconds", "minutes", "hours"))) {
      return("x is a dates object unable to work with a unit values of 'seconds','minutes', or 'hours'")
    }
    given$dates <- TRUE
  } else if(is(x, 'times')) {
    if(any(units %in% c('months', 'years'))) {
      return("x is a times object unable to work with a unit value of 'months', 'years'")
    }
    given$times <- TRUE
  } else {
    return("x is not a chron object")
  }
  return(given)
}
  
hour.minute.second <- function(x) {
  ## get the total number of seconds
  X <- as.numeric(x)

  if(inherits(x, what='dates')) {
    X <- X - floor(X)
  }
  
  seconds <- 86400 * abs(X - floor(X))

  ## get total number of whole seconds
  sec <- floor(seconds)

  ## get number of hours in sec
  hh <- sec %/% 3600
  ## place those seconds from these hours in consumed.sec
  consumed.sec <- hh * 3600

  ## get number of minutes in remainint seconds
  mm <- (sec - consumed.sec) %/% 60
  ## add those seconds from these minutes in consumed.sec
  consumed.sec <- consumed.sec + mm * 60

  ## subtract the number consumed seconds from seconds
  ss <- seconds - consumed.sec

  list(hour = hh, minute = mm, second = ss)
}

second.minute.hour.day.month.year <- function(x, origin.) {
  mdy <- month.day.year(x, origin.)

  hms <- hour.minute.second(x)

  list(second = hms$second, minute = hms$minute, hour = hms$hour,
       day = mdy$day, month = mdy$month, year = mdy$year)
}

month.days <- function(x) {
  non.na <- !is.na(x)
  mdy <- month.day.year(x)
  year <- as.numeric(mdy$year)
  month <- as.numeric(mdy$month)

  non.na <- !is.na(mo)
  bad <- seq(along = mo)[non.na][mo[non.na] < 1 |
               mo[non.na] >  12]
  if (n.bad <- length(bad)) {
    if (n.bad > 10) 
      msg <- paste(n.bad, "months out of range set to NA")
    else {
      if(n.bad > 1) {
        msg <- paste("month(s) out of range in positions", 
                     paste(bad, collapse = ","))
      } else {
        msg <- paste("month out of range in position", bad)
      }
      msg <- paste(msg, "set to NA")
    }
    warning(msg)
    mo[bad] <- NA
    non.na[bad] <- FALSE
  }
  
  
  month.days <- month.length[month]
}  

floor.chron <- function(x,
                        units=c("seconds", "minutes", "hours", "days", "months", "years"),
                        inclusive=TRUE) {
  require('chron', character.only=TRUE)

  if(missing(units)) {
    return(floor(unclass(x)))
  }
  
  units <- match.arg(units, several.ok=TRUE)

  given <- .checkRoundChron(x, units)
  if(is.character(given)) {
    stop(given)
  }

  if(given$dates) {
    ncol <- 6
  } else {
    ncol <- 4
  }

  ## save attribes
  attribs <- attributes(x)

  ## Get in individual components of the date
  time <- do.call(cbind, second.minute.hour.day.month.year(x)[1:ncol])

  index <- match(units, default.arg(units))

}

ceiling.chron <- function(x,
                          units=c("seconds", "minutes", "hours", "days", "months", "years"),
                          inclusive=TRUE) {
  require('chron', character.only=TRUE)

  require('chron', character.only=TRUE)
  
  if(missing(units)) {
    return(ceiling(unclass(x)))
  }
  
  units <- match.arg(arg=units, several.ok=TRUE)

  given <- .checkRoundChron(x=x, units=units)

  if(is.character(given)) {
    stop(given)
  }

  if(given$dates) {
    ncol <- 6
  } else {
    ncol <- 4
  }

  ## save attribes
  attribs <- attributes(x)

  ## Get in individual components of the date
  time <- do.call(cbind, second.minute.hour.day.month.year(x)[1:ncol])

  index <- match(units, default.arg(units))

  if(index == 1) {
    ## ceiling on seconds which is a integer so ceiling it
    time[,1] <- ceiling(time[,1])
  } else {
    ## set the min and max vales for each of the date components
    max.vals <- c(59, 59, 23, NA, 12)
    length(max.vals) <- ncol - 1
    max.vals <- matrix(rep(max.vals, each=nrow), nrow=nrow)

    if(given$dates) {
      ## if this is a date set the max days according to leap year.
      max.vals[,4] <- ifelse(time[,5] == 2 & leap.year(time[,6]), 29, month.length[time[,5]])
    }

    min.vals <- c(0,0,0,1,1)
    length(min.vals) <- ncol - 1
    min.vals <- matrix(rep(min.vals, each=nrow), nrow=nrow)
    
    rep.seq <- seq(from=1, to=index - 1)

    if(inclusive) {
      replacement.vals <- min.vals[,rep.seq]
    } else {
      replacement.vals <- max.vals[,rep.seq]
    }
    
    ## if all of the less sigificate values are equal to
    ## the replacement values then return x unchanged
    not.rep <- matrix(FALSE, ncol=ncol, nrow=nrow)
    not.rep[,rep.seq] <- time[,rep.seq] != replacement.vals
    if(! any(not.rep[,rep.seq])) {
      return(x)
    }
    
    time[not.rep] <- replacement.vals[not.rep]

    if(inclusive) {
      inc(time[sapply(split(not.rep[,rep.seq], 1:nrow), any), index]) <- 1
      
      for(i in seq(from=index, to=ncol - 1)) {
        ## find which rows have larger then max vals
        test <- time[,i] > max.vals[,i]

        ## For all rows where test is true
        ## increment the value of the next col and
        ## set the cols value to the minium value.
        inc(time[test, i + 1]) <- 1
        time[test, i] <- min.vals[test, i]
        
        ## remove the test var
        rm(test)
      }
    }
  }


  ## Find the interger representation of the date
  if(given$dates) {
    result <- julian(x=time[,5], d=time[,4], y=time[,6], origin.=attribs$origin)
  } else {
    result <- 0
  }

  ## Find the decimal representation of the time and add it the the result
  if(given$times) {
    inc(result) <- (3600 * hh + 60 * mm + ss) / (24 * 3600)
  }

  ## set the existing attributes on the result
  attributes(result) <- attribs

  return(result)
}
