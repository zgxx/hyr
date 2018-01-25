
--提取数据插入临时表
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
	[type] INT NOT NULL,		--1代表会员日时，0代表非会员日时
)

/*
SELECT * FROM ##CxTemp

SELECT Class AS 打折力度,CASE WHEN type = 0 THEN '非会员日' ELSE '会员日' END AS 类别,
CASE WHEN profit_rate < 0 THEN '负毛利数量' ELSE '' END AS 盈亏,COUNT(1) AS 所有数量 FROM ##CxTemp 
GROUP BY Class,type,CASE WHEN profit_rate < 0 THEN '负毛利数量' ELSE '' END
ORDER BY 类别,打折力度,盈亏 DESC

SELECT C.Class AS 打折力度,CASE WHEN C.type = 0 THEN '非会员日' ELSE '会员日' END AS 类别,
CASE WHEN C.profit_rate < 0 THEN '负毛利数量' ELSE '' END AS 盈亏,COUNT(1) AS 有库存数量 FROM ##CxTemp C,
(SELECT p_id,SUM(1) AS kc FROM s_storehouse GROUP BY p_id) ST  --总库存商品数
 WHERE C.P_ID = ST.p_id
GROUP BY C.Class,C.type,CASE WHEN C.profit_rate < 0 THEN '负毛利数量' ELSE '' END
ORDER BY 类别,打折力度,盈亏 DESC
*/


INSERT INTO ##CxTemp
--会员日,非处方药85折的品种
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,PXMD.retailPrice, PXMD.costp,CONVERT(NUMERIC(18,4),(PXMD.retailPrice -costp)/PXMD.retailPrice) AS MLL,0.85 AS CLASS,1 AS type
FROM Products P,--s_storehouse ST,
( SELECT A.P_id,A.retailPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	 AND A.retailPrice <> 0 AND A.PrePrice1+A.RecBuyPrice <> 0
	 --门店价格体系，如果配送价没有则用最近进价
 ) AS PXMD
WHERE P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id AND PXMD.retailPrice > 0 	--AND ST.p_id = P.Product_ID 
AND P.DELETED = 0 AND P.Isdir = 0 AND P.Product_ID NOT IN (8000,8001,8456,19072)	--四个拆零剔除
AND P.Parent_id NOT LIKE '000004000001%'	--剔除中药饮片
AND P.OTCFlag = 0 AND P.ColdStore = 0
AND P.Factory NOT LIKE '武汉国灸科技%' AND P.Factory NOT LIKE '%奇力康%'
AND P.Product_ID NOT IN (7310)		--不添加新疆鹿角胶(茎鹿)(纸盒)
AND P.name NOT LIKE '%瑾植%'
--有会员价的商品不参加会员日
AND P.Product_ID NOT IN (SELECT DISTINCT P.Product_ID FROM Products P,Px_price PX WHERE P.Product_ID = PX.P_id AND PX.VipPrice> 0) 
ORDER BY MLL DESC


INSERT INTO ##CxTemp
--会员日,处方药95折的品种，包含冷链
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,PXMD.retailPrice, PXMD.costp,CONVERT(NUMERIC(18,4),(PXMD.retailPrice -costp)/PXMD.retailPrice) AS MLL,0.95 AS CLASS,1 AS type
FROM Products P,--s_storehouse ST,
( SELECT A.P_id,A.retailPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	 AND A.retailPrice <> 0 AND A.PrePrice1+A.RecBuyPrice <> 0
	 --门店价格体系，如果配送价没有则用最近进价
 ) AS PXMD
WHERE P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id AND PXMD.retailPrice > 0 	--AND ST.p_id = P.Product_ID 
AND P.DELETED = 0 AND P.Isdir = 0 AND P.Product_ID NOT IN (8000,8001,8456,19072)	--四个拆零剔除
AND (P.OTCFlag >0 OR P.ColdStore = 1 OR P.Product_ID IN (7310))	--7310代表新疆鹿角胶(茎鹿)(纸盒)加入会员日95折里
--有会员价的商品不参加会员日
AND P.Product_ID NOT IN (SELECT DISTINCT P.Product_ID FROM Products P,Px_price PX WHERE P.Product_ID = PX.P_id AND PX.VipPrice> 0) 
ORDER BY MLL DESC


INSERT INTO ##CxTemp
--会员日,部分98折的品种
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,PXMD.retailPrice, PXMD.costp,CONVERT(NUMERIC(18,4),(PXMD.retailPrice -costp)/PXMD.retailPrice) AS MLL,0.98 AS CLASS,1 AS type
FROM Products P,--s_storehouse ST,
( SELECT A.P_id,A.retailPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	 AND A.retailPrice <> 0 
	 --门店价格体系，如果配送价没有则用最近进价
 ) AS PXMD
WHERE P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id AND PXMD.retailPrice > 0 	--AND ST.p_id = P.Product_ID 
AND P.DELETED = 0 AND P.Isdir = 0
AND (P.Factory LIKE '武汉国灸科技%' OR P.Factory LIKE '%奇力康%')
ORDER BY MLL DESC


INSERT INTO ##CxTemp
--非会员日,98折的品种
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,PXMD.retailPrice, PXMD.costp,CONVERT(NUMERIC(18,4),(PXMD.retailPrice -costp)/PXMD.retailPrice) AS MLL,0.98 AS CLASS,0 AS type
FROM Products P,--s_storehouse ST,
( SELECT A.P_id,A.retailPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	  AND A.retailPrice <> 0 
	 --门店价格体系，如果配送价没有则用最近进价
 ) AS PXMD
WHERE P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id AND PXMD.retailPrice > 0 	--AND ST.p_id = P.Product_ID 
AND P.DELETED = 0 AND P.Isdir = 0
AND P.Product_ID NOT IN (SELECT DISTINCT P_id FROM Px_price WHERE VipPrice > 0)	--凡是有会员价商品平时不参与98折，按普通会员价执行
AND P.Parent_id NOT LIKE '000004000001%' AND P.Product_ID NOT IN (8000,8001,8456,19072) AND P.name NOT LIKE '%瑾植%'
--有会员价的商品不参加会员日
AND P.Product_ID NOT IN (SELECT DISTINCT P.Product_ID FROM Products P,Px_price PX WHERE P.Product_ID = PX.P_id AND PX.VipPrice> 0) 
ORDER BY MLL DESC

--++++++++++++++++++++++++++++++++++++++

--先将几种打折的比例，单据号，和备注插入临时表
IF exists (select * from tempdb..sysobjects where id = object_id('tempdb..#CxZKTemp'))
DROP table [dbo].[#CxZKTemp]
CREATE TABLE [dbo].[#CxZKTemp]([ZKL] NUMERIC(18,2) NOT NULL,[BNUM] VARCHAR(3) NOT NULL,[NOTE] VARCHAR(80) NOT NULL,[type] INT NOT NULL)	--type为1是会员日当天
INSERT INTO #CxZKTemp VALUES 
(0.85,'20','门店版2018 会员日 非处方品种85折',1),
(0.95,'21','门店版2018 会员日 处方药95折',1),
(0.98,'22','门店版2018 会员日 部分品种98折',1),
(0.98,'30','门店版2018 非会员日 会员98折',0)

DECLARE @ZKL1 NUMERIC(18,2),@BNUM1 VARCHAR(3),@NOTE1 VARCHAR(80),@DBID1 INT,
@ZKL2 NUMERIC(18,2),@BNUM2 VARCHAR(3),@NOTE2 VARCHAR(80),@DBID2 INT,
@PID INT,@UID INT

--开始循环，插入单据和明细
--首先要插入会员日当天的
DECLARE CURSOR_CX_HYR CURSOR FOR 
	SELECT zkl,bnum,note FROM #CxZKTemp WHERE type = 1
OPEN CURSOR_CX_HYR
	FETCH NEXT FROM CURSOR_CX_HYR INTO @ZKL1,@BNUM1,@NOTE1
WHILE @@FETCH_STATUS = 0
BEGIN

	--插入PM_Index
	INSERT INTO PM_Index (billdate,billnumber,billtype,e_id,note,auditman,auditdate,billstate,begindate,
	enddate,begintime,endtime,weeks,days,RetailBill,SaleBill,VipType,p_id,MinPQty,MinMoney,SumSpeP,SumDisP,ChangeOne,
	Dts_BillID,Factory,LimitDays,MaxQty,MaxPCount,VipMaxQty,VipMaxPCount)
	VALUES(
	'2018-01-01 00:00:00.000','CX-180101-'+RIGHT('000'+@BNUM1,6),17,2,@NOTE1,2,CONVERT(VARCHAR(10),GETDATE(),23),'0','2018-01-01 00:00:00.000','2030-01-15 00:00:00.000',
	'1900-01-01 00:00:00.000','1900-01-01 23:59:59.000','1111111','00000100000000010000000001000000','1',0,0,0,'0.0000','0.0000','0','0','0','0',
	' ','1','0.0000','0','0.0000','0')

	SELECT @DBID1 = MAX(billid) FROM PM_Index    --获得插入后的billid

	--插入PM_ClientStock
	INSERT INTO PM_ClientStock (billid,mode,data_id,Dts_Detail_ID) VALUES(@DBID1,0,0,0),(@DBID1,1,0,0)

	--开始插入PM_Detail
	INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
	SELECT @DBID1,P_ID,u_id,0,0,@ZKL1,0,1,0,0,0,'',0
	FROM ##CxTemp WHERE CLASS = @ZKL1 AND type = 1

	FETCH NEXT FROM CURSOR_CX_HYR INTO @ZKL1,@BNUM1,@NOTE1
END
CLOSE CURSOR_CX_HYR
DEALLOCATE CURSOR_CX_HYR

--++++++++++++++++++++++++++++++++++++++
--要插入非会员日的
DECLARE CURSOR_CX_HYR CURSOR FOR 
	SELECT zkl,bnum,note FROM #CxZKTemp WHERE type = 0
OPEN CURSOR_CX_HYR
	FETCH NEXT FROM CURSOR_CX_HYR INTO @ZKL2,@BNUM2,@NOTE2
WHILE @@FETCH_STATUS = 0
BEGIN

	--插入PM_Index
	INSERT INTO PM_Index (billdate,billnumber,billtype,e_id,note,auditman,auditdate,billstate,begindate,
	enddate,begintime,endtime,weeks,days,RetailBill,SaleBill,VipType,p_id,MinPQty,MinMoney,SumSpeP,SumDisP,ChangeOne,
	Dts_BillID,Factory,LimitDays,MaxQty,MaxPCount,VipMaxQty,VipMaxPCount)
	VALUES(
	'2018-01-01 00:00:00.000','CX-180101-'+RIGHT('000'+@BNUM2,6),17,2,@NOTE2,2,CONVERT(VARCHAR(10),GETDATE(),23),'0','2018-01-01 00:00:00.000','2030-01-15 00:00:00.000',
	'1900-01-01 00:00:00.000','1900-01-01 23:59:59.000','1111111','11111011111111101111111110111111','1',0,0,0,'0.0000','0.0000','0','0','0','0',
	' ','1','0.0000','0','0.0000','0')

	SELECT @DBID2 = MAX(billid) FROM PM_Index    --获得插入后的billid

	--插入PM_ClientStock
	INSERT INTO PM_ClientStock (billid,mode,data_id,Dts_Detail_ID) VALUES(@DBID2,0,0,0),(@DBID2,1,0,0)

	--开始插入PM_Detail
	INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
	SELECT @DBID2,P_ID,u_id,0,0,@ZKL2,0,1,0,0,0,'',0
	FROM ##CxTemp WHERE CLASS = @ZKL2 AND type = 0

	FETCH NEXT FROM CURSOR_CX_HYR INTO @ZKL2,@BNUM2,@NOTE2
END
CLOSE CURSOR_CX_HYR
DEALLOCATE CURSOR_CX_HYR
