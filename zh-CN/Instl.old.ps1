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
#  https://github.com/ilikeyi/powershell.install.software
#  https://gitee.com/ilikeyi/powershell.install.software
#

# 获取脚本参数（如果有）
[CmdletBinding()]
param(
	[parameter(Mandatory = $false, HelpMessage = "静默")]
	[Switch]$Force
)

# 所有软件配置
$app = @(
	("Nvidia GEFORCE GAME READY DRIVER",                  # 软件包名称
	 "Disable",                                           # 状态：Enable = 启用，Disable = 禁用
	 "Install",                                           # 动作：Install = 安装，NoInst = 下载后不安装，Unzip = 下载后仅解压，To = 安装到目录
	 "wait",                                              # 运行方式：Wait = 等待完成，Fast = 直接运行
	 "exe",                                               # 文件类型：exe, zip 或自定义文件类型
	 "auto",                                              # 盘符：Auto = 全盘搜索，(A:)-(Z:) = 指定盘符或自定义路径( \\IP\ )
	 "安装包\驱动程序\显卡",                              # 目录结构，例如：AUTO 改成 C，合并结果：C:\安装包\驱动程序\显卡
	 "*-desktop-win10-*-international-dch-whql",          # 匹配文件名，支持模糊功能（*）
	 "460.89-desktop-win10-64bit-international-dch-whql", # 网站下载绝对文件名，请勿填后缀
	 "https://us.download.nvidia.cn/Windows/460.89/",     # 网站路径前缀，/ 号结尾
	 "-s -clean -noreboot -noeula"),                      # 参数
	("Yi's 个性主题包",
	 "Disable",
	 "Install",
	 "fast",
	 "deskthemepack",
	 "auto",
	 "安装包\主题包",
	 "Yi*",
	 "Yi",
	 "https://fengyi.tel/",
	 ""),
	("Sysinternals Suite",
	 "Disable",
	 "To",
	 "wait",
	 "zip",
	 $env:SystemDrive,
	 "",
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
	 "安装包\AIO",
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
	 "安装包\AIO",
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
	 "安装包\开发软件",
	 "python-*",
	 "python-3.9.1-amd64",
	 "https://www.python.org/ftp/python/3.9.1/",
	 "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"),
	("酷狗音乐",
	 "Disable",
	 "Install",
	 "wait",
	 "exe",
	 "auto",
	 "安装包\音乐软件",
	 "kugou*",
	 "kugou9175",
	 "https://downmini.yun.kugou.com/web/",
	 "/S"),
	("网易云音乐",
	 "Disable",
	 "Install",
	 "wait",
	 "exe",
	 "auto",
	 "安装包\音乐软件",
	 "cloudmusicsetup*",
	 "cloudmusicsetup2.7.5.198554",
	 "https://d1.music.126.net/dmusic/",
	 "/S"),
	("QQ 音乐",
	 "Disable",
	 "Install",
	 "fast",
	 "exe",
	 "auto",
	 "安装包\音乐软件",
	 "QQMusicSetup",
	 "QQMusicSetup",
	 "https://dldir1.qq.com/music/clntupate/",
	 "/S"),
	("腾讯 QQ 2020",
	 "Enable",
	 "Install",
	 "wait",
	 "exe",
	 "auto",
	 "安装包\社交软件",
	 "PCQQ2020",
	 "PCQQ2020",
	 "https://down.qq.com/qqweb/PCQQ/PCQQ_EXE/",
	 "/S"),
	("微信",
	 "Enable",
	 "Install",
	 "wait",
	 "exe",
	 "auto",
	 "安装包\社交软件",
	 "WeChatSetup",
	 "WeChatSetup",
	 "https://dldir1.qq.com/weixin/Windows/",
	 "/S")
)

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
			Write-Host "   正在安装 - $($appname)" -ForegroundColor Green
		}
		Disable {
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
						Write-Host "    - 本地存在：$($_.fullname)"
						Open-App -filename $($_.fullname) -param $param -pp $pp
						break
					}
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
					Write-Host "    - 解压中"
					Archive-Unzip -filename $OutArchive -to $OutTo
					Write-Host "    - 解压完成`n"
					if ((Test-Path $OutArchive)) { remove-item -path $OutArchive -force }
					Get-ChildItem $OutTo -Recurse -Include "*$($filename)*.exe" -ErrorAction SilentlyContinue | Foreach-Object {
						Write-Host "    - 本地存在：$($_.fullname)"
						Open-App -filename $($_.fullname) -param $param -pp $pp
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
				Open-App -filename $OutAny -param $param -pp $pp
			} else {
				Write-Host "    * 开始下载`n      > 连接到：$url"
				try {
					Write-Host "      + 保存到：$OutAny"
					Test-Catalog -chkpath $OutTo
					(New-Object System.Net.WebClient).DownloadFile($url, $OutAny) | Out-Null
					Open-App -filename $OutAny -param $param -pp $pp
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
		$pp
	)

	if ((Test-Path $filename -PathType Leaf)) {
		Switch ($pp)
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
		Start-Install-Software -appname $app[$i][0] -status $app[$i][1] -act $app[$i][2] -pp $app[$i][3] -types $app[$i][4] -todisk $app[$i][5] -structure $app[$i][6] -filename $app[$i][7] -packer $app[$i][8] -url $app[$i][9] -param $app[$i][10]
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
   buildstring: 5.1.2.6.bk_release.210120-1208

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

Get-Mainpage

If ($Force) {
	Obtain-And-Install
	Process-other
} else {
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