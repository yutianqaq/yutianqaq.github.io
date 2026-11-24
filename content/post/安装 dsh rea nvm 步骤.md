---
title: 安装 dsh rea nvm 步骤
date: 2026-11-24
draft: false
tags: 
hidden: false
comments: false
---


# 安装 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

# 更新版本
nvm install --lts

# 给 dsh 安装 rea 
npx -y rea-agents@latest setup --client dsh

# 重启启动 dsh
npx @deepseek-ai/dsh web  

重启后新开一个会话，让 Agent 执行：列出你的 `mcp__rea__*` 工具
