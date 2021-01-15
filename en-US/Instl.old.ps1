#
#    Warning: In order to prevent overwriting after updating, please save as and then modify.
#
#    Author: Yi ( https://fengyi.tel )
#
#    Description:
#
#    You are welcome to use multifunctional installation scripts to install common software locally,
#    If there is no Installation package, activate the online download function
#
#    The main function:
#      1. Local Installation package, support parameters and activate silent installation;
#      2. Automatically judge whether the file exists or not, then download it online;
#      3. The installation disk can be specified with a drive letter. If it is not specified,
#         it will be searched in the order of [a-z]. If it is not found, the system drive will be defaulted;
#      4. Support decompression package processing, multiple modules.
#
#    Prerequisites
#      - PowerShell 1.0 or higher
#
#    Source code:
#    https://github.com/ilikeyi/powershell.install.software
#

# Get the script parameters if there are any
[CmdletBinding()]
param(
    [parameter(Mandatory = $false, HelpMessage = "silent installation.")]
    [Switch]$Force
)

# All software configurations
$app = @(
    ("Disable",
     "Install",
     "Wait",
     "exe",
     "Nvidia GEFORCE GAME READY DRIVER",
     "auto",
     "Yi\00\Drive",
     "461.09-desktop-win10-64bit-international-dch-whql",
     "461.09-desktop-win10-64bit-international-dch-whql",
     "https://us.download.nvidia.com/Windows/461.09/",
     "-s -clean -noreboot -noeula"),
    ("Disable",
     "Install",
     "Wait",
     "zip",
     "VisualCppRedist AIO",
     "auto",
     "Yi\00\AIO",
     "VisualCppRedist_AIO_x86_x64",
     "VisualCppRedist_AIO_x86_x64_42",
     "https://github.com/abbodi1406/vcredist/releases/download/v0.42.0/",
     "/y"),
    ("Disable",
     "Install",
     "Wait",
     "exe",
     "Gpg4win",
     "auto",
     "Yi\00\AIO",
     "gpg4win-3.1.13",
     "gpg4win-3.1.13",
     "https://files.gpg4win.org/",
     "/S"),
    ("Disable",
     "Install",
     "Wait",
     "exe",
     "Python",
     "auto",
     "Yi\00\AIO",
     "python-3.9.1-amd64",
     "python-3.9.1-amd64",
     "https://www.python.org/ftp/python/3.9.1/",
     "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"),
    ("Disable",
     "Install",
     "Wait",
     "exe",
     "kugou music",
     "auto",
     "Yi\00\V",
     "kugou9144",
     "kugou9144",
     "http://downmini.kugou.com/web/",
     "/S"),
    ("Disable",
     "Install",
     "Wait",
     "exe",
     "NetEase Cloud Music",
     "auto",
     "Yi\00\V",
     "cloudmusicsetup2.7.3.198319",
     "cloudmusicsetup2.7.3.198319",
     "https://d1.music.126.net/dmusic/",
     "/S"),
    ("Disable",
     "Install",
     "Fast",
     "exe",
     "QQ Music",
     "auto",
     "Yi\00\V",
     "QQMusicSetup",
     "QQMusicSetup",
     "https://dldir1.qq.com/music/clntupate/",
     "/S"),
    ("Enable",
     "Install",
     "Wait",
     "exe",
     "Tencent QQ 2020",
     "auto",
     "Yi\00\C",
     "PCQQ2020",
     "PCQQ2020",
     "https://down.qq.com/qqweb/PCQQ/PCQQ_EXE/",
     "/S"),
    ("Enable",
     "Install",
     "Wait",
     "exe",
     "WeChat",
     "auto",
     "Yi\00\C",
     "WeChatSetup",
     "WeChatSetup",
     "https://dldir1.qq.com/weixin/Windows/",
     "/S")
)

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

    # Judge whether to install, skip if not, and proceed to the next step.
    Switch ($status)
    {
        Enable {
            Write-Host "   'Installing'   - $($appname)" -ForegroundColor Green
        }
        Disable {
            Write-Host "   'Skip install' - $($appname)" -ForegroundColor Red
            return
        }
    }

    # Check if the directory exists, recreate it if it does not exist
    if(!(Test-Path $outputfoldoer -PathType Container)) {
        New-Item -Path $outputfoldoer -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        if(!(Test-Path $outputfoldoer -PathType Container)) {
            Write-Host "    - Failed to create directory: $($outputfoldoer)`n" -ForegroundColor Red
            return
        }
    }
    
    # Determine file type
    Switch ($types)
    {
        exe {
            # For the current type of EXE, it is judged whether there is an EXE installation file locally. If it exists, it will be installed. Otherwise, it will be downloaded and installed online.
            if (!(Test-Path $output -PathType Leaf))
            {
                Write-Host "`    - Download software: $appname
    - Download link: $url
    - Save the file to: $output"
                (New-Object System.Net.WebClient).DownloadFile($url, $output)
                Get-RunApp -filename $output -param $param -pp $pp -sel 1
            } else {
                Get-RunApp -filename $output -param $param -pp $pp -sel 1
            }
        }
        zip {
            # The current type of EXE, judge whether there is an EXE installation file locally, and install it if it exists
            # If it does not exist, proceed to the next step, download and install online.
            $tmpnewpathexe = $todisk + "\" + $structure + "\" + $filename + ".exe"
            $tmpnewpathzip = $todisk + "\" + $structure + "\" + $filename + ".zip"

            if (!(Test-Path $tmpnewpathexe -PathType Leaf))
            {
                if (!(Test-Path $tmpnewpathzip -PathType Leaf))
                {
                    Write-Host "    - This file does not exist: $tmpnewpathzip
    - Download software: $appname
    - Request URL address: $url
    - Save the file to: $output"
                    (New-Object System.Net.WebClient).DownloadFile($url, $output)
                    Switch ($act)
                    {
                        Unzip {
                            if ((Test-Path $output -PathType Leaf)) {
                                Write-Host "    - Unzip only"
                                Expand-Archive -LiteralPath $output -DestinationPath $outputfoldoer -force

                                # Delete the ZIP file after decompression
                                if ((Test-Path $output)) { remove-item -path $output -force }
                                return
                            }
                        }
                        Install {
                            if ((Test-Path $output -PathType Leaf)) {
                                Write-Host "    - Unzip after download"
                                Expand-Archive -LiteralPath $output -DestinationPath $outputfoldoer -force

                                # Delete the ZIP file after decompression
                                if ((Test-Path $output)) { remove-item -path $output -force }
                                
                                # Perform the next step to install the application
                                Get-RunApp -filename $tmpnewpathexe -param $param -pp $pp -sel 1
                                return
                            }
                        }
                    }
                } else {
                    Write-Host "    - Locally exist: $tmpnewpathzip"
                    Switch ($act)
                    {
                        Unzip {
                            if ((Test-Path $output -PathType Leaf)) {
                                Write-Host "    - Unzip Only"
                                Expand-Archive -LiteralPath $output -DestinationPath $outputfoldoer -force

                                # Delete the ZIP file after decompression
                                if ((Test-Path $output)) { remove-item -path $output -force }
                                return
                            }
                        }
                        Install {
                            if ((Test-Path $output -PathType Leaf)) {
                                Write-Host "   Unzip after install"
                                Expand-Archive -LiteralPath $output -DestinationPath $outputfoldoer -force
    
                                # Delete the ZIP file after decompression
                                if ((Test-Path $output)) { remove-item -path $output -force }
                                
                                # Perform the next step to install the application
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
            # The current type is bat, it is judged whether there is a bat file locally, if it exists, it will run, otherwise it will be downloaded and run online.
            if (!(Test-Path $output -PathType Leaf))
            {
                Write-Host "`n    - Download software: $appname
    - Request URL address: $url
    - Save the file to: $output"
                (New-Object System.Net.WebClient).DownloadFile($url, $output)
                Get-RunApp -filename $output -param $param -pp $pp -sel 2
            } else {
                Get-RunApp -filename $output -param $param -pp $pp -sel 2
            }
        }
        ps1 {
            # The current type is ps1, and it is judged whether there is a ps1 file locally, if it exists, it will run, otherwise it will be downloaded and run online.
            if (!(Test-Path $output -PathType Leaf))
            {
                Write-Host "`n    - Download software: $appname
    - Download link: $url
    - Save the file to: $output"
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
                Write-Host "    - Fast running: $filename
    - Parameter: $param"
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
                Write-Host "    - Waiting to run: $filename
    - Parameter: $param"
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
        Write-Host "    - No installation files were found, please check the integrity: $filename" -ForegroundColor Red
    }
}

cls
Write-Host "`n   Author: Yi ( http://fengyi.tel )

   From: Yi's Solution
   buildstring: 5.1.0.1.bk_release.210120-1208

   Installed software list ( total $($app.Count) items )
   ---------------------------------------------------"
for ($i=0; $i -lt $app.Count; $i++) {
    Switch ($app[$i][0])
    {
        Enable {
            Write-Host "   'Wait install' - $($app[$i][4])" -ForegroundColor Green
        }
        Disable {
            Write-Host "   'Skip install' - $($app[$i][4])" -ForegroundColor Red
        }
    }
}
Write-Host "   ---------------------------------------------------"

function Wait-Exit {
    param(
        [int]$wait
    )
    Write-Host "`n   Tip: The installation script will automatically exit after $wait seconds..." -ForegroundColor Red
    Start-Sleep -s $wait
    exit
}

function Install-start {
    Write-Host "`n   Installing software..."
    Write-Host "   ---------------------------------------------------"
    for ($i=0; $i -lt $app.Count; $i++) {
        Get-Version -status $app[$i][0] -act $app[$i][1] -pp $app[$i][2] -types $app[$i][3] -appname $app[$i][4] -todisk $app[$i][5] -structure $app[$i][6] -filename $app[$i][7] -packer $app[$i][8] -url $app[$i][9] -param $app[$i][10]
    }
}

function Process-other {
    Write-Host "`n    Processing other:" -ForegroundColor Green

    Write-Host "    - Delete startup items"
    Remove-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "Wechat" | Out-Null

    Write-Host "    - Delete scheduled task"
    Disable-ScheduledTask -TaskName GoogleUpdateTaskMachineCore -ErrorAction SilentlyContinue | Out-Null
    Disable-ScheduledTask -TaskName GoogleUpdateTaskMachineUA -ErrorAction SilentlyContinue | Out-Null

    Write-Host "    - Delete redundant shortcuts"
    Set-Location "$env:public\Desktop"
    Remove-Item -Force -ErrorAction SilentlyContinue ".\Kleopatra.lnk" | Out-Null

    Write-Host "    - Rename"
    #Rename-Item -Path ".\Google Chrome.lnk" -NewName "New Browser.lnk" -ErrorAction SilentlyContinue | Out-Null
}

If ($Force) {
    Install-start
    Process-other
} else {
    Write-Host "   Do you want to install the above software?" -ForegroundColor Green

    $caption="Please confirm before installing the software."
    $message="Continue installation (Y)`nCancel the installation (N)"
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
            Write-Host "`n   Cancel the installation."
            Wait-Exit -wait 2
        }
    }
}
