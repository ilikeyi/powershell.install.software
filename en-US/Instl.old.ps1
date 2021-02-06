<#
  Warning: In order to prevent overwriting after updating, please save as and then modify.

  PowerShell installation software

  .THE MAIN FUNCTION
    1. There is no installation package locally, activate the download function;
    2. The drive letter can be specified, and the current system drive will be excluded after setting automatic.
       When no available disk is found, the default setting is the current system disk;
    3. Search file name supports fuzzy search, wildcard *;
    4. The file name is searched first by language structure, for example:
       - Operating system preferred language: en-US
       - File name: ChromeChrome
       The preferred search condition is GoogleChrome*en-US*, and if the search is not found, search again by default file name.
    5. Support decompression package processing, etc.

  .PREREQUISITES
  - PowerShell 2.0 Or higher

  .LINK
  - https://github.com/ilikeyi/powershell.install.software
  - https://gitee.com/ilikeyi/powershell.install.software


  Package configuration tutorial

 Package Configuration        Description
("Gpg4win",                   Package name
 "Disable",                   Status: Enable - enabled; Disable - disabled
 "Install",                   Action: Install - install; NoInst - does not install after download; Unzip - only extract after download; To - install to directory
 "wait",                      Operation mode: Wait - wait for completion; Fast - run directly
 "auto",                      After setting automatic, the current system disk will be excluded. If no available disk is found, the default setting is the current system disk; specify the drive letter [A:]-[Z:]; specify the path: \\192.168.1.1
 "Installation package\AIO",  Directory Structure
 "https://files.gpg4win.org", Website address
 "gpg4win-latest",            File name downloaded from website
 "exe",                       File type downloaded from the website: exe, zip or custom file type; result: https://files.gpg4win.org/gpg4win-latest.exe
 "gpg4win*",                  File name fuzzy search (*)
 "/S"),                       Operating parameters

#>

#Requires -version 2.0

# Get script parameters ( if any )
[CmdletBinding()]
param(
	[parameter(Mandatory = $false, HelpMessage = "Silent")]
	[Switch]$Force
)

$Host.UI.RawUI.WindowTitle = "PowerShell installation software"

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
	 "https://cn.download.nvidia.cn/Windows/461.40",
	 "461.40-desktop-win10-64bit-international-dch-whql",
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
	 "PCQQ2021",
	 "exe",
	 "PCQQ2021",
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

function TestAvailableDisk {
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

function CheckCatalog {
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

function JoinUrl {
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

function StartInstallSoftware {
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

	$url = JoinUrl -Path "$($url)" -ChildPath "$($packer).$($types)"

	Switch ($todisk) {
		auto {
			$drives = Get-PSDrive -PSProvider FileSystem | where { -not ("$($env:SystemDrive)\" -eq $_.Root) } | Select-Object -ExpandProperty 'Root'
			foreach ($drive in $drives) {
				$tempoutputfoldoer = Join-Path -Path $($drive) -ChildPath "$($structure)"
				Get-ChildItem $tempoutputfoldoer -Recurse -Include "*$($filename)*$((Get-Culture).Name)*" -ErrorAction SilentlyContinue | Foreach-Object {
					$OutTo = Join-Path -Path "$($drive)" -ChildPath "$($structure)"
					$OutAny = $($_.fullname)
					break
				}
				Get-ChildItem $tempoutputfoldoer -Recurse -Include "*$($filename)*" -ErrorAction SilentlyContinue | Foreach-Object {
					$OutTo = Join-Path -Path "$($drive)" -ChildPath "$($structure)"
					$OutAny = $($_.fullname)
					break
				}
				foreach ($drive in $drives) {
					if (TestAvailableDisk -Path $drive)	{
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
			Get-ChildItem $OutTo -Recurse -Include "*$($filename)*$((Get-Culture).Name)*" -ErrorAction SilentlyContinue | Foreach-Object {
				$OutAny = $($_.fullname)
				break
			}
			Get-ChildItem $OutTo -Recurse -Include "*$($filename)*" -ErrorAction SilentlyContinue | Foreach-Object {
				$OutAny = $($_.fullname)
				break
			}
			$OutAny = Join-Path -Path $($todisk) -ChildPath "$($structure)\$($packer).$($types)"
		}
	}

	Switch ($types)
	{
		zip {
			Switch ($act)
			{
				Install {
					Get-ChildItem $OutTo -Recurse -Include "*$($filename)*$((Get-Culture).Name)*.exe" -ErrorAction SilentlyContinue | Foreach-Object {
						Write-Host "    - Locally exist: $($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode
						break
					}
					Get-ChildItem $OutTo -Recurse -Include "*$($filename)*.exe" -ErrorAction SilentlyContinue | Foreach-Object {
						Write-Host "    - Locally exist: $($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode
						break
					}
					if (Test-Path -Path $OutArchive) {
						Write-Host "    - Existing installation package"
					} else {
						Write-Host "    * Start download`n      > Connected to: $url"
						try {
							Write-Host "      + Save to: $OutArchive"
							CheckCatalog -chkpath $OutTo
							(New-Object System.Net.WebClient).DownloadFile($url, $OutArchive) | Out-Null
						} catch {
							Write-Host "      - Status: Not available`n" -ForegroundColor Red
							break
						}
					}
					if (Test-Path -Path $OutArchive) {
						Write-Host "    - Unpacking"
						Archive -filename $OutArchive -to $OutTo
						Write-Host "    - Unzip complete"
						if ((Test-Path $OutArchive)) { remove-item -path $OutArchive -force }
					} else {
						Write-Host "    - An error occurred during download`n" -ForegroundColor Red
					}
					Get-ChildItem $OutTo -Recurse -Include "*$($filename)*$((Get-Culture).Name)*.exe" -ErrorAction SilentlyContinue | Foreach-Object {
						Write-Host "    - Locally exist: $($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode
						break
					}
					Get-ChildItem $OutTo -Recurse -Include "*$($filename)*.exe" -ErrorAction SilentlyContinue | Foreach-Object {
						Write-Host "    - Locally exist: $($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode
						break
					}
				}
				NoInst {
					if (Test-Path -Path $OutArchive) {
						Write-Host "    - Installed`n"
					} else {
						Write-Host "    * Start download`n      > Connected to: $url"
						try {
							Write-Host "      + Save to: $OutArchive"
							CheckCatalog -chkpath $OutTo
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
						Write-Host "    - Installed`n"
						break
					}
					if (Test-Path -Path $OutArchive) {
						Write-Host "    - Compressed package available"
					} else {
						Write-Host "    * Start download`n        > Connected to: $url"
						try {
							Write-Host "      + Save to: $OutArchive"
							(New-Object System.Net.WebClient).DownloadFile($url, $OutArchive) | Out-Null
						} catch {
							Write-Host "      - Status: Not available`n" -ForegroundColor Red
							break
						}
					}
					if (Test-Path -Path $OutArchive) {
						Write-Host "    - Unzip only"
						Archive -filename $OutArchive -to $newoutputfoldoer
						Write-Host "    - Unzip complete`n"
						if ((Test-Path $OutArchive)) { remove-item -path $OutArchive -force }
					} else {
						Write-Host "    - An error occurred during download`n" -ForegroundColor Red
					}
				}
				Unzip {
					if (Test-Path -Path $OutArchive) {
						Write-Host "    - Existing installation package"
					} else {
						Write-Host "    * Start download      > Connected to: $url"
						try {
							Write-Host "      + Save to: $OutArchive"
							CheckCatalog -chkpath $OutTo
							(New-Object System.Net.WebClient).DownloadFile($url, $OutArchive) | Out-Null
						} catch {
							Write-Host "      - Status: Not available`n" -ForegroundColor Red
							break
						}
					}
					if (Test-Path -Path $OutArchive) {
						Write-Host "    - Unzip only"
						Archive -filename $OutArchive -to $OutTo
						Write-Host "    - Unzip complete`n"
						if ((Test-Path $OutArchive)) { remove-item -path $OutArchive -force }
					} else {
						Write-Host "    - An error occurred during download`n" -ForegroundColor Red
					}
				}
			}
		}
		default {
			if ((Test-Path $OutAny -PathType Leaf)) {
				OpenApp -filename $OutAny -param $param -mode $mode
			} else {
				Write-Host "    * Start download`n      > Connected to: $url"
				try {
					Write-Host "      + Save to: $OutAny"
					CheckCatalog -chkpath $OutTo
					(New-Object System.Net.WebClient).DownloadFile($url, $OutAny) | Out-Null
					OpenApp -filename $OutAny -param $param -mode $mode
				} catch {
					Write-Host "      - Status: Not available`n" -ForegroundColor Red
					break
				}
			}
		}
	}
}

function Archive {
	param(
		$filename,
		$to
	)

	if (Compressing) {
		Write-host "    - Use $script:Zip to unzip the software"
		$arguments = "x ""-r"" ""-tzip"" ""$filename"" ""-o$to"" ""-y""";
		Start-Process $script:Zip "$arguments" -Wait -WindowStyle Minimized
	} else {
		Write-host "    - Use the decompression software that comes with the system"
		Expand-Archive -LiteralPath $filename -DestinationPath $to -force
	}
}

function Compressing {
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

function OpenApp {
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

function WaitExit {
	param(
		[int]$wait
	)
	Write-Host "`n   The installation script will automatically exit after $wait seconds." -ForegroundColor Red
	Start-Sleep -s $wait
	exit
}

function ObtainAndInstall {
	Write-Host "`n   INSTALLING SOFTWARE"
	Write-Host "   ---------------------------------------------------"
	for ($i=0; $i -lt $app.Count; $i++) {
		StartInstallSoftware -appname $app[$i][0] -status $app[$i][1] -act $app[$i][2] -mode $app[$i][3] -todisk $app[$i][4] -structure $app[$i][5] -url $app[$i][6] -packer $app[$i][7] -types $app[$i][8] -filename $app[$i][9] -param $app[$i][10]
	}
}

function ProcessOther {
	Write-Host "`n   Processing other:" -ForegroundColor Green

	Write-Host "   - Delete startup items"
	Remove-ItemProperty -Name "Wechat" -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue | Out-Null

	Write-Host "   - Delete redundant shortcuts"
	Set-Location "$env:public\Desktop"
	Remove-Item ".\Kleopatra.lnk" -Force -ErrorAction SilentlyContinue | Out-Null

	Write-Host "   - Rename"
	#Rename-Item-NewName "Google Chrome.lnk"  -Path ".\New Google Chrome.lnk" -ErrorAction SilentlyContinue | Out-Null
}

function Mainpage {
	Clear-Host
	Write-Host "`n   Author: Yi ( http://fengyi.tel )

   From: Yi's Solution
   buildstring: 5.3.1.0.bs_release.210120-1208

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
	Mainpage
	Initialization
	ObtainAndInstall
	ProcessOther
} else {
	Mainpage
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
			ObtainAndInstall
			ProcessOther
			WaitExit -wait 6
		}
		1 {
			Write-Host "`n   The user has cancelled the installation."
			WaitExit -wait 2
		}
	}
}