<#

  Warning: In order to prevent overwriting after updating, please save as and then modify.

  PowerShell installation software

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

  . PREREQUISITES
    - PowerShell 5.1 Or higher

  . LINK
    - https://github.com/ilikeyi/powershell.install.software
    - https://gitee.com/ilikeyi/powershell.install.software


  Package configuration tutorial

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

#>

#Requires -version 5.1

# Get script parameters ( if any )
[CmdletBinding()]
param
(
	[parameter(Mandatory = $false, HelpMessage = "Silent")]
	[Switch]$Force,
	[Switch]$Silent
)

$Global:AppQueue = @()
$Global:AppQueue.Clear()

$Host.UI.RawUI.WindowTitle = "PowerShell installation software"

# All software configurations
$app = @(
	("Yi's Personalized theme pack",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Fast,
	 "auto",
	 "Installation package\Theme pack",
	 "https://fengyi.tel",
	 "Yi",
	 "deskthemepack",
	 "Yi*",
	 "",
	 ""),
	("Nvidia GEFORCE GAME READY DRIVER",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Device Driver\Graphics card",
	 "https://us.download.nvidia.com/Windows/461.72",
	 "461.72-desktop-win10-64bit-international-dch-whql",
	 "exe",
	 "*-desktop-win10-*-international-dch-whql",
	 "-s -clean -noreboot -noeula",
	 ""),
	("Sysinternals Suite",
	 [Status]::Disable,
	 [Action]::To,
	 [Mode]::Fast,
	 $env:SystemDrive,
	 "",
	 "https://download.sysinternals.com/files",
	 "SysinternalsSuite",
	 "zip",
	 "SysinternalsSuite",
	 "",
	 ""),
	("VisualCppRedist AIO",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\AIO",
	 "https://github.com/abbodi1406/vcredist/releases/download/v0.45.0",
	 "VisualCppRedist_AIO_x86_x64_45",
	 "zip",
	 "VisualCppRedist*",
	 "/y",
	 ""),
	("Gpg4win",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\AIO",
	 "https://files.gpg4win.org",
	 "gpg4win-latest",
	 "exe",
	 "gpg4win*",
	 "/S",
	 ""),
	("Python",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Develop software",
	 "https://www.python.org/ftp/python/3.9.1",
	 "python-3.9.1-amd64",
	 "exe",
	 "python-*",
	 "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0",
	 ""),
	("kugou music",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Music software",
	 "https://downmini.yun.kugou.com/web",
	 "kugou9175",
	 "exe",
	 "kugou*",
	 "/S",
	 ""),
	("NetEase Cloud Music",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Music software",
	 "https://d1.music.126.net/dmusic",
	 "cloudmusicsetup2.7.5.198554",
	 "exe",
	 "cloudmusicsetup*",
	 "/S",
	 ""),
	("QQ music",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Music software",
	 "https://dldir1.qq.com/music/clntupate",
	 "QQMusicSetup",
	 "exe",
	 "QQMusicSetup",
	 "",
	 ""),
	("Thunder 11",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Download tool",
	 "https://down.sandai.net/thunder11",
	 "XunLeiWebSetup11.1.8.1418gw",
	 "exe",
	 "XunLeiWebSetup11*",
	 "/S",
	 ""),
	("Tencent QQ",
	 [Status]::Enable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Social application",
	 "https://down.qq.com/qqweb/PCQQ/PCQQ_EXE",
	 "PCQQ2021",
	 "exe",
	 "PCQQ2021",
	 "/S",
	 ""),
	("WeChat",
	 [Status]::Enable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Social application",
	 "https://dldir1.qq.com/weixin/Windows",
	 "WeChatSetup",
	 "exe",
	 "WeChatSetup",
	 "/S",
	 ""),
	("Tencent Video",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Online TV",
	 "https://dldir1.qq.com/qqtv",
	 "TencentVideo11.14.4043.0",
	 "exe",
	 "TencentVideo*",
	 "/S",
	 ""),
	("iQiyi video",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Online TV",
	 "https://dl-static.iqiyi.com/hz",
	 "IQIYIsetup_z43",
	 "exe",
	 "IQIYIsetup*",
	 "/S",
	 "")
)
# Finally, please don't put , at the end, otherwise you will understand.

Enum Status
{
	Enable
	Disable
}

Enum Mode
{
	Wait    # Wait for completion
	Fast    # Run directly
	Queue   # Queue
}

Enum Action
{
	Install # installation
	NoInst  # Do not install after download
	To      # Download the compressed package to the directory
	Unzip   # Only unzip after downloading
}

function SetFreeDisk
{
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\Yi\Install" -Name "DiskTo" -ErrorAction SilentlyContinue) {
		$GetDiskTo = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Yi\Install" -Name "DiskTo"
		if (TestAvailableDisk -Path $GetDiskTo)	{
			$global:FreeDiskTo = $GetDiskTo
			return
		}
	}

	$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { -not ("$($env:SystemDrive)\" -eq $_.Root) } | Select-Object -ExpandProperty 'Root'
	foreach ($drive in $drives) {
		if (TestAvailableDisk -Path $drive)	{
			SetNewFreeDisk -value $drive
			return
		}
	}

	SetNewFreeDisk -value "$($env:SystemDrive)\"
}

Function SetNewFreeDisk ($value)
{
	$FullPath = "HKCU:\SOFTWARE\Yi\Install"

	if (!(Test-Path $FullPath)) {
		New-Item -Path $FullPath -Force -ErrorAction SilentlyContinue | Out-Null
	}
	New-ItemProperty -LiteralPath $FullPath -Name "DiskTo" -Value $value -PropertyType String -Force -ea SilentlyContinue | Out-Null

	$global:FreeDiskTo = $value
}

Function SetFreeDiskGUI
{
	SetFreeDisk
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	[System.Windows.Forms.Application]::EnableVisualStyles()

	$Canel_Click = {
		$FormSelectDiSK.Close()
	}
	$OK_Click = {
		$FormSelectDiSKPane1.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.RadioButton]) {
				if ($_.Checked) {
					$FormSelectDiSK.Hide()
					SetNewFreeDisk -value $_.Text
					$FormSelectDiSK.Close()
				}
			}
		}
	}
	$FormSelectDiSK    = New-Object system.Windows.Forms.Form -Property @{
		autoScaleMode  = 2
		Height         = 568
		Width          = 450
		Text           = "Change automatic disk selection"
		TopMost        = $True
		MaximizeBox    = $False
		StartPosition  = "CenterScreen"
		MinimizeBox    = $false
		BackColor      = "#ffffff"
	}
	$FormSelectDiSKPane1 = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 468
		Width          = 490
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $true
		Padding        = 8
		Dock           = 1
	}
	$Start             = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "266,482"
		Height         = 36
		Width          = 75
		add_Click      = $OK_Click
		Text           = "OK"
	}
	$Canel             = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "345,482"
		Height         = 36
		Width          = 75
		add_Click      = $Canel_Click
		Text           = "Cancel"
	}
	$FormSelectDiSK.controls.AddRange((
		$FormSelectDiSKPane1,
		$Start,
		$Canel
	))

	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\Yi\Install" -Name "DiskTo" -ErrorAction SilentlyContinue) {
		$GetDiskTo = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Yi\Install" -Name "DiskTo"
		if (TestAvailableDisk -Path $GetDiskTo)	{
			$btnboot   = New-Object System.Windows.Forms.RadioButton -Property @{
				Height = 30
				Width  = 405
				Text   = $GetDiskTo
				Checked = $True
			}
			$FormSelectDiSKPane1.controls.AddRange($btnboot)
		}
	}

	$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { -not ($global:FreeDiskTo -eq $_.Root) } | Select-Object -ExpandProperty 'Root'
	foreach ($drive in $drives) {
		if (TestAvailableDisk -Path $drive)	{
			$btnboot   = New-Object System.Windows.Forms.RadioButton -Property @{
				Height = 30
				Width  = 405
				Text   = $drive
			}
			$FormSelectDiSKPane1.controls.AddRange($btnboot)
		}
	}

	$FormSelectDiSK.FormBorderStyle = 'Fixed3D'
	$FormSelectDiSK.ShowDialog() | Out-Null
}

function TestAvailableDisk
{
	param
	(
		[string]$Path
	)

	$test_tmp_filename = "writetest-"+[guid]::NewGuid()
	$test_filename = Join-Path -Path "$($Path)" -ChildPath "$($test_tmp_filename)" -ErrorAction SilentlyContinue

	try
	{
		[io.file]::OpenWrite($test_filename).close()

		if ((Test-Path -Path $test_filename))
		{
			Remove-Item $test_filename -ErrorAction SilentlyContinue
			return $true
		}
		$false
	}
	catch
	{
		return $false
	}
}

function TestURI
{
	Param
	(
		[Parameter(Position=0,Mandatory,HelpMessage="HTTP or HTTPS")]
		[ValidatePattern( "^(http|https)://" )]
		[Alias("url")]
		[string]$URI,
		[Parameter(ParameterSetName="Detail")]
		[Switch]$Detail,
		[ValidateScript({$_ -ge 0})]
		[int]$Timeout = 30
	)
	Process
	{
		Try
		{
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
				$test.BaseResponse | Select-Object ResponseURI,ContentLength,ContentType,LastModified, @{Name="Status";Expression={$Test.StatusCode}}
			} else {
				if ($test.statuscode -ne 200) { $False } else { $True }
			}
		}
		Catch
		{
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

function CheckCatalog
{
	Param
	(
		[string]$chkpath
	)

	if (!(Test-Path $chkpath -PathType Container))
	{
		New-Item -Path $chkpath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
		if (!(Test-Path $chkpath -PathType Container)) {
			Write-Host "    - Failed to create directory: $($chkpath)`n" -ForegroundColor Red
			return
		}
	}
}

function JoinUrl
{
	param
	(
		[parameter(Mandatory=$True, HelpMessage="Base Path")]
		[ValidateNotNullOrEmpty()]
		[string] $Path,
		[parameter(Mandatory=$True, HelpMessage="Child Path or Item Name")]
		[ValidateNotNullOrEmpty()]
		[string] $ChildPath
	)
	if ($Path.EndsWith('/'))
	{
		return "$Path"+"$ChildPath"
	} else {
		return "$Path/$ChildPath"
	}
}

function StartInstallSoftware
{
	param
	(
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
		$param,
		$method
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

	Switch ($todisk)
	{
		auto
		{
			$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { -not ("$($env:SystemDrive)\" -eq $_.Root) } | Select-Object -ExpandProperty 'Root'
			foreach ($drive in $drives) {
				$tempoutputfoldoer = Join-Path -Path $($drive) -ChildPath "$($structure)"
				Get-ChildItem -Path $tempoutputfoldoer -File -Filter "*$($filename)*$((Get-Culture).Name)*" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
					$OutTo = Join-Path -Path "$($drive)" -ChildPath "$($structure)"
					$OutAny = $($_.fullname)
					break
				}
				Get-ChildItem -Path $tempoutputfoldoer -File -Filter "*$($filename)*" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
					$OutTo = Join-Path -Path "$($drive)" -ChildPath "$($structure)"
					$OutAny = $($_.fullname)
					break
				}
				Get-ChildItem -Path $tempoutputfoldoer -File -Filter "*$($packer)*" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
					$OutTo = Join-Path -Path "$($drive)" -ChildPath "$($structure)"
					$OutAny = $($_.fullname)
					break
				}
				SetFreeDisk
				$OutTo = Join-Path -Path $global:FreeDiskTo -ChildPath "$($structure)"
				$OutAny = Join-Path -Path $global:FreeDiskTo -ChildPath "$($structure)\$($packer).$($types)"
			}
		}
		default
		{
			$OutTo = Join-Path -Path $($todisk) -ChildPath "$($structure)"
			$OutAny = Join-Path -Path $($todisk) -ChildPath "$($structure)\$($packer).$($types)"
			Get-ChildItem -Path $OutTo -File -Filter "*$($filename)*$((Get-Culture).Name)*" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
				$OutAny = $($_.fullname)
				break
			}
			Get-ChildItem -Path $OutTo -File -Filter "*$($filename)*" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
				$OutAny = $($_.fullname)
				break
			}
		}
	}

	Switch ($types)
	{
		zip
		{
			Switch ($act)
			{
				Install
				{
					Get-ChildItem -Path $OutTo -File -Filter "*$($filename)*$((Get-Culture).Name)*.exe" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
						Write-Host "    - Locally exist: $($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode -method $method
						break
					}
					Get-ChildItem -Path $OutTo -File -Filter "*$($filename)*.exe" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
						Write-Host "    - Locally exist: $($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode -method $method
						break
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - Existing installation package"
					} else {
						Write-Host "    * Start download`n      > Connected to:`n        $url`n      + Save to:`n        $OutAny"
						CheckCatalog -chkpath $OutTo
						Invoke-WebRequest -Uri $url -OutFile "$($OutAny)" -ErrorAction SilentlyContinue | Out-Null
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - Unpacking"
						Archive -filename $OutAny -to $OutTo
						Write-Host "    - Unzip complete"
						if ((Test-Path $OutAny)) { remove-item -path $OutAny -force }
					} else {
						Write-Host "    - An error occurred during download`n" -ForegroundColor Red
					}
					Get-ChildItem -Path $OutTo -File -Filter "*$($filename)*$((Get-Culture).Name)*.exe" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
						Write-Host "    - Locally exist: $($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode -method $method
						break
					}
					Get-ChildItem -Path $OutTo -File -Filter "*$($filename)*.exe" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
						Write-Host "    - Locally exist: $($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode -method $method
						break
					}
				}
				NoInst
				{
					if (Test-Path -Path $OutAny) {
						Write-Host "    - Installed`n"
					} else {
						Write-Host "    * Start download`n      > Connected to:`n        $url`n      + Save to:`n        $OutAny"
						CheckCatalog -chkpath $OutTo
						Invoke-WebRequest -Uri $url -OutFile "$($OutAny)" -ErrorAction SilentlyContinue | Out-Null
					}
				}
				To
				{
					$newoutputfoldoer = "$($OutTo)\$($packer)"
					if (Test-Path $newoutputfoldoer -PathType Container) {
						Write-Host "    - Installed`n"
						break
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - Compressed package available"
					} else {
						Write-Host "    * Start download`n      > Connected to:`n        $url`n      + Save to:`n        $OutAny"
						Invoke-WebRequest -Uri $url -OutFile $OutAny -ErrorAction SilentlyContinue | Out-Null
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - Unzip only"
						Archive -filename $OutAny -to $newoutputfoldoer
						Write-Host "    - Unzip complete`n"
						if ((Test-Path $OutAny)) { remove-item -path $OutAny -force }
					} else {
						Write-Host "    - An error occurred during download`n" -ForegroundColor Red
					}
				}
				Unzip
				{
					if (Test-Path -Path $OutAny) {
						Write-Host "    - Existing installation package"
					} else {
						Write-Host "    * Start download`n      > Connected to:`n        $url`n      + Save to:`n        $OutAny"
						CheckCatalog -chkpath $OutTo
						Invoke-WebRequest -Uri $url -OutFile $OutAny -ErrorAction SilentlyContinue | Out-Null
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - Unzip only"
						Archive -filename $OutAny -to $OutTo
						Write-Host "    - Unzip complete`n"
						if ((Test-Path $OutAny)) { remove-item -path $OutAny -force }
					} else {
						Write-Host "    - An error occurred during download`n" -ForegroundColor Red
					}
				}
			}
		}
		default
		{
			if ((Test-Path $OutAny -PathType Leaf))
			{
				OpenApp -filename $OutAny -param $param -mode $mode -method $method
			} else {
				Write-Host "    * Start download`n      > Connected to:`n        $url"
				if (TestURI $url) {
					Write-Host "      + Save to:`n        $OutAny"
					CheckCatalog -chkpath $OutTo
					Invoke-WebRequest -Uri $url -OutFile $OutAny -ErrorAction SilentlyContinue | Out-Null
					OpenApp -filename $OutAny -param $param -mode $mode -method $method
				} else {
					Write-Host "      - Status: Not available`n" -ForegroundColor Red
				}
			}
		}
	}
}

function Archive
{
	param
	(
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

function Compressing
{
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

function WaitEnd
{
	Write-Host "   Waiting for the queue" -ForegroundColor Green
	foreach ($nq in $Global:AppQueue) {
		Write-Host "    * PID: $nq" -ForegroundColor Red
		wait-process -id $nq -ErrorAction SilentlyContinue
		Write-Host "    - Completed`n"
	}
	$Global:AppQueue.Clear()
}

function OpenApp
{
	param
	(
		$filename,
		$param,
		$mode,
		$method
	)

	$Select = $method -split ":"
	switch ($Select[0])
	{
		1
		{
			$TestCfg = "$(Split-Path $filename)\$($Select[1]).$($Select[2])"
			$TestDefault = "$(Split-Path $filename)\$($Select[1]).default.$($Select[2])"
			$TestLanguage = "$(Split-Path $filename)\$($Select[1]).$((Get-Culture).Name).$($Select[2])"
			if (Test-Path $TestCfg -PathType Leaf){
				break
			} else {
				if (Test-Path $TestLanguage -PathType Leaf){
					Copy-Item -Path $TestLanguage -Destination $TestCfg -ErrorAction SilentlyContinue
				} else {
					if (Test-Path $TestDefault -PathType Leaf){
						Copy-Item -Path $TestDefault -Destination $TestCfg -ErrorAction SilentlyContinue
					}
				}
			}
		}
		default
		{
		}
	}

	if ((Test-Path $filename -PathType Leaf))
	{
		Switch ($mode)
		{
			Fast
			{
				if (([string]::IsNullOrEmpty($param)))
				{
					Write-Host "    - Fast running:`n      $filename`n"
					Start-Process -FilePath $filename
				} else {
					Write-Host "    - Fast running:`n      $filename`n    - parameter:`n      $param`n"
					Start-Process -FilePath $filename -ArgumentList $param
				}
			}
			Wait
			{
				if (([string]::IsNullOrEmpty($param)))
				{
					Write-Host "    - Wait for completion:`n      $filename`n"
					Start-Process -FilePath $filename -Wait
				} else {
					Write-Host "    - Wait for completion:`n      $filename`n    - parameter:`n      $param`n"
					Start-Process -FilePath $filename -ArgumentList $param -Wait
				}
			}
			Queue
			{
				Write-Host "    - Fast running:`n      $filename"
				if (([string]::IsNullOrEmpty($param)))
				{
					$AppRunQueue = Start-Process -FilePath $filename -passthru
					$Global:AppQueue += $AppRunQueue.Id
					Write-Host "    - Add queue: $($AppRunQueue.Id)`n"
				} else {
					$AppRunQueue = Start-Process -FilePath $filename -ArgumentList $param -passthru
					$Global:AppQueue += $AppRunQueue.Id
					Write-Host "    - parameter:`n      $param"
					Write-Host "    - Add queue: $($AppRunQueue.Id)`n"
				}
			}
		}
	} else {
		Write-Host "    - No installation files were found,`n      please check the integrity: $filename`n" -ForegroundColor Red
	}
}

function ToMainpage
{
	param
	(
		[int]$wait
	)
	Write-Host "`n   The installation script will automatically exit after $wait seconds." -ForegroundColor Red
	Start-Sleep -s $wait
	exit
}

function ObtainAndInstall
{
	Write-Host "`n   INSTALLING SOFTWARE"
	Write-Host "   ---------------------------------------------------"
	for ($i=0; $i -lt $app.Count; $i++) {
		StartInstallSoftware -appname $app[$i][0] -status $app[$i][1] -act $app[$i][2] -mode $app[$i][3] -todisk $app[$i][4] -structure $app[$i][5] -url $app[$i][6] -packer $app[$i][7] -types $app[$i][8] -filename $app[$i][9] -param $app[$i][10] -method $app[$i][11]
	}
}

function InstallGUI
{
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	[System.Windows.Forms.Application]::EnableVisualStyles()

	$AllSel_Click = {
		$Pane1.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]){ $_.Checked = $true }
		}
	}
	$AllClear_Click = {
		$Pane1.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]){ $_.Checked = $false }
		}
	}
	$Canel_Click = {
		$Install.Hide()
		Write-Host "   The user has cancelled the installation." -ForegroundColor Red
		$Install.Close()
	}
	$OK_Click = {
		$Install.Hide()
		Initialization
		$Pane1.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]) {
				if ($_.Checked) {
					StartInstallSoftware -appname $app[$_.Tag][0] -status "Enable" -act $app[$_.Tag][2] -mode $app[$_.Tag][3] -todisk $app[$_.Tag][4] -structure $app[$_.Tag][5] -url $app[$_.Tag][6] -packer $app[$_.Tag][7] -types $app[$_.Tag][8] -filename $app[$_.Tag][9] -param $app[$_.Tag][10] -method $app[$_.Tag][11]
				}
			}
		}
		WaitEnd
		ProcessOther
		$Install.Close()
	}
	$Install            = New-Object system.Windows.Forms.Form -Property @{
		autoScaleMode  = 2
		Height         = 568
		Width          = 450
		Text           = "INSTALLED SOFTWARE LIST ( total $($app.Count) items )"
		TopMost        = $True
		MaximizeBox    = $False
		StartPosition  = "CenterScreen"
		MinimizeBox    = $false
		BackColor      = "#ffffff"
	}
	$Pane1             = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 468
		Width          = 490
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $true
		Padding        = 8
		Dock           = 1
	}
	$AllSel            = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = New-Object System.Drawing.Point(10,482)
		Height         = 36
		Width          = 75
		add_Click      = $AllSel_Click
		Text           = "Select all"
	}
	$AllClear          = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = New-Object System.Drawing.Point(88,482)
		Height         = 36
		Width          = 75
		add_Click      = $AllClear_Click
		Text           = "Clear all"
	}
	$Setting           = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = New-Object System.Drawing.Point(187,482)
		Height         = 36
		Width          = 75
		add_Click      = { SetFreeDiskGUI }
		Text           = "Set up"
	}
	$Start             = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = New-Object System.Drawing.Point(266,482)
		Height         = 36
		Width          = 75
		add_Click      = $OK_Click
		Text           = "OK"
	}
	$Canel             = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = New-Object System.Drawing.Point(345,482)
		Height         = 36
		Width          = 75
		add_Click      = $Canel_Click
		Text           = "Cancel"
	}

	for ($i=0; $i -lt $app.Count; $i++)
	{
		$CheckBox  = New-Object System.Windows.Forms.CheckBox -Property @{
			Height = 30
			Width  = 405
			Text   = $app[$i][0]
			Tag    = $i
		}

		if ($app[$i][1] -like "Enable") {
			$CheckBox.Checked = $true
		} else {
			$CheckBox.Checked = $false
		}
		$Pane1.controls.AddRange($CheckBox)		
	}

	$Install.controls.AddRange((
		$Pane1,
		$AllSel,
		$AllClear,
		$Setting,
		$Start,
		$Canel
	))
	$Install.FormBorderStyle = 'Fixed3D'
	$Install.ShowDialog() | Out-Null
}

function ShowList
{
	for ($i=0; $i -lt $app.Count; $i++)
	{
		Switch ($app[$i][1])
		{
			Enable
			{
				Write-Host "   WAIT INSTALL - $($app[$i][0])" -ForegroundColor Green
			}
			Disable
			{
				Write-Host "   SKIP INSTALL - $($app[$i][0])" -ForegroundColor Red
			}
		}
	}
}

function Mainpage
{
	Clear-Host
	Write-Host "`n   Author: Yi ( http://fengyi.tel )

   From: Yi's Solutions
   buildstring: 6.1.0.1.bs_release.210226-1208

   INSTALLED SOFTWARE LIST ( total $($app.Count) items )
   ---------------------------------------------------"
}

$GroupCleanRun = @(
	"Wechat"
	"HCDNClient"
	"qqlive"
	"cloudmusic"
	"QQMusic"
	"Thunder"
)

function CleanRun {
	Write-Host "   - Delete startup items"
	foreach ($nsf in $GroupCleanRun) {
		Remove-ItemProperty -Name $nsf -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue | Out-Null
	}
}

function ProcessOther
{
	Write-Host "`n   Processing other:" -ForegroundColor Green

	CleanRun

	Write-Host "   - Disable scheduled tasks"
	Disable-ScheduledTask -TaskName GoogleUpdateTaskMachineCore -ErrorAction SilentlyContinue | Out-Null
	Disable-ScheduledTask -TaskName GoogleUpdateTaskMachineUA -ErrorAction SilentlyContinue | Out-Null

	Write-Host "   - Delete redundant shortcuts"
	Set-Location "$env:public\Desktop"
	Remove-Item ".\Kleopatra.lnk" -Force -ErrorAction SilentlyContinue | Out-Null

	Write-Host "   - Rename"
	#Rename-Item-NewName "Google Chrome.lnk"  -Path ".\New Google Chrome.lnk" -ErrorAction SilentlyContinue | Out-Null
}

function initialization
{
}

Mainpage

If ($Force) {
	ShowList
	Initialization
	ObtainAndInstall
	WaitEnd
	ProcessOther
} else {
	InstallGUI
	if ($Silent) {
		exit
	} else {
		ToMainpage -wait 2
	}
}
