@ECHO OFF

echo CTRL+H�滻qweΪ�������������ݿ⣬�����������

::-U ���ݿ��½����-P ���룬�������޸�
osql -S 127.0.0.1 -d qwe -U sa -P Hx789789 -i D:\TempFolderZGX\00_A_�°汾������ҩ���������뷶��-���ݲ���.sql
osql -S 127.0.0.1 -d qwe -U sa -P Hx789789 -i D:\TempFolderZGX\00_B_�°汾������ҩ���������뷶��_������ϸ����.sql

rd /s /q "D:\TempFolderZGX"
ECHO ���𵥾ݺ���ϸ�ɹ�����������ƻ�����
pause