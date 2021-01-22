#
#  Warning: In order to prevent overwriting after updating, please save as and then modify.
#
#  You are welcome to install the software using PowerShell
#
#  The main function:
#    1. The installation package does not exist locally, activate the download;
#    2. You can specify the drive letter of the Apps, if not specified, search in the order of [d-z],
#       Only the available disks are searched, and the default current system disk is not searched;
#    3. Search file name supports fuzzy search, wildcard *;
#    4. Support decompression package processing, etc.
#
#  Prerequisites:
#    - PowerShell 1.0 Or higher
#
#  Source code:
#  https://github.com/ilikeyi/powershell.install.software
#  https://gitee.com/ilikeyi/powershell.install.software
#

# Get script parameters ( if any )
[CmdletBinding()]
param(
	[parameter(Mandatory = $false, HelpMessage = "Silent")]
	[Switch]$Force
)

# All software configurations
$app = @(
	("Nvidia GEFORCE GAME READY DRIVER",                  # Package name
	 "Disable",                                           # Status: Enable = enabled, Disable = disabled
	 "Install",                                           # Action: Install = install, NoInst = do not install after download, Unzip = only extract after download, To = install to directory
	 "wait",                                              # Operating mode: Wait = wait for the end of the run, Fast = run directly
	 "exe",                                               # File type: exe, zip, or custom file type
	 "auto",                                              # Drive letter: Auto = full disk search, A-Z = designated drive letter or custom path
	 "Installation package\Drive",                        # Directory structure, for example: change AUTO to C, merge result: C:\Yi\Apps\Drive
	 "*-desktop-win10-*-international-dch-whql",          # Match file name, support fuzzy function (*)
	 "460.89-desktop-win10-64bit-international-dch-whql", # The absolute file name of the website download, please do not fill in the suffix
	 "https://us.download.nvidia.cn/Windows/460.89/",     # Site path prefix, ending with /
	 "-s -clean -noreboot -noeula"),                      # Parameters
	("Sysinternals Suite",
	 "Disable",
	 "To",
	 "wait",
	 "zip",
	 "auto",
	 "Installation package",
	 "SysinternalsSuite",
	 "SysinternalsSuite",
	 "https://download.sysinternals.com/files/",
	 ""),
	("VisualCppRedist AIO",
	 "Disable",
	 "Install",
	 "wait",
	 "zip",
	 "auto",
	 "Installation package\AIO",
	 "VisualCppRedist*",
	 "VisualCppRedist_AIO_x86_x64_43",
	 "https://github.com/abbodi1406/vcredist/releases/download/v0.43.0/",
	 "/y"),
	("Gpg4win",
	 "Disable",
	 "Install",
	 "wait",
	 "exe",
	 "auto",
	 "Installation package\AIO",
	 "gpg4win*",
	 "gpg4win-3.1.15",
	 "https://files.gpg4win.org/",
	 "/S"),
	("Python",
	 "Disable",
	 "Install",
	 "wait",
	 "exe",
	 "auto",
	 "Installation package\AIO",
	 "python-*",
	 "python-3.9.1-amd64",
	 "https://www.python.org/ftp/python/3.9.1/",
	 "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"),
	("kugou music",
	 "Disable",
	 "Install",
	 "wait",
	 "exe",
	 "auto",
	 "Installation package\Music",
	 "kugou*",
	 "kugou9175",
	 "https://downmini.yun.kugou.com/web",
	 "/S"),
	("NetEase Cloud Music",
	 "Disable",
	 "Install",
	 "wait",
	 "exe",
	 "auto",
	 "Installation package\Music",
	 "cloudmusicsetup*",
	 "cloudmusicsetup2.7.5.198554",
	 "https://d1.music.126.net/dmusic/",
	 "/S"),
	("QQ music",
	 "Disable",
	 "Install",
	 "fast",
	 "exe",
	 "auto",
	 "Installation package\Music",
	 "QQMusicSetup",
	 "QQMusicSetup",
	 "https://dldir1.qq.com/music/clntupate/",
	 "/S"),
	("Tencent QQ 2020",
	 "Enable",
	 "Install",
	 "wait",
	 "exe",
	 "auto",
	 "Installation package\social",
	 "PCQQ2020",
	 "PCQQ2020",
	 "https://down.qq.com/qqweb/PCQQ/PCQQ_EXE/",
	 "/S"),
	("WeChat",
	 "Enable",
	 "Install",
	 "wait",
	 "exe",
	 "auto",
	 "Installation package\social",
	 "WeChatSetup",
	 "WeChatSetup",
	 "https://dldir1.qq.com/weixin/Windows/",
	 "/S")
)

function Test-Disk {
	param (
		[string]$Path
	)
	$test_tmp_filename = "writetest-"+[guid]::NewGuid()
	$test_filename = $Path + ":\" + $test_tmp_filename
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

function Check-SD {
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

function Get-Version {
	param(
		$appname,
		$status,
		$act,
		$pp,
		$types,
		$todisk,
		$structure,
		$filename,
		$packer,
		$url,
		$param
	)

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

	$url = $url + $packer + "." + $types

	switch -regex ($todisk)
	{
		"auto" { break }
		"^[a-z]$" { break }
		default { $todisk = "auto" }
	}

	Switch ($todisk)
	{
		auto {
			$drives = Get-PSDrive | Select-Object -ExpandProperty 'Name' | Select-String -Pattern '^[a-z]$'
			$newdrives = Get-PSDrive | Select-Object -ExpandProperty 'Name' | Select-String -Pattern '^[d-z]$'
			foreach ($drive in $drives) {
				$newpath = "$($drive):\$($structure)\$($filename).$($types)"
				$tempoutputfoldoer = "$($drive):\$($structure)"
				Get-ChildItem $tempoutputfoldoer -Recurse -Include "*$($filename)*" -ErrorAction SilentlyContinue | Foreach-Object {
					$outputexe = $($_.fullname)
					$outputfoldoer = "$($drive):\$($structure)"
					break
				}
				foreach ($drive in $newdrives) {
					if(Test-Disk -Path $drive) {
						if ( $act -eq "To" ) {
							$outputfoldoer = "$($drive):\$($structure)\$($packer)"
							$outputexe = "$($drive):\$($structure)\$($packer)\$($packer).exe"
							$outputzip = "$($drive):\$($structure)\$($packer)\$($packer).zip"
						} else {
							$outputfoldoer = "$($drive):\$($structure)"
							$outputexe = "$($drive):\$($structure)\$($packer).exe"
							$outputzip = "$($drive):\$($structure)\$($packer).zip"
						}
						break
					} else {
						if ( $act -eq "To") {
							$outputfoldoer = "$($env:SystemDrive)\$($structure)\$($packer)"
							$outputexe = "$($env:SystemDrive)\$($structure)\$($packer)\$($packer).exe"
							$outputzip = "$($env:SystemDrive)\$($structure)\$($packer)\$($packer).zip"
						} else {
							$outputfoldoer = "$($env:SystemDrive)\$($structure)"
							$outputexe = "$($env:SystemDrive)\$($structure)\$($packer).exe"
							$outputzip = "$($env:SystemDrive)\$($structure)\$($packer).zip"
						}
					}
				}
			}
		}
		default {
			if ( $act -eq "To") {
				$outputfoldoer = "$($todisk)\$($structure)\$($packer)"
				$outputexe = "$($todisk)\$($structure)\$($packer)\$($packer).exe"
				$outputzip = "$($todisk)\$($structure)\$($packer)\$($packer).zip"
			} else {
				$outputfoldoer = "$($todisk)\$($structure)"
				$outputexe = "$($todisk)\$($structure)\$($packer).exe"
				$outputzip = "$($todisk)\$($structure)\$($packer).zip"
			}
		}
	}

	Switch ($types)
	{
		zip {
			Switch ($act)
			{
				Install {
					Get-ChildItem $outputfoldoer -Recurse -Include "*$($filename)*.exe" -ErrorAction SilentlyContinue | Foreach-Object {
						Write-Host "    - Existing installation package"
						Get-RunApp -filename $($_.fullname) -param $param -pp $pp
						break
						return
					}
				}
				To {
					if (Test-Path $outputfoldoer -PathType Container) {
						Write-Host "    - Existing installation package`n"
					} else {
						Write-Host "`    * Start download`n    - Connection address: $url"
						Write-Host "`    - Save the file to: $outputzip"
						try {
							Write-Host "`    - Save the file to: $outputzip"
							Check-SD -chkpath $outputfoldoer
							(New-Object System.Net.WebClient).DownloadFile($url, $outputzip) | Out-Null
						} catch {
							Write-Host "     - Status: Not available`n" -ForegroundColor Red
						}
						Write-Host "    - Unzip only"
						Archive-Unzip -filename $outputzip -to $outputfoldoer
						if ((Test-Path $outputzip)) { remove-item -path $outputzip -force }
					}
				}
				Unzip {
					if ((Test-Path -Path $outputzip)) {
						Write-Host "    - Existing installation package"
					} else {
						Write-Host "`    * Start download    - Connection address: $url"
						Write-Host "`    - Save the file to: $outputzip"
						try {
							Write-Host "`    - Save the file to: $outputzip"
							Check-SD -chkpath $outputfoldoer
							(New-Object System.Net.WebClient).DownloadFile($url, $outputzip) | Out-Null
						} catch {
							Write-Host "     - Status: Not available`n" -ForegroundColor Red
						}
					}
					Write-Host "    - Unzip only"
					Archive-Unzip -filename $outputzip -to $outputfoldoer
					if ((Test-Path $outputzip)) { remove-item -path $outputzip -force }
				}
				Install {
					if ((Test-Path -Path $outputzip)) {
						Write-Host "    - Existing installation package"
					} else {
						Write-Host "`    * Start download`n    - Connection address: $url"
						Write-Host "`    - Save the file to: $outputzip"
						try {
							Write-Host "`    - Save the file to: $outputzip"
							Check-SD -chkpath $outputfoldoer
							(New-Object System.Net.WebClient).DownloadFile($url, $outputzip) | Out-Null
						} catch {
							Write-Host "     - Status: Not available`n" -ForegroundColor Red
						}
					}
					Write-Host "    - Run after decompression"
					Archive-Unzip -filename $outputzip -to $outputfoldoer
					if ((Test-Path $outputzip)) { remove-item -path $outputzip -force }
					Get-ChildItem $outputfoldoer -Recurse -Include "*$($filename)*.exe" -ErrorAction SilentlyContinue | Foreach-Object {
					    Write-Host "    - Locally exist: $($_.fullname)"
					    Get-RunApp -filename $($_.fullname) -param $param -pp $pp
					}
				}
			}
		}
		default {
			if ((Test-Path $outputexe -PathType Leaf)) {
				Get-RunApp -filename $outputexe -param $param -pp $pp
			} else {
				Write-Host "`    * Start download`n    - Connection address: $url"
				try {
					Write-Host "`    - Save the file to: $outputexe"
					Check-SD -chkpath $outputfoldoer
					(New-Object System.Net.WebClient).DownloadFile($url, $outputexe) | Out-Null
					Get-RunApp -filename $outputexe -param $param -pp $pp
				} catch {
					Write-Host "     - Status: Not available`n" -ForegroundColor Red
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
		Write-host "    - Use $script:Zip to unzip the software`n"
		$arguments = "x ""-r"" ""-tzip"" ""$filename"" ""-o$to"" ""-y""";
		Start-Process $script:Zip "$arguments" -Wait -WindowStyle Minimized
	} else {
		Write-host "    - Use the decompression software that comes with the system`n"
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

function Get-RunApp {
	param(
		$filename,
		$param,
		$pp
	)

	if ((Test-Path $filename -PathType Leaf)) {
		Switch ($pp)
		{
			Fast {
				Write-Host "    - Fast running: $filename`n    - parameter: $param`n"
				Start-Process -FilePath $filename -ArgumentList $param
			}
			Wait {
				Write-Host "    - Waiting to run: $filename`n    - parameter: $param`n"
				Start-Process -FilePath $filename -ArgumentList $param -Wait
			}
		}
	} else {
		Write-Host "    - No installation files were found,`n      please check the integrity: $filename`n" -ForegroundColor Red
	}
}

cls
Write-Host "`n   Author: Yi ( http://fengyi.tel )

   From: Yi's Solution
   buildstring: 5.1.2.2.bk_release.210120-1208

   Installed software list ( total $($app.Count) items )
   ---------------------------------------------------"
for ($i=0; $i -lt $app.Count; $i++) {
	Switch ($app[$i][1])
	{
		Enable {
			Write-Host "   'Wait install' - $($app[$i][0])" -ForegroundColor Green
		}
		Disable {
			Write-Host "   'Skip install' - $($app[$i][0])" -ForegroundColor Red
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
		Get-Version -appname $app[$i][0] -status $app[$i][1] -act $app[$i][2] -pp $app[$i][3] -types $app[$i][4] -todisk $app[$i][5] -structure $app[$i][6] -filename $app[$i][7] -packer $app[$i][8] -url $app[$i][9] -param $app[$i][10]
	}
}

function Process-other {
	Write-Host "`n    Processing other:" -ForegroundColor Green

	Write-Host "    - Delete startup items"
	Remove-ItemProperty -Name "Wechat" -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue | Out-Null

	Write-Host "    - Delete redundant shortcuts"
	Set-Location "$env:public\Desktop"
	Remove-Item ".\Kleopatra.lnk" -Force -ErrorAction SilentlyContinue | Out-Null

	Write-Host "    - Rename"
	#Rename-Item-NewName "Google Chrome.lnk"  -Path ".\New Google Chrome.lnk" -ErrorAction SilentlyContinue | Out-Null
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
			Write-Host "`n   The user has cancelled the installation."
			Wait-Exit -wait 2
		}
	}
}