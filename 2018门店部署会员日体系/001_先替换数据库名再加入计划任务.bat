echo ��ʼ���»�Ա����ϸ,����ر�
@echo off 
if "%1"=="h" goto begin 

start mshta vbscript:createobject("wscript.shell").run("""%~nx0"" h",0)(window.close)&&exit 

:begin 
osql -S 127.0.0.1 -d qwe -U sa -P Hx789789 -i D:\�ɶ�����������޹�˾\2018�ŵ겿���Ա����ϵ\00_B_�°汾������ҩ���������뷶��_������ϸ����.sql