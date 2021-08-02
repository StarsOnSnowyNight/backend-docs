# wkhtmltox安装使用说明.md
------
wkhtmltopdf并且wkhtmltoimage是开源的（LGPLv3）命令行工具来渲染HTML到使用Qt WebKit渲染引擎PDF和各种图像格式。它们完全“无头”运行，不需要显示或显示服务。

> * [官网](https://wkhtmltopdf.org/)
> * [下载地址](https://wkhtmltopdf.org/downloads.html)


### windows安装
- 从官网/wps下载：wkhtmltox-0.12.5-1.msvc2015-win64.exe
- 双击安装
- 测试安装结果
```
C:\Users\Administrator>D:\wkhtmltopdf\bin\wkhtmltoimage http://pm.jlwgroups.com/htmltofile/index.html D:\wkhtmltopdf\test.png
Loading page (1/2)
Rendering (2/2)
Done

C:\Users\Administrator>D:\wkhtmltopdf\bin\wkhtmltopdf http://pm.jlwgroups.com/htmltofile/index.html D:\wkhtmltopdf\test.pdf
Loading pages (1/6)
Counting pages (2/6)
Resolving links (4/6)
Loading headers and footers (5/6)
Printing pages (6/6)
Done
C:\Users\Administrator>
```

### ubuntu安装
- 从官网/wps下载：wkhtmltox_0.12.5-1.xenial_amd64.deb(这个是ubuntu16.04的版本。18的版本去官网下载)
- 上传文件
```
ubuntu@VM-0-9-ubuntu:/opt$ pwd
/opt
ubuntu@VM-0-9-ubuntu:/opt$ ls
jdk1.8.0_231  jdk-8u231-linux-x64.tar.gz  wkhtmltox_0.12.5-1.xenial_amd64.deb
```
- 安装文件
```
ubuntu@VM-0-9-ubuntu:/opt$ sudo dpkg -i wkhtmltox_0.12.5-1.xenial_amd64.deb 

(Reading database ... 66482 files and directories currently installed.)
Preparing to unpack wkhtmltox_0.12.5-1.xenial_amd64.deb ...
Unpacking wkhtmltox (1:0.12.5-1.xenial) over (1:0.12.5-1.xenial) ...
dpkg: dependency problems prevent configuration of wkhtmltox:
 wkhtmltox depends on fontconfig; however:
  Package fontconfig is not installed.
 wkhtmltox depends on libjpeg-turbo8; however:
  Package libjpeg-turbo8 is not installed.
 wkhtmltox depends on libxrender1; however:
  Package libxrender1 is not installed.
 wkhtmltox depends on xfonts-75dpi; however:
  Package xfonts-75dpi is not installed.
 wkhtmltox depends on xfonts-base; however:
  Package xfonts-base is not installed.

dpkg: error processing package wkhtmltox (--install):
 dependency problems - leaving unconfigured
Processing triggers for man-db (2.7.5-1) ...
Errors were encountered while processing:
 wkhtmltox


ubuntu@VM-0-9-ubuntu:/opt$ sudo apt-get -f install
......
ubuntu@VM-0-9-ubuntu:/opt$ sudo dpkg -i wkhtmltox_0.12.5-1.xenial_amd64.deb 

(Reading database ... 67562 files and directories currently installed.)
Preparing to unpack wkhtmltox_0.12.5-1.xenial_amd64.deb ...
Unpacking wkhtmltox (1:0.12.5-1.xenial) over (1:0.12.5-1.xenial) ...
Setting up wkhtmltox (1:0.12.5-1.xenial) ...
Processing triggers for man-db (2.7.5-1) ...

ubuntu@VM-0-9-ubuntu:/opt$ whereis wkhtmltoimage
wkhtmltoimage: /usr/local/bin/wkhtmltoimage
```
- 测试安装结果
```
ubuntu@VM-0-9-ubuntu:/opt$ sudo /usr/local/bin/wkhtmltoimage http://pm.jlwgroups.com/htmltofile/index.html test1.png
Loading page (1/2)
Rendering (2/2)                                                    
Done                                                               
```