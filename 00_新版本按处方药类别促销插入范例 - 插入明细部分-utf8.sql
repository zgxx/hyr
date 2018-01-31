--获得单据号对应的billid
DECLARE @BID_hyr1 INT,@BID_hyr_85 INT,@BID_hyr95 INT,@BID_hyr98 INT, @BID_fhyr1 INT,@BID_fhyr98 INT
SELECT @BID_hyr1  = billid FROM PM_Index WHERE billnumber = 'CX-180101-00020' AND note LIKE '门店版2018%'   --门店版2018 会员日 选定不打折品种
SELECT @BID_hyr_85  = billid FROM PM_Index WHERE billnumber = 'CX-180101-00021' AND note LIKE '门店版2018%'	 --门店版2018 会员日 非处方品种85折
SELECT @BID_hyr95 = billid FROM PM_Index WHERE billnumber = 'CX-180101-00022' AND note LIKE '门店版2018%'	 --门店版2018 会员日 处方药95折
SELECT @BID_hyr98  = billid FROM PM_Index WHERE billnumber = 'CX-180101-00023' AND note LIKE '门店版2018%'   --门店版2018 会员日 部分品种98折

SELECT @BID_fhyr1  = billid FROM PM_Index WHERE billnumber = 'CX-180101-00030' AND note LIKE '门店版2018%'   --门店版2018 非会员日 选定不打折品种
SELECT @BID_fhyr98  = billid FROM PM_Index WHERE billnumber = 'CX-180101-00031' AND note LIKE '门店版2018%'   --门店版2018 非会员日 会员98折

IF (@BID_hyr1+@BID_hyr_85+@BID_hyr95+@BID_hyr98+@BID_fhyr1+@BID_fhyr98) IS NULL 
BEGIN 
  SELECT [有点问题]='促销单据还没有'
  SELECT [解决方法]='先执行插入单据的脚本再执行此脚本'
      RETURN		--加个return 退出执行SQL
END
 
--提取数据插入临时表
IF exists (select * from tempdb..sysobjects where id = object_id('tempdb..##CxTemp'))
DROP table [dbo].[##CxTemp]
GO

CREATE TABLE [dbo].[##CxTemp](
	[P_ID] [int] NOT NULL,
	[u_id] [int] NOT NULL,
	[retailPrice] NUMERIC(18,4)  NOT NULL,
	[costp] NUMERIC(18,4) NOT NULL,
	[vipprice] NUMERIC(18,4) NOT NULL,
	[profit_rate] NUMERIC(18,4) NOT NULL,
	[Class] NUMERIC(18,2) NOT NULL,   --代表打折力度
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
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,ISNULL(PXMD.retailPrice,0) AS retailPrice, ISNULL(PXMD.costp,0) AS costp,ISNULL(PXMD.VipPrice,0) AS VipPrice,
CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice,0) - ISNULL(costp,0))/ISNULL(PXMD.retailPrice,9999)) AS MLL,  --毛利率
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
AND P.Product_ID NOT IN (7310)		--不添加新疆鹿角胶(茎鹿)(纸盒)
AND P.name NOT LIKE '%瑾植%'
ORDER BY MLL DESC


INSERT INTO ##CxTemp
--会员日,处方药95折的品种，包含冷链
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,ISNULL(PXMD.retailPrice,0) AS retailPrice, ISNULL(PXMD.costp,0) AS costp,ISNULL(PXMD.VipPrice,0) AS VipPrice,
CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice,0) - ISNULL(costp,0))/ISNULL(PXMD.retailPrice,9999)) AS MLL,  --毛利率
0.95 AS CLASS,1 AS type
FROM Products P LEFT JOIN
( SELECT A.P_id,A.retailPrice,A.VipPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	  AND A.retailPrice > 0 
	 --门店价格体系，如果配送价没有则用最近进价
 ) AS PXMD ON P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id
WHERE P.DELETED = 0 AND P.Isdir = 0 AND P.Product_ID NOT IN (8000,8001,8456,19072)	--四个拆零剔除
AND (P.OTCFlag >0 OR P.ColdStore = 1 OR P.Product_ID IN (7310))	--7310代表新疆鹿角胶(茎鹿)(纸盒)加入会员日95折里
ORDER BY MLL DESC


INSERT INTO ##CxTemp
--会员日,部分98折的品种
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,ISNULL(PXMD.retailPrice,0) AS retailPrice, ISNULL(PXMD.costp,0) AS costp,ISNULL(PXMD.VipPrice,0) AS VipPrice,
CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice,0) - ISNULL(costp,0))/ISNULL(PXMD.retailPrice,9999)) AS MLL,  --毛利率
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
ORDER BY MLL DESC


INSERT INTO ##CxTemp
--非会员日,98折的品种,凡是有会员价商品不参与98折，按普通会员价执行
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,ISNULL(PXMD.retailPrice,0) AS retailPrice, ISNULL(PXMD.costp,0) AS costp,ISNULL(PXMD.VipPrice,0) AS VipPrice,
CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice,0) - ISNULL(costp,0))/ISNULL(PXMD.retailPrice,9999)) AS MLL,  --毛利率
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
ORDER BY MLL DESC


