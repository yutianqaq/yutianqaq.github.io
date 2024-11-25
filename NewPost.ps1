Write-Host "【创建文章】"

# 获取用户输入
$input = Read-Host "请输入Slug"

# 获取当前日期并格式化
$date = Get-Date -Format "yyyyMMdd"

# 创建目录并新建 Markdown 文件
$newPostPath = "content\post\$input\index.md"
# $newPostPath = "content\post\$($date.Substring(0,4))\$($date.Substring(4,2))$($date.Substring(6,2))-$input\index.md"
hugo new $newPostPath

Write-Host "文章已创建：$newPostPath"
