--2018年2月8日11:44:49，zgx
--加入计划任务，每天自动更新新品种，时间早上8:05开始每隔4小时执行一次
--ansi编码_添加自定限购

--插入促销明细，先提取数据插入暂存表

--IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id = object_id('tempdb..#zgxCxTemp'))	--临时表方法
--DROP table [dbo].[#zgxCxTemp]

--DROP table [dbo].[zgxCxTemp]
IF NOT EXISTS (select * from sysobjects where id = object_id('zgxCxTemp') and OBJECTPROPERTY(id, 'IsUserTable') = 1)  --实表方法，判断如果此表不存在则创建
CREATE TABLE [dbo].[zgxCxTemp](
	[P_ID] [int] NOT NULL,
	[u_id] [int] NOT NULL,
	[retailPrice] NUMERIC(18,4)  NOT NULL,
	[VIPretailPrice] NUMERIC(18,4)  NOT NULL,	--打折后的价格
	[costp] NUMERIC(18,4) NOT NULL,
	[vipprice] NUMERIC(18,4) NOT NULL,
	[profit_rate] NUMERIC(18,4) NOT NULL,			--折后毛利率
	[Class] NUMERIC(18,2) NOT NULL,   --代表打折力度
	[type] INT NOT NULL,		--1代表会员日时，0代表非会员日时
)ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sysindexes WHERE name='IX_zgxCxTemp')
CREATE NONCLUSTERED INDEX IX_zgxCxTemp ON zgxCxTemp([Class],[P_ID],[type])	--建个索引玩

--INCLUDE([profit_rate],[u_id],[retailPrice],[VIPretailPrice],[costp])WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
--ON [PRIMARY]		--INCLUDE在sql2000不支持

TRUNCATE TABLE zgxCxTemp	--先清空表

/*
SELECT * FROM zgxCxTemp

SELECT Class AS 打折力度,CASE WHEN type = 0 THEN '非会员日' ELSE '会员日' END AS 类别,
CASE WHEN profit_rate < 0 THEN '负毛利数量' ELSE '' END AS 盈亏,COUNT(1) AS 所有数量 FROM zgxCxTemp 
GROUP BY Class,type,CASE WHEN profit_rate < 0 THEN '负毛利数量' ELSE '' END
ORDER BY 类别,打折力度,盈亏 DESC

SELECT C.Class AS 打折力度,CASE WHEN C.type = 0 THEN '非会员日' ELSE '会员日' END AS 类别,
CASE WHEN C.profit_rate < 0 THEN '负毛利数量' ELSE '' END AS 盈亏,COUNT(1) AS 有库存数量 FROM zgxCxTemp C,
(SELECT p_id,SUM(1) AS kc FROM s_storehouse GROUP BY p_id) ST  --总库存商品数
 WHERE C.P_ID = ST.p_id
GROUP BY C.Class,C.type,CASE WHEN C.profit_rate < 0 THEN '负毛利数量' ELSE '' END
ORDER BY 类别,打折力度,盈亏 DESC

--检查商品特价促销的商品是否被会员日体系剔除
SELECT * FROM PM_Detail WHERE billid IN 
(SELECT billid FROM PM_Index WHERE billnumber = 'CX-180101-00021')  --非处方85折
AND p_id IN (SELECT Product_ID FROM Products WHERE Code IN ('131543'))  --例如复方板蓝根

*/

SET NOCOUNT ON;
--获得单据号对应的billid，准备插入促销明细
DECLARE @BID_hyr1 INT,@BID_hyr85 INT,@BID_hyr95 INT,@BID_hyr98 INT, @BID_fhyr1 INT,@BID_fhyr98 INT,@BID_tdpz INT,@BID_zbsj INT
SELECT @BID_hyr1  = billid FROM PM_Index WHERE billnumber = 'CX-180101-00020'   --会员日 可选限购品种,可自行添加限购品种，门店版2018
--SELECT @BID_hyr1  = 0
SELECT @BID_hyr85 = billid FROM PM_Index WHERE billnumber = 'CX-180101-00021'	 --门店版2018 会员日 非处方品种85折
SELECT @BID_hyr95 = billid FROM PM_Index WHERE billnumber = 'CX-180101-00022'	 --门店版2018 会员日 处方药95折
SELECT @BID_hyr98 = billid FROM PM_Index WHERE billnumber = 'CX-180101-00023'   --门店版2018 会员日 部分品种98折

--SELECT @BID_fhyr1  = billid FROM PM_Index WHERE billnumber = 'CX-180101-00030'   --门店版2018 非会员日 选定打折品种
SELECT @BID_fhyr1  = 0
SELECT @BID_fhyr98  = billid FROM PM_Index WHERE billnumber = 'CX-180101-00031'   --门店版2018 非会员日 会员98折

SELECT @BID_tdpz  = billid FROM PM_Index WHERE billnumber = 'CX-180201-00010'   --门店版2018 特定品种手动指定价格，限定50个

SELECT @BID_zbsj  = billid FROM PM_Index WHERE billnumber = 'CX-180205-00099'   --总部特定锁价品种，此单据不可修改

--防止门店自行修改此单据，自动审核生效
UPDATE PM_Index SET auditman = 2,billstate = 0 WHERE billnumber =  'CX-180205-00099' AND billtype = 10 AND auditman <> 2 AND billstate <> 0

IF (@BID_hyr1+@BID_hyr85+@BID_hyr95+@BID_hyr98+@BID_fhyr1+@BID_fhyr98+@BID_tdpz) IS NULL 
--IF (ISNULL(@BID_hyr1,0)+ISNULL(@BID_hyr85,0)+ISNULL(@BID_hyr95,0)+ISNULL(@BID_hyr98,0)+ISNULL(@BID_fhyr1,0)+ISNULL(@BID_fhyr98,0)) > 0
BEGIN 
  SELECT [有点问题]='某个促销单被删除，或修改了单据号，存储过程停止更新'
  SELECT [解决方法]='删除所有单据后用脚本重建单据'
      RETURN		--加个return 退出执行SQL
END

INSERT INTO zgxCxTemp
--会员日,非处方药85折的品种
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,ISNULL(PXMD.retailPrice,0) AS retailPrice, ISNULL(PXMD.retailPrice*0.85,0) AS VIPretailPrice,
ISNULL(PXMD.costp,0) AS costp,ISNULL(PXMD.VipPrice,0) AS VipPrice,
CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice*0.85,0) - ISNULL(costp,0))/ISNULL(PXMD.retailPrice*0.85,9999)) AS MLL,  --折后毛利率
0.85 AS CLASS,1 AS type
FROM Products P LEFT JOIN
	( SELECT A.P_id,A.retailPrice,A.VipPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
	A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	  AND A.retailPrice > 0 
	 --门店价格体系，如果配送价没有则用最近进价
	) AS PXMD ON P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id
WHERE P.DELETED = 0 AND P.Isdir = 0 AND P.Product_ID NOT IN (8000,8001,8456,19072,7310)	--四个拆零剔除,7310代表新疆鹿角胶(茎鹿)(纸盒)
AND P.Parent_id NOT LIKE '000004000001%'	--剔除中药饮片
AND P.OTCFlag = 0 AND P.ColdStore = 0
AND P.Factory NOT LIKE '武汉国灸科技%' AND P.Factory NOT LIKE '%奇力康%'
AND P.name NOT LIKE '%瑾植%'
AND P.Product_ID NOT IN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_hyr1,@BID_fhyr1,@BID_tdpz,@BID_zbsj)) --剔除
ORDER BY MLL


INSERT INTO zgxCxTemp
--会员日,处方药95折的品种，包含冷链
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,ISNULL(PXMD.retailPrice,0) AS retailPrice, ISNULL(PXMD.retailPrice*0.95,0) AS VIPretailPrice,
 ISNULL(PXMD.costp,0) AS costp,ISNULL(PXMD.VipPrice,0) AS VipPrice,
CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice*0.95,0) - ISNULL(costp,0))/ISNULL(PXMD.retailPrice*0.95,9999)) AS MLL,  --折后毛利率
0.95 AS CLASS,1 AS type
FROM Products P LEFT JOIN
( SELECT A.P_id,A.retailPrice,A.VipPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	  AND A.retailPrice > 0 
	 --门店价格体系，如果配送价没有则用最近进价
 ) AS PXMD ON P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id
WHERE P.DELETED = 0 AND P.Isdir = 0 AND P.Product_ID NOT IN (8000,8001,8456,19072)	--四个拆零剔除
AND (P.OTCFlag >0 OR P.ColdStore = 1 OR P.Product_ID IN (7310) )	--7310代表新疆鹿角胶(茎鹿)(纸盒)加入会员日95折里
AND P.Product_ID NOT IN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_hyr1,@BID_fhyr1,@BID_tdpz,@BID_zbsj)) --剔除
ORDER BY MLL


INSERT INTO zgxCxTemp
--会员日,特定部分98折的品种
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,ISNULL(PXMD.retailPrice,0) AS retailPrice,  ISNULL(PXMD.retailPrice*0.98,0) AS VIPretailPrice,
ISNULL(PXMD.costp,0) AS costp,ISNULL(PXMD.VipPrice,0) AS VipPrice,
CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice*0.98,0) - ISNULL(costp,0))/ISNULL(PXMD.retailPrice*0.98,9999)) AS MLL,  --折后毛利率
0.98 AS CLASS,1 AS type
FROM Products P LEFT JOIN
( SELECT A.P_id,A.retailPrice,A.VipPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	  AND A.retailPrice > 0 
	 --门店价格体系，如果配送价没有则用最近进价
 ) AS PXMD ON P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id
WHERE P.DELETED = 0 AND P.Isdir = 0
AND (P.Factory LIKE '武汉国灸科技%' OR P.Factory LIKE '%奇力康%')		--手动添加了这些品种
ORDER BY MLL


INSERT INTO zgxCxTemp
--非会员日,98折的品种,凡是有会员价商品不参与98折，按普通会员价执行
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,ISNULL(PXMD.retailPrice,0) AS retailPrice, ISNULL(PXMD.retailPrice*0.98,0) AS VIPretailPrice,
ISNULL(PXMD.costp,0) AS costp,ISNULL(PXMD.VipPrice,0) AS VipPrice,
CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice*0.98,0) - ISNULL(costp,0))/ISNULL(PXMD.retailPrice*0.98,9999)) AS MLL,  --折后毛利率
0.98 AS CLASS,0 AS type
FROM Products P LEFT JOIN
( SELECT A.P_id,A.retailPrice,A.VipPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	  AND A.retailPrice > 0 
	 --门店价格体系，如果配送价没有则用最近进价
 ) AS PXMD ON P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id
WHERE  P.DELETED = 0 AND P.Isdir = 0
AND (PXMD.VipPrice = 0 OR PXMD.VipPrice IS NULL)		--会员价的品种不参与打折
AND P.Parent_id NOT LIKE '000004000001%' AND P.Product_ID NOT IN (8000,8001,8456,19072) AND P.name NOT LIKE '%瑾植%'
AND P.Product_ID NOT IN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_hyr1,@BID_fhyr1,@BID_tdpz,@BID_zbsj)) --剔除
ORDER BY MLL

------------------



SET NOCOUNT OFF;

--删除会员日体系里，被指定忽略的品种
DELETE FROM PM_Detail WHERE billid IN (@BID_hyr85,@BID_hyr95,@BID_hyr98) 
AND (
  P_ID IN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_hyr1))   --会员日 可选限购品种,可自行添加限购品种，门店版2018
  OR 
  P_ID IN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_tdpz))   --剔除门店添加的商品特价促销品种
  OR 
  P_ID IN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_zbsj))   --剔除总部特定锁价品种
    ) 

--删除非会员日体系里，被指定忽略的品种
DELETE FROM PM_Detail WHERE billid IN (@BID_fhyr98)
AND (
  P_ID IN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_fhyr1))  --门店版2018 非会员日 选定打折品种
  OR 
  P_ID IN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_tdpz))   --剔除门店添加的商品特价促销品种
  OR 
  P_ID IN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_zbsj))   --剔除总部特定锁价品种
    ) 


--删除会员日体系里，错误的品种
DELETE FROM PM_Detail WHERE billid = @BID_hyr85 AND P_ID NOT IN (SELECT p_id FROM zgxCxTemp C WHERE C.CLASS = 0.85 AND C.type = 1)
DELETE FROM PM_Detail WHERE billid = @BID_hyr95 AND P_ID NOT IN (SELECT p_id FROM zgxCxTemp C WHERE C.CLASS = 0.95 AND C.type = 1)
DELETE FROM PM_Detail WHERE billid = @BID_hyr98 AND P_ID NOT IN (SELECT p_id FROM zgxCxTemp C WHERE C.CLASS = 0.98 AND C.type = 1)

--删除非会员日体系里，错误的品种
DELETE FROM PM_Detail WHERE billid = @BID_fhyr98 AND P_ID NOT IN (SELECT p_id FROM zgxCxTemp C WHERE C.CLASS = 0.98 AND C.type = 0)

--从门店手动添加商品特价促销品种剔除总部锁价的
DELETE FROM PM_Detail WHERE billid IN (@BID_tdpz) 
AND p_id IN (SELECT Product_ID FROM Products WHERE FirstSale = 1) 
--如果门店手动添加商品特价促销品种超过50个，会被自动剔除最后加入的
DELETE FROM PM_Detail WHERE billid IN (@BID_tdpz) 
AND detail_id NOT IN  (SELECT TOP 50 detail_id FROM PM_Detail PMD1 WHERE PMD1.billid IN (@BID_tdpz) ORDER BY PMD1.detail_id)
--从门店手动添加商品特价促销品种剔除部分总部特定选定的锁价品种
DELETE FROM PM_Detail WHERE billid IN (@BID_tdpz) AND (P_ID IN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_zbsj)))
 

--------------------------------------------------------
--开始插入PM_Detail的明细
--会员日 非处方品种85折
INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
SELECT @BID_hyr85,C.P_ID,C.u_id,0,0,C.class,0,1,0,0,0,C.profit_rate,0
FROM zgxCxTemp C LEFT JOIN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_hyr85)) PMD ON PMD.p_id = C.P_ID
WHERE C.CLASS = 0.85 AND C.type = 1  AND PMD.p_id IS NULL

--会员日 处方药95折
INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
SELECT @BID_hyr95,C.P_ID,C.u_id,0,0,C.class,0,1,0,0,0,C.profit_rate,0
FROM zgxCxTemp C LEFT JOIN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_hyr95)) PMD ON PMD.p_id = C.P_ID
WHERE C.CLASS = 0.95 AND C.type = 1  AND PMD.p_id IS NULL

--会员日 部分品种98折
INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
SELECT @BID_hyr98,C.P_ID,C.u_id,0,0,C.class,0,1,0,0,0,C.profit_rate,0
FROM zgxCxTemp C LEFT JOIN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_hyr98)) PMD ON PMD.p_id = C.P_ID
WHERE C.CLASS = 0.98 AND C.type = 1  AND PMD.p_id IS NULL
------
--非会员日 会员98折
INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
SELECT @BID_fhyr98,C.P_ID,C.u_id,0,0,C.class,0,1,0,0,0,C.profit_rate,0
FROM zgxCxTemp C LEFT JOIN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_fhyr98)) PMD ON PMD.p_id = C.P_ID
WHERE C.CLASS = 0.98 AND C.type = 0  AND PMD.p_id IS NULL


---------------------------------------
--设置限购

--将会员日85折后,正毛利的品种的每人每日限购数量设置为0
UPDATE PM_Detail SET vipDayQty = 0
--SELECT DISTINCT PMD.p_id ,CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice,0) - ISNULL(PXMD.costp,0))/ISNULL(PXMD.retailPrice,9999)) AS MLL  --毛利率
FROM PM_Detail PMD,zgxCxTemp C
WHERE PMD.p_id = C.P_ID
AND C.CLASS = 0.85 AND C.type = 1 AND PMD.billid = @BID_hyr85
AND C.profit_rate >= 0
AND vipDayQty <> 0

--将会员日95折后,正毛利的品种的每人每日限购数量设置为0
UPDATE PM_Detail SET vipDayQty = 0
--SELECT DISTINCT PMD.p_id ,CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice,0) - ISNULL(PXMD.costp,0))/ISNULL(PXMD.retailPrice,9999)) AS MLL  --毛利率
FROM PM_Detail PMD,zgxCxTemp C
WHERE PMD.p_id = C.P_ID 
AND C.CLASS = 0.95 AND C.type = 1 AND PMD.billid = @BID_hyr95
AND C.profit_rate >= 0
AND vipDayQty <> 0

---------
--将会员日85折后,负毛利的品种的每人每日限购数量设置为2
UPDATE PM_Detail SET vipDayQty = 2
--SELECT DISTINCT PMD.p_id ,CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice,0) - ISNULL(PXMD.costp,0))/ISNULL(PXMD.retailPrice,9999)) AS MLL  --毛利率
FROM PM_Detail PMD,zgxCxTemp C
WHERE PMD.p_id = C.P_ID
AND C.CLASS = 0.85 AND C.type = 1 AND PMD.billid = @BID_hyr85
AND C.profit_rate < 0
AND vipDayQty <> 2


--将会员日95折后,负毛利的品种的每人每日限购数量设置为2
UPDATE PM_Detail SET vipDayQty = 2
--SELECT DISTINCT PMD.p_id ,CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice,0) - ISNULL(PXMD.costp,0))/ISNULL(PXMD.retailPrice,9999)) AS MLL  --毛利率
FROM PM_Detail PMD,zgxCxTemp C
WHERE PMD.p_id = C.P_ID
AND C.CLASS = 0.95 AND C.type = 1 AND PMD.billid = @BID_hyr95
AND C.profit_rate < 0
AND vipDayQty <> 2

--更新明细后对手动添加商品的单据的备注加入时间，供参考
UPDATE PM_Index SET note = CONVERT(VARCHAR(20),GETDATE(),120)+SUBSTRING(note,20,100)
WHERE billid = @BID_tdpz
