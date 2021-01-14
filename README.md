#    You are welcome to use multifunctional installation scripts to install common software locally,  If there is no Installation package, activate the online download function
#    欢迎您使用多功能安装脚本，本地安装常用软件，不存在安装包，则激活在线下载功能

    The main function:
      1. Local Installation package, support parameters and activate silent installation;
      2. Automatically judge whether the file exists or not, then download it online;
      3. The installation disk can be specified with a drive letter. If it is not specified,
         it will be searched in the order of [a-z]. If it is not found, the system drive will be defaulted;
      4. Support decompression package processing, multiple modules.

    Prerequisites
      - PowerShell 5.1 or PowerShellCore 7.03 higher

    主要功能：
      1. 本地安装包，支持参数并激活静默安装；
      2. 自动判断文件是否存在，未存在，则在线下载；
      3. 安装盘可指定盘符，未指定则按 [a-z] 顺序搜索，
         未搜索到则默认系统盘；
      4. 支持解压包处理，多模块。

    先决条件：
      - PowerShell 5.1 或 PowerShellCore 7.03 更高

# 如何创建
# How to create

([Status]::Disable,
 [Action]::Install,
 [PP]::Wait,
 [FileType]::exe,
 "Nvidia GEFORCE GAME READY DRIVER",
 "auto",
 "Yi\00\Drive",
 "461.09-desktop-win10-64bit-international-dch-whql",
 "461.09-desktop-win10-64bit-international-dch-whql",
 "https://us.download.nvidia.com/Windows/461.09/",
 "-s -clean -noreboot -noeula"),

# How to create help:
1. Target structure: "Yi\00\Drive"
2. Drive letter: After setting "auto", search from A to Z (full disk search, according to structure),
Combine: [a-z]:\Yi\00\Drive

3. Drive letter: modify "auto" to "D",
Specify absolute path D:\Yi\00\Drive

# 帮助：
1、目标结构："Yi\00\Drive"
2、盘符：设置 "auto" 后，从 A 到 Z 盘搜索（全盘搜索，按结构），
合并：[a-z]:\Yi\00\Drive

3、盘符：修改 "auto" 为 "D"，
指定绝对路径 D:\Yi\00\Drive
