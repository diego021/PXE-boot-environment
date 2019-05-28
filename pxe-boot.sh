#!/bin/bash
SOURCE_DIR=$(dirname $(realpath {BASH_SOURCE[0]}))
PATH=$SOURCE_DIR/bin
LD_LIBRARY_PATH=$SOURCE_DIR/lib
export LD_LIBRARY_PATH

function kill() {
    busybox killall -9 dnsmasq 2> /dev/null
    busybox killall -9 busybox 2> /dev/null
}

function configure_grub() {
    busybox sed -i -e "s/PXE_SERVER/$PXE_SERVER/g" -e "s/CLIENT/$RANGE_END/" -e "s/ROUTE/$ROUTE/" $SOURCE_DIR/ftpd/grub.cfg
    busybox sed -i "s/PXE_SERVER/$PXE_SERVER/g" $SOURCE_DIR/ftpd/pxelinux.cfg/default
}

function network_data() {
    local IFACE=$(busybox ip route | busybox head -n1 | busybox awk '{print $NF}')
    local NET=$(busybox ip addr | busybox grep -E "^    inet .* $IFACE$" | busybox awk '{print $2}')
    PXE_SERVER=$(busybox echo $NET | busybox cut -d'/' -f1)
    ROUTE=$(busybox ip route | busybox head -n1 | busybox awk '{print $3}')
    RANGE_START=$(busybox echo $PXE_SERVER | busybox awk -F. '{printf "%d.%d.%d.%d", $1,$2,$3,120}')
    RANGE_END=$(busybox echo $PXE_SERVER | busybox awk -F. '{printf "%d.%d.%d.%d", $1,$2,$3,180}')
}

function run_dnsmasq() {
    dnsmasq --no-resolv --no-hosts \
	    --dhcp-range=$RANGE_START,$RANGE_END,1h \
            --dhcp-vendorclass=BIOS,PXEClient:Arch:00000 \
            --dhcp-vendorclass=UEFI,PXEClient:Arch:00007 \
            --dhcp-vendorclass=UEFI,PXEClient:Arch:00009 \
            --dhcp-option=3,$ROUTE \
            --dhcp-option=6,$PXE_SERVER,1.1.1.1 \
            --dhcp-boot=net:BIOS,pxelinux.0,pxeserver,$PXE_SERVER \
            --dhcp-boot=net:UEFI,grubx64.efi,pxeserver,$PXE_SERVER \
	    --enable-tftp --tftp-root=$(pwd)/ftpd
}

function run_httpd() {
    busybox httpd -p 80 -h $SOURCE_DIR/http 
}

if [ $UID != 0 ]; then
    echo 'Must be root to run PXE-boot-environment'
    exit 1
fi

case "$1" in 
    "-kill") echo -n 'Killing services...'
             kill
             echo 'done'
	     ;;
    "-start") echo -n 'Starting services...'
	      kill
	      network_data
              run_dnsmasq
              run_httpd
	      configure_grub
	      echo 'done'
	      ;;
    *) echo 'Run with -start or -kill'
       exit 1
       ;;
esac

exit 0
