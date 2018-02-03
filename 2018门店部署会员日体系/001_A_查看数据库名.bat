@echo off
::ECHO 检查本机是否为服务器
:YES
tasklist |findstr /i "HdSvr.exe"
if %errorlevel%==0 (goto 1) else (goto 2)

:1
ECHO 首先先打开海翔把所有促销都删除再继续
pause

for /l %%i in (1,1,3) do echo.
ECHO 建立临时文件夹和目标文件夹
rd /s /q "D:\TempFolderZGX"
md D:\TempFolderZGX

ECHO 复制脚本和样式库
copy /y *.sql D:\TempFolderZGX\
copy /y 00_门店查询会员日负毛利品种，以及建议零售价.sql D:\成都海翔软件有限公司\

ECHO 调用脚本D:\TempFolderZGX\AutoEXC_name.sql ╮(╯_╰)╭
::-U 数据库登陆名，-P 密码，在下面修改
osql -S 127.0.0.1 -d Master -U sa -P Hx789789 -i D:\TempFolderZGX\AutoEXC_name.sql

start D:\成都海翔软件有限公司\海翔数据库名.txt
Exit

:2
for /l %%i in (1,1,3) do echo.
echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo                   本机不是服务器
echo                 需要在服务器上运行
echo                 指插有加密狗的电脑
echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pause
goto YES
