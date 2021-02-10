<#

  警告：为防止更新后覆盖，请另存为后再修改。

  PowerShell 安装软件

  .主要功能
    1. 本地不存在安装包，激活下载功能；
    2. 可指定盘符，设置自动后将排除当前系统盘，
       搜索不到可用盘时，默认设置为当前系统盘；
    3. 搜索文件名支持模糊查找，通配符 *；
    4. 搜索文件名优先按语言结构来搜索，例如：
       - 操作系统首选语言：en-US
       - 文件名：ChromeChrome
       优先搜索条件为 GoogleChrome*en-US*，未搜索到按默认文件名重新搜索；
    5. 支持运行前处理，前往 function OpenApp {} 处更改该模块；
    6. 支持解压包处理等。

  .先决条件
  - PowerShell 5.1 或更高

  .连接
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
 "1:DefenderControl:ini")                                  运行前：1 - 选择方案1；DefenderControl = 配置文件名；ini = 类型，前往 function OpenApp {} 处更改该模块

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

#Requires -version 5.0

# 获取脚本参数（如果有）
[CmdletBinding()]
param(
	[parameter(Mandatory = $false, HelpMessage = "静默")]
	[Switch]$Force
)

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
	 [Mode]::Wait,
	 "auto",
	 "安装包\驱动程序\显卡",
	 "https://cn.download.nvidia.cn/Windows/461.40",
	 "461.40-desktop-win10-64bit-international-dch-whql",
	 "exe",
	 "*-desktop-win10-*-international-dch-whql",
	 "-s -clean -noreboot -noeula",
	 ""),
	("Sysinternals Suite",
	 [Status]::Disable,
	 [Action]::To,
	 [Mode]::Wait,
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
	 [Mode]::Wait,
	 "auto",
	 "安装包\AIO",
	 "https://github.com/abbodi1406/vcredist/releases/download/v0.43.0",
	 "VisualCppRedist_AIO_x86_x64_43",
	 "zip",
	 "VisualCppRedist*",
	 "/y",
	 ""),
	("Gpg4win",
	 [Status]::Disable,
	 [Action]::Install,
	 [Mode]::Wait,
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
	 [Mode]::Wait,
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
	 [Mode]::Wait,
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
	 [Mode]::Wait,
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
	 [Mode]::Fast,
	 "auto",
	 "安装包\音乐软件",
	 "https://dldir1.qq.com/music/clntupate",
	 "QQMusicSetup",
	 "exe",
	 "QQMusicSetup",
	 "/S",
	 ""),
	("腾讯 QQ 2020",
	 [Status]::Enable,
	 [Action]::Install,
	 [Mode]::Wait,
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
	 [Mode]::Wait,
	 "auto",
	 "安装包\社交软件",
	 "https://dldir1.qq.com/weixin/Windows",
	 "WeChatSetup",
	 "exe",
	 "WeChatSetup",
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
}

Enum Action
{
	Install # 安装
	NoInst  # 下载后不安装
	To      # 下载压缩包到目录
	Unzip   # 下载后仅解压
}

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

function TestURI {
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

function CheckCatalog {
	Param(
		[string]$chkpath
	)

	if(!(Test-Path $chkpath -PathType Container)) {
		New-Item -Path $chkpath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
		if(!(Test-Path $chkpath -PathType Container)) {
			Write-Host "    - 创建目录失败：$($chkpath)`n" -ForegroundColor Red
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
	} else {
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

	Switch ($todisk) {
		auto {
			$drives = Get-PSDrive -PSProvider FileSystem | where { -not ("$($env:SystemDrive)\" -eq $_.Root) } | Select-Object -ExpandProperty 'Root'
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
				foreach ($drive in $drives) {
					if (TestAvailableDisk -Path $drive)	{
						$OutTo = Join-Path -Path "$($drive)" -ChildPath "$($structure)"
						$OutAny = Join-Path -Path "$($drive)" -ChildPath "$($structure)\$($packer).$($types)"
					} else {
						$OutTo = Join-Path -Path $($env:SystemDrive) -ChildPath "$($structure)"
						$OutAny = Join-Path -Path $($env:SystemDrive) -ChildPath "$($structure)\$($packer).$($types)"
					}
				}
			}
		}
		default {
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
		zip {
			Switch ($act)
			{
				Install {
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
						Write-Host "    * 开始下载`n      > 连接到：$url`n      + 保存到：$OutAny"
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
				NoInst {
					if (Test-Path -Path $OutAny) {
						Write-Host "    - 已安装`n"
					} else {
						Write-Host "    * 开始下载`n      > 连接到：$url`n      + 保存到：$OutAny"
						CheckCatalog -chkpath $OutTo
						Invoke-WebRequest -Uri $url -OutFile "$($OutAny)" -ErrorAction SilentlyContinue | Out-Null
					}
				}
				To {
					$newoutputfoldoer = "$($OutTo)\$($packer)"
					if (Test-Path $newoutputfoldoer -PathType Container) {
						Write-Host "    - 已安装`n"
						break
					}
					if (Test-Path -Path $OutAny) {
						Write-Host "    - 已有压缩包"
					} else {
						Write-Host "    * 开始下载`n      > 连接到：$url`n      + 保存到：$OutAny"
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
				Unzip {
					if (Test-Path -Path $OutAny) {
						Write-Host "    - 已有安装包"
					} else {
						Write-Host "    * 开始下载`n      > 连接到：$url`n      + 保存到：$OutAny"
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
		default {
			if ((Test-Path $OutAny -PathType Leaf)) {
				OpenApp -filename $OutAny -param $param -mode $mode -method $method
			} else {
				Write-Host "    * 开始下载`n      > 连接到：$url"
				if (TestURI $url) {
					Write-Host "      + 保存到：$OutAny"
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

function Archive {
	param(
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
		$mode,
		$method
	)

	$Select = $method -split ":"
	switch ($Select[0]) {
		1 {
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
		default {
		}
	}

	if ((Test-Path $filename -PathType Leaf)) {
		Switch ($mode)
		{
			Fast {
				Write-Host "    - 快速运行：$filename`n    - 参数：$param`n"
				if (([string]::IsNullOrEmpty($param))){
					Start-Process -FilePath $filename
				} else {
					Start-Process -FilePath $filename -ArgumentList $param
				}
			}
			Wait {
				Write-Host "    - 等待完成：$filename`n    - 参数：$param`n"
				if (([string]::IsNullOrEmpty($param))){
					Start-Process -FilePath $filename -Wait
				} else {
					Start-Process -FilePath $filename -ArgumentList $param -Wait
				}
			}
		}
	} else {
		Write-Host "    - 未发现安装文件，请检查完整性：$filename`n" -ForegroundColor Red
	}
}

function WaitExit {
	param(
		[int]$wait
	)
	Write-Host "`n   安装脚本将会在 $wait 秒后自动退出。" -ForegroundColor Red
	Start-Sleep -s $wait
	exit
}

function ObtainAndInstall {
	Write-Host "`n   正在安装软件中"
	Write-Host "   ---------------------------------------------------"
	for ($i=0; $i -lt $app.Count; $i++) {
		StartInstallSoftware -appname $app[$i][0] -status $app[$i][1] -act $app[$i][2] -mode $app[$i][3] -todisk $app[$i][4] -structure $app[$i][5] -url $app[$i][6] -packer $app[$i][7] -types $app[$i][8] -filename $app[$i][9] -param $app[$i][10] -method $app[$i][11]
	}
}

function ProcessOther {
	Write-Host "`n   处理其它：" -ForegroundColor Green

	Write-Host "   - 删除开机自启动项"
	Remove-ItemProperty -Name "Wechat" -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue | Out-Null

	Write-Host "   - 禁用计划任务"
	Disable-ScheduledTask -TaskName GoogleUpdateTaskMachineCore -ErrorAction SilentlyContinue | Out-Null
	Disable-ScheduledTask -TaskName GoogleUpdateTaskMachineUA -ErrorAction SilentlyContinue | Out-Null

	Write-Host "   - 删除多余快捷方式"
	Set-Location "$env:public\Desktop"
	Remove-Item ".\Kleopatra.lnk" -Force -ErrorAction SilentlyContinue | Out-Null

	Write-Host "   - 更名"
	#Rename-Item-NewName "谷歌浏览器.lnk"  -Path ".\Google Chrome.lnk" -ErrorAction SilentlyContinue | Out-Null
}

function Mainpage {
	Clear-Host
	Write-Host "`n   Author: Yi ( http://fengyi.tel )

   From: Yi's Solutions
   buildstring: 5.3.1.2.bs_release.210120-1208

   安装软件列表 ( 共 $($app.Count) 款 )
   ---------------------------------------------------"
	for ($i=0; $i -lt $app.Count; $i++) {
		Switch ($app[$i][1])
		{
			Enable {
				Write-Host "   等待安装 - $($app[$i][0])" -ForegroundColor Green
			}
			Disable {
				Write-Host "   跳过安装 - $($app[$i][0])" -ForegroundColor Red
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
	Write-Host "   是否安装以上软件？" -ForegroundColor Green
	$caption="安装软件前请确认。"
	$message="继续安装（Y）`n取消安装（N）"
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
			Write-Host "`n   用户已取消安装。"
			WaitExit -wait 2
		}
	}
}