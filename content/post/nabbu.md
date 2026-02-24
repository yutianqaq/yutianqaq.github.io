


nmap原始文件内容
nmap 192.168.1.117 -p 2080,5173,5432,22 -sV -oX nmap-output 

```

 cat nmap-output 
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE nmaprun>
<?xml-stylesheet href="file:///usr/share/nmap/nmap.xsl" type="text/xsl"?>
<!-- Nmap 7.95 scan initiated Fri Jan  2 11:35:27 2026 as: /usr/lib/nmap/nmap -&#45;privileged -p 2080,5173,5432,22 -sV -oX nmap-output 192.168.1.117 -->
<nmaprun scanner="nmap" args="/usr/lib/nmap/nmap -&#45;privileged -p 2080,5173,5432,22 -sV -oX nmap-output 192.168.1.117" start="1767382527" startstr="Fri Jan  2 11:35:27 2026" version="7.95" xmloutputversion="1.05">
<scaninfo type="syn" protocol="tcp" numservices="4" services="22,2080,5173,5432"/>
<verbose level="0"/>
<debugging level="0"/>
<host starttime="1767382527" endtime="1767382528"><status state="up" reason="localhost-response" reason_ttl="0"/>
<address addr="192.168.1.117" addrtype="ipv4"/>
<hostnames>
</hostnames>
<ports><port protocol="tcp" portid="22"><state state="open" reason="syn-ack" reason_ttl="64"/><service name="ssh" product="OpenSSH" version="10.0p2 Debian 5" extrainfo="protocol 2.0" ostype="Linux" method="probed" conf="10"><cpe>cpe:/a:openbsd:openssh:10.0p2</cpe><cpe>cpe:/o:linux:linux_kernel</cpe></service></port>
<port protocol="tcp" portid="2080"><state state="filtered" reason="no-response" reason_ttl="0"/><service name="autodesk-nlm" method="table" conf="3"/></port>
<port protocol="tcp" portid="5173"><state state="filtered" reason="no-response" reason_ttl="0"/></port>
<port protocol="tcp" portid="5432"><state state="filtered" reason="no-response" reason_ttl="0"/><service name="postgresql" method="table" conf="3"/></port>
</ports>
<times srtt="61" rttvar="5000" to="100000"/>
</host>
<runstats><finished time="1767382528" timestr="Fri Jan  2 11:35:28 2026" summary="Nmap done at Fri Jan  2 11:35:28 2026; 1 IP address (1 host up) scanned in 1.41 seconds" elapsed="1.41" exit="success"/><hosts up="1" down="0" total="1"/>
</runstats>
</nmaprun>

```

问题描述：
终端终输出正确
受到了ssh这样带有,额外字段影响`"extra_info":"protocol 2.0","method":"probed","name":"ssh","os_type":"Linux","product":"OpenSSH","version":"10.0p2 Debian 5"`  导致在22端口后面都会有信息，实际不应该有
```
{"ip":"192.168.1.117","timestamp":"2026-01-02T20:13:16.588674058Z","port":22,"protocol":"tcp","tls":false,"extra_info":"protocol 2.0","method":"probed","name":"ssh","os_type":"Linux","product":"OpenSSH","version":"10.0p2 Debian 5"}
```


```
┌──(kali㉿kali)-[~/asm/tools/naabu]
└─$ sudo /home/kali/go/bin/naabu -host 192.168.1.117 -port 22,2080,5173,5432 -nmap-cli 'nmap -sV -oX nmap-output' -json -o test2_fixed3

                  __
  ___  ___  ___ _/ /  __ __
 / _ \/ _ \/ _ \/ _ \/ // /
/_//_/\_,_/\_,_/_.__/\_,_/

                projectdiscovery.io

[INF] Current naabu version 2.3.7 (latest)
[WRN] UI Dashboard is disabled, Use -dashboard option to enable
[INF] Running CONNECT scan with non root privileges
[INF] Running nmap scan on range 0: 192.168.1.117 -p 22,2080,5173,5432
[INF] Using custom nmap arguments: -sV -oX nmap-output
[INF] Integrating nmap results for 192.168.1.117:
  22/tcp (ssh 10.0p2 Debian 5 OpenSSH)
[INF] Found 4 ports on host 192.168.1.117 (192.168.1.117)
{"ip":"192.168.1.117","timestamp":"2026-01-02T20:13:16.587829151Z","port":5432,"protocol":"tcp","tls":false}
{"ip":"192.168.1.117","timestamp":"2026-01-02T20:13:16.588674058Z","port":22,"protocol":"tcp","tls":false,"extra_info":"protocol 2.0","method":"probed","name":"ssh","os_type":"Linux","product":"OpenSSH","version":"10.0p2 Debian 5"}
{"ip":"192.168.1.117","timestamp":"2026-01-02T20:13:16.588682586Z","port":2080,"protocol":"tcp","tls":false}
{"ip":"192.168.1.117","timestamp":"2026-01-02T20:13:16.588684502Z","port":5173,"protocol":"tcp","tls":false}
                                                                                                                                                                                             
┌──(kali㉿kali)-[~/asm/tools/naabu]
└─$ cat test2_fixed3
{"ip":"192.168.1.117","timestamp":"2026-01-02T20:13:16.588752152Z","port":5432,"protocol":"tcp","tls":false}
{"ip":"192.168.1.117","timestamp":"2026-01-02T20:13:16.588752152Z","port":22,"protocol":"tcp","tls":false,"extra_info":"protocol 2.0","method":"probed","name":"ssh","os_type":"Linux","product":"OpenSSH","version":"10.0p2 Debian 5"}
{"ip":"192.168.1.117","timestamp":"2026-01-02T20:13:16.588752152Z","port":2080,"protocol":"tcp","tls":false,"extra_info":"protocol 2.0","method":"probed","name":"ssh","os_type":"Linux","product":"OpenSSH","version":"10.0p2 Debian 5"}
{"ip":"192.168.1.117","timestamp":"2026-01-02T20:13:16.588752152Z","port":5173,"protocol":"tcp","tls":false,"extra_info":"protocol 2.0","method":"probed","name":"ssh","os_type":"Linux","product":"OpenSSH","version":"10.0p2 Debian 5"}
```

但是当ssh这类有额外信息的在最后时候
输出的文件将不受影响

```
┌──(kali㉿kali)-[~/asm/tools/naabu]
└─$ sudo /home/kali/go/bin/naabu -host 192.168.1.117 -port 22,2080,5173,5432 -nmap-cli 'nmap -sV -oX nmap-output' -json -o test2_final

                  __
  ___  ___  ___ _/ /  __ __
 / _ \/ _ \/ _ \/ _ \/ // /
/_//_/\_,_/\_,_/_.__/\_,_/

                projectdiscovery.io

[INF] Current naabu version 2.3.7 (latest)
[WRN] UI Dashboard is disabled, Use -dashboard option to enable
[INF] Running CONNECT scan with non root privileges
[INF] Running nmap scan on range 0: 192.168.1.117 -p 22,5173,2080,5432
[INF] Using custom nmap arguments: -sV -oX nmap-output
[INF] Integrating nmap results for 192.168.1.117:
  22/tcp (ssh 10.0p2 Debian 5 OpenSSH)
[INF] Found 4 ports on host 192.168.1.117 (192.168.1.117)
{"ip":"192.168.1.117","timestamp":"2026-01-02T20:12:49.130256857Z","port":5173,"protocol":"tcp","tls":false}
{"ip":"192.168.1.117","timestamp":"2026-01-02T20:12:49.130791905Z","port":2080,"protocol":"tcp","tls":false}
{"ip":"192.168.1.117","timestamp":"2026-01-02T20:12:49.130797678Z","port":5432,"protocol":"tcp","tls":false}
{"ip":"192.168.1.117","timestamp":"2026-01-02T20:12:49.130802565Z","port":22,"protocol":"tcp","tls":false,"extra_info":"protocol 2.0","method":"probed","name":"ssh","os_type":"Linux","product":"OpenSSH","version":"10.0p2 Debian 5"}
                                                                                                                                                                                             
┌──(kali㉿kali)-[~/asm/tools/naabu]
└─$ cat test2_final                                                                                                                   
{"ip":"192.168.1.117","timestamp":"2026-01-02T20:12:49.130857521Z","port":5173,"protocol":"tcp","tls":false}
{"ip":"192.168.1.117","timestamp":"2026-01-02T20:12:49.130857521Z","port":2080,"protocol":"tcp","tls":false}
{"ip":"192.168.1.117","timestamp":"2026-01-02T20:12:49.130857521Z","port":5432,"protocol":"tcp","tls":false}
{"ip":"192.168.1.117","timestamp":"2026-01-02T20:12:49.130857521Z","port":22,"protocol":"tcp","tls":false,"extra_info":"protocol 2.0","method":"probed","name":"ssh","os_type":"Linux","product":"OpenSSH","version":"10.0p2 Debian 5"}
```