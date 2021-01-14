#
#    警告：为防止更新后覆盖，请另存为后再修改。
#
#    Author: Yi ( https://fengyi.tel )
#
#    From: Yi Solution Suite
#    buildstring: 5.1.0.0.bk_release.210120-1208
#
#
#    描述:
#
#    欢迎您使用多功能安装脚本，本地安装常用软件，
#    不存在安装包，则激活在线下载功能
#
#    主要功能：
#      1. 本地安装包，支持参数并激活静默安装；
#      2. 自动判断文件是否存在，未存在，则在线下载；
#      3. 安装盘可指定盘符，未指定则按 [a-z] 顺序搜索，
#         未搜索到则默认系统盘；
#      4. 支持解压包处理，多模块。
#
#    先决条件：
#      - PowerShell 5.1 或更高
#
#    源代码：
#    https://github.com/ilikeyi/powershell.install.software
#

# 获取脚本参数（如果有）
[CmdletBinding()]
param(
    [parameter(Mandatory = $false, HelpMessage = "静默安装.")]
    [Switch]$Force
)

# 所有软件配置
$app = @(
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
    ([Status]::Disable,
     [Action]::Install,
     [PP]::Wait,
     [FileType]::zip,
     "VisualCppRedist AIO",
     "auto",
     "Yi\00\AIO",
     "VisualCppRedist_AIO_x86_x64",
     "VisualCppRedist_AIO_x86_x64_42",
     "https://github.com/abbodi1406/vcredist/releases/download/v0.42.0/",
     "/y"),
    ([Status]::Disable,
     [Action]::Install,
     [PP]::Wait,
     [FileType]::exe,
     "Gpg4win",
     "auto",
     "Yi\00\AIO",
     "gpg4win-3.1.13",
     "gpg4win-3.1.13",
     "https://files.gpg4win.org/",
     "/S"),
    ([Status]::Disable,
     [Action]::Install,
     [PP]::Wait,
     [FileType]::exe,
     "Python",
     "auto",
     "Yi\00\AIO",
     "python-3.9.1-amd64",
     "python-3.9.1-amd64",
     "https://www.python.org/ftp/python/3.9.1/",
     "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"),
    ([Status]::Disable,
     [Action]::Install,
     [PP]::Wait,
     [FileType]::exe,
     "酷狗音乐",
     "auto",
     "Yi\00\V",
     "kugou9144",
     "kugou9144",
     "http://downmini.kugou.com/web/",
     "/S"),
    ([Status]::Disable,
     [Action]::Install,
     [PP]::Wait,
     [FileType]::exe,
     "网易云音乐",
     "auto",
     "Yi\00\V",
     "cloudmusicsetup2.7.3.198319",
     "cloudmusicsetup2.7.3.198319",
     "https://d1.music.126.net/dmusic/",
     "/S"),
    ([Status]::Disable,
     [Action]::Install,
     [PP]::Fast,
     [FileType]::exe,
     "QQ 音乐",
     "auto",
     "Yi\00\V",
     "QQMusicSetup",
     "QQMusicSetup",
     "https://dldir1.qq.com/music/clntupate/",
     "/S"),
    ([Status]::Enable,
     [Action]::Install,
     [PP]::Wait,
     [FileType]::exe,
     "腾讯 QQ 2020",
     "auto",
     "Yi\00\C",
     "PCQQ2020",
     "PCQQ2020",
     "https://down.qq.com/qqweb/PCQQ/PCQQ_EXE/",
     "/S"),
    ([Status]::Enable,
     [Action]::Install,
     [PP]::Wait,
     [FileType]::exe,
     "微信",
     "auto",
     "Yi\00\C",
     "WeChatSetup",
     "WeChatSetup",
     "https://dldir1.qq.com/weixin/Windows/",
     "/S")
)

Enum Status
{
    Enable
    Disable
}

Enum PP
{
    Wait      # 等待进程安装结束
    Fast      # 快速安装不等待进程结束
}

Enum Action
{
    Install   # 安装
    NoInst    # 仅下载，不安装
    Unzip     # 下载完成后，仅压缩
}

Enum FileType
{
    exe
    zip
    bat
    ps1
}

function Get-Version {
    param(
        $status,
        $act,
        $pp,
        $types,
        $appname,
        $todisk,
        $structure,
        $filename,
        $packer,
        $url,
        $param
    )
    $url = $url + $packer + "." + $types

    switch -regex ($todisk) {
        "auto" { break }
        "^[a-z]$" { break }
        default {
            $todisk = "auto"
        }
    }

    Switch ($todisk)
    {
        auto {
            $drives = Get-PSDrive | Select-Object -ExpandProperty 'Name' | Select-String -Pattern '^[a-z]$'
            foreach ($drive in $drives){
                $newpath = "$($drive):\$($structure)\$($filename).$($types)"

                if((Test-Path $newpath)) {
                    $output = "$($drive):\$($structure)\$($filename).$($types)"
                    $outputfoldoer = "$($drive):\$($structure)\"
                    break
                } else {
                    $output = "$($env:SystemDrive)\$($structure)\$($filename).$($types)"
                    $outputfoldoer = "$($env:SystemDrive)\$($structure)\"
                }
            }
        }
        default {
            $output = $todisk + ":\" + $structure + "\" + $filename+"." + $types
            $outputfoldoer = $todisk + ":\" + $structure + "\"
        }
    }

    # 判断是否安装，不安装则跳过，安装则进行下一步。
    Switch ($status)
    {
        Enable {
            Write-Host "   '正在安装' - $($appname)" -ForegroundColor Green
        }
        Disable {
            Write-Host "   '跳过安装' - $($appname)" -ForegroundColor Red
            return
        }
    }
   
    # 检查是否存在目录，不存在则重新创建
    if(!(Test-Path $outputfoldoer -PathType Container)) {
        New-Item -Path $outputfoldoer -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        if(!(Test-Path $outputfoldoer -PathType Container)) {
            Write-Host "    - 创建目录失败：$($outputfoldoer)`n" -ForegroundColor Red
            return
        }
    }
    
    # 判断文件类型
    Switch ($types)
    {
        exe {
            # 当前类型 EXE，判断本地是否存在 EXE 安装文件，存在则进行安装，不则在线下载并安装。
            if (!(Test-Path $output -PathType Leaf))
            {
                Write-Host "`    - 下载软件：$appname
    - 下载地址：$url
    - 保存文件到：$output"
                (New-Object System.Net.WebClient).DownloadFile($url, $output)
                Get-RunApp -filename $output -param $param -pp $pp -sel 1
            } else {
                Get-RunApp -filename $output -param $param -pp $pp -sel 1
            }
        }
        zip {
            # 当前类型 EXE，判断本地是否存在 EXE 安装文件，存在则进行安装
            # 不存在则进行下一步，在线下载并安装。
            $tmpnewpathexe = $todisk + "\" + $structure + "\" + $filename + ".exe"
            $tmpnewpathzip = $todisk + "\" + $structure + "\" + $filename + ".zip"

            if (!(Test-Path $tmpnewpathexe -PathType Leaf))
            {
                if (!(Test-Path $tmpnewpathzip -PathType Leaf))
                {
                    Write-Host "    - 此文件不存在：$tmpnewpathzip
    - 下载软件：$appname
    - 请求 URL 地址：$url
    - 保存文件到：$output"
                    (New-Object System.Net.WebClient).DownloadFile($url, $output)
                    Switch ($act)
                    {
                        Unzip {
                            if ((Test-Path $output -PathType Leaf)) {
                                Write-Host "    - 仅解压..."
                                Expand-Archive -LiteralPath $output -DestinationPath $outputfoldoer -force

                                # 解压后删除 ZIP 文件
                                if ((Test-Path $output)) { remove-item -path $output -force }
                                return
                            }
                        }
                        Install {
                            if ((Test-Path $output -PathType Leaf)) {
                                Write-Host "    - 解压后运行..."
                                Expand-Archive -LiteralPath $output -DestinationPath $outputfoldoer -force

                                # 解压后删除 ZIP 文件
                                if ((Test-Path $output)) { remove-item -path $output -force }
                                
                                # 执行下一步，安装应用
                                Get-RunApp -filename $tmpnewpathexe -param $param -pp $pp -sel 1
                                return
                            }
                        }
                    }
                } else {
                    Write-Host "    - 本地存在：$tmpnewpathzip"
                    Switch ($act)
                    {
                        Unzip {
                            if ((Test-Path $output -PathType Leaf)) {
                                Write-Host "    - 仅解压"
                                Expand-Archive -LiteralPath $output -DestinationPath $outputfoldoer -force

                                # 解压后删除 ZIP 文件
                                if ((Test-Path $output)) { remove-item -path $output -force }
                                return
                            }
                        }
                        Install {
                            if ((Test-Path $output -PathType Leaf)) {
                                Write-Host "    - 下载后解压"
                                Expand-Archive -LiteralPath $output -DestinationPath $outputfoldoer -force
    
                                # 解压后删除 ZIP 文件
                                if ((Test-Path $output)) { remove-item -path $output -force }
                                
                                # 执行下一步，安装应用
                                Get-RunApp -filename $tmpnewpathexe -param $param -pp $pp -sel 1
                                return
                            }
                        }
                    }
                }
            } else {
                Get-RunApp -filename $tmpnewpathexe -param $param -pp $pp -sel 1
            }
        }
        bat {
            # 当前类型 bat，判断本地是否存在 bat 文件，存在则运行，不则在线下载并运行。
            if (!(Test-Path $output -PathType Leaf))
            {
                Write-Host "`n    - 下载软件：$appname
    - 请求 URL 地址：$url
    - 保存文件到：$output"
                (New-Object System.Net.WebClient).DownloadFile($url, $output)
                Get-RunApp -filename $output -param $param -pp $pp -sel 2
            } else {
                Get-RunApp -filename $output -param $param -pp $pp -sel 2
            }
        }
        ps1 {
            # 当前类型 ps1，判断本地是否存在 ps1 文件，存在则运行，不则在线下载并运行。
            if (!(Test-Path $output -PathType Leaf))
            {
                Write-Host "`n    - 下载软件：$appname
    - 下载地址：$url
    - 保存文件到：$output"
                (New-Object System.Net.WebClient).DownloadFile($url, $output)
                Get-RunApp -filename $output -param $param -pp $pp -sel 3
            } else {
                Get-RunApp -filename $output -param $param -pp $pp -sel 3
            }
        }
    }
}

function Get-RunApp {
    param(
        $filename,
        $param,
        $pp,
        $sel
    )

    if ((Test-Path $filename -PathType Leaf))
    {
        Switch ($pp)
        {
            Fast {
                Write-Host "    - 快速运行：$filename
    - 参数：$param"
                if ($param -eq ""){
                    switch ($sel)
                    {
                        1 { Start-Process -FilePath $filename }
                        2 { Start-Process $filename }
                        3 { Start-Process powershell -argument "$filename" }
                    }
                } else {
                    switch ($sel)
                    {
                        1 { Start-Process -FilePath $filename -ArgumentList $param }
                        2 { Start-Process $filename }
                        3 { Start-Process powershell -argument "$filename $param" }
                    }
                }
            }
            Wait {
                Write-Host "    - 等待运行：$filename
    - 参数：$param"
                if ($param -eq ""){
                    switch ($sel)
                    {
                        1 { Start-Process -FilePath $filename -Wait }
                        2 { Start-Process $filename -Wait }
                        3 { Start-Process powershell -argument "$filename" -Wait }
                    }
                } else {
                    switch ($sel)
                    {
                        1 { Start-Process -FilePath $filename -ArgumentList $param -Wait }
                        2 { Start-Process $filename -Wait }
                        3 { Start-Process powershell -argument "$filename $param" -Wait }
                    }
                }
            }
        }
        Write-Host ""
    } else {
        Write-Host "    - 未发现安装文件，请检查完整性：$filename`n" -ForegroundColor Red
    }
}

cls
Write-Host "`n   Author: Yi ( http://fengyi.tel )

   From: Yi Solution Suite
   buildstring: 5.1.0.0.bk_release.210120-1208

   安装软件列表 ( 共 $($app.Count) 款 )
   ---------------------------------------------------"
for ($i=0; $i -lt $app.Count; $i++) {
    Switch ($app[$i][0])
    {
        Enable {
            Write-Host "   '等待安装' - $($app[$i][4])" -ForegroundColor Green
        }
        Disable {
            Write-Host "   '跳过安装' - $($app[$i][4])" -ForegroundColor Red
        }
    }
}
Write-Host "   ---------------------------------------------------"

function Wait-Exit {
    param(
        [int]$wait
    )
    Write-Host "`n   提示：$wait 秒后自动退出安装脚本..." -ForegroundColor Red
    Start-Sleep -s $wait
    exit
}

function Install-start {
    Write-Host "`n   正在安装软件..."
    Write-Host "   ---------------------------------------------------"
    for ($i=0; $i -lt $app.Count; $i++) {
        Get-Version -status $app[$i][0] -act $app[$i][1] -pp $app[$i][2] -types $app[$i][3] -appname $app[$i][4] -todisk $app[$i][5] -structure $app[$i][6] -filename $app[$i][7] -packer $app[$i][8] -url $app[$i][9] -param $app[$i][10]
    }
}

function Process-other {
    Write-Host "`n    处理其它：" -ForegroundColor Green

    Write-Host "    - 删除开机自启动项"
    Remove-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "Wechat" | Out-Null

    Write-Host "    - 删除计划任务"
    Disable-ScheduledTask -TaskName GoogleUpdateTaskMachineCore -ErrorAction SilentlyContinue | Out-Null
    Disable-ScheduledTask -TaskName GoogleUpdateTaskMachineUA -ErrorAction SilentlyContinue | Out-Null

    Write-Host "    - 删除多余快捷方式"
    Set-Location "$env:public\Desktop"
    Remove-Item -Force -ErrorAction SilentlyContinue ".\Kleopatra.lnk" | Out-Null

    Write-Host "    - 更名"
    #Rename-Item -Path ".\Google Chrome.lnk" -NewName "谷歌浏览器.lnk" -ErrorAction SilentlyContinue | Out-Null
}

If ($Force) {
    Install-start
    Process-other
} else {
    Write-Host "   是否安装以上软件？" -ForegroundColor Green

    $caption="安装软件前请确认。"
    $message="继续安装（Y）`n取消安装（N）"
    $choices = @("&Yes","&No")
    $choicedesc = New-Object System.Collections.ObjectModel.Collection[System.Management.Automation.Host.ChoiceDescription] 
    $choices | foreach  { $choicedesc.Add((New-Object "System.Management.Automation.Host.ChoiceDescription" -ArgumentList $_))} 
    $prompt = $Host.ui.PromptForChoice($caption, $message, $choicedesc, 1)
    Switch ($prompt)
    {
        0 {
            Install-start
            Process-other
            Wait-Exit -wait 6
        }
        1 {
            Write-Host "`n   取消安装。"
            Wait-Exit -wait 2
        }
    }
}
