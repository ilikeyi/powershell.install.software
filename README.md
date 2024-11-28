<a name="readme-top"></a>
PowerShell Software Installer
-

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
irm https://fengyi.tel/pi | iex
```

<p>After running the installation script, users can customize the installation interface: specify the download link, specify the installation location, add routing functions, add context to obtain ownership, and go to: package scripts, create templates, create deployment engine upgrade packages, backup, etc.</p>
<p>You can choose either: interactive experience installation and custom installation to suit different installation requirements.</p>

<br>

Detailed introduction
-

 * <a href="https://github.com/ilikeyi/Instl/blob/main/_Learn/Readme/Readme.Detailed.zh-CN.pdf">简体中文 - 中国</a>


<br>

Key Features
-

<ul>
<p>1.&nbsp;&nbsp;If the installation package does not exist locally, activate the download function;</p>
<p>2.&nbsp;&nbsp;When using the download function, the system type is automatically determined and selected in order, and so on;</p>
<p>3.&nbsp;&nbsp;Automatically select a drive letter:</p>
<ul>
	<dl>
	   <dd>You can specify a drive letter. If set to automatic, the current system drive will be excluded. If no available drive is found, the system will fall back to the current system drive.</dd>
	   <dd>You can set the minimum required remaining free space, the default is 1GB;</dd>
	</dl>
</ul>

<br>

<p>4.&nbsp;&nbsp;Search file name supports fuzzy search and wildcard *;</p>
<p>5.&nbsp;&nbsp;Queue, run the installer and add it to the queue, waiting for it to finish;</p>
<p>6.&nbsp;&nbsp;Search by pre-set structure: </p>
<ul>
	<dl>
	   <dd>* Original download address: https://fengyi.tel/Instl.Packer.Latest.exe</dd>
	   <dd>   + Obfuscated file name: Instl.Packer*</dd>
	   <dd>     Condition 1: System language: en-US, Search condition: Instl.Packer*en-US*</dd>
	   <dd>     Condition 2: Search for fuzzy file names: Instl.Packer*</dd>
	   <dd>     Condition 3: Search the website to download the original file name: Instl.Packer.Latest</dd>
	</dl>
</ul>

<br>

<p>7.&nbsp;&nbsp;Dynamic functions: Added pre-run and post-run processing, go to Function OpenApp {} to change the module;</p>
<p>8.&nbsp;&nbsp;Support decompression package processing, etc.</p>


<br>


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<br>

## License

Distributed under the MIT License. See `LICENSE` for more information.

<br>

## Contact

Yi - [https://fengyi.tel](https://fengyi.tel) - 775159955@qq.com

Project Link: [https://github.com/ilikeyi/Instl](https://github.com/ilikeyi/Instl)
