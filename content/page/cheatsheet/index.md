---
title: "CheatSheet"
date: 2022-03-06
layout: "cheatsheet"
slug: "cheatsheet"
menu:
    main:
        weight: 5
        params: 
            icon: clock
---

## Cheat Sheet
[HackTools](https://yutianqaq.github.io/hack-tools/) [代码片段](https://gist.github.com/yutianqaq) [工具集合](https://gist.github.com/yutianqaq/9529b55a7bee6c51f91d6cf975f9e7af)

### 编译命令_Go

`go install mvdan.cc/garble@latest`

```bash
# garble
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 garble -tiny -literals -seed=random build -ldflags "-s -w -H=windowsgui" -trimpath -o hello-grable.exe

CGO_ENABLED=0 GOOS=windows GOARCH=amd64 garble -seed=random build -ldflags "-s -w -H=windowsgui" -trimpath -o hello-grable.exe

# go
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -ldflags "-s -w -H=windowsgui" -trimpath

## windows
set CGO_ENABLED=0 && set GOOS=windows && set GOARCH=amd64 && go build -ldflags "-s -w -H=windowsgui" -trimpath 
```

### devenv.exe

[Devenv command line switches - Visual Studio | Microsoft Learn](https://learn.microsoft.com/en-us/visualstudio/ide/reference/devenv-command-line-switches?view=vs-2022)

```
devenv /build Release .\Project.sln
```

## 系统和软件包自动换源
```
curl -LO https://gitee.com/RubyMetric/chsrc/releases/download/pre/chsrc_latest-1_amd64.deb
sudo sudo dpkg -i chsrc_latest-1_amd64.deb
```


## docker
```
curl https://get.docker.com/ | sh

# 换源（可选）
sudo chsrc set dockerhub
```


## go
```
#!/bin/bash
set -e
# Install snap if missing
if ! command -v snap &>/dev/null; then
    echo "Installing snap..."
    sudo apt update && sudo apt install snapd -y
fi
# Install latest Go via snap
sudo snap install --classic go
# Add Go to PATH for current session
export PATH=$PATH:/snap/bin
echo "✅ Go installed: $(go version)"
```


## projectdiscovery
```
go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest
pdtm -ia
```




## gowitness
```
go install github.com/sensepost/gowitness@latest
```


```
gowitness scan file -f targets.txt --threads 5 --write-db
```







用于更新平时在 github、x 看到的项目、技巧等

https://pauljerimy.com/security-certification-roadmap/ - 证书表格

https://ntdoc.m417z.com/ - Nt 文档

https://github.com/Flangvik/SharpCollection - C# 工具集



## 命令帮助

[rubeus.exe](https://yutianqaq.github.io/rubeus.txt) - [sharphound.exe](https://yutianqaq.github.io/sharphound.txt) - [sqlrecon.exe](https://github.com/skahwah/SQLRecon/wiki) - [sigthief.py](https://yutianqaq.github.io/sigthief.txt)

### 信息搜集

[Google Dorks for Bug Bounty](https://taksec.github.io/google-dorks-bug-bounty/) - Google Dorks 语法自动生成工具
https://github.com/msd0pe-1/cve-maker - cve 搜索工具
https://github.com/vdjagilev/nmap-formatter - xml2cvs、json、html
https://github.com/projectdiscovery/httpx - 存活、标题、指纹、技术探测

### 利用

https://github.com/projectdiscovery/nuclei - 基于模板的 POC 验证工具


## 规避杀软

### Nim

[icyguider/Nimcrypt2: .NET, PE, & Raw Shellcode Packer/Loader Written in Nim](https://github.com/icyguider/Nimcrypt2)

[aeverj/NimShellCodeLoader: 使用nim编写的shellcode加载器](https://github.com/aeverj/NimShellCodeLoader)



## Cobalt Strike

### BOF

https://github.com/ajpc500/BOFs - Collection of Beacon Object Files

### 插件

https://github.com/0xthirteen/MoveKit - 横向移动

https://github.com/yutianqaq/CSx3Ldr - 免杀 Nim

