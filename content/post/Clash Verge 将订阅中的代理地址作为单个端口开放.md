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

来到 Profile 选中订阅地址，点击右键选择 Open File

![](9ac6f43ecd25db757eebd1b949da3496.png)

在 proxies 上方新增如下内容
```yaml
listeners:
  - name: mixed-in
    type: mixed
    port: 17891
    listen: 127.0.0.1
    proxy: proxies 中的 name 字段1
    users: 
	  - admin: password 
  - name: socks-in
    type: socks
    port: 17892
    listen: 127.0.0.1
    proxy: proxies 中的 name 字段2
  - name: http-in
    type: http
    port: 17893
    listen: 127.0.0.1
    proxy: proxies 中的 name 字段3
    
```
> 当有 `users` 字段时将作为需认证的代理
> mixed 为将socks/http合并，socks 为仅限socks，http 为仅限 http
> name需要唯一
>proxy字段需要填写对应的 proxies 中的 name 字段


修改后
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
    proxy: "proxies 中的 name 字段"
proxies:
  - {name: 🇭🇰 港hk, server: ...[snip]... true}
```

完成后选择重启应用，当订阅更新时，配置将消失

![](c8bebe5e750f709686b05a66f046739b.png)

 

![](chrome-extension://mapjgeachilmcbbokkgcbgpbakaaeehi/assets/check.svg)