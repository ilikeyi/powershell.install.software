#
#  警告：为防止更新后覆盖，请另存为后再修改。
#
#  欢迎您使用 PowerShell 安装软件
#
#  主要功能：
#    1. 本地不存在安装包，激活下载；
#    2. 可指定软件包盘符，未指定则按 [d-z] 顺序搜索，
#       仅搜索可用盘，未搜索到默认当前系统盘；
#    3. 搜索文件名支持模糊查找，通配符 *；
#    4. 支持解压包处理等。
#
#  先决条件：
#Requires -version 1.0
#
#  源代码：
#  - https://github.com/ilikeyi/powershell.install.software
#  - https://gitee.com/ilikeyi/powershell.install.software
#

# 获取脚本参数（如果有）
[CmdletBinding()]
param(
	[parameter(Mandatory = $false, HelpMessage = "静默")]
	[Switch]$Force
)

<# 软件包配置教程

变量名       软件包配置                  描述
$appname   ("Gpg4win",                   软件包名称
$status     "Disable",                   状态：Enable - 启用；Disable - 禁用
$act        "Install",                   动作：Install - 安装；NoInst 下载后不安装；Unzip - 下载后仅解压；To - 安装到目录
$mode       "wait",                      运行方式：Wait - 等待完成；Fast - 直接运行
$todisk     "auto",                      设置 Auto 自动从 A-Z 盘开始搜索；指定盘符 [A:]-[Z:]；指定路径：\\192.168.1.1
$structure  "安装包\AIO",                目录结构
$url        "https://files.gpg4win.org", 网站地址
$packer     "gpg4win-3.1.15",            从网站下载的文件名
$types      "exe",                       从网站下载的文件类型：exe, zip 或自定义文件类型；结果：https://files.gpg4win.org/gpg4win-3.1.15.exe
$filename   "gpg4win*",                  文件名模糊查找（*）
$param      "/S"),                       运行参数

#>

# 所有软件配置
$app = @(
	("Yi's 个性主题包",
	 "Disable",
	 "Install",
	 "fast",
	 "auto",
	 "安装包\主题包",
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
	 "安装包\驱动程序\显卡",
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
	 "安装包\AIO",
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
	 "安装包\AIO",
	 "https://files.gpg4win.org",
	 "gpg4win-3.1.15",
	 "exe",
	 "gpg4win*",
	 "/S"),
	("Python",
	 "Disable",
	 "Install",
	 "wait",
	 "auto",
	 "安装包\开发软件",
	 "https://www.python.org/ftp/python/3.9.1",
	 "python-3.9.1-amd64",
	 "exe",
	 "python-*",
	 "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"),
	("酷狗音乐",
	 "Disable",
	 "Install",
	 "wait",
	 "auto",
	 "安装包\音乐软件",
	 "https://downmini.yun.kugou.com/web",
	 "kugou9175",
	 "exe",
	 "kugou*",
	 "/S"),
	("网易云音乐",
	 "Disable",
	 "Install",
	 "wait",
	 "auto",
	 "安装包\音乐软件",
	 "https://d1.music.126.net/dmusic",
	 "cloudmusicsetup2.7.5.198554",
	 "exe",
	 "cloudmusicsetup*",
	 "/S"),
	("QQ 音乐",
	 "Disable",
	 "Install",
	 "fast",
	 "auto",
	 "安装包\音乐软件",
	 "https://dldir1.qq.com/music/clntupate",
	 "QQMusicSetup",
	 "exe",
	 "QQMusicSetup",
	 "/S"),
	("腾讯 QQ 2020",
	 "Enable",
	 "Install",
	 "wait",
	 "auto",
	 "安装包\社交软件",
	 "https://down.qq.com/qqweb/PCQQ/PCQQ_EXE",
	 "PCQQ2020",
	 "exe",
	 "PCQQ2020",
	 "/S"),
	("微信",
	 "Enable",
	 "Install",
	 "wait",
	 "auto",
	 "安装包\社交软件",
	 "https://dldir1.qq.com/weixin/Windows",
	 "WeChatSetup",
	 "exe",
	 "WeChatSetup",
	 "/S")
)
# 最后 ) 结尾请勿带 , 号，否则你懂的。

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

function Test-Catalog {
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
			Write-Host "   正在安装 - $($appname)" -ForegroundColor Green
		}
		Disable {
			Write-Host "   跳过安装 - $($appname)" -ForegroundColor Red
			return
		}
	}

	$url = Join-Url -Path "$($url)" -ChildPath "$($packer).$($types)"

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
						Write-Host "    - 本地存在：$($_.fullname)"
						Open-App -filename $($_.fullname) -param $param -mode $mode
						break
					}
					if (Test-Path -Path $OutArchive) {
						Write-Host "    - 已有安装包"
					} else {
						Write-Host "    * 开始下载`n      > 连接到：$url"
						try {
							Write-Host "      + 保存到：$OutArchive"
							Test-Catalog -chkpath $OutTo
							(New-Object System.Net.WebClient).DownloadFile($url, $OutArchive) | Out-Null
						} catch {
							Write-Host "      - 状态：不可用`n" -ForegroundColor Red
							break
						}
					}
					Write-Host "    - 解压中"
					Archive-Unzip -filename $OutArchive -to $OutTo
					Write-Host "    - 解压完成"
					if ((Test-Path $OutArchive)) { remove-item -path $OutArchive -force }
					Get-ChildItem $OutTo -Recurse -Include "*$($filename)*.exe" -ErrorAction SilentlyContinue | Foreach-Object {
						Write-Host "    - 本地存在：$($_.fullname)"
						Open-App -filename $($_.fullname) -param $param -mode $mode
					}
				}
				NoInst {
					if (Test-Path -Path $OutArchive) {
						Write-Host "    - 已有安装包`n"
					} else {
						Write-Host "    * 开始下载`n      > 连接到：$url"
						try {
							Write-Host "      + 保存到：$OutArchive"
							Test-Catalog -chkpath $OutTo
							(New-Object System.Net.WebClient).DownloadFile($url, $OutArchive) | Out-Null
						} catch {
							Write-Host "      - 状态：不可用`n" -ForegroundColor Red
							break
						}
					}
				}
				To {
					$newoutputfoldoer = "$($OutTo)\$($packer)"
					if (Test-Path $newoutputfoldoer -PathType Container) {
						Write-Host "    - 已有安装包`n"
						break
					} else {
						Write-Host "    * 开始下载`n      > 连接到：$url"
						try {
							Write-Host "      + 保存到：$OutArchive"
							Test-Catalog -chkpath $newoutputfoldoer
							(New-Object System.Net.WebClient).DownloadFile($url, $OutArchive) | Out-Null
						} catch {
							Write-Host "      - 状态：不可用`n" -ForegroundColor Red
							break
						}
						Write-Host "    - 仅解压"
						Archive-Unzip -filename $OutArchive -to $newoutputfoldoer
						Write-Host "    - 解压完成`n"
						if ((Test-Path $OutArchive)) { remove-item -path $OutArchive -force }
					}
				}
				Unzip {
					if ((Test-Path -Path $OutArchive)) {
						Write-Host "    - 已有安装包`n"
					} else {
						Write-Host "    * 开始下载      > 连接到：$url"
						try {
							Write-Host "      + 保存到：$OutArchive"
							Test-Catalog -chkpath $OutTo
							(New-Object System.Net.WebClient).DownloadFile($url, $OutArchive) | Out-Null
						} catch {
							Write-Host "      - 状态：不可用`n" -ForegroundColor Red
							break
						}
					}
					Write-Host "    - 仅解压"
					Archive-Unzip -filename $OutArchive -to $OutTo
					Write-Host "    - 解压完成`n"
					if ((Test-Path $OutArchive)) { remove-item -path $OutArchive -force }
				}
			}
		}
		default {
			if ((Test-Path $OutAny -PathType Leaf)) {
				Open-App -filename $OutAny -param $param -mode $mode
			} else {
				Write-Host "    * 开始下载`n      > 连接到：$url"
				try {
					Write-Host "      + 保存到：$OutAny"
					Test-Catalog -chkpath $OutTo
					(New-Object System.Net.WebClient).DownloadFile($url, $OutAny) | Out-Null
					Open-App -filename $OutAny -param $param -mode $mode
				} catch {
					Write-Host "      - 状态：不可用`n" -ForegroundColor Red
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
		Write-host "    - 使用 $script:Zip 解压软件"
		$arguments = "x ""-r"" ""-tzip"" ""$filename"" ""-o$to"" ""-y""";
		Start-Process $script:Zip "$arguments" -Wait -WindowStyle Minimized
	} else {
		Write-host "    - 使用系统自带的解压软件"
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

function Wait-Exit {
	param(
		[int]$wait
	)
	Write-Host "`n   提示：$wait 秒后自动退出安装脚本..." -ForegroundColor Red
	Start-Sleep -s $wait
	exit
}

function Obtain-And-Install {
	Write-Host "`n   正在安装软件中"
	Write-Host "   ---------------------------------------------------"
	for ($i=0; $i -lt $app.Count; $i++) {
		Start-Install-Software -appname $app[$i][0] -status $app[$i][1] -act $app[$i][2] -mode $app[$i][3] -todisk $app[$i][4] -structure $app[$i][5] -url $app[$i][6] -packer $app[$i][7] -types $app[$i][8] -filename $app[$i][9] -param $app[$i][10]
	}
}

function Process-other {
	Write-Host "`n   处理其它：" -ForegroundColor Green

	Write-Host "   - 删除开机自启动项"
	Remove-ItemProperty -Name "Wechat" -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue | Out-Null

	Write-Host "   - 删除多余快捷方式"
	Set-Location "$env:public\Desktop"
	Remove-Item ".\Kleopatra.lnk" -Force -ErrorAction SilentlyContinue | Out-Null

	Write-Host "   - 更名"
	#Rename-Item-NewName "谷歌浏览器.lnk"  -Path ".\Google Chrome.lnk" -ErrorAction SilentlyContinue | Out-Null
}

function Get-Mainpage {
	cls
	Write-Host "`n   Author: Yi ( http://fengyi.tel )

   From: Yi's Solution
   buildstring: 5.2.0.0.bs_release.210120-1208

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
	Get-Mainpage
	Initialization
	Obtain-And-Install
	Process-other
} else {
	Get-Mainpage
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
			Obtain-And-Install
			Process-other
			Wait-Exit -wait 6
		}
		1 {
			Write-Host "`n   用户已取消安装。"
			Wait-Exit -wait 2
		}
	}
}