# PXE-boot-environment
Basic files and configuration needed to setup a **PXE boot server**, compatible with both **Legacy Boot** and **UEFI**.

# Requirements

* dnsmasq
* nginx (or any other webserver)

# Support

It currently has support for PXE installing:

 * Centos 7.6

# Installation

## dnsmasq

You can use *dnsmasq.conf* file provided here, take into account the following parameters:

```
interface=enp2s0                                     # Must configure the server inetrface which will provide DHCP.
dhcp-option=3,192.168.0.1                            # Your network gateway, 192.168.0.1 in this case.
dhcp-option=6,192.168.0.3,1.1.1.1                    # DNS Servers you want to provide, change 192.168.0.3 for your server IP.
dhcp-boot=net:UEFI,grubx64.efi,pxeserver,192.168.0.3 # Change 192.168.0.3 for your server IP.
dhcp-boot=net:BIOS,pxelinux.0,pxeserver,192.168.0.3  # Change 192.168.0.3 for your server IP.
```

Additionally, you can change the other parameters if you know what you are doing.

Also, you can define */etc/dnsmasq.d/address.conf* file in the following format if you want to provide internal domain names:

```
address=/myinternaldomain.com/192.168.0.3
```
