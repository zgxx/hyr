@echo off
::ECHO ��鱾���Ƿ�Ϊ������
:YES
tasklist |findstr /i "HdSvr.exe"
if %errorlevel%==0 (goto 1) else (goto 2)

:1
ECHO �����ȴ򿪺�������д�����ɾ���ټ���
pause

for /l %%i in (1,1,3) do echo.
ECHO ������ʱ�ļ��к�Ŀ���ļ���
rd /s /q "D:\TempFolderZGX"
md D:\TempFolderZGX

ECHO ���ƽű�����ʽ��
copy /y *.sql D:\TempFolderZGX\
copy /y 00_�ŵ��ѯ��Ա�ո�ë��Ʒ�֣��Լ��������ۼ�.sql D:\�ɶ�����������޹�˾\

ECHO ���ýű�D:\TempFolderZGX\AutoEXC_name.sql �r(�s_�t)�q
::-U ���ݿ��½����-P ���룬�������޸�
osql -S 127.0.0.1 -d Master -U sa -P Hx789789 -i D:\TempFolderZGX\AutoEXC_name.sql

start D:\�ɶ�����������޹�˾\�������ݿ���.txt
Exit

:2
for /l %%i in (1,1,3) do echo.
echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo                   �������Ƿ�����
echo                 ��Ҫ�ڷ�����������
echo                 ָ���м��ܹ��ĵ���
echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pause
goto YES
