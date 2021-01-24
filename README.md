You are welcome to install the software using PowerShell
-
欢迎您使用 PowerShell 安装软件
-

    The main function:
      1. There is no installation package locally, activate the download function;
      2. The drive letter can be specified, and the current system drive will be excluded after setting automatic.
       When no available disk is found, the default setting is the current system disk;
      3. Search file name supports fuzzy search, wildcard *;
      4. Support decompression package processing, etc.

    Prerequisites
      - Instl.old.ps1 - ( PowerShell 2.0 或更高 )
      - Instl.ps1     - ( PowerShell 5.0 或更高 )

    主要功能：
      1. 本地不存在安装包，激活下载功能；
      2. 可指定盘符，设置自动后将排除当前系统盘，
         搜索不到可用盘时，默认设置为当前系统盘；
      3. 搜索文件名支持模糊查找，通配符 *；
      4. 支持解压包处理等。

    先决条件：
      - Instl.old.ps1 - ( PowerShell 2.0 或更高 )
      - Instl.ps1     - ( PowerShell 5.0 或更高 )

# Package configuration tutorial
```
Variable    Package Configuration        Description
$appname   ("Gpg4win",                   Package name
$status     [Status]::Disable,           Status: Enable - enabled; Disable - disabled
$act        [Action]::Install,           Action: Install - install; NoInst - does not install after download; Unzip - only extract after download; To - install to directory
$mode       [Mode]::Wait,                Operation mode: Wait - wait for completion; Fast - run directly
$todisk     "auto",                      After setting automatic, the current system disk will be excluded. If no available disk is found, the default setting is the current system disk; specify the drive letter [A:]-[Z:]; specify the path: \\192.168.1.1
$structure  "Installation package\AIO",  Directory Structure
$url        "https://files.gpg4win.org", Website address
$packer     "gpg4win-3.1.15",            File name downloaded from website
$types      "exe",                       File type downloaded from the website: exe, zip or custom file type; result: https://files.gpg4win.org/gpg4win-3.1.15.exe
$filename   "gpg4win*",                  File name fuzzy search (*)
$param      "/S"),                       Operating parameters
```

# 软件包配置教程
```
变量名       软件包配置                  描述
$appname   ("Gpg4win",                   软件包名称
$status     [Status]::Disable,           状态：Enable - 启用；Disable - 禁用
$act        [Action]::Install,           动作：Install - 安装；NoInst 下载后不安装；Unzip - 下载后仅解压；To - 安装到目录
$mode       [Mode]::Wait,                运行方式：Wait - 等待完成；Fast - 直接运行
$todisk     "auto",                      设置自动后将排除当前系统盘，搜索不到可用盘时，默认设置为当前系统盘；指定盘符 [A:]-[Z:]；指定路径：\\192.168.1.1
$structure  "安装包\AIO",                目录结构
$url        "https://files.gpg4win.org", 网站地址
$packer     "gpg4win-3.1.15",            从网站下载的文件名
$types      "exe",                       从网站下载的文件类型：exe, zip 或自定义文件类型；结果：https://files.gpg4win.org/gpg4win-3.1.15.exe
$filename   "gpg4win*",                  文件名模糊查找（*）
$param      "/S"),                       运行参数
```