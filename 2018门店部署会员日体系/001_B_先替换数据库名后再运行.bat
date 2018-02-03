@ECHO OFF

echo CTRL+H替换qwe为本机修正堂数据库，保存后再运行

::-U 数据库登陆名，-P 密码，在下面修改
osql -S 127.0.0.1 -d qwe -U sa -P Hx789789 -i D:\TempFolderZGX\00_A_新版本按处方药类别促销插入范例-单据部分.sql
osql -S 127.0.0.1 -d qwe -U sa -P Hx789789 -i D:\TempFolderZGX\00_B_新版本按处方药类别促销插入范例_插入明细部分.sql

rd /s /q "D:\TempFolderZGX"
ECHO 部署单据和明细成功接下来加入计划任务
pause