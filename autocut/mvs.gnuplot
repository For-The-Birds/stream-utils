set terminal qt size 1600,900 enhanced font 'Verdana,10'
#set datafile separator '\t'
#set key autotitle columnhead

set style fill  transparent solid 0.35 noborder
#set logscale y;

plot 'FILENAME-mean.tsv' \
        u 2:3 w p pt 7 ps 0.1, \
     '' u 2:4 w l lc rgb "red", \
     '' u 2:5 w l lc rgb "yellow", \
     '' u 2:6 w l lc rgb "green", \
     '' u 2:7 w l lc rgb "blue", \
     'FILENAME-mean-filter.tsv' u 2:3

# sed 's/FILENAME/0628-mt4.txt/' mvs.gnuplot | gnuplot -p
