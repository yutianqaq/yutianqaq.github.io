---
title: Reverse Shell 终端升级备忘录
date: 2026-08-31
draft: false
tags: 
hidden: false
comments: false
---

**1. 在目标机器（反弹 Shell 中）执行：**
```
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

**2. 在本地键盘按下：**
```
Ctrl + Z
```

**3. 在本地机器（你的终端中）执行：**

```
stty raw -echo; fg
```

_(执行后按下回车，如果没反应再按一次回车)_

**4. 在目标机器（恢复后的 Shell 中）执行：**
```
export TERM=xterm-256-color
```

**5. 修复窗口大小（可选，在目标机器执行）：**
```
# 先新开一个本地终端运行 stty size 看一下你的本地长宽（例如输出 38 116）
# 然后在目标机器输入对应的数字：
stty rows 38 columns 116
```