#!/bin/bash

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

time=12
bwnet=10
bwhost=12
delay=0.25

# Red settings (for DCTCP)
red_limit=1000000
red_min=90000
red_max=90001
red_avpkt=1500
red_burst=61
red_prob=1
iperf_port=5001
#iperf=~/iperf-patched/src/iperf
iperf=`which iperf`
qsize=1000

    dirtcp=tcp
    direcn=tcpecn
    dirvtcp=tcpvtcp
    dirout=vtcp_comp
    rm -rf $dirtcp $direcn $dirvtcp $dirout
    mkdir $dirout
    mkdir $dirtcp
    mkdir $direcn
    mkdir $dirvtcp

    red_params="--red_limit $red_limit \
    --red_min $red_min \
    --red_max $red_max \
    --red_avpkt $red_avpkt \
    --red_burst $red_burst \
    --red_prob $red_prob"
 
    python tcpecn.py --cong reno --delay $delay -b $bwnet -B $bwhost -d $dirtcp --maxq $qsize -t $time \
    ${red_params} \
    --ecn 0 --red 1 --vtcp 0 \
    --iperf $iperf -k 0 -n 2

    trace=$(ls -t /tmp/wireshark* | head -1)
    gzip ${trace}
    mv ${trace}.gz $dirtcp/ 

    python tcpecn.py --cong reno --delay $delay -b $bwnet -d $direcn -B $bwhost --maxq $qsize -t $time \
    ${red_params}  \
    --ecn 1 --red 1 --vtcp 0 --iperf $iperf -k 0 -n 2

    trace=$(ls -t /tmp/wireshark* | head -1)
    gzip ${trace}
    mv ${trace}.gz $direcn/

    python tcpecn.py --cong reno --delay $delay -b $bwnet -d $dirvtcp -B $bwhost --maxq $qsize -t $time \
    ${red_params}  \
    --ecn 0 --red 1 --vtcp 1 --iperf $iperf -k 0 -n 2

    trace=$(ls -t /tmp/wireshark* | head -1)
    gzip ${trace}
    mv ${trace}.gz $dirvtcp/

#    python plot_tcpprobe.py -f $dirtcp/cwnd.txt -o $dirtcp/cwnd-iperf.png -p $iperf_port
#    python plot_tcpprobe.py -f $direcn/cwnd.txt -o $direcn/cwnd-iperf.png -p $iperf_port
#    python plot_tcpprobe.py -f $dirvtcp/cwnd.txt -o $dirvtcp/cwnd-iperf.png -p $iperf_port
#    python plot_queue.py -f $dirtcp/q.txt $dirvtcp/q.txt --legend tcp vtcp -o \
#    $dirout/tcp_ecn_vtcp_queue.png
#    python plot_queue.py -f $dirtcp/q.txt $direcn/q.txt $dirvtcp/q.txt --legend tcp ecn vtcp -o \
#    $dirout/tcp_ecn_vtcp_queue.png
    #rm -rf $dir1 $dir2
    #python plot_ping.py -f $dir/ping.txt -o $dir/rtt.png
    ./getq $dirtcp/q.txt > $dirout/tcp_q.txt
    ./getq $direcn/q.txt > $dirout/tcpecn_q.txt
    ./getq $dirvtcp/q.txt > $dirout/tcpvtcp_q.txt
    ./getcwnd $dirtcp/cwnd.txt > $dirtcp/tcp_cwnd.txt
    ./getcwnd $direcn/cwnd.txt > $direcn/tcp_cwnd.txt
    ./getcwnd $dirvtcp/cwnd.txt > $dirvtcp/tcp_cwnd.txt
    ./getswnd $dirtcp/cwnd.txt > $dirtcp/tcp_swnd.txt
    ./getswnd $direcn/cwnd.txt > $direcn/tcpn_swnd.txt
    ./getswnd $dirvtcp/cwnd.txt > $dirvtcp/tcp_swnd.txt
    gnuplot -e  "keys=\"non-ECN ECN virtual-ECN\"; files=\"$dirout/tcp_q.txt $dirout/tcpecn_q.txt $dirout/tcpvtcp_q.txt\"; outfile=\"$dirout/que.png\"" plot_que
    
    gnuplot -e  "infile=\"$dirtcp/tcp_cwnd.txt\"; outfile=\"$dirtcp/cwnd.png\"" plot_cwnd
    gnuplot -e  "infile=\"$direcn/tcp_cwnd.txt\"; outfile=\"$direcn/cwnd.png\"" plot_cwnd
    gnuplot -e  "infile=\"$dirvtcp/tcp_cwnd.txt\"; outfile=\"$dirvtcp/cwnd.png\"" plot_cwnd
    gnuplot -e  "infile=\"$dirtcp/tcp_swnd.txt\"; outfile=\"$dirtcp/swnd.png\"" plot_swnd
    gnuplot -e  "infile=\"$direcn/tcp_swnd.txt\"; outfile=\"$direcn/swnd.png\"" plot_swnd
    gnuplot -e  "infile=\"$dirvtcp/tcp_swnd.txt\"; outfile=\"$dirvtcp/swnd.png\"" plot_swnd
chown mininet:mininet $dirtcp/* $dirout/* $dirvtcp/* $direcn/*
