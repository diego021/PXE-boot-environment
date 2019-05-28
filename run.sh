#!/bin/bash
SOURCE_DIR=$(dirname $(realpath {BASH_SOURCE[0]}))
LD_LIBRARY_PATH=$SOURCE_DIR/lib
PATH=$SOURCE_DIR/bin

function kill() {
    busybox killall -9 dnsmasq 2> /dev/null
    busybox killall -9 busybox 2> /dev/null
}

function run_dnsmasq() {
    dnsmasq --no-resolv --no-hosts \
	    --dhcp-range=192.168.0.120,192.168.0.180,1h \
            --dhcp-vendorclass=BIOS,PXEClient:Arch:00000 \
            --dhcp-vendorclass=UEFI,PXEClient:Arch:00007 \
            --dhcp-vendorclass=UEFI,PXEClient:Arch:00009 \
            --dhcp-option=3,192.168.0.1 \
            --dhcp-option=6,192.168.0.3,1.1.1.1 \
            --dhcp-boot=net:BIOS,pxelinux.0,pxeserver,192.168.0.3 \
            --dhcp-boot=net:UEFI,grubx64.efi,pxeserver,192.168.0.3 \
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
              run_dnsmasq
              run_httpd
	      echo 'done'
	      ;;
    *) echo 'Run with -start or -kill'
       exit 1
       ;;
esac

exit 0
