@ECHO OFF

::CTRL+H�滻chxztΪ�������������ݿ⣬�����������

::-U ���ݿ��½����-P ���룬�������޸�
osql -S 127.0.0.1 -d chxzt -U sa -P Hx789789 -i D:\TempFolderZGX\00_A_�°汾������ҩ���������뷶��-���ݲ���.sql
osql -S 127.0.0.1 -d chxzt -U sa -P Hx789789 -i D:\TempFolderZGX\00_B_�°汾������ҩ���������뷶��_������ϸ����.sql

::start D:\TempFolderZGX\
::start D:\TempFolderZGX\ҩƷ���_ҽ����Ҫ.xls

rd /s /q "D:\TempFolderZGX"
ECHO ���𵥾ݺ���ϸ�ɹ�����������ƻ�����
pause