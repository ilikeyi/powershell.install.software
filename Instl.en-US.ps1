<#

  PowerShell installation software

  . THE MAIN FUNCTION
    1. The installation package does not exist locally, and the download function is activated;
    2. The default automatic download drive letter and priority download connection address can be modified by setting;
	   The system type is automatically judged, and the download connection is automatically selected in order, and so on.
    3. The drive letter can be specified, and the current system drive will be excluded after setting automatic.
       When no available disk is found, the default setting is the current system disk;
    4. Search file name supports fuzzy search, wildcard *;
    5. Queue, add to the queue after running the installer, and wait for the end;
    6. Search sequentially according to the preset structure:
       * Original download address: https://fengyi.tel/Instl.Packer.Latest.exe
         + Fuzzy file name: Instl.Packer*
           - Condition 1: System language: en-US, search condition: Instl.Packer*en-US*
           - Condition 2: Search for fuzzy file name: Instl.Packer*
           - Condition 3: Search the website to download the original file name: Instl.Packer.Latest
    7. Dynamic function: add pre-run and post-run processing, go to function OpenApp {} to change the module;
    8. Support decompression package processing, etc.

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

#>

#Requires -version 5.1

# Get script parameters ( if any )
[CmdletBinding()]
param
(
	[Switch]$Force,
	[Switch]$Silent
)

$Global:UniqueID  = "Yi"
$Global:AuthorURL = "https://fengyi.tel"
$Global:AppQueue = @()

$Host.UI.RawUI.WindowTitle = "Installation software"

# All software configurations
$app = @(
	("$($Global:UniqueID)'s Personalized theme pack",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Fast,
	 "auto",
	 "Installation package\Theme pack",
	 "$($Global:AuthorURL)/$($Global:UniqueID).deskthemepack",
	 "",
	 "",
	 "$($Global:UniqueID)*",
	 "",
	 ""),
	("Nvidia GEFORCE GAME READY DRIVER",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Device Driver\Graphics card",
	 "",
	 "https://us.download.nvidia.cn/Windows/461.92/461.92-desktop-win10-64bit-international-dch-whql.exe",
	 "",
	 "*-desktop-win10-*-international-dch-whql",
	 "-s -clean -noreboot -noeula",
	 ""),
	("Sysinternals Suite",
	 [Status]::Disable,
	 [Action]::To,
	 [Mode]::Fast,
	 $env:SystemDrive,
	 "",
	 "https://download.sysinternals.com/files/SysinternalsSuite.zip",
	 "",
	 "https://download.sysinternals.com/files/SysinternalsSuite-ARM64.zip",
	 "SysinternalsSuite",
	 "",
	 ""),
	("VisualCppRedist AIO",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\AIO",
	 "https://github.com/abbodi1406/vcredist/releases/download/v0.45.0/VisualCppRedist_AIO_x86_x64_45.zip",
	 "",
	 "",
	 "VisualCppRedist*",
	 "/y",
	 ""),
	("Gpg4win",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\AIO",
	 "https://files.gpg4win.org/gpg4win-latest.exe",
	 "",
	 "",
	 "gpg4win*",
	 "/S",
	 ""),
	("Python",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Develop software",
	 "https://www.python.org/ftp/python/3.9.2/python-3.9.2.exe",
	 "https://www.python.org/ftp/python/3.9.2/python-3.9.2-amd64.exe",
	 "",
	 "python-*",
	 "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0",
	 ""),
	("kugou music",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Music software",
	 "https://downmini.yun.kugou.com/web/kugou9229.exe",
	 "",
	 "",
	 "kugou*",
	 "/S",
	 ""),
	("NetEase Cloud Music",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Music software",
	 "https://d1.music.126.net/dmusic/cloudmusicsetup2.7.6.198710.exe",
	 "",
	 "",
	 "cloudmusicsetup*",
	 "/S",
	 ""),
	("QQ music",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Music software",
	 "https://dldir1.qq.com/music/clntupate/QQMusic_YQQWinPCDL.exe",
	 "",
	 "",
	 "QQMusicSetup",
	 "",
	 ""),
	("Thunder 11",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Download tool",
	 "https://down.sandai.net/thunder11/XunLeiWebSetup11.1.10.1598gw.exe",
	 "",
	 "",
	 "XunLeiWebSetup11*",
	 "/S",
	 ""),
	("Tencent QQ",
	 [Status]::Enable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Social application",
	 "https://down.qq.com/qqweb/PCQQ/PCQQ_EXE/PCQQ2021.exe",
	 "",
	 "",
	 "PCQQ2021",
	 "/S",
	 ""),
	("WeChat",
	 [Status]::Enable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Social application",
	 "https://dldir1.qq.com/weixin/Windows/WeChatSetup.exe",
	 "",
	 "",
	 "WeChatSetup",
	 "/S",
	 ""),
	("Tencent Video",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Online TV",
	 "https://dldir1.qq.com/qqtv/TencentVideo11.17.7063.0.exe",
	 "",
	 "",
	 "TencentVideo*",
	 "/S",
	 ""),
	("iQiyi video",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "Installation package\Online TV",
	 "https://dl-static.iqiyi.com/hz/IQIYIsetup_z40.exe",
	 "",
	 "",
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

function GetArchitecture
{
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$($Global:UniqueID)\Install" -Name "Architecture" -ErrorAction SilentlyContinue) {
		$Global:InstlArchitecture = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$($Global:UniqueID)\Install" -Name "Architecture"
		return
	}

	SetArchitecture -Type $env:PROCESSOR_ARCHITECTURE
}

Function SetArchitecture
{
	param
	(
		[string]$Type
	)

	$FullPath = "HKCU:\SOFTWARE\$($Global:UniqueID)\Install"

	if (-not (Test-Path $FullPath)) {
		New-Item -Path $FullPath -Force -ErrorAction SilentlyContinue | Out-Null
	}
	New-ItemProperty -LiteralPath $FullPath -Name "Architecture" -Value $Type -PropertyType String -Force -ea SilentlyContinue | Out-Null

	$Global:InstlArchitecture = $Type
}

function SetFreeDisk
{
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$($Global:UniqueID)\Install" -Name "DiskTo" -ErrorAction SilentlyContinue) {
		$GetDiskTo = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$($Global:UniqueID)\Install" -Name "DiskTo"
		if (TestAvailableDisk -Path $GetDiskTo)	{
			$Global:FreeDiskTo = $GetDiskTo
			return
		}
	}

	$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { -not ((JoinMainFolder -Path $env:SystemDrive) -eq $_.Root) } | Select-Object -ExpandProperty 'Root'
	foreach ($drive in $drives) {
		if (TestAvailableDisk -Path $drive)	{
			SetNewFreeDisk -Disk $drive
			return
		}
	}

	SetNewFreeDisk -Disk (JoinMainFolder -Path $env:SystemDrive)
}

Function SetNewFreeDisk
{
	param
	(
		[string]$Disk
	)

	$FullPath = "HKCU:\SOFTWARE\$($Global:UniqueID)\Install"

	if (-not (Test-Path $FullPath)) {
		New-Item -Path $FullPath -Force -ErrorAction SilentlyContinue | Out-Null
	}
	New-ItemProperty -LiteralPath $FullPath -Name "DiskTo" -Value $Disk -PropertyType String -Force -ea SilentlyContinue | Out-Null

	$Global:FreeDiskTo = $Disk
}

Function SetupGUI
{
	GetArchitecture
	SetFreeDisk

	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	[System.Windows.Forms.Application]::EnableVisualStyles()

	$Canel_Click = {
		$FormSelectDiSK.Close()
	}
	$OK_ArchitectureARM64_Click = {
		$SoftwareTipsErrorMsg.Text = "Prefer arm64 download address, select in order: x64, x86."
	}
	$OK_ArchitectureX64_Click = {
		$SoftwareTipsErrorMsg.Text = "Prefer the x64 download address, and select in order: x86."
	}
	$OK_ArchitectureX86_Click = {
		$SoftwareTipsErrorMsg.Text = "Only select the x86 download address."
	}
	$OK_Click = {
		$FormSelectDiSK.Hide()
		if ($ArchitectureARM64.Checked) { SetArchitecture -Type "ARM64" }
		if ($ArchitectureX64.Checked) { SetArchitecture -Type "AMD64" }
		if ($ArchitectureX86.Checked) { SetArchitecture -Type "x86" }

		$FormSelectDiSKPane1.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.RadioButton]) {
				if ($_.Checked) {
					SetNewFreeDisk -Disk $_.Text
				}
			}
		}
		$FormSelectDiSK.Close()
	}
	$FormSelectDiSK    = New-Object system.Windows.Forms.Form -Property @{
		autoScaleMode  = 2
		Height         = 568
		Width          = 450
		Text           = "Set up"
		TopMost        = $True
		MaximizeBox    = $False
		StartPosition  = "CenterScreen"
		MinimizeBox    = $false
		BackColor      = "#ffffff"
	}
	$ArchitectureTitle = New-Object System.Windows.Forms.Label -Property @{
		Height         = 22
		Width          = 380
		Text           = "Preferred download address"
		Location       = '10,10'
	}
	$GroupArchitecture = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 28
		Width          = 400
		autoSizeMode   = 1
		Padding        = 8
		Location       = '10,35'
	}
	$ArchitectureARM64 = New-Object System.Windows.Forms.RadioButton -Property @{
		Height         = 22
		Width          = 60
		Text           = "arm64"
		Location       = '10,0'
		add_Click      = $OK_ArchitectureARM64_Click
	}
	$ArchitectureX64    = New-Object System.Windows.Forms.RadioButton -Property @{
		Height         = 22
		Width          = 60
		Text           = "x64"
		Location       = '80,0'
		add_Click      = $OK_ArchitectureX64_Click
	}
	$ArchitectureX86    = New-Object System.Windows.Forms.RadioButton -Property @{
		Height         = 22
		Width          = 60
		Text           = "x86"
		Location       = '140,0'
		add_Click      = $OK_ArchitectureX86_Click
	}
	$SoftwareTips      = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 50
		Width          = 392
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $False
		Padding        = 0
		Dock           = 0
		Location       = '18,68'
	}
	$SoftwareTipsErrorMsg = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		Text           = ""
	}
	$FormSelectDiSKTitle = New-Object System.Windows.Forms.Label -Property @{
		Height         = 22
		Width          = 360
		Text           = "Select auto download drive letter"
		Location       = '10,130'
	}
	$FormSelectDiSKPane1 = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 300
		Width          = 400
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $true
		Padding        = 4
		Dock           = 0
		Location       = '10,150'
	}
	$Start             = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "10,482"
		Height         = 36
		Width          = 202
		add_Click      = $OK_Click
		Text           = "OK"
	}
	$Canel             = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "218,482"
		Height         = 36
		Width          = 202
		add_Click      = $Canel_Click
		Text           = "Cancel"
	}
	$FormSelectDiSK.controls.AddRange((
		$ArchitectureTitle,
		$GroupArchitecture,
		$SoftwareTips,
		$FormSelectDiSKTitle,
		$FormSelectDiSKPane1,
		$Start,
		$Canel
	))
	$SoftwareTips.controls.AddRange((
		$SoftwareTipsErrorMsg
	))
	$GroupArchitecture.controls.AddRange((
		$ArchitectureARM64,
		$ArchitectureX64,
		$ArchitectureX86
	))

	switch ($Global:InstlArchitecture) {
		"ARM64" {
			$ArchitectureARM64.Checked = $True
		}
		"AMD64" {
			if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
				$ArchitectureARM64.Enabled = $True
			} else {
				$ArchitectureARM64.Enabled = $False
			}

			$ArchitectureX64.Checked = $True
		}
		Default {
			if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
				$ArchitectureARM64.Enabled = $True
			} else {
				$ArchitectureARM64.Enabled = $False
			}
			
			if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
				$ArchitectureX64.Enabled = $True
			} else {
				$ArchitectureX64.Enabled = $False
			}

			$ArchitectureX86.Checked = $True
		}
	}

	$drives = Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty 'Root'
	foreach ($drive in $drives) {
		if (TestAvailableDisk -Path $drive)	{
			$RadioButton   = New-Object System.Windows.Forms.RadioButton -Property @{
				Height = 26
				Width  = 390
				Text   = $drive
			}

			$FormSelectDiSKPane1.controls.AddRange($RadioButton)
		}
	}

	$GetDiskTo = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$($Global:UniqueID)\Install" -Name "DiskTo"
	if (TestAvailableDisk -Path $GetDiskTo)	{
		$FormSelectDiSKPane1.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.RadioButton]) {
				if ($_.Text -like $GetDiskTo) {
					$_.Checked = $True
				}
			}
		}
	} else {
		$FormSelectDiSKPane1.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.RadioButton]) {
				if ($_.Text -like (JoinMainFolder -Path $env:SystemDrive)) {
					$_.Checked = $True
				}
			}
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

	if (-not (Test-Path $chkpath -PathType Container))
	{
		New-Item -Path $chkpath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
		if (-not (Test-Path $chkpath -PathType Container)) {
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
		[string]$Path,
		[parameter(Mandatory=$True, HelpMessage="Child Path or Item Name")]
		[ValidateNotNullOrEmpty()]
		[string]$ChildPath
	)
	if ($Path.EndsWith('/'))
	{
		return "$Path"+"$ChildPath"
	} else {
		return "$Path/$ChildPath"
	}
}

Function JoinMainFolder
{
	param
	(
		[string]$Path
	)
	if ($Path.EndsWith('\'))
	{
		return "$Path"
	} else {
		return "$Path\"
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
		$urlx64,
		$urlarm64,
		$filename,
		$param,
		$method
	)

	GetArchitecture
	SetFreeDisk

	Switch ($status)
	{
		Enable
		{
			Write-Host "   Installing   - $($appname)" -ForegroundColor Green
		}
		Disable
		{
			Write-Host "   Skip install - $($appname)" -ForegroundColor Red
			return
		}
	}

	switch ($Global:InstlArchitecture) {
		"arm64" {
			if ([string]::IsNullOrEmpty($urlarm64)) {
				if ([string]::IsNullOrEmpty($urlx64)) {
					if ([string]::IsNullOrEmpty($url)) {
						$FilenameTo = $urlx64
					} else {
						$url = $url
						$FilenameTo = $url
					}
				} else {
					$url = $urlx64
					$FilenameTo = $urlx64
				}
			} else {
				$url = $urlarm64
				$FilenameTo = $urlarm64
			}
		}
		"AMD64" {
			if ($Global:InstlArchitecture -eq "AMD64") {
				if ([string]::IsNullOrEmpty($urlx64)) {
					if ([string]::IsNullOrEmpty($url)) {
						$FilenameTo = $urlx64
					} else {
						$url = $url
						$FilenameTo = $url
					}
				} else {
					$url = $urlx64
					$FilenameTo = $urlx64
				}
			}
		}
		Default {
			if ($Global:InstlArchitecture -eq "x86") {
				if ([string]::IsNullOrEmpty($url)) {
					$FilenameTo = $urlx64
				} else {
					$url = $url
					$FilenameTo = $url
				}
			}
		}
	}

	$SaveToName = [IO.Path]::GetFileName($FilenameTo)
	$packer = [IO.Path]::GetFileNameWithoutExtension($FilenameTo)
	$types =  [IO.Path]::GetExtension($FilenameTo).Replace(".", "")

	Switch ($todisk)
	{
		auto
		{
			$drives = Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty 'Root'
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
				$OutTo = Join-Path -Path $Global:FreeDiskTo -ChildPath "$($structure)"
				$OutAny = Join-Path -Path $Global:FreeDiskTo -ChildPath "$($structure)\$SaveToName"
			}
		}
		default
		{
			$OutTo = Join-Path -Path $($todisk) -ChildPath "$($structure)"
			$OutAny = Join-Path -Path $($todisk) -ChildPath "$($structure)\$SaveToName"
			Get-ChildItem -Path $OutTo -File -Filter "*$($filename)*$((Get-Culture).Name)*" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
				$OutAny = $($_.fullname)
				break
			}
			Get-ChildItem -Path $OutTo -File -Filter "*$($filename)*" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
				$OutAny = $($_.fullname)
				break
			}
			Get-ChildItem -Path $OutTo -File -Filter "*$($packer)*" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
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
					Get-ChildItem -Path $OutTo -File -Filter "*$($packer)*.exe" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
						Write-Host "   - $($lang.LocallyExist)`n     $($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode -method $method
						break
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - Existing installation package"
					} else {
						Write-Host "    * Start download"
						if ([string]::IsNullOrEmpty($url)) {
							Write-Host "    - The download address is invalid. " -ForegroundColor Red
						} else {
							if (TestURI $url) {
								Write-Host "      > Connected to:`n        $url`n      + Save to:`n        $OutAny"
								CheckCatalog -chkpath $OutTo
								Invoke-WebRequest -Uri $url -OutFile "$($OutAny)" -ErrorAction SilentlyContinue | Out-Null
							} else {
								Write-Host "      - Status: unavailable" -ForegroundColor Red
							}
						}
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - Unpacking"
						Archive -filename $OutAny -to $OutTo
						Write-Host "    - Decompression is complete"
						Remove-Item -path $OutAny -force -ErrorAction SilentlyContinue
					} else {
						Write-Host "      - An error occurred during the download`n" -ForegroundColor Red
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
					Get-ChildItem -Path $OutTo -File -Filter "*$($packer)*.exe" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
						Write-Host "   - $($lang.LocallyExist)`n     $($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode -method $method
						break
					}
				}
				NoInst
				{
					if (Test-Path -Path $OutAny) {
						Write-Host "    - Installed`n"
					} else {
						Write-Host "    * Start download"
						if ([string]::IsNullOrEmpty($url)) {
							Write-Host "      - The download address is invalid." -ForegroundColor Red
						} else {
							if (TestURI $url) {
								Write-Host "      > Connected to:`n        $url`n      + Save to:`n        $OutAny"
								CheckCatalog -chkpath $OutTo
								Invoke-WebRequest -Uri $url -OutFile "$($OutAny)" -ErrorAction SilentlyContinue | Out-Null
							} else {
								Write-Host "      - Status: unavailable`n" -ForegroundColor Red
							}
						}
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
						Write-Host "    * Start download"
						if ([string]::IsNullOrEmpty($url)) {
							Write-Host "      - The download address is invalid. " -ForegroundColor Red
						} else {
							Write-Host "      > Connected to:`n        $url`n      + Save to:`n        $OutAny"
							Invoke-WebRequest -Uri $url -OutFile $OutAny -ErrorAction SilentlyContinue | Out-Null
						}
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - Unzip only"
						Archive -filename $OutAny -to $newoutputfoldoer
						Write-Host "    - Unzip complete`n"
						Remove-Item -path $OutAny -force -ErrorAction SilentlyContinue
					} else {
						Write-Host "      - An error occurred during the download`n" -ForegroundColor Red
					}
				}
				Unzip
				{
					if (Test-Path -Path $OutAny) {
						Write-Host "    - Existing installation package"
					} else {
						Write-Host "    * Start download"
						if ([string]::IsNullOrEmpty($url)) {
							Write-Host "      - The download address is invalid." -ForegroundColor Red
						} else {
							if (TestURI $url) {
								Write-Host "      > Connected to:`n        $url`n      + Save to:`n        $OutAny"
								CheckCatalog -chkpath $OutTo
								Invoke-WebRequest -Uri $url -OutFile $OutAny -ErrorAction SilentlyContinue | Out-Null
							} else {
								Write-Host "      - Status: unavailable`n" -ForegroundColor Red
							}
						}
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - Unzip only"
						Archive -filename $OutAny -to $OutTo
						Write-Host "    - Unzip complete`n"
						Remove-Item -path $OutAny -force -ErrorAction SilentlyContinue
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
				Write-Host "    * Start download"
				if ([string]::IsNullOrEmpty($url)) {
					Write-Host "      - The download address is invalid.`n" -ForegroundColor Red
				} else {
					Write-Host "      > Connected to:`n        $url"
					if (TestURI $url) {
						Write-Host "      + Save to:`n        $OutAny"
						CheckCatalog -chkpath $OutTo
						Invoke-WebRequest -Uri $url -OutFile $OutAny -ErrorAction SilentlyContinue | Out-Null
						OpenApp -filename $OutAny -param $param -mode $mode -method $method
					} else {
						Write-Host "      - Status: unavailable`n" -ForegroundColor Red
					}
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

	if (Test-Path "$env:SystemDrive\$($Global:UniqueID)\$($Global:UniqueID)\AIO\7z.exe") {
		$script:Zip = "$env:SystemDrive\$($Global:UniqueID)\$($Global:UniqueID)\AIO\7z.exe"
		return $true
	}
	return $false
}

function WaitEnd
{
	Write-Host "`n   Waiting for the queue" -ForegroundColor Green
	for ($i=0; $i -lt $Global:AppQueue.Count; $i++) {
		Write-Host "    * PID: $($Global:AppQueue[$i]['ID'])" -ForegroundColor Red
		if ((Get-Process -ID $($Global:AppQueue[$i]['ID']) -ErrorAction SilentlyContinue).Path -eq $Global:AppQueue[$i]['PATH']) {
			Wait-Process -id $($Global:AppQueue[$i]['ID']) -ErrorAction SilentlyContinue
		}
		Write-Host "    - Completed`n"
	}
	$Global:AppQueue = @()
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
				if ([string]::IsNullOrEmpty($param))
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
				if ([string]::IsNullOrEmpty($param))
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
				if ([string]::IsNullOrEmpty($param))
				{
					$AppRunQueue = Start-Process -FilePath $filename -passthru
					$Global:AppQueue += @{
						ID="$($AppRunQueue.Id)";
						PATH="$($filename)"
					}
					Write-Host "    - Add queue: $($AppRunQueue.Id)`n"
				} else {
					$AppRunQueue = Start-Process -FilePath $filename -ArgumentList $param -passthru
					$Global:AppQueue += @{
						ID="$($AppRunQueue.Id)";
						PATH="$($filename)"
					}
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
		StartInstallSoftware -appname $app[$i][0] -status $app[$i][1] -act $app[$i][2] -mode $app[$i][3] -todisk $app[$i][4] -structure $app[$i][5] -url $app[$i][6] -urlx64 $app[$i][7] -urlarm64 $app[$i][8] -filename $app[$i][9] -param $app[$i][10] -method $app[$i][11]
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
                    StartInstallSoftware -appname $app[$_.Tag][0] -status "Enable" -act $app[$_.Tag][2] -mode $app[$_.Tag][3] -todisk $app[$_.Tag][4] -structure $app[$_.Tag][5] -url $app[$_.Tag][6] -urlx64 $app[$_.Tag][7] -urlarm64 $app[$_.Tag][8] -filename $app[$_.Tag][9] -param $app[$_.Tag][10] -method $app[$_.Tag][11]
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
	$Setting           = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "10,482"
		Height         = 36
		Width          = 133
		add_Click      = { SetupGUI }
		Text           = "Set up"
	}
	$Start             = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "148,482"
		Height         = 36
		Width          = 133
		add_Click      = $OK_Click
		Text           = "OK"
	}
	$Canel             = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "286,482"
		Height         = 36
		Width          = 133
		add_Click      = $Canel_Click
		Text           = "Cancel"
	}

	for ($i=0; $i -lt $app.Count; $i++)
	{
		$CheckBox  = New-Object System.Windows.Forms.CheckBox -Property @{
			Height = 28
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

	$SelectMenu = New-Object System.Windows.Forms.ContextMenuStrip
	$SelectMenu.Items.Add("Select all").add_Click($AllSel_Click)
	$SelectMenu.Items.Add("Clear all").add_Click($AllClear_Click)
	$Install.ContextMenuStrip = $SelectMenu

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
	Write-Host "`n   Author: $($Global:UniqueID) ( $($Global:AuthorURL) )

   From: $($Global:UniqueID)'s Solutions
   buildstring: 6.1.0.4.bs_release.210226-1208

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
