<a name="readme-top"></a>
PowerShell 软件安装器
-

<br>

快速下载指南
-

以管理员身份打开“Terminal”或“PowerShell ISE”，将以下命令行粘贴到“Terminal”对话框，按回车键（Enter）后开始运行；

<br>

以管理员身份打开“Terminal”或“PowerShell ISE”，设置 PowerShell 执行策略：绕过，PS 命令行：
```
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
```

<br>

a) 优先从 Yi 节点下载
```
curl https://fengyi.tel/pi -o get.ps1; .\get.ps1;
wget https://fengyi.tel/pi -O get.ps1; .\get.ps1;
iwr https://fengyi.tel/pi -out get.ps1; .\get.ps1;
Invoke-WebRequest https://fengyi.tel/pi -OutFile get.ps1; .\get.ps1;
```

<br>

b) 优先从 Github 节点下载
```
curl https://github.com/ilikeyi/Instl/raw/main/Instl.ps1 -o get.ps1; .\get.ps1;
wget https://github.com/ilikeyi/Instl/raw/main/Instl.ps1 -O get.ps1; .\get.ps1;
iwr https://github.com/ilikeyi/Instl/raw/main/Instl.ps1 -out get.ps1; .\get.ps1;
Invoke-WebRequest https://github.com/ilikeyi/Instl/raw/main/Instl.ps1 -OutFile get.ps1; .\get.ps1;
```

<br>

可用语言
-

 * <a href="https://github.com/ilikeyi/Instl">United States - English</a>


<br>

主要功能
-

<ul>
<p>1.&nbsp;&nbsp;本地不存在安装包，激活下载功能；</p>
<p>2.&nbsp;&nbsp;使用下载功能时，自动判断系统类型，自动按顺序选择，依次类推；</p>
<p>3.&nbsp;&nbsp;自动选择盘符：</p>
<ul>
	<dl>
	   <dd>可指定盘符，设置自动后将排除当前系统盘，搜索不到可用盘时，回退到当前系统盘；</dd>
	   <dd>可设置最低要求剩余可用空间，默认 1GB；</dd>
	</dl>
</ul>

<br>

<p>4.&nbsp;&nbsp;搜索文件名支持模糊查找，通配符 *；</p>
<p>5.&nbsp;&nbsp;队列，运行安装程序后添加到队列，等待结束；</p>
<p>6.&nbsp;&nbsp;依次按预先设置的结构搜索：</p>
<ul>
	<dl>
	   <dd>* 原始下载地址：https://fengyi.tel/Instl.Packer.Latest.exe</dd>
	   <dd>&nbsp;&nbsp;+ 模糊文件名：Instl.Packer*</dd>
	   <dd>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;条件 1：系统语言：en-US，搜索条件：Instl.Packer*en-US*</dd>
	   <dd>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;条件 2：搜索模糊文件名：Instl.Packer*</dd>
	   <dd>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;条件 3：搜索网站下载原始文件名：Instl.Packer.Latest</dd>
	</dl>
</ul>

<br>

<p>7.&nbsp;&nbsp;动态功能：已添加运行前，运行后处理，前往 Function OpenApp {} 处更改该模块；</p>
<p>8.&nbsp;&nbsp;支持解压包处理等。</p>


<br>


<p align="right">(<a href="#readme-top">返回页首</a>)</p>

<br>

## License

根据 MIT 许可证分发。有关更多信息，请参阅“许可证”。

<br>

## Contact

Yi - [https://fengyi.tel](https://fengyi.tel) - 775159955@qq.com

Project Link: [https://github.com/ilikeyi/Instl](https://github.com/ilikeyi/Instl)
