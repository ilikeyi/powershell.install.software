#    You are welcome to install the software using PowerShell
#    欢迎您使用 PowerShell 安装软件

    The main function:
      1. The installation package does not exist locally, activate the download;
      2. You can specify the drive letter of the Apps, if not specified, search in the order of [d-z],
         Only the available disks are searched, and the default current system disk is not searched;
      3. Search file name supports fuzzy search, wildcard *;
      4. Support decompression package processing, etc.

    Prerequisites
      - PowerShell 1.0 or higher

    主要功能：
      1. 本地不存在安装包，激活下载；
      2. 可指定软件包盘符，未指定则按 [d-z] 顺序搜索，
         仅搜索可用盘，未搜索到默认当前系统盘；
      3. 搜索文件名支持模糊查找，通配符 *；
      4. 支持解压包处理等。

    先决条件：
      - PowerShell 5.1 或 PowerShellCore 7.03 更高

# How to using
```
("Nvidia GEFORCE GAME READY DRIVER",                  # Package name
 [Status]::Disable,                                   # Status: Enable = enabled, Disable = disabled
 [Action]::Install,                                   # Action: Install = install, NoInst = do not install after download, Unzip = only extract after download, To = install to directory
 [PP]::Wait,                                          # Operating mode: Wait = wait for the end of the run, Fast = run directly
 [FileType]::exe,                                     # File type: exe, zip, or custom file type
 "auto",                                              # Drive letter: Auto = full disk search, A-Z = designated drive letter or custom path
 "Installation package\Drive",                        # Directory structure, for example: change AUTO to C, merge result: C:\Yi\Apps\Drive
 "*-desktop-win10-*-international-dch-whql",          # Match file name, support fuzzy function (*)
 "460.89-desktop-win10-64bit-international-dch-whql", # The absolute file name of the website download, please do not fill in the suffix
 "https://us.download.nvidia.cn/Windows/460.89/",     # Site path prefix, ending with /
 "-s -clean -noreboot -noeula"),                      # Parameters
```

# 如何使用
```
("Nvidia GEFORCE GAME READY DRIVER",                  # 软件包名称
 [Status]::Disable,                                   # 状态：Enable = 启用，Disable = 禁用
 [Action]::Install,                                   # 动作：Install = 安装，NoInst = 下载后不安装，Unzip = 下载后仅解压，To = 安装到目录
 [PP]::Wait,                                          # 运行方式：Wait = 等待运行结束，Fast = 直接运行
 [FileType]::exe,                                     # 文件类型：exe, zip，或自定义文件类型
 "auto",                                              # 盘符：Auto = 全盘搜索，A-Z = 指定盘符或自定义路径
 "安装包\驱动",                                        # 目录结构，例如：AUTO 改成 C，合并结果：C:\Yi\Apps\Drive
 "*-desktop-win10-*-international-dch-whql",          # 匹配文件名，支持模糊功能（*）
 "460.89-desktop-win10-64bit-international-dch-whql", # 网站下载绝对文件名，请勿填后缀
 "https://us.download.nvidia.cn/Windows/460.89/",     # 网站路径前缀，/ 号结尾
 "-s -clean -noreboot -noeula")
```
