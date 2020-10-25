#
#    Warning: In order to prevent overwriting after updating, please save as and then modify.
#
#    Author: Yi ( https://fengyi.tel )
#
#    From: Yi Solution Suite For MSWin Bundled Kit
#    buildstring: 2.0.0.2.bk_release.201025-1208
#
#
#    Description:
#
#    You are welcome to use multifunctional installation scripts to install common software locally,
#    If there is no Installation package, activate the online download function
#
#    The main function:
#       1. Local Installation package, support parameters and activate silent installation;
#       2. Automatically judge whether the file exists or not, then download it online;
#       3. Support decompression package processing, multiple modules.
#
#    Prerequisites
#      - PowerShell 5.1 or PowerShellCore 7.03 higher
#

[CmdletBinding()]
param(
    [parameter(Mandatory = $false, HelpMessage = "Forced operation.")]
    [Switch]$Force
)

# All software configurations
$app = @(
     ([Status]::Disable,
     [Action]::Install,
     [PP]::Wait,
     [FileType]::zip,
     "AIO Repack for Microsoft Visual C++ Redistributable Runtimes",
     "$env:SystemDrive\Bundled Kit\00\AIO",
     "VisualCppRedist_AIO_x86_x64",
     "VisualCppRedist_AIO_x86_x64_38",
     "https://github.com/abbodi1406/vcredist/releases/download/v0.38.0/",
     "/aiA /gm2"),
    ([Status]::Disable,
     [Action]::Install,
     [PP]::Wait,
     [FileType]::exe,
     "Gpg4win",
     "$env:SystemDrive\Bundled Kit\00\AIO",
     "gpg4win-3.1.13",
     "gpg4win-3.1.13",
     "https://files.gpg4win.org/",
     "/S"),
    ([Status]::Disable,
     [Action]::Install,
     [PP]::Wait,
     [FileType]::exe,
     "Python",
     "$env:SystemDrive\Bundled Kit\00\AIO",
     "python-3.8.5",
     "python-3.8.5",
     "https://www.python.org/ftp/python/3.8.5/",
     "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"),
    ([Status]::Disable,
     [Action]::Install,
     [PP]::Wait,
     [FileType]::exe,
      "Nvidia",
      "$env:SystemDrive\Bundled Kit\00\Drive",
      "451.67-desktop-win10-64bit-international-dch-whql",
      "451.67-desktop-win10-64bit-international-dch-whql",
      "https://cn.download.nvidia.com/Windows/451.67/",
      "-s -clean -noreboot -noeula"),
    ([Status]::Disable,
     [Action]::Install,
     [PP]::Wait,
     [FileType]::exe,
     "kugou music",
     "$env:SystemDrive\Bundled Kit\00\Music video",
     "kugou9144",
     "kugou9144",
     "http://downmini.kugou.com/web/",
     "/S"),
    ([Status]::Disable,
     [Action]::Install,
     [PP]::Wait,
     [FileType]::exe,
     "NetEase Cloud Music",
     "$env:SystemDrive\Bundled Kit\00\Music video",
     "cloudmusicsetup2.7.3.198319",
     "cloudmusicsetup2.7.3.198319",
     "https://d1.music.126.net/dmusic/",
     "/S"),
    ([Status]::Disable,
     [Action]::Install,
     [PP]::Fast,
     [FileType]::exe,
     "QQ Music",
     "$env:SystemDrive\Bundled Kit\00\Music video",
     "QQMusicSetup",
     "QQMusicSetup",
     "https://dldir1.qq.com/music/clntupate/",
     "/S"),
    ([Status]::Enable,
     [Action]::Install,
     [PP]::Wait,
     [FileType]::exe,
     "Tencent QQ 2020",
     "$env:SystemDrive\Bundled Kit\00\Chat Tools",
     "PCQQ2020",
     "PCQQ2020",
     "https://down.qq.com/qqweb/PCQQ/PCQQ_EXE/",
     "/S"),
    ([Status]::Enable,
     [Action]::Install,
     [PP]::Wait,
     [FileType]::exe,
     "WeChat",
     "$env:SystemDrive\Bundled Kit\00\Chat Tools",
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
    Wait      # Wait for the process installation to end
    Fast      # Quick installation does not wait for the process to end
}

Enum Action
{
    Install   # installation
    NoInst    # Download only, not install
    Unzip     # After the download is complete, only compress
}

Enum FileType
{
    exe
    zip
    bat
    ps1
}

function Get-Version {
    param($status,$act,$pp,$types,$appname,$folder,$filename,$packer,$url,$param)
    $url = $url + $packer + "." + $types
    $output = $folder + "\" + $filename+"." + $types
    $outputfoldoer = $folder + "\"

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
    if(!(Test-Path $folder -PathType Container)) {
        New-Item -Path $folder -ItemType Directory | Out-Null
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
            }
            else
            {
                Get-RunApp -filename $output -param $param -pp $pp -sel 1
            }
        }
        zip {
            # The current type of EXE, judge whether there is an EXE installation file locally, and install it if it exists
            # If it does not exist, proceed to the next step, download and install online.
            $tmpnewpathexe = $folder + "\" + $filename + ".exe"
            $tmpnewpathzip = $folder + "\" + $filename + ".zip"

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
                                Write-Host "   Unzip only...."
                                Expand-Archive -LiteralPath $output -DestinationPath $outputfoldoer -force

                                # Delete the ZIP file after decompression
                                if ((Test-Path $output)) { remove-item -path $output -force }
                                return
                            }
                        }
                        Install {
                            if ((Test-Path $output -PathType Leaf)) {
                                Write-Host "   Run after decompression..."
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
                else
                {
                    Write-Host "   Locally exist: $tmpnewpathzip"
                    Switch ($act)
                    {
                        Unzip {
                            if ((Test-Path $output -PathType Leaf)) {
                                Write-Host "   Unzip Only"
                                Expand-Archive -LiteralPath $output -DestinationPath $outputfoldoer -force
                                
                                # Delete the ZIP file after decompression
                                if ((Test-Path $output)) { remove-item -path $output -force }
                                return
                            }
                        }
                        Install {
                            if ((Test-Path $output -PathType Leaf)) {
                                echo "   Unzip after install."
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
            }
            else
            {
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
            }
            else
            {
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
            }
            else
            {
                Get-RunApp -filename $output -param $param -pp $pp -sel 3
            }
        }
    }
}

function Get-RunApp {
    param($filename,$param,$pp,$sel)

    if ((Test-Path $filename -PathType Leaf))
    {
        Switch ($pp)
        {
            Fast {
                Write-Host "   Quickly execute commands: $filename $param`n"
                if ($param -eq ""){
                    switch ($sel)
                    {
                        1 { Start-Process -FilePath $filename }
                        2 { Start-Process $filename }
                        3 { Start-Process powershell -argument "$filename" }
                    }
                }
                else
                {
                    switch ($sel)
                    {
                        1 { Start-Process -FilePath $filename -ArgumentList $param }
                        2 { Start-Process $filename }
                        3 { Start-Process powershell -argument "$filename $param" }
                    }
                }
            }
            Wait {
                Write-Host "   Execute the command (waiting to end): $filename $param`n"
                if ($param -eq ""){
                    switch ($sel)
                    {
                        1 { Start-Process -FilePath $filename -Wait }
                        2 { Start-Process $filename -Wait }
                        3 { Start-Process powershell -argument "$filename" -Wait }
                    }
                }
                else
                {
                    switch ($sel)
                    {
                        1 { Start-Process -FilePath $filename -ArgumentList $param -Wait }
                        2 { Start-Process $filename -Wait }
                        3 { Start-Process powershell -argument "$filename $param" -Wait }
                    }
                }
            }
        }
    }
    else
    {
        Write-Host "   No installation files were found, please check the integrity: $filename ."
    }
}

Write-Host "`n   FYSuite Advanced panel v2.0
   Author: Yi ( http://fengyi.tel )

   Install software ( List )
   ------------------------------------"
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
Write-Host "   ------------------------------------`n"

If ($Force) {
} else {
	Write-Host "   Press any key to start installation ...`n"
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Write-Host "   Installing software...
   ------------------------------------"
for ($i=0; $i -lt $app.Count; $i++) {
    Get-Version -status $app[$i][0] -act $app[$i][1] -pp $app[$i][2] -types $app[$i][3] -appname $app[$i][4] -folder $app[$i][5] -filename $app[$i][6] -packer $app[$i][7] -url $app[$i][8] -param $app[$i][9]
}
Write-Host "   ------------------------------------`n"

Write-Host "   Delete redundant shortcuts"
Set-Location "$env:userprofile\Desktop\"
Remove-Item -Force -ErrorAction SilentlyContinue ".\Kleopatra.lnk" | Out-Null

Write-Host "   Delete startup items"
Remove-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "Wechat" | Out-Null

Write-Host "   Delete scheduled task"
Disable-ScheduledTask -TaskName GoogleUpdateTaskMachineCore -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName GoogleUpdateTaskMachineUA -ErrorAction SilentlyContinue | Out-Null

Write-Host "   Rename"
Set-Location "$env:public\Desktop\"
#Rename-Item -Path ".\Google Chrome.lnk" -NewName "New Browser.lnk" -ErrorAction SilentlyContinue | Out-Null