
--��ȡ���ݲ�����ʱ��
IF exists (select * from tempdb..sysobjects where id = object_id('tempdb..##CxTemp'))
DROP table [dbo].[##CxTemp]
GO

CREATE TABLE [dbo].[##CxTemp](
	[P_ID] [int] NOT NULL,
	[u_id] [int] NOT NULL,
	[retailPrice] NUMERIC(18,4)  NOT NULL,
	[costp] NUMERIC(18,4) NOT NULL,
	[profit_rate] NUMERIC(18,4) NOT NULL,
	[Class] NUMERIC(18,2) NOT NULL,
	[type] INT NOT NULL,		--1�����Ա��ʱ��0����ǻ�Ա��ʱ
)

/*
SELECT * FROM ##CxTemp

SELECT Class AS ��������,CASE WHEN type = 0 THEN '�ǻ�Ա��' ELSE '��Ա��' END AS ���,
CASE WHEN profit_rate < 0 THEN '��ë������' ELSE '' END AS ӯ��,COUNT(1) AS �������� FROM ##CxTemp 
GROUP BY Class,type,CASE WHEN profit_rate < 0 THEN '��ë������' ELSE '' END
ORDER BY ���,��������,ӯ�� DESC

SELECT C.Class AS ��������,CASE WHEN C.type = 0 THEN '�ǻ�Ա��' ELSE '��Ա��' END AS ���,
CASE WHEN C.profit_rate < 0 THEN '��ë������' ELSE '' END AS ӯ��,COUNT(1) AS �п������ FROM ##CxTemp C,
(SELECT p_id,SUM(1) AS kc FROM s_storehouse GROUP BY p_id) ST  --�ܿ����Ʒ��
 WHERE C.P_ID = ST.p_id
GROUP BY C.Class,C.type,CASE WHEN C.profit_rate < 0 THEN '��ë������' ELSE '' END
ORDER BY ���,��������,ӯ�� DESC
*/


INSERT INTO ##CxTemp
--��Ա��,�Ǵ���ҩ85�۵�Ʒ��
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,PXMD.retailPrice, PXMD.costp,CONVERT(NUMERIC(18,4),(PXMD.retailPrice -costp)/PXMD.retailPrice) AS MLL,0.85 AS CLASS,1 AS type
FROM Products P,--s_storehouse ST,
( SELECT A.P_id,A.retailPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	 AND A.retailPrice <> 0 AND A.PrePrice1+A.RecBuyPrice <> 0
	 --�ŵ�۸���ϵ��������ͼ�û�������������
 ) AS PXMD
WHERE P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id AND PXMD.retailPrice > 0 	--AND ST.p_id = P.Product_ID 
AND P.DELETED = 0 AND P.Isdir = 0 AND P.Product_ID NOT IN (8000,8001,8456,19072)	--�ĸ������޳�
AND P.Parent_id NOT LIKE '000004000001%'	--�޳���ҩ��Ƭ
AND P.OTCFlag = 0 AND P.ColdStore = 0
AND P.Factory NOT LIKE '�人���ĿƼ�%' AND P.Factory NOT LIKE '%������%'
AND P.Product_ID NOT IN (7310)		--������½�¹�ǽ�(��¹)(ֽ��)
AND P.name NOT LIKE '%�ֲ%'
--�л�Ա�۵���Ʒ���μӻ�Ա��
AND P.Product_ID NOT IN (SELECT DISTINCT P.Product_ID FROM Products P,Px_price PX WHERE P.Product_ID = PX.P_id AND PX.VipPrice> 0) 
ORDER BY MLL DESC


INSERT INTO ##CxTemp
--��Ա��,����ҩ95�۵�Ʒ�֣���������
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,PXMD.retailPrice, PXMD.costp,CONVERT(NUMERIC(18,4),(PXMD.retailPrice -costp)/PXMD.retailPrice) AS MLL,0.95 AS CLASS,1 AS type
FROM Products P,--s_storehouse ST,
( SELECT A.P_id,A.retailPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	 AND A.retailPrice <> 0 AND A.PrePrice1+A.RecBuyPrice <> 0
	 --�ŵ�۸���ϵ��������ͼ�û�������������
 ) AS PXMD
WHERE P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id AND PXMD.retailPrice > 0 	--AND ST.p_id = P.Product_ID 
AND P.DELETED = 0 AND P.Isdir = 0 AND P.Product_ID NOT IN (8000,8001,8456,19072)	--�ĸ������޳�
AND (P.OTCFlag >0 OR P.ColdStore = 1 OR P.Product_ID IN (7310))	--7310�����½�¹�ǽ�(��¹)(ֽ��)�����Ա��95����
--�л�Ա�۵���Ʒ���μӻ�Ա��
AND P.Product_ID NOT IN (SELECT DISTINCT P.Product_ID FROM Products P,Px_price PX WHERE P.Product_ID = PX.P_id AND PX.VipPrice> 0) 
ORDER BY MLL DESC


INSERT INTO ##CxTemp
--��Ա��,����98�۵�Ʒ��
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,PXMD.retailPrice, PXMD.costp,CONVERT(NUMERIC(18,4),(PXMD.retailPrice -costp)/PXMD.retailPrice) AS MLL,0.98 AS CLASS,1 AS type
FROM Products P,--s_storehouse ST,
( SELECT A.P_id,A.retailPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	 AND A.retailPrice <> 0 
	 --�ŵ�۸���ϵ��������ͼ�û�������������
 ) AS PXMD
WHERE P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id AND PXMD.retailPrice > 0 	--AND ST.p_id = P.Product_ID 
AND P.DELETED = 0 AND P.Isdir = 0
AND (P.Factory LIKE '�人���ĿƼ�%' OR P.Factory LIKE '%������%')
ORDER BY MLL DESC


INSERT INTO ##CxTemp
--�ǻ�Ա��,98�۵�Ʒ��
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,PXMD.retailPrice, PXMD.costp,CONVERT(NUMERIC(18,4),(PXMD.retailPrice -costp)/PXMD.retailPrice) AS MLL,0.98 AS CLASS,0 AS type
FROM Products P,--s_storehouse ST,
( SELECT A.P_id,A.retailPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	  AND A.retailPrice <> 0 
	 --�ŵ�۸���ϵ��������ͼ�û�������������
 ) AS PXMD
WHERE P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id AND PXMD.retailPrice > 0 	--AND ST.p_id = P.Product_ID 
AND P.DELETED = 0 AND P.Isdir = 0
AND P.Product_ID NOT IN (SELECT DISTINCT P_id FROM Px_price WHERE VipPrice > 0)	--�����л�Ա����Ʒƽʱ������98�ۣ�����ͨ��Ա��ִ��
AND P.Parent_id NOT LIKE '000004000001%' AND P.Product_ID NOT IN (8000,8001,8456,19072) AND P.name NOT LIKE '%�ֲ%'
--�л�Ա�۵���Ʒ���μӻ�Ա��
AND P.Product_ID NOT IN (SELECT DISTINCT P.Product_ID FROM Products P,Px_price PX WHERE P.Product_ID = PX.P_id AND PX.VipPrice> 0) 
ORDER BY MLL DESC

--++++++++++++++++++++++++++++++++++++++

--�Ƚ����ִ��۵ı��������ݺţ��ͱ�ע������ʱ��
IF exists (select * from tempdb..sysobjects where id = object_id('tempdb..#CxZKTemp'))
DROP table [dbo].[#CxZKTemp]
CREATE TABLE [dbo].[#CxZKTemp]([ZKL] NUMERIC(18,2) NOT NULL,[BNUM] VARCHAR(3) NOT NULL,[NOTE] VARCHAR(80) NOT NULL,[type] INT NOT NULL)	--typeΪ1�ǻ�Ա�յ���
INSERT INTO #CxZKTemp VALUES 
(0.85,'20','�ŵ��2018 ��Ա�� �Ǵ���Ʒ��85��',1),
(0.95,'21','�ŵ��2018 ��Ա�� ����ҩ95��',1),
(0.98,'22','�ŵ��2018 ��Ա�� ����Ʒ��98��',1),
(0.98,'30','�ŵ��2018 �ǻ�Ա�� ��Ա98��',0)

DECLARE @ZKL1 NUMERIC(18,2),@BNUM1 VARCHAR(3),@NOTE1 VARCHAR(80),@DBID1 INT,
@ZKL2 NUMERIC(18,2),@BNUM2 VARCHAR(3),@NOTE2 VARCHAR(80),@DBID2 INT,
@PID INT,@UID INT

--��ʼѭ�������뵥�ݺ���ϸ
--����Ҫ�����Ա�յ����
DECLARE CURSOR_CX_HYR CURSOR FOR 
	SELECT zkl,bnum,note FROM #CxZKTemp WHERE type = 1
OPEN CURSOR_CX_HYR
	FETCH NEXT FROM CURSOR_CX_HYR INTO @ZKL1,@BNUM1,@NOTE1
WHILE @@FETCH_STATUS = 0
BEGIN

	--����PM_Index
	INSERT INTO PM_Index (billdate,billnumber,billtype,e_id,note,auditman,auditdate,billstate,begindate,
	enddate,begintime,endtime,weeks,days,RetailBill,SaleBill,VipType,p_id,MinPQty,MinMoney,SumSpeP,SumDisP,ChangeOne,
	Dts_BillID,Factory,LimitDays,MaxQty,MaxPCount,VipMaxQty,VipMaxPCount)
	VALUES(
	'2018-01-01 00:00:00.000','CX-180101-'+RIGHT('000'+@BNUM1,6),17,2,@NOTE1,2,CONVERT(VARCHAR(10),GETDATE(),23),'0','2018-01-01 00:00:00.000','2030-01-15 00:00:00.000',
	'1900-01-01 00:00:00.000','1900-01-01 23:59:59.000','1111111','00000100000000010000000001000000','1',0,0,0,'0.0000','0.0000','0','0','0','0',
	' ','1','0.0000','0','0.0000','0')

	SELECT @DBID1 = MAX(billid) FROM PM_Index    --��ò�����billid

	--����PM_ClientStock
	INSERT INTO PM_ClientStock (billid,mode,data_id,Dts_Detail_ID) VALUES(@DBID1,0,0,0),(@DBID1,1,0,0)

	--��ʼ����PM_Detail
	INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
	SELECT @DBID1,P_ID,u_id,0,0,@ZKL1,0,1,0,0,0,'',0
	FROM ##CxTemp WHERE CLASS = @ZKL1 AND type = 1

	FETCH NEXT FROM CURSOR_CX_HYR INTO @ZKL1,@BNUM1,@NOTE1
END
CLOSE CURSOR_CX_HYR
DEALLOCATE CURSOR_CX_HYR

--++++++++++++++++++++++++++++++++++++++
--Ҫ����ǻ�Ա�յ�
DECLARE CURSOR_CX_HYR CURSOR FOR 
	SELECT zkl,bnum,note FROM #CxZKTemp WHERE type = 0
OPEN CURSOR_CX_HYR
	FETCH NEXT FROM CURSOR_CX_HYR INTO @ZKL2,@BNUM2,@NOTE2
WHILE @@FETCH_STATUS = 0
BEGIN

	--����PM_Index
	INSERT INTO PM_Index (billdate,billnumber,billtype,e_id,note,auditman,auditdate,billstate,begindate,
	enddate,begintime,endtime,weeks,days,RetailBill,SaleBill,VipType,p_id,MinPQty,MinMoney,SumSpeP,SumDisP,ChangeOne,
	Dts_BillID,Factory,LimitDays,MaxQty,MaxPCount,VipMaxQty,VipMaxPCount)
	VALUES(
	'2018-01-01 00:00:00.000','CX-180101-'+RIGHT('000'+@BNUM2,6),17,2,@NOTE2,2,CONVERT(VARCHAR(10),GETDATE(),23),'0','2018-01-01 00:00:00.000','2030-01-15 00:00:00.000',
	'1900-01-01 00:00:00.000','1900-01-01 23:59:59.000','1111111','11111011111111101111111110111111','1',0,0,0,'0.0000','0.0000','0','0','0','0',
	' ','1','0.0000','0','0.0000','0')

	SELECT @DBID2 = MAX(billid) FROM PM_Index    --��ò�����billid

	--����PM_ClientStock
	INSERT INTO PM_ClientStock (billid,mode,data_id,Dts_Detail_ID) VALUES(@DBID2,0,0,0),(@DBID2,1,0,0)

	--��ʼ����PM_Detail
	INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
	SELECT @DBID2,P_ID,u_id,0,0,@ZKL2,0,1,0,0,0,'',0
	FROM ##CxTemp WHERE CLASS = @ZKL2 AND type = 0

	FETCH NEXT FROM CURSOR_CX_HYR INTO @ZKL2,@BNUM2,@NOTE2
END
CLOSE CURSOR_CX_HYR
DEALLOCATE CURSOR_CX_HYR
