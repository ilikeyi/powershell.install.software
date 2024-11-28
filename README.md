<a name="readme-top"></a>
Yi’s soultions
-
PowerShell 软件安装器

<br>

QUICK DOWNLOAD GUIDE
-

Open "Terminal" or "PowerShell ISE" as an administrator, paste the following command line into the "Terminal" dialog box, and press Enter to start running;

<br>

Open "Terminal" or "PowerShell ISE" as an administrator, set PowerShell execution policy: Bypass, PS command line:
```
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
```

<br>

a) Prioritize downloading from Github node
```
irm https://github.com/ilikeyi/Instl/raw/main/Instl.ps1 | iex
```

<br>

b) Prioritize downloading from Yi node
```
irm https://fengyi.tel/instl | iex
```

<p>After running the installation script, users can customize the installation interface: specify the download link, specify the installation location, add routing functions, add context to obtain ownership, and go to: package scripts, create templates, create deployment engine upgrade packages, backup, etc.</p>
<p>You can choose either: interactive experience installation and custom installation to suit different installation requirements.</p>

<br>

Detailed introduction
-

 * United States - English
 
 * 简体中文 - 中国 | <a href="https://github.com/ilikeyi/Instl/blob/main/_Learn/Readme/Readme.Detailed.zh-CN.pdf">Github</a>


<br>

主要功能
-

<h4><pre>主要功能</pre></h4>
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
	   <dd>   + 模糊文件名：Instl.Packer*</dd>
	   <dd>   条件 1：系统语言：en-US，搜索条件：Instl.Packer*en-US*</dd>
	   <dd>   条件 2：搜索模糊文件名：Instl.Packer*</dd>
	   <dd>   条件 3：搜索网站下载原始文件名：Instl.Packer.Latest</dd>
	</dl>
</ul>

<br>

<p>7.&nbsp;&nbsp;动态功能：已添加运行前，运行后处理，前往 Function OpenApp {} 处更改该模块；</p>
<p>8.&nbsp;&nbsp;支持解压包处理等。</p>


<br>


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<br>

## License

Distributed under the MIT License. See `LICENSE` for more information.

<br>

## Contact

Yi - [https://fengyi.tel](https://fengyi.tel) - 775159955@qq.com

Project Link: [https://github.com/ilikeyi/Instl](https://github.com/ilikeyi/Instl)
