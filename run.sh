#!/bin/bash
SOURCE_DIR=$(dirname $(realpath {BASH_SOURCE[0]}))
PATH=$SOURCE_DIR/bin:$PATH
LD_LIBRARY_PATH=$SOURCE_DIR/lib
export LD_LIBRARY_PATH

function kill() {
    busybox killall -9 dnsmasq 2> /dev/null
    busybox killall -9 busybox 2> /dev/null
}

function network_data() {
    local IFACE=$(ip route | head -n1 | awk '{print $NF}')
    local NET=$(ip addr | grep -E "^    inet .* $IFACE$" | awk '{print $2}')
    PXE_SERVER=$(echo $NET | cut -d'/' -f1)
    ROUTE=$(ip route | head -n1 | awk '{print $3}')
    RANGE_START=$(echo $PXE_SERVER | awk -F. '{printf "%d.%d.%d.%d", $1,$2,$3,120}')
    RANGE_END=$(echo $PXE_SERVER | awk -F. '{printf "%d.%d.%d.%d", $1,$2,$3,180}')
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
	      echo 'done'
	      ;;
    *) echo 'Run with -start or -kill'
       exit 1
       ;;
esac

exit 0
