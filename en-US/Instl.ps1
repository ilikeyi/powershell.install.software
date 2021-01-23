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
#Requires -version 3.0
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
	 [Status]::Disable,                                   # Status: Enable = enabled, Disable = disabled
	 [Action]::Install,                                   # Action: Install = install, NoInst = do not install after download, Unzip = only extract after download, To = install to directory
	 [Mode]::Wait,                                        # Operating mode: Wait = wait for the end of the run, Fast = run directly
	 "exe",                                               # File type: exe, archive or custom file type
	 "auto",                                              # Drive letter: Auto = full disk search, A-Z = designated drive letter or custom path
	 "Installation package\Driver\Graphics card",         # Directory structure, for example: change AUTO to C, merge result: C:\Installation package\Driver\Graphics card
	 "*-desktop-win10-*-international-dch-whql",          # Match file name, support fuzzy function (*)
	 "460.89-desktop-win10-64bit-international-dch-whql", # The absolute file name of the website download, please do not fill in the suffix
	 "https://us.download.nvidia.cn/Windows/460.89/",     # Site path prefix, ending with /
	 "-s -clean -noreboot -noeula"),                      # Parameters
	("Yi's Personalized theme pack",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Fast,
	 "deskthemepack",
	 "auto",
	 "Installation package\Theme pack",
	 "Yi*",
	 "Yi",
	 "https://fengyi.tel/",
	 ""),
	("Sysinternals Suite",
	 [Status]::Disable,
	 [Action]::To,
	 [Mode]::Wait,
	 "zip",
	 $env:SystemDrive,
	 "",
	 "SysinternalsSuite",
	 "SysinternalsSuite",
	 "https://download.sysinternals.com/files/",
	 ""),
	("VisualCppRedist AIO",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Wait,
	 "zip",
	 "auto",
	 "Installation package\AIO",
	 "VisualCppRedist*",
	 "VisualCppRedist_AIO_x86_x64_43",
	 "https://github.com/abbodi1406/vcredist/releases/download/v0.43.0/",
	 "/y"),
	("Gpg4win",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Wait,
	 "exe",
	 "auto",
	 "Installation package\AIO",
	 "gpg4win*",
	 "gpg4win-3.1.15",
	 "https://files.gpg4win.org/",
	 "/S"),
	("Python",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Wait,
	 "exe",
	 "auto",
	 "Installation package\Develop software",
	 "python-*",
	 "python-3.9.1-amd64",
	 "https://www.python.org/ftp/python/3.9.1/",
	 "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"),
	("kugou music",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Wait,
	 "exe",
	 "auto",
	 "Installation package\Music software",
	 "kugou*",
	 "kugou9175",
	 "https://downmini.yun.kugou.com/web/",
	 "/S"),
	("NetEase Cloud Music",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Wait,
	 "exe",
	 "auto",
	 "Installation package\Music software",
	 "cloudmusicsetup*",
	 "cloudmusicsetup2.7.5.198554",
	 "https://d1.music.126.net/dmusic/",
	 "/S"),
	("QQ music",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Fast,
	 "exe",
	 "auto",
	 "Installation package\Music software",
	 "QQMusicSetup",
	 "QQMusicSetup",
	 "https://dldir1.qq.com/music/clntupate/",
	 "/S"),
	("Tencent QQ 2020",
	 [Status]::Enable,
	 [Action]::Install,
	 [Mode]::Wait,
	 "exe",
	 "auto",
	 "Installation package\Social application",
	 "PCQQ2020",
	 "PCQQ2020",
	 "https://down.qq.com/qqweb/PCQQ/PCQQ_EXE/",
	 "/S"),
	("WeChat",
	 [Status]::Enable,
	 [Action]::Install,
	 [Mode]::Wait,
	 "exe",
	 "auto",
	 "Installation package\Social application",
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

Enum Mode
{
	Wait    # Wait for completion
	Fast    # Run directly
}

Enum Action
{
	Install # installation
	NoInst  # Do not install after download
	To      # Download the compressed package to the directory
	Unzip   # Only unzip after downloading
}

function Test-Available-Disk {
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

function Test-URI {
	Param(
		[Parameter(Position=0,Mandatory,HelpMessage="HTTP or HTTPS")]
		[ValidatePattern( "^(http|https)://" )]
		[Alias("url")]
		[string]$URI,
		[Parameter(ParameterSetName="Detail")]
		[Switch]$Detail,
		[ValidateScript({$_ -ge 0})]
		[int]$Timeout = 30
	)
	Process {
		Try {
			$paramHash = @{
				UseBasicParsing = $True
				DisableKeepAlive = $True
				Uri = $uri
				Method = 'Head'
				ErrorAction = 'stop'
				TimeoutSec = $Timeout
			}
			$test = Invoke-WebRequest @paramHash
			if ($Detail) {
				$test.BaseResponse | Select ResponseURI,ContentLength,ContentType,LastModified, @{Name="Status";Expression={$Test.StatusCode}}
			} else {
				if ($test.statuscode -ne 200) { $False } else { $True }
			}
		} Catch {
			write-verbose -message $_.exception
			if ($Detail) {
				$objProp = [ordered]@{
					ResponseURI = $uri
					ContentLength = $null
					ContentType = $null
					LastModified = $null
					Status = 404
				}
				New-Object -TypeName psobject -Property $objProp
			} else { $False }
		}
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

function Start-Install-Software {
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
			Write-Host "   Installing   - $($appname)" -ForegroundColor Green
		}
		Disable {
			Write-Host "   Skip install - $($appname)" -ForegroundColor Red
			return
		}
	}

	$url = $url + $packer + "." + $types

	Switch ($todisk)
	{
		auto {
			$drives = Get-PSDrive | Select-Object -ExpandProperty 'Name' | Select-String -Pattern '^[a-z]$'
			$newdrives = Get-PSDrive | Select-Object -ExpandProperty 'Name' | Select-String -Pattern '^[d-z]$'
			foreach ($drive in $drives) {
				$tempoutputfoldoer = "$($drive):\$($structure)"
				Get-ChildItem $tempoutputfoldoer -Recurse -Include "*$($filename)*" -ErrorAction SilentlyContinue | Foreach-Object {
					$OutTo = Join-Path -Path "$($drive):" -ChildPath "$($structure)"
					$OutAny = $($_.fullname)
					break
				}
				foreach ($drive in $newdrives) {
					if(Test-Available-Disk -Path $drive) {
						$OutTo = Join-Path -Path "$($drive):" -ChildPath "$($structure)"
						$OutAny = Join-Path -Path "$($drive):" -ChildPath "$($structure)\$($packer).$($types)"
						$OutArchive = Join-Path -Path "$($drive):" -ChildPath "$($structure)\$($packer).zip"
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
						Open-App -filename $($_.fullname) -param $param -pp $pp
						break
					}
					if (Test-Path -Path $OutArchive) {
						Write-Host "    - Existing installation package`n"
					} else {
						Write-Host "    * Start download`n      ^ Connected to: $url`n      + Save to: $OutArchive"
						Test-Catalog -chkpath $OutTo
						Invoke-WebRequest -Uri $url -OutFile "$($OutArchive)" -ErrorAction SilentlyContinue | Out-Null
					}
					Write-Host "    - Unpacking"
					Archive-Unzip -filename $OutArchive -to $OutTo
					Write-Host "    - Unzip complete`n"
					if ((Test-Path $OutArchive)) { remove-item -path $OutArchive -force }
					Get-ChildItem $OutTo -Recurse -Include "*$($filename)*.exe" -ErrorAction SilentlyContinue | Foreach-Object {
						Write-Host "    - Locally exist: $($_.fullname)"
						Open-App -filename $($_.fullname) -param $param -pp $pp
					}
				}
				NoInst {
					if (Test-Path -Path $OutArchive) {
						Write-Host "    - Existing installation package`n"
					} else {
						Write-Host "    * Start download`n      ^ Connected to: $url`n      + Save to: $OutArchive"
						Test-Catalog -chkpath $OutTo
						Invoke-WebRequest -Uri $url -OutFile "$($OutArchive)" -ErrorAction SilentlyContinue | Out-Null
					}
				}
				To {
					$newoutputfoldoer = "$($OutTo)\$($packer)"
					if (Test-Path $newoutputfoldoer -PathType Container) {
						Write-Host "    - Existing installation package`n"
						break
					} else {
						Write-Host "    * Start download`n      ^ Connected to: $url`n      + Save to: $OutArchive"
						Invoke-WebRequest -Uri $url -OutFile $OutArchive -ErrorAction SilentlyContinue | Out-Null
						Write-Host "    - Unzip only"
						Archive-Unzip -filename $OutArchive -to $newoutputfoldoer
						Write-Host "    - Unzip complete`n"
						if ((Test-Path $OutArchive)) { remove-item -path $OutArchive -force }
					}
				}
				Unzip {
					if ((Test-Path -Path $OutArchive)) {
						Write-Host "    - Existing installation package`n"
					} else {
						Write-Host "    * Start download`n      ^ Connected to: $url`n      + Save to: $OutArchive"
						Test-Catalog -chkpath $OutTo
						Invoke-WebRequest -Uri $url -OutFile $OutArchive -ErrorAction SilentlyContinue | Out-Null
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
				Open-App -filename $OutAny -param $param -pp $pp
			} else {
				Write-Host "    * Start download`n      ^ Connected to: $url"
				if (test-uri $url) {
					Write-Host "      + Save to: $OutAny"
					Test-Catalog -chkpath $OutTo
					Invoke-WebRequest -Uri $url -OutFile $OutAny -ErrorAction SilentlyContinue | Out-Null
					Open-App -filename $OutAny -param $param -pp $pp
				} else {
					Write-Host "      - Status: Not available`n" -ForegroundColor Red
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

function Open-App {
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
	Write-Host "`n   Installing software..."
	Write-Host "   ---------------------------------------------------"
	for ($i=0; $i -lt $app.Count; $i++) {
		Start-Install-Software -appname $app[$i][0] -status $app[$i][1] -act $app[$i][2] -pp $app[$i][3] -types $app[$i][4] -todisk $app[$i][5] -structure $app[$i][6] -filename $app[$i][7] -packer $app[$i][8] -url $app[$i][9] -param $app[$i][10]
	}
}

function Process-other {
	Write-Host "`n   Processing other:" -ForegroundColor Green

	Write-Host "   - Delete startup items"
	Remove-ItemProperty -Name "Wechat" -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue | Out-Null

	Write-Host "   - Disable scheduled tasks"
	Disable-ScheduledTask -TaskName GoogleUpdateTaskMachineCore -ErrorAction SilentlyContinue | Out-Null
	Disable-ScheduledTask -TaskName GoogleUpdateTaskMachineUA -ErrorAction SilentlyContinue | Out-Null

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
   buildstring: 5.1.2.6.bk_release.210120-1208

   INSTALLED SOFTWARE LIST ( total $($app.Count) items )
   ---------------------------------------------------"
	for ($i=0; $i -lt $app.Count; $i++) {
		Switch ($app[$i][1])
		{
			Enable {
				Write-Host "   WAIT - $($app[$i][0])" -ForegroundColor Green
			}
			Disable {
				Write-Host "   SKIP - $($app[$i][0])" -ForegroundColor Red
			}
		}
	}
	Write-Host "   ---------------------------------------------------"
}

Get-Mainpage

If ($Force) {
	Obtain-And-Install
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