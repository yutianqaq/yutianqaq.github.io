
在使用 VMware 虚拟化运行 Linux 系统时，很多人可能遇到这样的问题：

> **明明在虚拟机里删了大文件，宿主机的硬盘空间却一点没少。**

甚至点击 VMware 设置中的“碎片整理”或“压缩”按钮也没效果？那你可能忽略了一个关键步骤。
## 问题现象

- 虚拟机中删除了大量文件，比如日志、临时数据等。
- 虚拟机显示磁盘空间已经释放。
- 宿主机中 `.vmdk` 文件大小不变，磁盘占用未减少。
这是因为：**删除文件只是释放了文件系统中的“引用”，但磁盘空间在底层并未真正“清空”或“重写”。**

## 解决方法一
在开机后执行以下命令，过程可能变慢，耐心等待。
```
sudo vmware-toolbox-cmd disk shrink /
```
执行前的效果
虚拟机
![Image Description](/images/Pasted%20image%2020250806143752.png)
宿主机
![Image Description](/images/Pasted%20image%2020250806143708.png)

执行之后
![Image Description](/images/Pasted%20image%2020250806175039.png)

## 解决方法二

```
sudo dd if=/dev/zero of=zero.fill bs=1M
sudo sync
sudo rm -f zero.fill

```

![Image Description](/images/Pasted%20image%2020250806180747.png)

完成后，关机点击压缩
![Image Description](/images/Pasted%20image%2020250806180841.png)

效果
![Image Description](/images/Pasted%20image%2020250806182112.png)