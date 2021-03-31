![Installation interface](https://raw.githubusercontent.com/ilikeyi/powershell.install.software/main/Mainpage.png)

You are welcome to install the software using PowerShell
-
欢迎您使用 PowerShell 安装软件
-

```
  . THE MAIN FUNCTION
    1. There is no installation package locally, activate the download function;
    2. The drive letter can be specified, and the current system drive will be excluded after setting automatic.
       When no available disk is found, the default setting is the current system disk;
    3. Search file name supports fuzzy search, wildcard *;
    4. Queue, add to the queue after running the installer, and wait for the end;
    5. Search sequentially according to the preset structure:
       * Original download address: https://fengyi.tel/Instl.Packer.Latest.exe
         + Fuzzy file name: Instl.Packer*
           - Condition 1: System language: en-US, search condition: Instl.Packer*en-US*
           - Condition 2: Search for fuzzy file name: Instl.Packer*
           - Condition 3: Search the website to download the original file name: Instl.Packer.Latest
    6. Dynamic function: add pre-run and post-run processing, go to function OpenApp {} to change the module;
    7. Support decompression package processing, etc.
```

```
  . 主要功能
    1. 本地不存在安装包，激活下载功能；
    2. 可指定盘符，设置自动后将排除当前系统盘，
       搜索不到可用盘时，默认设置为当前系统盘；
    3. 搜索文件名支持模糊查找，通配符 *；
    4. 队列，运行安装程序后添加到队列，等待结束；
    5. 依次按预先设置的结构搜索：
       * 原始下载地址：https://fengyi.tel/Instl.Packer.Latest.exe
         + 模糊文件名：Instl.Packer*
           - 条件 1：系统语言：en-US，搜索条件：Instl.Packer*en-US*
           - 条件 2：搜索模糊文件名：Instl.Packer*
           - 条件 3：搜索网站下载原始文件名：Instl.Packer.Latest
    6. 动态功能：已添加运行前，运行后处理，前往 function OpenApp {} 处更改该模块；
    7. 支持解压包处理等。
```


# Package configuration tutorial
```
 Package Configuration                                     Description
("Windows Defender Control",                               Package name
 [Status]::Enable,                                         Status: Enable - enabled; Disable - disabled
 [Action]::Install,                                        Action: Install - install; NoInst - does not install after download; Unzip - only extract after download; To - install to directory
 [Mode]::Wait,                                             Operation mode: Wait - wait for completion; Fast - run directly
 "auto",                                                   After setting automatic, the current system disk will be excluded. If no available disk is found, the default setting is the current system disk; specify the drive letter [A:]-[Z:]; specify the path: \\192.168.1.1
 "Installation package\Tool",                              Directory Structure
 "https://www.sordum.org/files/download/defender-control/DefenderControl.zip", Default, including x86 download address
 "",                                                       x64 download link
 "",                                                       Arm64 download link
 "DefenderControl*",                                       File name fuzzy search (*)
 "/D",                                                     Operating parameters
 "1:DefenderControl:ini")                                  Dynamic module: choose option 1; DefenderControl = configuration file name; ini = type, go to function OpenApp {} to change the module

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
 "https://www.sordum.org/files/download/defender-control/DefenderControl.zip", 默认，含 x86 下载地址
 "",                                                       x64 下载地址
 "",                                                       Arm64 下载地址
 "DefenderControl*",                                       文件名模糊查找 (*)
 "/D",                                                     运行参数
 "1:DefenderControl:ini")                                  动态模块：选择方案 1；DefenderControl = 配置文件名；ini = 类型，前往 function OpenApp {} 处更改该模块

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
