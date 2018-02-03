echo 开始更新会员日明细,请勿关闭
@echo off 
if "%1"=="h" goto begin 

start mshta vbscript:createobject("wscript.shell").run("""%~nx0"" h",0)(window.close)&&exit 

:begin 
osql -S 127.0.0.1 -d qwe -U sa -P Hx789789 -i D:\成都海翔软件有限公司\2018门店部署会员日体系\00_B_新版本按处方药类别促销插入范例_插入明细部分.sql