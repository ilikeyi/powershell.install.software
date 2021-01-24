#
#  Warning: In order to prevent overwriting after updating, please save as and then modify.
#
#  You are welcome to install the software using PowerShell
#
#  The main function:
#    1. There is no installation package locally, activate the download function;
#    2. The drive letter can be specified, and the current system drive will be excluded after setting automatic.
#       When no available disk is found, the default setting is the current system disk;
#    3. Search file name supports fuzzy search, wildcard *;
#    4. Support decompression package processing, etc.
#
#  Prerequisites:
#Requires -version 2.0
#
#  Source code:
#  - https://github.com/ilikeyi/powershell.install.software
#  - https://gitee.com/ilikeyi/powershell.install.software
#

# Get script parameters ( if any )
[CmdletBinding()]
param(
	[parameter(Mandatory = $false, HelpMessage = "Silent")]
	[Switch]$Force
)

<# Package configuration tutorial

Variable    Package Configuration        Description
$appname   ("Gpg4win",                   Package name
$status     "Disable",                   Status: Enable - enabled; Disable - disabled
$act        "Install",                   Action: Install - install; NoInst - does not install after download; Unzip - only extract after download; To - install to directory
$mode       "wait",                      Operation mode: Wait - wait for completion; Fast - run directly
$todisk     "auto",                      After setting automatic, the current system disk will be excluded. If no available disk is found, the default setting is the current system disk; specify the drive letter [A:]-[Z:]; specify the path: \\192.168.1.1
$structure  "Installation package\AIO",  Directory Structure
$url        "https://files.gpg4win.org", Website address
$packer     "gpg4win-latest",            File name downloaded from website
$types      "exe",                       File type downloaded from the website: exe, zip or custom file type; result: https://files.gpg4win.org/gpg4win-latest.exe
$filename   "gpg4win*",                  File name fuzzy search (*)
$param      "/S"),                       Operating parameters

#>

# All software configurations
$app = @(
	("Yi's Personalized theme pack",
	 "Disable",
	 "Install",
	 "fast",
	 "auto",
	 "Installation package\Theme pack",
	 "https://fengyi.tel",
	 "Yi",
	 "deskthemepack",
	 "Yi*",
	 ""),
	("Nvidia GEFORCE GAME READY DRIVER",
	 "Disable",
	 "Install",
	 "wait",
	 "auto",
	 "Installation package\Device Driver\Graphics card",
	 "https://us.download.nvidia.cn/Windows/460.89",
	 "460.89-desktop-win10-64bit-international-dch-whql",
	 "exe",
	 "*-desktop-win10-*-international-dch-whql",
	 "-s -clean -noreboot -noeula"),
	("Sysinternals Suite",
	 "Disable",
	 "To",
	 "wait",
	 $env:SystemDrive,
	 "",
	 "https://download.sysinternals.com/files",
	 "SysinternalsSuite",
	 "zip",
	 "SysinternalsSuite",
	 ""),
	("VisualCppRedist AIO",
	 "Disable",
	 "Install",
	 "wait",
	 "auto",
	 "Installation package\AIO",
	 "https://github.com/abbodi1406/vcredist/releases/download/v0.43.0",
	 "VisualCppRedist_AIO_x86_x64_43",
	 "zip",
	 "VisualCppRedist*",
	 "/y"),
	("Gpg4win",
	 "Disable",
	 "Install",
	 "wait",
	 "auto",
	 "Installation package\AIO",
	 "https://files.gpg4win.org",
	 "gpg4win-latest",
	 "exe",
	 "gpg4win*",
	 "/S"),
	("Python",
	 "Disable",
	 "Install",
	 "wait",
	 "auto",
	 "Installation package\Develop software",
	 "https://www.python.org/ftp/python/3.9.1",
	 "python-3.9.1-amd64",
	 "exe",
	 "python-*",
	 "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"),
	("kugou music",
	 "Disable",
	 "Install",
	 "wait",
	 "auto",
	 "Installation package\Music software",
	 "https://downmini.yun.kugou.com/web",
	 "kugou9175",
	 "exe",
	 "kugou*",
	 "/S"),
	("NetEase Cloud Music",
	 "Disable",
	 "Install",
	 "wait",
	 "auto",
	 "Installation package\Music software",
	 "https://d1.music.126.net/dmusic",
	 "cloudmusicsetup2.7.5.198554",
	 "exe",
	 "cloudmusicsetup*",
	 "/S"),
	("QQ music",
	 "Disable",
	 "Install",
	 "fast",
	 "auto",
	 "Installation package\Music software",
	 "https://dldir1.qq.com/music/clntupate",
	 "QQMusicSetup",
	 "exe",
	 "QQMusicSetup",
	 "/S"),
	("Tencent QQ 2020",
	 "Enable",
	 "Install",
	 "wait",
	 "auto",
	 "Installation package\Social application",
	 "https://down.qq.com/qqweb/PCQQ/PCQQ_EXE",
	 "PCQQ2020",
	 "exe",
	 "PCQQ2020",
	 "/S"),
	("WeChat",
	 "Enable",
	 "Install",
	 "wait",
	 "auto",
	 "Installation package\Social application",
	 "https://dldir1.qq.com/weixin/Windows",
	 "WeChatSetup",
	 "exe",
	 "WeChatSetup",
	 "/S")
)
# Finally, please don't put , at the end, otherwise you will understand.

function Test-Available-Disk {
	param (
		[string]$Path
	)
	$test_tmp_filename = "writetest-"+[guid]::NewGuid()
	$test_filename = Join-Path -Path "$($Path)" -ChildPath "$($test_tmp_filename)"

	try {
		[io.file]::OpenWrite($test_filename).close()

		if ((Test-Path -Path $test_filename)) {
			Remove-Item $test_filename -ErrorAction SilentlyContinue
			return $true
		}
		$false
	} catch {
		return $false
	}
}

function Test-Catalog {
	Param(
		[string]$chkpath
	)

	if(!(Test-Path $chkpath -PathType Container)) {
		New-Item -Path $chkpath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
		if(!(Test-Path $chkpath -PathType Container)) {
			Write-Host "    - Failed to create directory: $($chkpath)`n" -ForegroundColor Red
			return
		}
	}
}

function Join-Url {
	param (
		[parameter(Mandatory=$True, HelpMessage="Base Path")]
		[ValidateNotNullOrEmpty()]
		[string] $Path,
		[parameter(Mandatory=$True, HelpMessage="Child Path or Item Name")]
		[ValidateNotNullOrEmpty()]
		[string] $ChildPath
	)
	if ($Path.EndsWith('/')) {
		return "$Path"+"$ChildPath"
	}
	else {
		return "$Path/$ChildPath"
	}
}

function Start-Install-Software {
	param(
		$appname,
		$status,
		$act,
		$mode,
		$todisk,
		$structure,
		$url,
		$packer,
		$types,
		$filename,
		$param
	)

	Switch ($status)
	{
		Enable {
			Write-Host "   Installing   - $($appname)" -ForegroundColor Green
		}
		Disable {
			Write-Host "   Skip install - $($appname)" -ForegroundColor Red
			return
		}
	}

	$url = Join-Url -Path "$($url)" -ChildPath "$($packer).$($types)"

	Switch ($todisk)
	{
		auto {
			$drives = Get-PSDrive -PSProvider FileSystem | where { -not ("$($env:SystemDrive)\" -eq $_.Root) } | Select-Object -ExpandProperty 'Root'
			foreach ($drive in $drives) {
				$tempoutputfoldoer = Join-Path -Path $($drive) -ChildPath "$($structure)"
				Get-ChildItem $tempoutputfoldoer -Recurse -Include "*$($filename)*" -ErrorAction SilentlyContinue | Foreach-Object {
					$OutTo = Join-Path -Path "$($drive)" -ChildPath "$($structure)"
					$OutAny = $($_.fullname)
					break
				}
				foreach ($drive in $drives) {
					if(Test-Available-Disk -Path $drive) {
						$OutTo = Join-Path -Path "$($drive)" -ChildPath "$($structure)"
						$OutAny = Join-Path -Path "$($drive)" -ChildPath "$($structure)\$($packer).$($types)"
						$OutArchive = Join-Path -Path "$($drive)" -ChildPath "$($structure)\$($packer).zip"
					} else {
						$OutTo = Join-Path -Path $($env:SystemDrive) -ChildPath "$($structure)"
						$OutAny = Join-Path -Path $($env:SystemDrive) -ChildPath "$($structure)\$($packer).$($types)"
						$OutArchive = Join-Path -Path $($env:SystemDrive) -ChildPath "$($structure)\$($packer).zip"
					}
				}
			}
		}
		default {
			$OutTo = Join-Path -Path $($todisk) -ChildPath "$($structure)"
			$OutAny = Join-Path -Path $($todisk) -ChildPath "$($structure)\$($packer).$($types)"
			$OutArchive = Join-Path -Path $($todisk) -ChildPath "$($structure)\$($packer).zip"
		}
	}

	Switch ($types)
	{
		zip {
			Switch ($act)
			{
				Install {
					Get-ChildItem $OutTo -Recurse -Include "*$($filename)*.exe" -ErrorAction SilentlyContinue | Foreach-Object {
						Write-Host "    - Locally exist: $($_.fullname)"
						Open-App -filename $($_.fullname) -param $param -mode $mode
						break
					}
					if (Test-Path -Path $OutArchive) {
						Write-Host "    - Existing installation package"
					} else {
						Write-Host "    * Start download`n      > Connected to: $url"
						try {
							Write-Host "      + Save to: $OutArchive"
							Test-Catalog -chkpath $OutTo
							(New-Object System.Net.WebClient).DownloadFile($url, $OutArchive) | Out-Null
						} catch {
							Write-Host "      - Status: Not available`n" -ForegroundColor Red
							break
						}
					}
					Write-Host "    - Unpacking"
					Archive-Unzip -filename $OutArchive -to $OutTo
					Write-Host "    - Unzip complete"
					if ((Test-Path $OutArchive)) { remove-item -path $OutArchive -force }
					Get-ChildItem $OutTo -Recurse -Include "*$($filename)*.exe" -ErrorAction SilentlyContinue | Foreach-Object {
						Write-Host "    - Locally exist: $($_.fullname)"
						Open-App -filename $($_.fullname) -param $param -mode $mode
					}
				}
				NoInst {
					if (Test-Path -Path $OutArchive) {
						Write-Host "    - Existing installation package"
					} else {
						Write-Host "    * Start download`n      > Connected to: $url"
						try {
							Write-Host "      + Save to: $OutArchive"
							Test-Catalog -chkpath $OutTo
							(New-Object System.Net.WebClient).DownloadFile($url, $OutArchive) | Out-Null
						} catch {
							Write-Host "      - Status: Not available`n" -ForegroundColor Red
							break
						}
					}
				}
				To {
					$newoutputfoldoer = "$($OutTo)\$($packer)"
					if (Test-Path $newoutputfoldoer -PathType Container) {
						Write-Host "    - Existing installation package`n"
						break
					} else {
						Write-Host "    * Start download`n        > Connected to: $url"
						try {
							Write-Host "      + Save to: $OutArchive"
							Test-Catalog -chkpath $newoutputfoldoer
							(New-Object System.Net.WebClient).DownloadFile($url, $OutArchive) | Out-Null
						} catch {
							Write-Host "      - Status: Not available`n" -ForegroundColor Red
							break
						}
						Write-Host "    - Unzip only"
						Archive-Unzip -filename $OutArchive -to $newoutputfoldoer
						Write-Host "    - Unzip complete`n"
						if ((Test-Path $OutArchive)) { remove-item -path $OutArchive -force }
					}
				}
				Unzip {
					if ((Test-Path -Path $OutArchive)) {
						Write-Host "    - Existing installation package"
					} else {
						Write-Host "    * Start download      > Connected to: $url"
						try {
							Write-Host "      + Save to: $OutArchive"
							Test-Catalog -chkpath $OutTo
							(New-Object System.Net.WebClient).DownloadFile($url, $OutArchive) | Out-Null
						} catch {
							Write-Host "      - Status: Not available`n" -ForegroundColor Red
							break
						}
					}
					Write-Host "    - Unzip only"
					Archive-Unzip -filename $OutArchive -to $OutTo
					Write-Host "    - Unzip complete`n"
					if ((Test-Path $OutArchive)) { remove-item -path $OutArchive -force }
				}
			}
		}
		default {
			if ((Test-Path $OutAny -PathType Leaf)) {
				Open-App -filename $OutAny -param $param -mode $mode
			} else {
				Write-Host "    * Start download`n      > Connected to: $url"
				try {
					Write-Host "      + Save to: $OutAny"
					Test-Catalog -chkpath $OutTo
					(New-Object System.Net.WebClient).DownloadFile($url, $OutAny) | Out-Null
					Open-App -filename $OutAny -param $param -mode $mode
				} catch {
					Write-Host "      - Status: Not available`n" -ForegroundColor Red
					break
				}
			}
		}
	}
}

function Archive-Unzip {
	param(
		$filename,
		$to
	)

	if (Get-Zip) {
		Write-host "    - Use $script:Zip to unzip the software"
		$arguments = "x ""-r"" ""-tzip"" ""$filename"" ""-o$to"" ""-y""";
		Start-Process $script:Zip "$arguments" -Wait -WindowStyle Minimized
	} else {
		Write-host "    - Use the decompression software that comes with the system"
		Expand-Archive -LiteralPath $filename -DestinationPath $to -force
	}
}

function Get-Zip {
	if (Test-Path "$env:ProgramFiles\7-Zip\7z.exe") {
		$script:Zip = "$env:ProgramFiles\7-Zip\7z.exe"
		return $true
	}

	if (Test-Path "$env:ProgramFiles(x86)\7-Zip\7z.exe") {
		$script:Zip = "$env:ProgramFiles(x86)\7-Zip\7z.exe"
		return $true
	}

	if (Test-Path "$env:SystemDrive\Yi\Yi\AIO\7z.exe") {
		$script:Zip = "$env:SystemDrive\Yi\Yi\AIO\7z.exe"
		return $true
	}
	return $false
}

function Open-App {
	param(
		$filename,
		$param,
		$mode
	)

	if ((Test-Path $filename -PathType Leaf)) {
		Switch ($mode)
		{
			Fast {
				Write-Host "    - Fast running: $filename`n    - parameter: $param`n"
				if (([string]::IsNullOrEmpty($param))){
					Start-Process -FilePath $filename
				} else {
					Start-Process -FilePath $filename -ArgumentList $param
				}
			}
			Wait {
				Write-Host "    - Wait for completion: $filename`n    - parameter: $param`n"
				if (([string]::IsNullOrEmpty($param))){
					Start-Process -FilePath $filename -Wait
				} else {
					Start-Process -FilePath $filename -ArgumentList $param -Wait
				}
			}
		}
	} else {
		Write-Host "    - No installation files were found,`n      please check the integrity: $filename`n" -ForegroundColor Red
	}
}

function Wait-Exit {
	param(
		[int]$wait
	)
	Write-Host "`n   Tip: The installation script will automatically exit after $wait seconds..." -ForegroundColor Red
	Start-Sleep -s $wait
	exit
}

function Obtain-And-Install {
	Write-Host "`n   INSTALLING SOFTWARE"
	Write-Host "   ---------------------------------------------------"
	for ($i=0; $i -lt $app.Count; $i++) {
		Start-Install-Software -appname $app[$i][0] -status $app[$i][1] -act $app[$i][2] -mode $app[$i][3] -todisk $app[$i][4] -structure $app[$i][5] -url $app[$i][6] -packer $app[$i][7] -types $app[$i][8] -filename $app[$i][9] -param $app[$i][10]
	}
}

function Process-other {
	Write-Host "`n   Processing other:" -ForegroundColor Green

	Write-Host "   - Delete startup items"
	Remove-ItemProperty -Name "Wechat" -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue | Out-Null

	Write-Host "   - Delete redundant shortcuts"
	Set-Location "$env:public\Desktop"
	Remove-Item ".\Kleopatra.lnk" -Force -ErrorAction SilentlyContinue | Out-Null

	Write-Host "   - Rename"
	#Rename-Item-NewName "Google Chrome.lnk"  -Path ".\New Google Chrome.lnk" -ErrorAction SilentlyContinue | Out-Null
}

function Get-Mainpage {
	cls
	Write-Host "`n   Author: Yi ( http://fengyi.tel )

   From: Yi's Solution
   buildstring: 5.2.0.1.bs_release.210120-1208

   INSTALLED SOFTWARE LIST ( total $($app.Count) items )
   ---------------------------------------------------"
	for ($i=0; $i -lt $app.Count; $i++) {
		Switch ($app[$i][1])
		{
			Enable {
				Write-Host "   WAIT INSTALL - $($app[$i][0])" -ForegroundColor Green
			}
			Disable {
				Write-Host "   SKIP INSTALL - $($app[$i][0])" -ForegroundColor Red
			}
		}
	}
	Write-Host "   ---------------------------------------------------"
}

function initialization {
}

If ($Force) {
	Get-Mainpage
	Initialization
	Obtain-And-Install
	Process-other
} else {
	Get-Mainpage
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
			Initialization
			Obtain-And-Install
			Process-other
			Wait-Exit -wait 6
		}
		1 {
			Write-Host "`n   The user has cancelled the installation."
			Wait-Exit -wait 2
		}
	}
}