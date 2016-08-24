#!/bin/bash

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

if [ "$#" -lt 1 ]
then
  echo "Usage: `basename $0` key bw cutoff vtcp label limit min max avpkt burst prob" 1>&2
  exit 1
fi

key1=$1; shift
bw=$1; shift
cutoff=$1; shift
vtcp=$1; shift
label="$1-${bw}mbps"; shift
red_limit=$1; shift
red_min=$1; shift
red_max=$1; shift
red_avpkt=$1; shift
red_burst=$1; shift
red_prob=$1

time=12
bwnet=${bw}
bwhost=${bw}
delay=0.25

warmup=5
maxtime=35

iperf_port=5001
#iperf=~/iperf-patched/src/iperf
iperf=`which iperf`
qsize=1000
    dir="vtcpfair/${label}-c${cutoff}"
    rm -rf $dir
    mkdir -p $dir
    python tcpfair.py --cong reno --cong1 reno --congrest reno --delay $delay -b $bwnet -B $bwhost -d $dir --maxq $qsize -t $time \
    --red_limit $red_limit \
    --red_min $red_min \
    --red_max $red_max \
    --red_avpkt $red_avpkt \
    --red_burst $red_burst \
    --red_prob $red_prob \
    --ecn 0 --ecnrest 1 --cutoff $cutoff \
    --vtcp $vtcp --vtcprest 0 \
    --red 1 \
    --iperf $iperf -k 0 -n 11
    #python plot_tcpprobe.py -f $dir/cwnd.txt -o $dir/cwnd.png -p $iperf_port
    #python plot_queue.py -f $dir/q.txt --legend "tcp-ecn"  -o $dir/queue.png
    trace=$(ls -t /tmp/wireshark* | head -1)
    gzip ${trace}
    mv ${trace}.gz $dir/
    gzip $dir/cwnd.txt
    #rm -rf $dir1 $dir2
    #python plot_ping.py -f $dir/ping.txt -o $dir/rtt.png
    ./process $warmup $maxtime 10 $cutoff $key1 $dir/${trace##*/}.gz
    chown mininet:mininet $dir/*
    pkill -9 iperf
