set terminal pngcairo size 1920,1080 enhanced font 'Verdana,10'
set yrange [0:]
set style fill  transparent solid 0.35 noborder
set output 'mvec.png'
plot 'motionvec.txt' using 1 with points pt 7 ps 1, \
     'motionvec.txt' using 2 with points pt 7 ps 1
     #'motionvec.txt_' using 3 with points pt 7 ps 1
