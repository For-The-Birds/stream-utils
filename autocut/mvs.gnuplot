#set terminal qt size 1600,900 enhanced font 'Verdana,10'
set terminal pngcairo size 1920,1080 enhanced font 'Verdana,10'
set output 'FILENAME.png'
#set datafile separator '\t'
#set key autotitle columnhead
set title "FILENAME"

set style fill  transparent solid 0.35 noborder
set logscale y;

#     '' u 2:4 w l lc rgb "red", \

plot 'FILENAME-mean.tsv' \
        u 2:3 w p pt 7 ps 0.1, \
     '' u 2:5 w l lc rgb "yellow", \
     '' u 2:6 w l lc rgb "green", \
     '' u 2:7 w l lc rgb "blue", \
     'FILENAME-mean-filter.tsv' u 2:3 w p lc rgb "red"

# sed 's/FILENAME/2022-03-10_06:25.mkv.mvs/' mvs.gnuplot | gnuplot -p
