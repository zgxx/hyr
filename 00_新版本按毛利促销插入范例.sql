
--��ȡ���ݲ�����ʱ��
IF exists (select * from tempdb..sysobjects where id = object_id('tempdb..##CxTemp'))
DROP table [dbo].[##CxTemp]
GO

CREATE TABLE [dbo].[##CxTemp](
	[P_ID] [int] NOT NULL,
	[u_id] [int] NOT NULL,
	[retailPrice] NUMERIC(18,4)  NOT NULL,
	[costp] NUMERIC(18,4) NOT NULL,
	[MLL] NUMERIC(18,4) NOT NULL,
	[Class] NUMERIC(18,2) NULL
)

/*
SELECT * FROM ##CxTemp

SELECT Class,COUNT(1) AS �������� FROM ##CxTemp GROUP BY Class ORDER BY Class DESC

SELECT Class,COUNT(1) AS �п������ FROM ##CxTemp C,s_storehouse ST WHERE C.P_ID = ST.p_id
GROUP BY C.Class ORDER BY Class DESC
*/

INSERT INTO ##CxTemp
--ë������30%Ʒ��85��
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,PXMD.retailPrice, PXMD.costp,CONVERT(NUMERIC(18,4),(PXMD.retailPrice -costp)/PXMD.retailPrice) AS MLL,0.85 AS CLASS
FROM Products P,--s_storehouse ST,
( SELECT A.P_id,A.retailPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	 AND A.retailPrice <> 0 AND A.PrePrice1+A.RecBuyPrice <> 0
	 --�ŵ�۸���ϵ��������ͼ�û�������������
 ) AS PXMD
WHERE P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id AND PXMD.retailPrice <> 0 	--AND ST.p_id = P.Product_ID 
AND P.Parent_id NOT LIKE '000004000001%'	--�޳���ҩ��Ƭ
AND (PXMD.retailPrice -costp)/PXMD.retailPrice >= 0.3
ORDER BY MLL DESC

INSERT INTO ##CxTemp
--ë������5%С��30%Ʒ��95��
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,PXMD.retailPrice, PXMD.costp,CONVERT(NUMERIC(18,4),(PXMD.retailPrice -costp)/PXMD.retailPrice) AS MLL,0.95 AS CLASS
FROM Products P,--s_storehouse ST,
( SELECT A.P_id,A.retailPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	 AND A.retailPrice <> 0 AND A.PrePrice1+A.RecBuyPrice <> 0
	 --�ŵ�۸���ϵ��������ͼ�û�������������
 ) AS PXMD
WHERE P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id AND PXMD.retailPrice <> 0 	--AND ST.p_id = P.Product_ID 
AND P.Parent_id NOT LIKE '000004000001%'	--�޳���ҩ��Ƭ
AND (PXMD.retailPrice -costp)/PXMD.retailPrice >= 0.05
AND (PXMD.retailPrice -costp)/PXMD.retailPrice < 0.3
ORDER BY MLL DESC


INSERT INTO ##CxTemp
--ë������2%С��5%Ʒ��98��
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,PXMD.retailPrice, PXMD.costp,CONVERT(NUMERIC(18,4),(PXMD.retailPrice -costp)/PXMD.retailPrice) AS MLL,0.98 AS CLASS
FROM Products P,--s_storehouse ST,
( SELECT A.P_id,A.retailPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	 AND A.retailPrice <> 0 AND A.PrePrice1+A.RecBuyPrice <> 0
	 --�ŵ�۸���ϵ��������ͼ�û�������������
 ) AS PXMD
WHERE P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id AND PXMD.retailPrice <> 0 	--AND ST.p_id = P.Product_ID 
AND P.Parent_id NOT LIKE '000004000001%'	--�޳���ҩ��Ƭ
AND (PXMD.retailPrice -costp)/PXMD.retailPrice >= 0.02
AND (PXMD.retailPrice -costp)/PXMD.retailPrice < 0.05
ORDER BY MLL DESC


INSERT INTO ##CxTemp
--ë��С��2%Ʒ�ֲ�����
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,PXMD.retailPrice, PXMD.costp,CONVERT(NUMERIC(18,4),(PXMD.retailPrice -costp)/PXMD.retailPrice) AS MLL,1 AS CLASS
FROM Products P,--s_storehouse ST,
( SELECT A.P_id,A.retailPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	 AND A.retailPrice <> 0 AND A.PrePrice1+A.RecBuyPrice <> 0
	 --�ŵ�۸���ϵ��������ͼ�û�������������
 ) AS PXMD
WHERE P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id AND PXMD.retailPrice <> 0 	--AND ST.p_id = P.Product_ID 
AND P.Parent_id NOT LIKE '000004000001%'	--�޳���ҩ��Ƭ
AND (PXMD.retailPrice -costp)/PXMD.retailPrice < 0.02
ORDER BY MLL DESC


--�����ִ��۵ı���������ʱ��
IF exists (select * from tempdb..sysobjects where id = object_id('tempdb..#CxZKTemp'))
DROP table [dbo].[#CxZKTemp]
CREATE TABLE [dbo].[#CxZKTemp]([ZKL] NUMERIC(18,2) NOT NULL)
INSERT INTO #CxZKTemp VALUES (0.85),(0.95),(0.98),(1.00)

DECLARE @ZK NUMERIC(18,2),@BID INT,@MBID INT,@DBID INT,@PNAME VARCHAR(100),@PID INT,@UID INT,@STIME DATETIME,@ETIME DATETIME
SET @STIME = '2018-01-01 00:00:00.000'		--�˴�Ϊ���ʼʱ��
SET @ETIME = '2030-12-31 00:00:00.000'		--�˴�Ϊ�����ʱ��

--��ʼѭ�������뵥�ݺ���ϸ
DECLARE CURSOR_CX CURSOR FOR 
	SELECT * FROM #CxZKTemp  --TOP 1
OPEN CURSOR_CX
	FETCH NEXT FROM CURSOR_CX INTO @ZK
WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @MBID = MAX(billid) FROM PM_Index  --��õ�ǰ���billid

	--����PM_Index
	INSERT INTO PM_Index (billdate,billnumber,billtype,e_id,note,auditman,auditdate,billstate,begindate,
	enddate,begintime,endtime,weeks,days,RetailBill,SaleBill,VipType,p_id,MinPQty,MinMoney,SumSpeP,SumDisP,ChangeOne,
	Dts_BillID,Factory,LimitDays,MaxQty,MaxPCount,VipMaxQty,VipMaxPCount)
	VALUES(
	'2018-01-15 00:00:00.000','CX-180115-'+RIGHT('00000'+CONVERT(VARCHAR(6),@MBID+1),5),17,2,'�ŵ�� 2018 ��Ա��,'+CONVERT(VARCHAR(6),@ZK),2,CONVERT(VARCHAR(10),GETDATE(),23),'0',@STIME,@ETIME,'1900-01-01 00:00:00.000',
	'1900-01-01 23:59:59.000','1111111','00000100000000010000000001000000',	'1',0,0,0,'0.0000','0.0000','0','0','0','0',' ','1','0.0000','0','0.0000','0')

	SELECT @DBID = MAX(billid) FROM PM_Index    --��ò�����billid

	--����PM_ClientStock
	INSERT INTO PM_ClientStock (billid,mode,data_id,Dts_Detail_ID) VALUES(@DBID,0,0,0),(@DBID,1,0,0)

	--��ʼ����PM_Detail
	INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,
	billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
	SELECT @DBID,P_ID,u_id,0,0,@ZK,0,1,0,0,0,'',0
	FROM ##CxTemp WHERE CLASS = @ZK

	FETCH NEXT FROM CURSOR_CX INTO @ZK
END
CLOSE CURSOR_CX
DEALLOCATE CURSOR_CX
