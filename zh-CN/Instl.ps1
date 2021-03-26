<#

  警告：为防止更新后覆盖，请另存为后再修改。

  PowerShell 安装软件

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

  . 先决条件
    - PowerShell 5.1 或更高

  . 连接
    - https://github.com/ilikeyi/powershell.install.software
    - https://gitee.com/ilikeyi/powershell.install.software


  软件包配置教程

 软件包                                                    描述
("Windows Defender Control",                               软件包名称
 [Status]::Enable,                                         状态：Enable - 启用；Disable - 禁用
 [Action]::Install,                                        动作：Install - 安装；NoInst - 下载后不安装；Unzip - 下载后仅解压；To - 安装到目录
 [Mode]::Wait,                                             运行方式：Wait - 等待完成；Fast - 直接运行
 "auto",                                                   设置自动后将排除当前系统盘，搜索不到可用盘时，默认设置为当前系统盘；指定盘符 [A:]-[Z:]；指定路径：\\192.168.1.1
 "安装包\工具",                                            目录结构
 "https://www.sordum.org/files/download/defender-control", 网站地址
 "DefenderControl",                                        从网站下载的文件名
 "zip",                                                    从网站下载的文件类型：exe, zip 或自定义文件类型；结果：https://files.gpg4win.org/gpg4win-latest.exe
 "DefenderControl*",                                       文件名模糊查找（*）
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

#>

#Requires -version 5.1

# 获取脚本参数（如果有）
[CmdletBinding()]
param
(
	[parameter(Mandatory = $false, HelpMessage = "静默")]
	[Switch]$Force,
	[Switch]$Silent
)

$Global:AppQueue = @()
$Global:AppQueue.Clear()

$Host.UI.RawUI.WindowTitle = "PowerShell 安装软件"

# 所有软件配置
$app = @(
	("Yi's 个性主题包",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Fast,
	 "auto",
	 "安装包\主题包",
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
	 "安装包\驱动程序\显卡",
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
	 "安装包\AIO",
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
	 "安装包\AIO",
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
	 "安装包\开发软件",
	 "https://www.python.org/ftp/python/3.9.1",
	 "python-3.9.1-amd64",
	 "exe",
	 "python-*",
	 "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0",
	 ""),
	("酷狗音乐",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "安装包\音乐软件",
	 "https://downmini.yun.kugou.com/web",
	 "kugou9175",
	 "exe",
	 "kugou*",
	 "/S",
	 ""),
	("网易云音乐",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "安装包\音乐软件",
	 "https://d1.music.126.net/dmusic",
	 "cloudmusicsetup2.7.5.198554",
	 "exe",
	 "cloudmusicsetup*",
	 "/S",
	 ""),
	("QQ 音乐",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "安装包\音乐软件",
	 "https://dldir1.qq.com/music/clntupate",
	 "QQMusicSetup",
	 "exe",
	 "QQMusicSetup",
	 "",
	 ""),
	("迅雷 11",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "安装包\下载工具",
	 "https://down.sandai.net/thunder11",
	 "XunLeiWebSetup11.1.8.1418gw",
	 "exe",
	 "XunLeiWebSetup11*",
	 "/S",
	 ""),
	("腾讯 QQ",
	 [Status]::Enable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "安装包\社交软件",
	 "https://down.qq.com/qqweb/PCQQ/PCQQ_EXE",
	 "PCQQ2021",
	 "exe",
	 "PCQQ2021",
	 "/S",
	 ""),
	("微信",
	 [Status]::Enable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "安装包\社交软件",
	 "https://dldir1.qq.com/weixin/Windows",
	 "WeChatSetup",
	 "exe",
	 "WeChatSetup",
	 "/S",
	 ""),
	("腾讯视频",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "安装包\网络电视",
	 "https://dldir1.qq.com/qqtv",
	 "TencentVideo11.14.4043.0",
	 "exe",
	 "TencentVideo*",
	 "/S",
	 ""),
	("爱奇艺视频",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "安装包\网络电视",
	 "https://dl-static.iqiyi.com/hz",
	 "IQIYIsetup_z43",
	 "exe",
	 "IQIYIsetup*",
	 "/S",
	 "")
)
# 最后 ) 结尾请勿带 , 号，否则你懂的。

Enum Status
{
	Enable
	Disable
}

Enum Mode
{
	Wait    # 等待完成
	Fast    # 直接运行
	Queue   # 队列
}

Enum Action
{
	Install # 安装
	NoInst  # 下载后不安装
	To      # 下载压缩包到目录
	Unzip   # 下载后仅解压
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

	$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { -not ((JoinMainFolder -Path $env:SystemDrive) -eq $_.Root) } | Select-Object -ExpandProperty 'Root'
	foreach ($drive in $drives) {
		if (TestAvailableDisk -Path $drive)	{
			SetNewFreeDisk -value $drive
			return
		}
	}

	SetNewFreeDisk -value (JoinMainFolder -Path $env:SystemDrive)
}

Function SetNewFreeDisk ($value)
{
	$FullPath = "HKCU:\SOFTWARE\Yi\Install"

	if (-not (Test-Path $FullPath)) {
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
		Text           = "更改自动选择磁盘"
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
		Text           = "确认"
	}
	$Canel             = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "345,482"
		Height         = 36
		Width          = 75
		add_Click      = $Canel_Click
		Text           = "取消"
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

	if (-not (Test-Path $chkpath -PathType Container))
	{
		New-Item -Path $chkpath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
		if (-not (Test-Path $chkpath -PathType Container)) {
			Write-Host "    - 创建目录失败：$($chkpath)`n" -ForegroundColor Red
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
		$packer,
		$types,
		$filename,
		$param,
		$method
	)

	Switch ($status)
	{
		Enable {
			Write-Host "   正在安装 - $($appname)" -ForegroundColor Green
		}
		Disable {
			Write-Host "   跳过安装 - $($appname)" -ForegroundColor Red
			return
		}
	}

	$url = JoinUrl -Path "$($url)" -ChildPath "$($packer).$($types)"

	Switch ($todisk)
	{
		auto
		{
			$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { -not ((JoinMainFolder -Path $env:SystemDrive) -eq $_.Root) } | Select-Object -ExpandProperty 'Root'
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
						Write-Host "    - 本地存在：$($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode -method $method
						break
					}
					Get-ChildItem -Path $OutTo -File -Filter "*$($filename)*.exe" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
						Write-Host "    - 本地存在：$($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode -method $method
						break
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - 已有安装包"
					} else {
						Write-Host "    * 开始下载`n      > 连接到：`n        $url`n      + 保存到：`n        $OutAny"
						CheckCatalog -chkpath $OutTo
						Invoke-WebRequest -Uri $url -OutFile "$($OutAny)" -ErrorAction SilentlyContinue | Out-Null
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - 解压中"
						Archive -filename $OutAny -to $OutTo
						Write-Host "    - 解压完成"
						if ((Test-Path $OutAny)) { remove-item -path $OutAny -force }
					} else {
						Write-Host "    - 下载过程中出现错误`n" -ForegroundColor Red
					}
					Get-ChildItem -Path $OutTo -File -Filter "*$($filename)*$((Get-Culture).Name)*.exe" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
						Write-Host "    - 本地存在：$($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode -method $method
						break
					}
					Get-ChildItem -Path $OutTo -File -Filter "*$($filename)*.exe" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
						Write-Host "    - 本地存在：$($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode -method $method
						break
					}
				}
				NoInst
				{
					if (Test-Path -Path $OutAny) {
						Write-Host "    - 已安装`n"
					} else {
						Write-Host "    * 开始下载`n      > 连接到：`n        $url`n      + 保存到：`n        $OutAny"
						CheckCatalog -chkpath $OutTo
						Invoke-WebRequest -Uri $url -OutFile "$($OutAny)" -ErrorAction SilentlyContinue | Out-Null
					}
				}
				To
				{
					$newoutputfoldoer = "$($OutTo)\$($packer)"
					if (Test-Path $newoutputfoldoer -PathType Container) {
						Write-Host "    - 已安装`n"
						break
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - 已有压缩包"
					} else {
						Write-Host "    * 开始下载`n      > 连接到：`n        $url`n      + 保存到：`n        $OutAny"
						Invoke-WebRequest -Uri $url -OutFile $OutAny -ErrorAction SilentlyContinue | Out-Null
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - 仅解压"
						Archive -filename $OutAny -to $newoutputfoldoer
						Write-Host "    - 解压完成`n"
						if ((Test-Path $OutAny)) { remove-item -path $OutAny -force }
					} else {
						Write-Host "    - 下载过程中出现错误`n" -ForegroundColor Red
					}
				}
				Unzip
				{
					if (Test-Path -Path $OutAny) {
						Write-Host "    - 已有安装包"
					} else {
						Write-Host "    * 开始下载`n      > 连接到：`n        $url`n      + 保存到：`n        $OutAny"
						CheckCatalog -chkpath $OutTo
						Invoke-WebRequest -Uri $url -OutFile $OutAny -ErrorAction SilentlyContinue | Out-Null
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - 仅解压"
						Archive -filename $OutAny -to $OutTo
						Write-Host "    - 解压完成`n"
						if ((Test-Path $OutAny)) { remove-item -path $OutAny -force }
					} else {
						Write-Host "    - 下载过程中出现错误`n" -ForegroundColor Red
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
				Write-Host "    * 开始下载`n      > 连接到：`n        $url"
				if (TestURI $url) {
					Write-Host "      + 保存到：`n        $OutAny"
					CheckCatalog -chkpath $OutTo
					Invoke-WebRequest -Uri $url -OutFile $OutAny -ErrorAction SilentlyContinue | Out-Null
					OpenApp -filename $OutAny -param $param -mode $mode -method $method
				} else {
					Write-Host "      - 状态：不可用`n" -ForegroundColor Red
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
		Write-host "    - 使用 $script:Zip 解压软件"
		$arguments = "x ""-r"" ""-tzip"" ""$filename"" ""-o$to"" ""-y""";
		Start-Process $script:Zip "$arguments" -Wait -WindowStyle Minimized
	} else {
		Write-host "    - 使用系统自带的解压软件"
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
	Write-Host "   正在等待队列" -ForegroundColor Green
	foreach ($nq in $Global:AppQueue) {
		Write-Host "    * PID: $nq" -ForegroundColor Red
		wait-process -id $nq -ErrorAction SilentlyContinue
		Write-Host "    - 已完成`n"
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
					Write-Host "    - 快速运行：`n      $filename`n"
					Start-Process -FilePath $filename
				} else {
					Write-Host "    - 快速运行：`n      $filename`n    - 参数：`n      $param`n"
					Start-Process -FilePath $filename -ArgumentList $param
				}
			}
			Wait
			{
				if (([string]::IsNullOrEmpty($param)))
				{
					Write-Host "    - 等待完成：`n      $filename`n"
					Start-Process -FilePath $filename -Wait
				} else {
					Write-Host "    - 等待完成：`n      $filename`n    - 参数：`n      $param`n"
					Start-Process -FilePath $filename -ArgumentList $param -Wait
				}
			}
			Queue
			{
				Write-Host "    - 快速运行：`n      $filename"
				if (([string]::IsNullOrEmpty($param)))
				{
					$AppRunQueue = Start-Process -FilePath $filename -passthru
					$Global:AppQueue += $AppRunQueue.Id
					Write-Host "    - 添加队列：$($AppRunQueue.Id)`n"
				} else {
					$AppRunQueue = Start-Process -FilePath $filename -ArgumentList $param -passthru
					$Global:AppQueue += $AppRunQueue.Id
					Write-Host "    - 参数：`n      $param"
					Write-Host "    - 添加队列：$($AppRunQueue.Id)`n"
				}
			}
		}
	} else {
		Write-Host "    - 未发现安装文件，请检查完整性：$filename`n" -ForegroundColor Red
	}
}

function ToMainpage
{
	param
	(
		[int]$wait
	)
	Write-Host "`n   安装脚本将会在 $wait 秒后自动退出。" -ForegroundColor Red
	Start-Sleep -s $wait
	exit
}

function ObtainAndInstall
{
	Write-Host "`n   正在安装软件中"
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
		Write-Host "   用户已取消安装。" -ForegroundColor Red
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
		Text           = "安装软件列表 ( 共 $($app.Count) 款 )"
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
		Text           = "选择所有"
	}
	$AllClear          = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = New-Object System.Drawing.Point(88,482)
		Height         = 36
		Width          = 75
		add_Click      = $AllClear_Click
		Text           = "清除所有"
	}
	$Setting           = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = New-Object System.Drawing.Point(187,482)
		Height         = 36
		Width          = 75
		add_Click      = { SetFreeDiskGUI }
		Text           = "设置"
	}
	$Start             = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = New-Object System.Drawing.Point(266,482)
		Height         = 36
		Width          = 75
		add_Click      = $OK_Click
		Text           = "确定"
	}
	$Canel             = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = New-Object System.Drawing.Point(345,482)
		Height         = 36
		Width          = 75
		add_Click      = $Canel_Click
		Text           = "取消"
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
				Write-Host "   等待安装 - $($app[$i][0])" -ForegroundColor Green
			}
			Disable
			{
				Write-Host "   跳过安装 - $($app[$i][0])" -ForegroundColor Red
			}
		}
	}
}

function Mainpage
{
	Clear-Host
	Write-Host "`n   Author: Yi ( http://fengyi.tel )

   From: Yi's Solutions
   buildstring: 6.1.0.2.bs_release.210226-1208

   安装软件列表 ( 共 $($app.Count) 款 )
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
	Write-Host "   - 删除开机自启动项"
	foreach ($nsf in $GroupCleanRun) {
		Remove-ItemProperty -Name $nsf -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue | Out-Null
	}
}

function ProcessOther
{
	Write-Host "`n   处理其它：" -ForegroundColor Green

	CleanRun

	Write-Host "   - 禁用计划任务"
	Disable-ScheduledTask -TaskName GoogleUpdateTaskMachineCore -ErrorAction SilentlyContinue | Out-Null
	Disable-ScheduledTask -TaskName GoogleUpdateTaskMachineUA -ErrorAction SilentlyContinue | Out-Null

	Write-Host "   - 删除多余快捷方式"
	Set-Location "$env:public\Desktop"
	Remove-Item ".\Kleopatra.lnk" -Force -ErrorAction SilentlyContinue | Out-Null

	Write-Host "   - 更名"
	#Rename-Item-NewName "谷歌浏览器.lnk"  -Path ".\Google Chrome.lnk" -ErrorAction SilentlyContinue | Out-Null
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
