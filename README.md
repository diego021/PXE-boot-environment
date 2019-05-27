# PXE-boot-environment
Basic files and configuration needed to setup a **PXE boot server**, compatible with both **Legacy Boot** and **UEFI**.

# Requirements

* dnsmasq
* nginx (or any other webserver)

# Support

It currently has support for PXE booting:

* Centos 7.6
* Clonezilla 2.6.1-25
* Slax 9.9.0 (legacy boot only)

# Installation

## DNSMASQ

You can use `dnsmasq.conf` file provided here, take into account the following parameters:

```
interface=enp2s0                                     # Must configure the server inetrface which will provide DHCP.
dhcp-option=3,192.168.0.1                            # Your network gateway, 192.168.0.1 in this case.
dhcp-option=6,192.168.0.3,1.1.1.1                    # DNS Servers you want to provide, change 192.168.0.3 for your server IP.
dhcp-boot=net:UEFI,grubx64.efi,pxeserver,192.168.0.3 # Change 192.168.0.3 for your server IP.
dhcp-boot=net:BIOS,pxelinux.0,pxeserver,192.168.0.3  # Change 192.168.0.3 for your server IP.
```

Additionally, you can change the other parameters if you know what you are doing.

Also, you can define `/etc/dnsmasq.d/address.conf` file in the following format if you want to provide internal domain names:

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

Then, enable autoindex functionality by adding the following to `/etc/nginx/sites-available/default`:

```
location ~ ^/(slax|pub)/ {
    autoindex on;
}
```

Alternatively, you can just replace `/etc/nginx/sites-available/default` with the one provided here.

