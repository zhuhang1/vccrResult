# Virtual Congestion Control (vCC) scripts

## Description
This repository contains the scripts used to produce the figures presented in the Virtualized Congestion Control system proposed in the [SIGCOMM 2016 paper](http://dl.acm.org/citation.cfm?doid=2934872.2934889). More information about vCC can be found at the [vCC homepage](http://webee.technion.ac.il/~isaac/vcc/), including the original SIGCOMM paper, an extended version of the paper, and a link to the git repository with the kernel patch that implements a vCC Proof of Concept.

## Getting Started
You will first have to set up a working Mininet environement. You can download a VM already set up with everything Mininet needs from http://mininet.org/download/ (which is the easiest method to get Mininet). The following instructions assume a Mininet 2.2.1 on Ubuntu 14.04 LTS VM set up according to the recommendations in http://mininet.org/vm-setup-notes/, but a native installation could also be used (although it might be missing a few applications, which would probably be easy to install).

### First Steps
Log into the VM (e.g., using `ssh mininet@mininet-vm`) and clone this repository by running `mkdir -p  ~/git && cd ~/git && git clone git@github.com:aranb/vcc-exp.git`. Then cd into the newly create directory (`cd ~/git/vcc-exp`).

You can get the usage message by running `./runme.sh -h` at this point.

### Basic Unfairness Tests
To get the results on the 3.19 kernel (as are presented in the paper), first install the relevant kernel:
`sudo apt-get update && sudo apt-get install linux-image-3.19.0-31-generic linux-headers-3.19.0-31-generic linux-headers-3.19.0-31 linux-image-extra-3.19.0-31-generic`, then reboot and choose the newly installed kernel version, and only after that run the unfairness experiments as described below. You can verify the kernel version by running `uname -r` at the shell prompt.

You can run basic ECN vs. non-ECN unfairness tests by running `sudo ./runme.sh unfairness` which will create all the figures in the SIGCOMM paper that do not rely on a modified kernel.

Note: the first time this script is run it will attempt to install gnuplot, if it is not already installed. You can also install gnuplot manually, before running this script for the first time.

### Producing All Graphs
To produce the graphs that include the Proof-of-Concept modifed kernel, follow the instructions in the README.md file in https://github.com/brycecr/vcc_linux_vecn.git to build the modified kernel, install this kernel on the Mininet VM, reboot the VM and choose the modified kernel during the boot process. You may use the instructions in https://wiki.ubuntu.com/KernelTeam/GitKernelBuild to build the kernel (after applying the patch) on one machine and install it on the Mininet VM. 

Note: You can build the modified kernel on the Mininet VM, but you will have to increase its disk (and partition) size considerably (by about 20 GB) and it might take a long time to build the kernel, depending on your hosts's hardware.

Since producing figures 1, 6, and 7 takes a while, you can get all the rest of the graphs which depend on the modified kernel by running `sudo ./runme.sh vcc` or just produce all the figures (including all unfairness figures except 1, 6, and 7) by running `sudo ./runme.sh short`. (It will take close to an hour to produce all the figures).

To produce figures 1, 6, and 7, you can use `sudo ./runme.sh 1 6 7`. You can also run `sudo ./runme.sh all` which will produce all the figures.

## Where do I find the results?
All the final figures will be copied into the ./figures directory which the script creates. The data which the graphs are based on can be found in the following directories:

|Figure   | Directory|
|----------|----------|
|1         |./tcphist |
|4, 6, 7   |./tcpfair |
|9         |./tcpvtcp |
|10, 11    |./vtcpfair|

