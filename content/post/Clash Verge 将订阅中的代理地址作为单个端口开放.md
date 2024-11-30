---
title: "Clash Verge 将订阅中的代理地址作为单个端口开放"
description: 
date: 2024-11-25T22:24:27+08:00
image: 
math: 
license: 
hidden: false
comments: true
draft: false
---

来到 Profile 选中订阅地址，点击右键选择 Open File 或者 Edit File

!![Image Description](/images/Pasted%20image%2020241130213818.png)

在 proxies 上方新增如下内容
```yaml
listeners:
  - name: mixed-in
    type: mixed
    port: 27891
    listen: 127.0.0.1
    proxy: proxies 中的 name 字段 - 美国节点
    users: 
	  - admin: password 
  - name: socks-in
    type: socks
    port: 27892
    listen: 127.0.0.1
    proxy: proxies 中的 name 字段 - 新加坡节点
  - name: http-in
    type: http
    port: 27893
    listen: 127.0.0.1
    proxy: proxies 中的 name 字段 - 香港节点
    
```
> 当有 `users` 字段时将作为需认证的代理
> mixed 为将socks/http合并，socks 为仅限socks，http 为仅限 http
> name 需要唯一
> proxy 字段需要填写对应的 proxies 中的 name 字段


以下配置将在本地启动一个节点，归属为香港，并开放同时支持 HTTP 和 SOCKS 协议的端口 `17891`
```bash
port: 7890
socks-port: 7891
allow-lan: true
mode: Rule
log-level: info
external-controller: 127.0.0.1:9090
listeners:
  - name: mixed-in
    type: mixed
    port: 17891
    listen: 127.0.0.1
    proxy: "🇭🇰 港hk"
proxies:
  - {name: 🇭🇰 港hk, server: ...[snip]... true}
```

完成后选择重启应用，当订阅更新时，配置将消失。

!![Image Description](/images/Pasted%20image%2020241130213828.png)

 