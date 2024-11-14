# barcharts.gnuplot

# A gnuplot script to generate a grid of barcharts from aggregates
# counts data.
#
# Expects several variables to be passed on the command line,
# particularly the variable 'files'.  Called from
# barcharts.sh.

# gnuplot -e "files='$file_list'" \
#         -e "titles='$title_list'" \
#         -e "max_count='$MAX_COUNT'" \
#         -e "max_rows='$MAXROWS'" \
#         -e "experiment='$EXPNAME'" \
#         barcharts.gnuplot

print "Running gnuplot script barcharts.gnuplot"

if ( !exists("files") ) {
  print "Variable 'files' must be specified (e.g. gnuplot -e 'files=...')"
  exit
}
n_samples=words(files)
if ( !exists("n_cols") ) {
  n_cols = 8
}
if ( !exists("n_rows") ) {
  n_rows = floor(n_samples/n_cols) + 1
}
if (exists("experiment")) {
  plot_title=experiment
} else {
  plot_title="Barcode Counts"
}
if ( !exists("max_count") ) {
  max_count=2500
}
if ( !exists("max_rows") ) {
  max_rows=5
}

plot_size=250

set datafile separator '\t'
set style data histograms
set style histogram

set terminal png medium size n_cols*plot_size,n_rows*plot_size
set output "barcode_counts.png"
set xrange [0:max_rows]
set yrange [0:max_count]
unset xtics
unset xlabel
unset ylabel
unset border
# set tmargin 2
# set bmargin 2
# set lmargin 0
# set rmargin 0
set key off
set style histogram clustered gap 0
set style fill solid 1.0 border
set boxwidth 0.5 absolute

set multiplot layout n_rows,n_cols \
  spacing 0,0 \
  title plot_title \
  font "Times New Roman, 24" \
  offset 0, -1

i = 0
do for [file in files] {
  print "processing file".file
  i = i + 1
  col = i - floor(i/n_cols)*n_cols
  row = floor(i/n_cols)

  # place ytics only on plots in the first column
  if (col == 1) {
    set ytics nomirror offset -0.5,0
  } else {
    unset ytics
  }

  set title word(titles, i) font "Times New Roman, 18" offset 0,-2
  plot file using 0:3:(0.5) with boxes \
    fillcolor "dark-gray" \
    linecolor "black"
}

unset multiplot
