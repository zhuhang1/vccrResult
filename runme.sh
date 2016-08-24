#!/bin/bash

# since this script eventually runs mininet, you should run it with sudo

script=`basename $0`
if [[ "$1" == "-h"  ]] 
then
	echo "Usage:	${script} {fig#...} {unfairness|all|short|vcc|extended}" 1>&2
	echo "	running ${script} without any arguments is like runnning \"${script} short\"" 1>&2
	echo "	figure numbers (e.g. 6) and subfigures (like 4a) can also be used" 1>&2
	echo "	all - 		produce all graphs that appear in the SIGCOMM paper" 1>&2
	echo "	unfairness - 	produce all figures that do not require a modified kernel" 1>&2
	echo "	short - 	produce figures except 1, 6, and 7 which take a long time to produce" 1>&2
	echo "	extended - 	produce figures that only appear in the extended version of the paper, except figure 15c" 1>&2
	echo "	vcc - 		produce only the figures that require a modified kernel" 1>&2
	echo "	IMPORTANT: since this script eventually runs mininet, you should run it with sudo" 1>&2
	exit 1
fi

if [ "$#" -eq 0 ]
then
	export targets="short"
else
	export targets=$@
fi

## If the following commands do not work you may comment them out and install gnuplot and python's termcolor package manually
echo "Verifying gnuplot is installed..."
command -v gnuplot >/dev/null 2>&1 || { apt-get update && apt-get -y install gnuplot; }
echo "Verifying python-termcolor is installed..."
dpkg -s python-termcolor >/dev/null 2>&1 || { apt-get install -y python-termcolor; }

figdir="./figures"
if [ ! -d "$figdir" ]; then
  mkdir -p $figdir
fi
#unset already_done
for target in ${targets}; do
	case ${target} in
	4|4[a-c])
		echo "********************************************************************************"
		echo "* Prodcuing Figure 4"
		echo "********************************************************************************"
		label="10s"
		bw=100
		./tcp_fair_RED.sh ${bw} ${label} RED1tab	
		cp ./tcpfair/$label-RED1-${bw}mbps-c1/goodput.png ${figdir}/fig4c.png
		cp ./tcpfair/$label-RED1-${bw}mbps-c5/goodput.png ${figdir}/fig4b.png
		cp ./tcpfair/$label-RED1-${bw}mbps-c9/goodput.png ${figdir}/fig4a.png
		already_done[4]=1
		;;
	6)
		echo "********************************************************************************"
		echo "* Prodcuing Figure 6"
		echo "********************************************************************************"
		source ./${script} 6a 6b
		already_done[6]=1
		;;
	6a)
		label="10s"
		bw=10
		./tcp_fair_RED.sh ${bw} ${label} REDtab
		./collect_fair ${figdir}/fig6a RED1:tcpfair/${label}-RED1-${bw}mbps RED2:tcpfair/${label}-RED2-${bw}mbps RED3:tcpfair/${label}-RED3-${bw}mbps
		;;
	6b)
		label="10s"
		bw=100
		if [ ${already_done[4]} ]
		then 
			tab="RED23tab"
		else
			tab="REDtab"
		fi
		./tcp_fair_RED.sh ${bw} ${label} ${tab}
		./collect_fair ${figdir}/fig6b RED1:tcpfair/${label}-RED1-${bw}mbps RED2:tcpfair/${label}-RED2-${bw}mbps RED3:tcpfair/${label}-RED3-${bw}mbps
		;;
	7)
		echo "********************************************************************************"
                echo "* Prodcuing Figure 7"
                echo "********************************************************************************"
		source ./${script} 7a 7b
		already_done[7]=1
		;;	
	7a)	
		label="10s"
		bw=10
		./tcp_fair_RED.sh ${bw} ${label} REDmin10tab
		./collect_fair ${figdir}/fig7a REDmin=20KB:tcpfair/${label}-REDmin20k-${bw}mbps REDmin=50KB:tcpfair/${label}-REDmin50k-${bw}mbps REDmin=100KB:tcpfair/${label}-REDmin100k-${bw}mbps
		;;
	7b)	
		label="10s"
		bw=100
		./tcp_fair_RED.sh ${bw} ${label} REDmin100tab
		./collect_fair ${figdir}/fig7b REDmin=20KB:tcpfair/${label}-REDmin20k-${bw}mbps REDmin=50KB:tcpfair/${label}-REDmin50k-${bw}mbps REDmin=100KB:tcpfair/${label}-REDmin100k-${bw}mbps
		;;
	6old)
		echo "********************************************************************************"
                echo "* Prodcuing Figure 6old"
                echo "********************************************************************************"
		if [ ! ${already_done[3]} ]
		then
			source ./${script} 4
		fi
		label="10s"
		bw=100
		cp ./tcpfair/$label-RED1-${bw}mbps-c1/retrans.png ${figdir}/fig6old.png
		;;
	9)
		echo "********************************************************************************"
                echo "* Prodcuing Figure 9"
                echo "********************************************************************************"
		./vtcp_ecn_comp.sh
		already_done[9]=1
		cp ./tcpvtcp/swnd.png ${figdir}/fig9.png
		;;
	15a)
		echo "********************************************************************************"
                echo "* Prodcuing Figure 15a"
                echo "********************************************************************************"
		if [ ! ${already_done[9]} ]
		then
			source ./${script} 9
		fi
		cp ./tcp/cwnd.png ${figdir}/fig15a.png	
		;;
	15b)
		echo "********************************************************************************"
                echo "* Prodcuing Figure 15b"
                echo "********************************************************************************"
		if [ ! ${already_done[9]} ]
		then
			source ./${script} 9
		fi
		cp ./tcpecn/cwnd.png ${figdir}/fig15b.png	
		;;
	15)
		source ./${script} 15a 15b
		;;
	18)
		echo "********************************************************************************"
                echo "* Prodcuing Figure 18"
                echo "********************************************************************************"
		if [ ! ${already_done[9]} ]
		then
			source ./${script} 9
		fi
		cp ./vtcp_comp/que.png ${figdir}/fig18.png
		;;
	17)
		echo "********************************************************************************"
                echo "* Prodcuing Figure 17"
                echo "********************************************************************************"
		if [ ! ${already_done[9]} ]
		then
			source ./${script} 9
		fi
		cp ./tcpvtcp/swnd.png ${figdir}/fig17.png
		;;
	11)
		source ./${script} 11a 11b
		;;
	11b)
		echo "********************************************************************************"
                echo "* Prodcuing Figure 11b"
                echo "********************************************************************************"
		bw=10
		clients=1
		./vtcp_fair.sh "virtual-ECN" ${bw} $clients 1 "vecn"$(tail -1 RED1tab)
		cp vtcpfair/vecnRED1-${bw}mbps-c1/goodput.png ${figdir}/fig11b.png
		;;
	11a)
		echo "********************************************************************************"
                echo "* Prodcuing Figure 11a"
                echo "********************************************************************************"
		bw=10
		clients=1
		./vtcp_fair.sh "non-ECN" ${bw} $clients 0 "noecn"$(tail -1 RED1tab)
		cp vtcpfair/noecnRED1-${bw}mbps-c1/goodput.png ${figdir}/fig11a.png
		;;
	10)
		source ./${script} 10a 10b 10c
		;;
	10c)
		echo "********************************************************************************"
                echo "* Prodcuing Figure 10c"
                echo "********************************************************************************"
		bw=10
		./vtcp_fair.sh "virtual-ECN" ${bw} 10 1 "vecn"$(tail -1 RED1tab)
		cp vtcpfair/vecnRED1-${bw}mbps-c10/total_retrans.png ${figdir}/fig10c.png
		;;
	10a)
		echo "********************************************************************************"
                echo "* Prodcuing Figure 10a"
                echo "********************************************************************************"
		bw=10
		./vtcp_fair.sh "non-ECN" ${bw} 10 0 "noecn"$(tail -1 RED1tab)
		cp vtcpfair/noecnRED1-${bw}mbps-c10/total_retrans.png ${figdir}/fig10a.png
		;;
	10b)
		echo "********************************************************************************"
                echo "* Prodcuing Figure 10b"
                echo "********************************************************************************"
		bw=10
		./vtcp_fair.sh "ECN" ${bw} 0 0 "ecn"$(tail -1 RED1tab)
		cp vtcpfair/ecnRED1-${bw}mbps-c0/total_retrans.png ${figdir}/fig10b.png
		;;

	1)
		echo "********************************************************************************"
                echo "* Prodcuing Figure 1"
                echo "********************************************************************************"
		bw=10
		./vtcp_hist.sh ${bw} $( tail -1 RED1tab )
		./collect_hist ${figdir}/fig1 ./vtcphist/RED1
		;;
	all)
		source ./${script} short 6 7 1
		;;
	short)
		source ./${script} 4 9 10 11
		;;
	unfairness)
		source ./${script} 4 6 7 10a 10b 11a 
		;;
	extended)
		source ./${script}  15 17 18
		;;
	vcc)
		source ./${script}  9 10c 11b 1
		;;
	*)
		echo "${script}: no such option" 1>&2
		exit 1
	esac
done
