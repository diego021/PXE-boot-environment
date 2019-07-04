# PXE-boot-environment

Embedded **PXE boot server**, compatible with both **Legacy Boot** and **UEFI**.

# Requirements

Embedded:
* None

Local install:
* dnsmasq
* nginx

# Support

It currently has support for PXE booting:

* Centos 7.6
* Clonezilla 2.6.1-25
* Debian 9
* Memtest86+ 5.01 (legacy only)
* Slax 9.9.0
* Windows PE (legacy only)

# Run embedded

To start the server, simply run this:

```
./pxe-boot.sh -start
```

To stop it:

```
./pxe-boot.sh -kill
```

# Installation

## DNSMASQ

You can use `dnsmasq.conf` file provided here, take into account the following parameters:

```
interface=enp2s0                                     # Must configure the server inetrface which will provide DHCP.
dhcp-range=192.168.0.120,192.168.0.180,1h            # DHCP range you want to provide for your network.
dhcp-option=3,192.168.0.1                            # Your network gateway, 192.168.0.1 in this case.
dhcp-option=6,192.168.0.3,1.1.1.1                    # DNS Servers you want to provide, change 192.168.0.3 for your server IP.
dhcp-boot=net:UEFI,grubx64.efi,pxeserver,192.168.0.3 # Change 192.168.0.3 for your server IP.
dhcp-boot=net:BIOS,pxelinux.0,pxeserver,192.168.0.3  # Change 192.168.0.3 for your server IP.
```

Additionally, it's possible to change other parameters if you know what you are doing.

You can define `/etc/dnsmasq.d/address.conf` file in the following format if you want to provide internal domain names:

```
address=/myinternaldomain.com/192.168.0.3
address=/mypxeserver.local/192.168.0.3
```

## TFTP

TFTP functionallity is given by **dnsmasq**, if you are using my `dnsmasq.conf` file, just copy this repo's `ftpd` folder to `/var`, full path shoud be `/var/ftpd`. If not, you can copy `ftpd` folder content to wherever your **ftpd-root** config is.

## NGINX
 
I will use **nginx** web server to provide local repository.

It's okay if you use default nginx configuration, note that my nginx root folder will be `/var/www/html` for this guide.

You must create `slax` and `pub` folders in http root:

```
mkdir -p /var/www/html/{slax,pub}
```

Then, it's recommended to enable autoindex functionality by adding the following to `/etc/nginx/sites-available/default`:

```
location ~ ^/(slax|pub)/ {
    autoindex on;
}
```

Or you can just replace `/etc/nginx/sites-available/default` with the one provided here.
