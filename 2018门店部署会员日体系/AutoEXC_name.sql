sp_configure 'show advanced options',1
reconfigure
GO
sp_configure 'xp_cmdshell',1
reconfigure
GO
sp_configure 'Ad Hoc Distributed Queries',1
reconfigure
GO
sp_configure 'Ole Automation Procedures',1
reconfigure
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--����������������
EXEC master..xp_cmdshell 'bcp "SELECT accountname,accountdb FROM master..HdAccount" queryout "D:\�ɶ�����������޹�˾\�������ݿ���.txt" -c -q -S"." -U"sa" -P"Hx789789"'