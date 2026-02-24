---
title: "pgsql"
date: "2026-01-03"
draft: false
tags: 
hidden: false
comments: false
---


# 列太多时显示不全
## 关闭 pager

先关闭 psql 的分页器，再执行 `\d`：

`docker compose exec postgres psql -U postgres -d jsonl_data`

进入 psql 后执行：

`\pset pager off \d nuclei_results`

这样就会一次性全部打印，不会被 `less` 截断。