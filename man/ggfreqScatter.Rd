\name{ggfreqScatter}
\alias{ggfreqScatter}
\title{Frequency Scatterplot}
\description{
Uses \code{ggplot2} to plot a scatterplot or dot-like chart for the case
where there is a very large number of overlapping values.  This works
for continuous and categorical \code{x} and \code{y}.  For continuous
variables it serves the same purpose as hexagonal binning.  Counts for
overlapping points are grouped into quantile groups and level of
transparency and rainbow colors are used to provide count information.
}
\usage{
ggfreqScatter(x, y, bins=50, g=10,
              xtrans = function(x) x,
              ytrans = function(y) y,
              xbreaks = pretty(x, 10),
              ybreaks = pretty(y, 10),
              xminor  = NULL, yminor = NULL,
              xlab = as.character(substitute(x)),
              ylab = as.character(substitute(y)),
              fcolors = colorspace::rainbow_hcl(10), nsize=FALSE, \dots)
}
\arguments{
\item{x}{x-variable}
\item{y}{y-variable}
\item{bins}{for continuous \code{x} or \code{y} is the number of bins to
	create by rounding.  Ignored for categorical variables.  If a
	2-vector, the first element corresponds to \code{x} and the second to
	\code{y}.}
\item{g}{number of quantile groups to make for frequency counts}
\item{xtrans,ytrans}{functions specifying transformations to be made
	before binning and plotting}
\item{xbreaks,ybreaks}{vectors of values to label on axis, on original
	scale}
\item{xminor,yminor}{values at which to put minor tick marks, on
	original scale}
\item{xlab,ylab}{axis labels.  If not specified and variable has a
	\code{label}, that label will be used.}
\item{fcolors}{\code{colors} argument to pass to
	\code{scale_color_gradientn} to color code frequencies}
\item{nsize}{set to \code{TRUE} to not vary color or transparency but
	instead to size the symbols in relation to the number of points.  Best
	with both \code{x} and \code{y} are discrete.  \code{ggplot2}
	\code{size} is taken as the fourth root of the frequency.  If there
	are 15 or unique frequencies all the unique frequencies are used,
	otherwise \code{g} quantile groups of frequencies are used.}
\item{\dots}{arguments to pass to \code{geom_point} such as \code{shape}
	and \code{size}}
}
\value{a \code{ggplot} object}
\author{Frank Harrell}
\seealso{\code{\link[Hmisc]{cut2}}}
\examples{
set.seed(1)
x <- rnorm(1000)
y <- rnorm(1000)
count <- sample(1:100, 1000, TRUE)
x <- rep(x, count)
y <- rep(y, count)
ggfreqScatter(x, y) + ggtitle("Using Deciles of Frequency Counts, 2500 Bins")

# Try with x categorical
x1 <- sample(c('cat', 'dog', 'giraffe'), length(x), TRUE)
ggfreqScatter(x1, y)

# Try with y categorical
y1 <- sample(LETTERS[1:10], length(x), TRUE)
ggfreqScatter(x, y1)

# Both categorical, larger point symbols, box instead of circle
ggfreqScatter(x1, y1, shape=15, size=7)
# Vary box size instead
ggfreqScatter(x1, y1, nsize=TRUE, shape=15)
}
\keyword{hplot}
\concept{grouping}
\concept{categorization}
\concept{discretization}
