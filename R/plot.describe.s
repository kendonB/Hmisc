plot.describe <- function(x, which=c('continuous', 'categorical'),
                          what=NULL, sort=c('ascending', 'descending', 'none'),
                          n.unique=10, digits=5, ...) {
  if(grType() != 'plotly')
    stop('must have plotly package installed and specify options(grType="plotly")')
 	
  which <- match.arg(which)
  if(length(what)) x <- x[what]

  sort <- match.arg(sort)

  format_counts <- function(s) {
    bl <- '                                     '
    na  <- substring(paste(names(s), bl, sep=''), 1,
                     max(nchar(names(s))))
    va  <- paste(substring(bl, 1,
                           max(nchar(s)) - nchar(s) + 1), s, sep='')
    zz  <- paste(na, va, sep=':')
    gsub(' ', '&nbsp;', zz)
  }

  fmtlab <- function(x) {
    lab <- sub('^.*:', '', x$descript)
    if(length(x$units))
      lab <- paste(lab, ' &emsp;<span style="font-size:0.8em">',
                   x$units, '</span>', sep='')
    lab
  }

  ge <- function(which) unlist(lapply(w, function(x) x[[which]]))
  
  if(which == 'categorical') {
    f <- function(x) {
      s <- x$counts
      v <- x$values
      type <- if('Sum' %in% names(s)) 'binary'
              else
                if(length(v) && is.list(v) &&
                   all(names(v) == c('value', 'frequency')) &&
                   is.character(v$value) && length(v$value) <= 20) 'categorical'
              else 'none'
                                                 
      if(type == 'none')
        return(data.frame(prop=numeric(0), text=character(0)))
      n    <- as.numeric(s['n'])
      if(type == 'binary') {
        val  <- ''
        freq <- as.numeric(s['Sum'])
      }
      else {
        val  <- v$value
        freq <- v$frequency
      }
      category  <- if(type == 'categorical') val else ''
      text <- 
        paste(category, if(type == 'categorical') ' ',
              round(freq / n, 3),
              '&emsp;<span style="font-size:0.7em">',
              freq, '/', n, '</span>', sep='')

      ## Details about variable for minimum frequency category
      left <- which.min(freq)[1]
      text[left] <- paste(c(fmtlab(x), text[left], format_counts(s)),
                           collapse='<br>')

      y <- if(type == 'binary') 0 else 1 : length(freq)
      y <- c(2, rep(1, length(freq) - 1))
      ## extra 1 for between-variable spacing

      j <- switch(sort,
                  ascending = order(freq),
                  descending= order(-freq),
                  none      = TRUE)
      
      data.frame(prop=freq[j] / n, y=y, text=I(text[j]),
                 category=I(category[j]),
                 missing=as.numeric(s['missing']), nlev=length(freq))
    }

    w <- lapply(x, f)
    nam <- names(w)
    
    for(na in nam) {
      l <- length(w[[na]]$prop)
      w[[na]]$xname <- if(l) rep(na, l) else character(0)
    }

    if(length(ge('xname')) == 0) {
      warning('no categorical variables found')
      return(invisible())
    }
 
    z <- data.frame(xname      = I(ge('xname')),
                    Proportion = ge('prop'),
                    y          = ge('y'),
                    text       = I(ge('text')),
                    category   = I(ge('category')),
                    missing    = ge('missing'),
                    nlev       = ge('nlev'))

    un <- unique(z$xname)
    nv  <- length(un)
    z$xnamef <- factor(z$xname, levels=un)
    z$xnamen <- as.integer(z$xnamef) - z$y / pmax(0.7 * nv, z$nlev) 

    z$cumy <- cumsum(z$y)

    p <- if(any(z$missing > 0))
           plotly::plot_ly(z, x=Proportion, y=cumy, text=text, #y=xnamen
                           color=missing, mode='markers',
                           hoverinfo='text',
                           type='scatter', name='')
         else
           plotly::plot_ly(z, x=Proportion, y=cumy, text=text,
                           mode='markers', hoverinfo='text',
                           type='scatter', name='')

    z$proplev <- 1.15
    p2 <- plotly::add_trace(data=z, x=proplev, y=cumy, text=category,
                            mode='text', textposition='left',
                            textfont=list(size=9), hoverinfo='none',
                            name='Levels')

    tl <- seq(0, 1, by=0.05)
    ## X tick mark labels for multiples of 0.1
    tt <- ifelse(tl %% 0.1 == 0, as.character(tl), '')
    tly <- z$cumy[z$y == 2]
    
    return(plotly::layout(xaxis=list(range=c(0,1.15), zeroline=TRUE,
                                     tickvals=tl, ticktext=tt),
                          yaxis=list(title='', autorange='reversed',
                                     tickvals=tly, ticktext=un),
                          autosize=FALSE, height=150 + 15 * nrow(z)))
  }

  ## which == 'continuous'
  f <- function(x) {
    s <- x$counts
    v <- x$values
    if(! (as.numeric(s['unique']) >= n.unique &&
          length(v) && is.list(v) &&
          all(names(v) == c('value', 'frequency')) &&
          is.numeric(v$value)) )
      return(data.frame(X=numeric(0), count=numeric(0), text=character(0)))
    X <- v$value
    Y <- v$frequency

    text <- paste(format(X, digits=digits), ' (n=', Y, ')', sep='')
    X    <- (X - X[1]) / diff(range(X))
    zz   <- format_counts(s)
    lab  <- fmtlab(x)

    text[1] <- paste(c(lab, text[1], zz), collapse='<br>')
    ## Note: plotly does not allow html tables as hover text
    m <- rep(as.numeric(s['missing']), length(X))
    list(X=X, prop=Y / sum(Y), text=I(text), missing=m)
  }
  
  w <- lapply(x, f)
  nam <- names(w)
  for(n in nam) {
    l <- length(w[[n]]$X)
    w[[n]]$xname <- if(l) rep(n, l) else character(0)
  }

  if(length(ge('xname')) == 0) {
    warning('no continuous variables found')
    return(invisible())
    }
    
  z <- data.frame(xname      = ge('xname'), X=ge('X'),
                  Proportion = round(ge('prop'), 4),
                  text       = ge('text'),
                  missing    = ge('missing'))
  
  ## Note: plotly does not allow font, color, size changes for hover text
  p <- if(any(z$missing > 0))
         plotly::plot_ly(z, x=X, y=xname, size=Proportion, text=text,
                         color=missing, mode='markers',
                         marker=list(symbol='line-ns-open'),
                         type='scatter', hoverinfo='text') else
         plotly::plot_ly(z, x=X, y=xname, size=Proportion, text=text,
                         mode='markers',
                         marker=list(symbol='line-ns-open'),
                         type='scatter', hoverinfo='text')
  plotly::layout(xaxis=list(title='', showticklabels=FALSE, zeroline=FALSE,
                            showgrid=FALSE),
                 yaxis=list(title=''), autosize=TRUE)
}

utils::globalVariables(c('X', 'Proportion', 'xname', 'cumy', 'proplev',
                         'category'))
