---
title: "Hugo 博客搭建时的问题"
description: 
date: 2024-11-25T22:48:38+08:00
hidden: false
comments: false
draft: false
---

## 不会自动换行
打开 hugo 博客的文件夹，全局搜索 goldmark
如果是 toml 格式，就改为下面的内容
```toml
[goldmark.renderer]
unsafe = true
hardwraps = true

```
yaml 格式
```yaml
markup:
  goldmark:
    renderer:
      hardWraps: true
```

![](chrome-extension://mapjgeachilmcbbokkgcbgpbakaaeehi/assets/check.svg)