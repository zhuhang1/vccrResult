#!/bin/bash

if [ "$#" -lt 1 ]
then
  echo "Usage: `basename $0` label key1" 1>&2
  exit 1
fi

label=$1
key1="$2"

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

time=12
bwnet=100
bwhost=100
delay=0.25

warmup=5

# RED2
#red_limit=400000
#red_min=30000
#red_max=90000
#red_avpkt=1000
#red_burst=55
#red_prob=0.02

# RED3
#red_limit=400000
#red_min=30000
#red_max=90000
#red_avpkt=1000
#red_burst=55
#red_prob=1.0

#RED compare?
#red_min=3333
#red_max=10000
#red_avpkt=1500
#red_burst=500
#red_prob=0.1

# RED 1
red_limit=1000000
red_min=90000
red_max=90001
red_avpkt=1500
red_burst=61 # 61 534 
red_prob=1
iperf_port=5001
#iperf=~/iperf-patched/src/iperf
iperf=`which iperf`
qsize=200
for cutoff in 1 2 3 4 5; do
    dir="tcpfair/${label}-c${cutoff}"
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
    --vtcp 0 --vtcprest 0 \
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
    ./process $warmup 10 $cutoff $key1 $dir/${trace##*/}.gz
    chown mininet:mininet $dir/*
    pkill -9 iperf
done
