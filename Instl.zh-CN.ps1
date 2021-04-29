<#

  PowerShell 安装软件

  . 主要功能
    1. 本地不存在安装包，激活下载功能；
    2. 使用下载功能时，自动判断系统类型，自动按顺序选择，依次类推；
    3. 自动选择盘符：
        3.1    可指定盘符，设置自动后将排除当前系统盘，
               搜索不到可用盘时，回退到当前系统盘；
        3.2    可设置最低要求剩余可用空间，默认 1GB；
    4. 搜索文件名支持模糊查找，通配符 *；
    5. 队列，运行安装程序后添加到队列，等待结束；
    6. 依次按预先设置的结构搜索：
       * 原始下载地址：https://fengyi.tel/Instl.Packer.Latest.exe
         + 模糊文件名：Instl.Packer*
           - 条件 1：系统语言：en-US，搜索条件：Instl.Packer*en-US*
           - 条件 2：搜索模糊文件名：Instl.Packer*
           - 条件 3：搜索网站下载原始文件名：Instl.Packer.Latest
    7. 动态功能：已添加运行前，运行后处理，前往 Function OpenApp {} 处更改该模块；
    8. 支持解压包处理等。

  . 先决条件
    - PowerShell 5.1 或更高

  . 连接
    - https://github.com/ilikeyi/powershell.install.software
    - https://gitee.com/ilikeyi/powershell.install.software


  软件包配置教程

 软件包                                                    描述
("Windows Defender Control",                              软件包名称
 [Status]::Enable,                                        状态：Enable - 启用；Disable - 禁用
 [Action]::Install,                                       动作：Install - 安装；NoInst - 下载后不安装；Unzip - 下载后仅解压；To - 安装到目录
 [Mode]::Wait,                                            运行方式：Wait - 等待完成；Fast - 直接运行
 "auto",                                                  设置自动后将排除当前系统盘，搜索不到可用盘时，默认设置为当前系统盘；指定盘符 [A:]-[Z:]；指定路径：\\192.168.1.1
 "安装包\工具",                                            目录结构
 "https://www.sordum.org/files/download/d-control/dControl.zip", 默认，含 x86 下载地址
 "",                                                      x64 下载地址
 "",                                                      Arm64 下载地址
 "dControl*",                                             文件名模糊查找 (*)
 "/D",                                                    运行参数
 "1:dControl:ini")                                        动态模块：选择方案 1；dControl = 配置文件名；ini = 类型，前往 Function OpenApp {} 处更改该模块

 .制作配置文件

 - 默认
   dControl.ini 复制后更改为 dControl.Default.ini

 - 英文
   dControl.ini 复制后更改为 dControl.en-US.ini
   打开 dControl.en-US.ini，将 Language=Auto 修改为 Language=English

 - 中文
   dControl.ini 复制后更改为 dControl.zh-CN.ini
   打开 dControl.zh-CN.ini，将 Language=Auto 修改为 Language=Chinese_简体中文

   制作完成后删除 dControl.ini。

#>

#Requires -version 5.1

# 获取脚本参数（如果有）
[CmdletBinding()]
param
(
	[Switch]$Force,
	[Switch]$Silent
)

# 作者
$Global:UniqueID  = "Yi"
$Global:AuthorURL = "https://fengyi.tel"

# 初始化自动选择磁盘最低大小：1GB
$Global:DiskMinSize = 1

# 重置队列
$Global:AppQueue = @()

# 标题栏
$Host.UI.RawUI.WindowTitle = "安装软件"

# 所有软件配置
$app = @(
	("$($Global:UniqueID)'s 深色个性主题包",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Fast,
	 "auto",
	 "安装包\主题包",
	 "$($Global:AuthorURL)/$($Global:UniqueID).deskthemepack",
	 "",
	 "",
	 "$($Global:UniqueID)*",
	 "",
	 ""),
	 ("$($Global:UniqueID)'s 浅色个性主题包",
	  [Status]::Disable,
	  [Action]::Install,
	  [Mode]::Fast,
	  "auto",
	  "安装包\主题包",
	  "$($Global:AuthorURL)/$($Global:UniqueID).Light.deskthemepack",
	  "",
	  "",
	  "$($Global:UniqueID)*Light*",
	  "",
	  ""),
	("Nvidia GEFORCE GAME READY DRIVER",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "安装包\驱动程序\显卡",
	 "",
	 "https://us.download.nvidia.cn/Windows/466.27/466.27-desktop-win10-64bit-international-dch-whql.exe",
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
	 "安装包\AIO",
	 "https://github.com/abbodi1406/vcredist/releases/download/v0.47.0/VisualCppRedist_AIO_x86_x64_47.zip",
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
	 "安装包\AIO",
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
	 "安装包\开发软件",
	 "https://www.python.org/ftp/python/3.9.4/python-3.9.4.exe",
	 "https://www.python.org/ftp/python/3.9.4/python-3.9.4-amd64.exe",
	 "",
	 "python-*",
	 "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0",
	 ""),
	("酷狗音乐",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "安装包\音乐软件",
	 "https://downmini.yun.kugou.com/web/kugou9229.exe",
	 "",
	 "",
	 "kugou*",
	 "/S",
	 ""),
	("网易云音乐",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "安装包\音乐软件",
	 "https://d1.music.126.net/dmusic/cloudmusicsetup2.8.0.198822.exe",
	 "",
	 "",
	 "cloudmusicsetup*",
	 "/S",
	 ""),
	("QQ 音乐",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "安装包\音乐软件",
	 "https://dldir1.qq.com/music/clntupate/QQMusic_YQQWinPCDL.exe",
	 "",
	 "",
	 "QQMusicSetup",
	 "",
	 ""),
	("迅雷 11",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "安装包\下载工具",
	 "https://down.sandai.net/thunder11/XunLeiWebSetup11.1.12.1692gw.exe",
	 "",
	 "",
	 "XunLeiWebSetup11*",
	 "/S",
	 ""),
	("腾讯 QQ",
	 [Status]::Enable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "安装包\社交软件",
	 "https://down.qq.com/qqweb/PCQQ/PCQQ_EXE/PCQQ2021.exe",
	 "",
	 "",
	 "PCQQ2021",
	 "/S",
	 ""),
	("微信",
	 [Status]::Enable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "安装包\社交软件",
	 "https://dldir1.qq.com/weixin/Windows/WeChatSetup.exe",
	 "",
	 "",
	 "WeChatSetup",
	 "/S",
	 ""),
	("腾讯视频",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "安装包\网络电视",
	 "https://dldir1.qq.com/qqtv/TencentVideo11.19.3049.0.exe",
	 "",
	 "",
	 "TencentVideo*",
	 "/S",
	 ""),
	("爱奇艺视频",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Queue,
	 "auto",
	 "安装包\网络电视",
	 "https://dl-static.iqiyi.com/hz/IQIYIsetup_z40.exe",
	 "",
	 "",
	 "IQIYIsetup*",
	 "/S",
	 "")
)
# 最后 ) 结尾请勿带 , 号，否则你懂的。

# 状态
Enum Status
{
	Enable
	Disable
}

# 运行模式
Enum Mode
{
	Wait    # 等待完成
	Fast    # 直接运行
	Queue   # 队列
}

# 运行动作
Enum Action
{
	Install # 安装
	NoInst  # 下载后不安装
	To      # 下载压缩包到目录
	Unzip   # 下载后仅解压
}

<#
	.系统架构
#>
# 获取系统架构
Function GetArchitecture
{
	# 从注册表获取：用户指定系统架构
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$($Global:UniqueID)\Install" -Name "Architecture" -ErrorAction SilentlyContinue) {
		$Global:InstlArchitecture = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$($Global:UniqueID)\Install" -Name "Architecture"
		return
	}

	# 初始化：系统架构
	SetArchitecture -Type $env:PROCESSOR_ARCHITECTURE
}

# 设置系统架构
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

<#
	.自动选择磁盘
#>
# 获取自动选择磁盘
Function SetFreeDiskTo
{
	<#
		.从注册表里获取：选择的磁盘并判断，如果是强行设置磁盘，跳过检查剩余磁盘空间了，继续
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$($Global:UniqueID)\Install" -Name "DiskTo" -ErrorAction SilentlyContinue) {
		$GetDiskTo = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$($Global:UniqueID)\Install" -Name "DiskTo"
		if (TestAvailableDisk -Path $GetDiskTo) {
			$Global:FreeDiskTo = $GetDiskTo
			return
		}
	}

	# 搜索磁盘条件，排除系统盘
	$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { -not ((JoinMainFolder -Path $env:SystemDrive) -eq $_.Root) } | Select-Object -ExpandProperty 'Root'

	# 从注册表里获取是否检查磁盘可用空间
	$GetDiskStatus = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$($Global:UniqueID)\Install" -Name "DiskStatus"

	# 从注册表里获取选择的磁盘
	$GetDiskMinSize = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$($Global:UniqueID)\Install" -Name "DiskMinSize"

	# 搜索磁盘条件，排除系统盘
	foreach ($drive in $drives) {
		if (TestAvailableDisk -Path $drive) {
			switch ($GetDiskStatus) {
				1 {
					if (VerifyAvailableSize -Disk $drive -Size $GetDiskMinSize) {
						SetNewFreeDiskTo -Disk $drive
						return
					}
				}
				Default {
					SetNewFreeDiskTo -Disk $drive
					return
				}
			}
		}
	}

	# 未找到可用磁盘，初始化：当前系统盘
	SetNewFreeDiskTo -Disk (JoinMainFolder -Path $env:SystemDrive)
}

Function SetNewFreeDiskTo
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

Function SetFreeDiskSize
{
	<#
		.从注册表里获取选择的磁盘并判断，如果是强行设置磁盘，跳过检查剩余磁盘空间了，继续
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$($Global:UniqueID)\Install" -Name "DiskMinSize" -ErrorAction SilentlyContinue) {
		$GetDiskMinSize = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$($Global:UniqueID)\Install" -Name "DiskMinSize"

		if ([string]::IsNullOrEmpty($GetDiskMinSize)) {
			SetNewFreeDiskSize -Size $Global:DiskMinSize
		}

		if (-not ($GetDiskMinSize -ge $Global:DiskMinSize)) {
			SetNewFreeDiskSize -Size $Global:DiskMinSize
		}
	} else {
		SetNewFreeDiskSize -Size $Global:DiskMinSize
	}
}

Function SetNewFreeDiskSize
{
	param
	(
		[string]$Size
	)

	$FullPath = "HKCU:\SOFTWARE\$($Global:UniqueID)\Install"

	if (-not (Test-Path $FullPath)) {
		New-Item -Path $FullPath -Force -ErrorAction SilentlyContinue | Out-Null
	}
	New-ItemProperty -LiteralPath $FullPath -Name "DiskMinSize" -Value $Size -PropertyType String -Force -ea SilentlyContinue | Out-Null
}

Function SetFreeDiskAvailable
{
	<#
		.从注册表里获取是否检查磁盘可用空间
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$($Global:UniqueID)\Install" -Name "DiskStatus" -ErrorAction SilentlyContinue) {
		$GetDiskStatus = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$($Global:UniqueID)\Install" -Name "DiskStatus"

		if ([string]::IsNullOrEmpty($GetDiskStatus)) {
			SetNewFreeDiskAvailable -Status 1
		} else {
			$Global:FreeDiskStatus = $GetDiskStatus
		}
	} else {
		SetNewFreeDiskAvailable -Status 1
	}
}

Function SetNewFreeDiskAvailable
{
	param
	(
		[string]$Status
	)

	$FullPath = "HKCU:\SOFTWARE\$($Global:UniqueID)\Install"

	if (-not (Test-Path $FullPath)) {
		New-Item -Path $FullPath -Force -ErrorAction SilentlyContinue | Out-Null
	}
	New-ItemProperty -LiteralPath $FullPath -Name "DiskStatus" -Value $Status -PropertyType String -Force -ea SilentlyContinue | Out-Null

	$Global:FreeDiskStatus = $Status
}

<#
	.验证可用磁盘大小
#>
Function VerifyAvailableSize
{
	param
	(
		[string]$Disk,
		[int]$Size
	)

	$TempCheckVerify = $false

	Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue | Where-Object { ((JoinMainFolder -Path $Disk) -eq $_.Root) } | ForEach-Object {
		if (($_.Free - $_.Used) -gt (ConvertSize -From GB -To Bytes $Size)) {
			$TempCheckVerify = $True
		} else {
			$TempCheckVerify = $false
		}
	}

	return $TempCheckVerify
}

Function ConvertSize {
	param (
		[validateset("Bytes","KB","MB","GB","TB")]
		[string]$From,
		[validateset("Bytes","KB","MB","GB","TB")]
		[string]$To,
		[Parameter(Mandatory=$true)]
		[double]$Value,
		[int]$Precision = 4
	)
	switch($From) {
		"Bytes" { $value = $Value }
		"KB" { $value = $Value * 1024 }
		"MB" { $value = $Value * 1024 * 1024 }
		"GB" { $value = $Value * 1024 * 1024 * 1024 }
		"TB" { $value = $Value * 1024 * 1024 * 1024 * 1024 }
	}
	switch ($To) {
		"Bytes" { return $value }
		"KB" { $Value = $Value/1KB }
		"MB" { $Value = $Value/1MB }
		"GB" { $Value = $Value/1GB }
		"TB" { $Value = $Value/1TB }
	}

	return [Math]::Round($value,$Precision,[MidPointRounding]::AwayFromZero)
}

Function SetupGUI
{
	GetArchitecture
	SetFreeDiskSize
	SetFreeDiskAvailable
	SetFreeDiskTo

	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	[System.Windows.Forms.Application]::EnableVisualStyles()

	Function GetDiskAvailable {
		$GetSaveDiskAvailable = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$($Global:UniqueID)\Install" -Name "DiskStatus"
		$SelectLowSize.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$($Global:UniqueID)\Install" -Name "DiskMinSize"
		switch ($GetSaveDiskAvailable) {
			1 {
				$FormSelectDiSKLowSize.Checked = $True
				$SelectLowSize.Enabled = $True
			}
			Default {
				$FormSelectDiSKLowSize.Checked = $False
				$SelectLowSize.Enabled = $False
			}
		}
	}
	$GetDiskAvailable_Click = {
		if ($FormSelectDiSKLowSize.Checked) {
			$SelectLowSize.Enabled = $True
		} else {
			$SelectLowSize.Enabled = $False
		}
	}
	$Canel_Click = {
		$FormSelectDiSK.Close()
	}
	$OK_ArchitectureARM64_Click = {
		$SoftwareTipsErrorMsg.Text = "首选 arm64 下载地址，依次按顺序选择：x64、x86。"
	}
	$OK_ArchitectureX64_Click = {
		$SoftwareTipsErrorMsg.Text = "首选 x64 下载地址，依次按顺序选择：x86。"
	}
	$OK_ArchitectureX86_Click = {
		$SoftwareTipsErrorMsg.Text = "仅选择 x86 下载地址。"
	}
	$OK_Click = {
		if ($ArchitectureARM64.Checked) { SetArchitecture -Type "ARM64" }
		if ($ArchitectureX64.Checked) { SetArchitecture -Type "AMD64" }
		if ($ArchitectureX86.Checked) { SetArchitecture -Type "x86" }

		if ($FormSelectDiSKLowSize.Checked) {
			SetNewFreeDiskAvailable -Status 1
		} else {
			SetNewFreeDiskAvailable -Status 2
		}

		$VerifyAvailableSelect = 0
		$FormSelectDiSKPane1.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.RadioButton]) {
				if ($_.Checked) {
					if ($FormSelectDiSKLowSize.Checked) {
						if (VerifyAvailableSize -Disk $_.Text -Size $SelectLowSize.Text) {
							SetNewFreeDiskSize -Size $($SelectLowSize.Text)
							SetNewFreeDiskTo -Disk $_.Text
							$FormSelectDiSK.Close()
						} else {
							$VerifyAvailableSelect = 1
						}
					} else {
						SetNewFreeDiskSize -Size $($SelectLowSize.Text)
						SetNewFreeDiskTo -Disk $_.Text
						$FormSelectDiSK.Close()
					}
				}
			}
		}
		switch ($VerifyAvailableSelect) {
			0 { $ErrorMsg.Text = "错误：未选择默认使用磁盘" }
			1 { $ErrorMsg.Text = "错误：选择的磁盘可用空间不足" }
		}
	}
	$FormSelectDiSK    = New-Object system.Windows.Forms.Form -Property @{
		autoScaleMode  = 2
		Height         = 568
		Width          = 450
		Text           = "设置"
		TopMost        = $True
		MaximizeBox    = $False
		StartPosition  = "CenterScreen"
		MinimizeBox    = $false
		BackColor      = "#ffffff"
	}
	$ArchitectureTitle = New-Object System.Windows.Forms.Label -Property @{
		Height         = 22
		Width          = 380
		Text           = "首选下载地址"
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
		Height         = 40
		Width          = 386
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
	$FormSelectDiSKSize = New-Object System.Windows.Forms.Label -Property @{
		Height         = 22
		Width          = 395
		Text           = "自动选择可用磁盘时"
		Location       = '10,115'
	}
	$FormSelectDiSKLowSize = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 22
		Width          = 360
		Text           = "检查最低可用剩余空间"
		Location       = '26,140'
		add_Click      = $GetDiskAvailable_Click
	}
	$SelectLowSize     = New-Object System.Windows.Forms.NumericUpDown -Property @{
		Height         = 22
		Width          = 60
		Location       = "45,165"
		Value          = 1
		Minimum        = 1
		Maximum        = 999999
		TextAlign      = 1
		add_Click      = $RefresISOLabelNEW_Click
	}
	$SelectLowUnit     = New-Object System.Windows.Forms.Label -Property @{
		Height         = 22
		Width          = 80
		Text           = "GB"
		Location       = "115,168"
	}
	$FormSelectDiSKTitle = New-Object System.Windows.Forms.Label -Property @{
		Height         = 22
		Width          = 380
		Text           = "默认使用磁盘："
		Location       = '24,205'
	}
	$FormSelectDiSKPane1 = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 210
		Width          = 380
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $true
		Padding        = 0
		Dock           = 0
		Location       = '24,228'
	}
	$ErrorMsg          = New-Object system.Windows.Forms.Label -Property @{
		Location       = "10,455"
		Height         = 26
		Width          = 408
		Text           = ""
	}
	$Start             = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "10,482"
		Height         = 36
		Width          = 202
		add_Click      = $OK_Click
		Text           = "确认"
	}
	$Canel             = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "218,482"
		Height         = 36
		Width          = 202
		add_Click      = $Canel_Click
		Text           = "取消"
	}
	$FormSelectDiSK.controls.AddRange((
		$ArchitectureTitle,
		$GroupArchitecture,
		$SoftwareTips,
		$FormSelectDiSKSize,
		$FormSelectDiSKLowSize,
		$SelectLowSize,
		$SelectLowUnit,
		$FormSelectDiSKTitle,
		$FormSelectDiSKPane1,
		$ErrorMsg,
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

	Get-PSDrive -PSProvider FileSystem | ForEach-Object {
		if (TestAvailableDisk -Path $_.Root) {
			$RadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
				Height = 20
				Width  = 370
				Text   = $_.Root
			}

			$FormSelectDiSKPane1.controls.AddRange($RadioButton)
		}
	}

	$GetDiskTo = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$($Global:UniqueID)\Install" -Name "DiskTo"
	if (TestAvailableDisk -Path $GetDiskTo) {
		$FormSelectDiSKPane1.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.RadioButton]) {
				if ($_.Text -eq $GetDiskTo) {
					$_.Checked = $True
				}
			}
		}
	} else {
		$FormSelectDiSKPane1.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.RadioButton]) {
				if ($_.Text -eq (JoinMainFolder -Path $env:SystemDrive)) {
					$_.Checked = $True
				}
			}
		}
	}

	GetDiskAvailable	

	$FormSelectDiSK.FormBorderStyle = 'Fixed3D'
	$FormSelectDiSK.ShowDialog() | Out-Null
}

Function TestAvailableDisk
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

Function TestURI
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

Function CheckCatalog
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

Function JoinUrl
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

Function StartInstallSoftware
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
	SetFreeDiskSize
	SetFreeDiskAvailable
	SetFreeDiskTo

	Switch ($status)
	{
		Enable
		{
			Write-Host "   正在安装 - $($appname)" -ForegroundColor Green
		}
		Disable
		{
			Write-Host "   跳过安装 - $($appname)" -ForegroundColor Red
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
			Get-PSDrive -PSProvider FileSystem | ForEach-Object {
				$TempRootPath = $_.Root
				$tempoutputfoldoer = Join-Path -Path $($TempRootPath) -ChildPath "$($structure)"
				Get-ChildItem -Path $tempoutputfoldoer -Filter "*$($filename)*$((Get-Culture).Name)*" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
					$OutTo = Join-Path -Path "$($TempRootPath)" -ChildPath "$($structure)"
					$OutAny = $($_.fullname)
					break
				}
				Get-ChildItem -Path $tempoutputfoldoer -Filter "*$($filename)*" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
					$OutTo = Join-Path -Path "$($TempRootPath)" -ChildPath "$($structure)"
					$OutAny = $($_.fullname)
					break
				}
				Get-ChildItem -Path $tempoutputfoldoer -Filter "*$($packer)*" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
					$OutTo = Join-Path -Path "$($TempRootPath)" -ChildPath "$($structure)"
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
			Get-ChildItem -Path $OutTo -Filter "*$($filename)*$((Get-Culture).Name)*" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
				$OutAny = $($_.fullname)
				break
			}
			Get-ChildItem -Path $OutTo -Filter "*$($filename)*" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
				$OutAny = $($_.fullname)
				break
			}
			Get-ChildItem -Path $OutTo -Filter "*$($packer)*" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
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
					Get-ChildItem -Path $OutTo -Filter "*$($filename)*$((Get-Culture).Name)*.exe" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
						Write-Host "    - 本地存在：$($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode -method $method
						break
					}
					Get-ChildItem -Path $OutTo -Filter "*$($filename)*.exe" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
						Write-Host "    - 本地存在：$($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode -method $method
						break
					}
					Get-ChildItem -Path $OutTo -Filter "*$($packer)*.exe" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
						Write-Host "   - $($lang.LocallyExist)`n     $($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode -method $method
						break
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - 已有安装包"
					} else {
						Write-Host "    * 开始下载"
						if ([string]::IsNullOrEmpty($url)) {
							Write-Host "    - 下载地址无效。" -ForegroundColor Red
						} else {
							if (TestURI $url) {
								Write-Host "      > 连接到：`n        $url`n      + 保存到：`n        $OutAny"
								CheckCatalog -chkpath $OutTo
								Invoke-WebRequest -Uri $url -OutFile "$($OutAny)" -ErrorAction SilentlyContinue | Out-Null
							} else {
								Write-Host "      - 状态：不可用" -ForegroundColor Red
							}
						}
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - 解压中"
						Archive -filename $OutAny -to $OutTo
						Write-Host "    - 解压完成"
						Remove-Item -path $OutAny -force -ErrorAction SilentlyContinue
					} else {
						Write-Host "      - 下载过程中出现错误`n" -ForegroundColor Red
					}
					Get-ChildItem -Path $OutTo -Filter "*$($filename)*$((Get-Culture).Name)*.exe" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
						Write-Host "    - 本地存在：$($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode -method $method
						break
					}
					Get-ChildItem -Path $OutTo -Filter "*$($filename)*.exe" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
						Write-Host "    - 本地存在：$($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode -method $method
						break
					}
					Get-ChildItem -Path $OutTo -Filter "*$($packer)*.exe" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
						Write-Host "   - $($lang.LocallyExist)`n     $($_.fullname)"
						OpenApp -filename $($_.fullname) -param $param -mode $mode -method $method
						break
					}
				}
				NoInst
				{
					if (Test-Path -Path $OutAny) {
						Write-Host "    - 已安装`n"
					} else {
						Write-Host "    * 开始下载"
						if ([string]::IsNullOrEmpty($url)) {
							Write-Host "      - 下载地址无效。" -ForegroundColor Red
						} else {
							if (TestURI $url) {
								Write-Host "      > 连接到：`n        $url`n      + 保存到：`n        $OutAny"
								CheckCatalog -chkpath $OutTo
								Invoke-WebRequest -Uri $url -OutFile "$($OutAny)" -ErrorAction SilentlyContinue | Out-Null
							} else {
								Write-Host "      - 状态：不可用`n" -ForegroundColor Red
							}
						}
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
						Write-Host "    * 开始下载"
						if ([string]::IsNullOrEmpty($url)) {
							Write-Host "      - 下载地址无效。" -ForegroundColor Red
						} else {
							Write-Host "      > 连接到：`n        $url`n      + 保存到：`n        $OutAny"
							Invoke-WebRequest -Uri $url -OutFile $OutAny -ErrorAction SilentlyContinue | Out-Null
						}
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - 仅解压"
						Archive -filename $OutAny -to $newoutputfoldoer
						Write-Host "    - 解压完成`n"
						Remove-Item -path $OutAny -force -ErrorAction SilentlyContinue
					} else {
						Write-Host "      - 下载过程中出现错误`n" -ForegroundColor Red
					}
				}
				Unzip
				{
					if (Test-Path -Path $OutAny) {
						Write-Host "    - 已有安装包"
					} else {
						Write-Host "    * 开始下载"
						if ([string]::IsNullOrEmpty($url)) {
							Write-Host "      - 下载地址无效。" -ForegroundColor Red
						} else {
							if (TestURI $url) {
								Write-Host "      > 连接到：`n        $url`n      + 保存到：`n        $OutAny"
								CheckCatalog -chkpath $OutTo
								Invoke-WebRequest -Uri $url -OutFile $OutAny -ErrorAction SilentlyContinue | Out-Null
							} else {
								Write-Host "      - 状态：不可用`n" -ForegroundColor Red
							}
						}
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - 仅解压"
						Archive -filename $OutAny -to $OutTo
						Write-Host "    - 解压完成`n"
						Remove-Item -path $OutAny -force -ErrorAction SilentlyContinue
					} else {
						Write-Host "      - 下载过程中出现错误`n" -ForegroundColor Red
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
				Write-Host "    * 开始下载"
				if ([string]::IsNullOrEmpty($url)) {
					Write-Host "      - 下载地址无效。`n" -ForegroundColor Red
				} else {
					Write-Host "      > 连接到：`n        $url"
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
}

Function Archive
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

Function Compressing
{
	if (Test-Path "$env:ProgramFiles\7-Zip\7z.exe") {
		$script:Zip = "$env:ProgramFiles\7-Zip\7z.exe"
		return $true
	}

	if (Test-Path "$env:ProgramFiles(x86)\7-Zip\7z.exe") {
		$script:Zip = "$env:ProgramFiles(x86)\7-Zip\7z.exe"
		return $true
	}

	if (Test-Path "$env:SystemDrive\$($Global:UniqueID)\$($Global:UniqueID)\7zPacker\7z.exe") {
		$script:Zip = "$env:SystemDrive\$($Global:UniqueID)\$($Global:UniqueID)\7zPacker\7z.exe"
		return $true
	}
	return $false
}

Function WaitEnd
{
	Write-Host "`n   正在等待队列" -ForegroundColor Green
	for ($i=0; $i -lt $Global:AppQueue.Count; $i++) {
		Write-Host "    * PID: $($Global:AppQueue[$i]['ID'])".PadRight(22) -NoNewline
		if ((Get-Process -ID $($Global:AppQueue[$i]['ID']) -ErrorAction SilentlyContinue).Path -eq $Global:AppQueue[$i]['PATH']) {
			Wait-Process -id $($Global:AppQueue[$i]['ID']) -ErrorAction SilentlyContinue
		}
		Write-Host "    - 已完成" -ForegroundColor Yellow
	}
	$Global:AppQueue = @()
}

Function OpenApp
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
					Write-Host "    - 快速运行：`n      $filename`n"
					Start-Process -FilePath $filename
				} else {
					Write-Host "    - 快速运行：`n      $filename`n    - 参数：`n      $param`n"
					Start-Process -FilePath $filename -ArgumentList $param
				}
			}
			Wait
			{
				if ([string]::IsNullOrEmpty($param))
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
				if ([string]::IsNullOrEmpty($param))
				{
					$AppRunQueue = Start-Process -FilePath $filename -passthru
					$Global:AppQueue += @{
						ID="$($AppRunQueue.Id)";
						PATH="$($filename)"
					}
					Write-Host "    - 添加队列：$($AppRunQueue.Id)`n"
				} else {
					$AppRunQueue = Start-Process -FilePath $filename -ArgumentList $param -passthru
					$Global:AppQueue += @{
						ID="$($AppRunQueue.Id)";
						PATH="$($filename)"
					}
					Write-Host "    - 参数：`n      $param"
					Write-Host "    - 添加队列：$($AppRunQueue.Id)`n"
				}
			}
		}
	} else {
		Write-Host "    - 未发现安装文件，请检查完整性：$filename`n" -ForegroundColor Red
	}
}

Function ToMainpage
{
	param
	(
		[int]$wait
	)
	Write-Host "`n   安装脚本将会在 $wait 秒后自动退出。" -ForegroundColor Red
	Start-Sleep -s $wait
	exit
}

Function ObtainAndInstall
{
	Write-Host "`n   正在安装软件中`n   ---------------------------------------------------"
	for ($i=0; $i -lt $app.Count; $i++) {
		StartInstallSoftware -appname $app[$i][0] -status $app[$i][1] -act $app[$i][2] -mode $app[$i][3] -todisk $app[$i][4] -structure $app[$i][5] -url $app[$i][6] -urlx64 $app[$i][7] -urlarm64 $app[$i][8] -filename $app[$i][9] -param $app[$i][10] -method $app[$i][11]
	}
}

Function InstallGUI
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
                    StartInstallSoftware -appname $app[$_.Tag][0] -status "Enable" -act $app[$_.Tag][2] -mode $app[$_.Tag][3] -todisk $app[$_.Tag][4] -structure $app[$_.Tag][5] -url $app[$_.Tag][6] -urlx64 $app[$_.Tag][7] -urlarm64 $app[$_.Tag][8] -filename $app[$_.Tag][9] -param $app[$_.Tag][10] -method $app[$_.Tag][11]
				}
			}
		}
		WaitEnd
		ProcessOther
		$Install.Close()
	}
	$Install           = New-Object system.Windows.Forms.Form -Property @{
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
	$Setting           = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "10,482"
		Height         = 36
		Width          = 133
		add_Click      = { SetupGUI }
		Text           = "设置"
	}
	$Start             = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "148,482"
		Height         = 36
		Width          = 133
		add_Click      = $OK_Click
		Text           = "确定"
	}
	$Canel             = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "286,482"
		Height         = 36
		Width          = 133
		add_Click      = $Canel_Click
		Text           = "取消"
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
	$SelectMenu.Items.Add("选择所有").add_Click($AllSel_Click)
	$SelectMenu.Items.Add("清除所有").add_Click($AllClear_Click)
	$Install.ContextMenuStrip = $SelectMenu

	$Install.FormBorderStyle = 'Fixed3D'
	$Install.ShowDialog() | Out-Null
}

Function ShowList
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

Function Mainpage
{
	Clear-Host
	Write-Host "`n   Author: $($Global:UniqueID) ( $($Global:AuthorURL) )

   From: $($Global:UniqueID)'s Solutions
   buildstring: 7.0.0.1.bs_release.210226-1208

   安装软件列表 ( 共 $($app.Count) 款 )`n   ---------------------------------------------------"
}

$GroupCleanRun = @(
	"Wechat"
	"HCDNClient"
	"qqlive"
	"cloudmusic"
	"QQMusic"
	"Thunder"
)

Function CleanRun {
	Write-Host "   - 删除开机自启动项"
	foreach ($nsf in $GroupCleanRun) {
		Remove-ItemProperty -Name $nsf -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue | Out-Null
	}
}

Function ProcessOther
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

Function initialization
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
