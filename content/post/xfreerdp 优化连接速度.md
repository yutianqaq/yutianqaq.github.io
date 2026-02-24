---
title: "xfreerdp 优化连接速度"
date: "2025-12-06"
draft: false
tags: 
hidden: false
comments: false
---

Below are various commands that may help in connecting to various lab instances, some have compression flags to help speed up connections:
**NOTE**: Can also be used with `proxychains`

`xfreerdp /cert:ignore /compression /auto-reconnect /u:USERNAME /p:PASSWORD /v:IP_ADDRESS`

`sudo rdesktop -u USERNAME -p PASSWORD -g 90% -r disk:local="/home/kali/Desktop/" IP-ADDRESS`

`rdesktop -u USERNAME -p PASSWORD -a 16 -P -z -b -g 1280x860 IP_ADDRESS`

 `xfreerdp /u:USERNAME /p:PASSWORD /cert:ignore /v:IP_ADDRESS /w:2600 /h:1400`

`xfreerdp +nego +sec-rdp +sec-tls +sec-nla /d: /u: /p: /v:IP_ADDRESS /u:USERNAME /p:PASSWORD /size:1180x708`

`rdesktop -z -P -x m -u USERNAME -p PASSWORD`

`xfreerdp /u:USERNAME /p:'PASSWORD' /v:IP_ADDRESS`

`xfreerdp /cert:ignore /bpp:8 /compression -themes -wallpaper /auto-reconnect /h:1000 /w:1400 /u:USERNAME /p:'PASSWORD' /v:IP_ADDRESS`

`xfreerdp /cert:ignore /compression /auto-reconnect /d:DOMAIN_NAME /u:USERNAME /p:PASSWORD /v:IP_ADDRESS`