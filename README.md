![Installation interface](https://raw.githubusercontent.com/ilikeyi/powershell.install.software/main/Installation%20interface.png)

You are welcome to install the software using PowerShell
-
欢迎您使用 PowerShell 安装软件
-

    The main function:
      1. There is no installation package locally, activate the download function;
      2. The drive letter can be specified, and the current system drive will be excluded after setting automatic.
         When no available disk is found, the default setting is the current system disk;
      3. Search file name supports fuzzy search, wildcard *;
      4. The file name is searched first by language structure, for example:
         - Operating system preferred language: en-US
         - File name: ChromeChrome
         The preferred search condition is GoogleChrome*en-US*, and if the search is not found, search again by default file name.
      5. Support pre-processing, go to function OpenApp {} to change the module;
      6. Support decompression package processing, etc.

    Prerequisites
      - Instl.old.ps1 - ( PowerShell 2.0 或更高 )
      - Instl.ps1     - ( PowerShell 5.0 或更高 )

    主要功能：
      1. 本地不存在安装包，激活下载功能；
      2. 可指定盘符，设置自动后将排除当前系统盘，
         搜索不到可用盘时，默认设置为当前系统盘；
      3. 搜索文件名支持模糊查找，通配符 *；
      4. 搜索文件名优先按语言结构来搜索，例如：
         - 操作系统首选语言：en-US
         - 文件名：ChromeChrome
         优先搜索条件为 GoogleChrome*en-US*，未搜索到按默认文件名重新搜索。
      5. 支持运行前处理，前往 function OpenApp {} 处更改该模块；
      6. 支持解压包处理等。

    先决条件：
      - Instl.old.ps1 - ( PowerShell 2.0 或更高 )
      - Instl.ps1     - ( PowerShell 5.0 或更高 )

# Package configuration tutorial
```
 Package Configuration                                     Description
("Windows Defender Control",                               Package name
 [Status]::Enable,                                         Status: Enable - enabled; Disable - disabled
 [Action]::Install,                                        Action: Install - install; NoInst - does not install after download; Unzip - only extract after download; To - install to directory
 [Mode]::Wait,                                             Operation mode: Wait - wait for completion; Fast - run directly
 "auto",                                                   After setting automatic, the current system disk will be excluded. If no available disk is found, the default setting is the current system disk; specify the drive letter [A:]-[Z:]; specify the path: \\192.168.1.1
 "Installation package\Tool",                              Directory Structure
 "https://www.sordum.org/files/download/defender-control", Website address
 "DefenderControl",                                        File name downloaded from website
 "zip",                                                    File type downloaded from the website: exe, zip or custom file type; result: https://files.gpg4win.org/gpg4win-latest.exe
 "DefenderControl*",                                       File name fuzzy search (*)
 "/D",                                                     Operating parameters
 "1:DefenderControl:ini")                                  Before running: 1 - select scheme 1; DefenderControl = configuration file name; ini = type, go to function OpenApp {} to change the module

 .Make configuration file

 - default
   DefenderControl.ini Change to DefenderControl.Default.ini

 - English
   DefenderControl.ini Change to DefenderControl.en-US.ini
   Open DefenderControl.en-US.ini and change Language=Auto to Language=English

 - Chinese
   DefenderControl.ini Change to DefenderControl.zh-CN.ini
   Open DefenderControl.zh-CN.ini and change Language=Auto to Language=Chinese_简体中文

   Delete DefenderControl.ini after making it.
```

# 软件包配置教程
```
 软件包                                                    描述
("Windows Defender Control",                               软件包名称
 [Status]::Enable,                                         状态：Enable - 启用；Disable - 禁用
 [Action]::Install,                                        动作：Install - 安装；NoInst - 下载后不安装；Unzip - 下载后仅解压；To - 安装到目录
 [Mode]::Wait,                                             运行方式：Wait - 等待完成；Fast - 直接运行
 "auto",                                                   设置自动后将排除当前系统盘，搜索不到可用盘时，默认设置为当前系统盘；指定盘符 [A:]-[Z:]；指定路径：\\192.168.1.1
 "安装包\工具",                                            目录结构
 "https://www.sordum.org/files/download/defender-control", 网站地址
 "DefenderControl",                                        从网站下载的文件名
 "zip",                                                    从网站下载的文件类型：exe, zip 或自定义文件类型；结果：https://files.gpg4win.org/gpg4win-latest.exe
 "DefenderControl*",                                       文件名模糊查找（*）
 "/D",                                                     运行参数
 "1:DefenderControl:ini")                                  运行前：1 - 选择方案1；DefenderControl = 配置文件名；ini = 类型，前往 function OpenApp {} 处更改该模块

 .制作配置文件

 - 默认
   DefenderControl.ini 复制后更改为 DefenderControl.Default.ini

 - 英文
   DefenderControl.ini 复制后更改为 DefenderControl.en-US.ini
   打开 DefenderControl.en-US.ini，将 Language=Auto 修改为 Language=English

 - 中文
   DefenderControl.ini 复制后更改为 DefenderControl.zh-CN.ini
   打开 DefenderControl.zh-CN.ini，将 Language=Auto 修改为 Language=Chinese_简体中文

   制作完成后删除 DefenderControl.ini。
```
