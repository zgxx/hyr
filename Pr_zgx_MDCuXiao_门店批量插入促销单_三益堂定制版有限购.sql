
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[zgx_MDCuXiao]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP procedure [dbo].[zgx_MDCuXiao]
GO

/****** Object:  StoredProcedure [dbo].[zgx_MDCuXiao]    Script Date: 01/08/2018 16:13:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[zgx_MDCuXiao]	
AS
--EXEC zgx_MDCuXiao       --加入作业系统，每天自动更新新品种，2017年10月25日
--2017年10月25日16:46:28 修改，加入新疆鹿角胶(茎鹿)(纸盒)会员日变成95折，平时98折

/*
SELECT * FROM PM_Index WHERE billtype = 17
SELECT * FROM PM_Detail WHERE billid IN (48)
SELECT * FROM PM_Detail WHERE billid IN (45,46,47,48) AND p_id IN (SELECT Product_ID FROM Products WHERE name LIKE '%瑾植%' AND Isdir = 0 AND DELETED = 0)
*/

--此存储过程,中药饮片永不打折,厂家带有"奇力康"或"武汉国灸科技"的最多98折

-----++++++++++++++++++++使用前注意!先看下面这段++++++++++++++++++++++++++-----
--下面这段被/*和*/注释的语句需要在总部的空白样式促销单下传后，立刻手动执行一次
--将下传的样式固定，以免被总部新修改的覆盖，然后再将EXEC zgx_MDCuXiao加入每天中午的定时作业系统
/*
UPDATE PM_Index SET note = '门店版 '+note WHERE billnumber 
IN ('CX-170831-00001','CX-170831-00002','CX-170831-00003','CX-170831-00004') AND note NOT LIKE '门店版 %'

UPDATE PM_Index SET Dts_BillID = 0 WHERE note LIKE '门店版 %' AND Dts_BillID <> 0
*/-----++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----





DECLARE @BID95 INT,@BID88 INT,@BID98 INT,@BID98q INT
SELECT @BID95  = billid FROM PM_Index WHERE billnumber = 'CX-170831-00001' AND note LIKE '门店版 %'   --会员日 处方药 95折
SELECT @BID88  = billid FROM PM_Index WHERE billnumber = 'CX-170831-00002' AND note LIKE '门店版 %'	 --会员日 非处方药 88折
SELECT @BID98q = billid FROM PM_Index WHERE billnumber = 'CX-170831-00003' AND note LIKE '门店版 %'	 --会员日 除了以上其余品种 98折
SELECT @BID98  = billid FROM PM_Index WHERE billnumber = 'CX-170831-00004' AND note LIKE '门店版 %'   --非会员日 98折

IF (@BID95 + @BID88 + @BID98q + @BID98) IS NULL 
BEGIN 
  SELECT [有点问题]='门店当前还没有对应总部的促销单,无法自动更新╮(╯▽╰)╭'
  SELECT [解决方法]='先点与总部交换数据，下一步再上一步，然后在下载选项里勾选接受促销单，再传输，么么哒'
      RETURN		--加个return 退出执行SQL
END


--清理会员日 处方药 95折里面的杂项，不剔除冷链
DELETE FROM PM_Detail WHERE billid = @BID95 AND p_id IN 
  (SELECT Product_ID FROM Products WHERE DELETED = 1 OR Isdir = 1 OR (OTCFlag = 0 AND ColdStore = 0) 
    OR Product_ID IN (8000,8001,8456,19072) 
    OR PRODUCT_ID IN (SELECT Product_ID FROM Products WHERE name LIKE '%瑾植%' AND Isdir = 0 AND DELETED = 0)
    ) --7310代表新疆鹿角胶(茎鹿)(纸盒)不从会员日95折里删除
    AND p_id NOT IN (7310)

--清理会员日 非处方药 88折里面的杂项
DELETE FROM PM_Detail WHERE billid = @BID88 AND p_id 
IN (SELECT Product_ID FROM Products WHERE DELETED = 1 OR OTCFlag > 0 OR Isdir = 1
	OR ColdStore = 1 OR Parent_id LIKE '000004000001%'   --剔除中药饮片
	OR Product_ID IN (8000,8001,8456,19072)				 --剔除拆零
	OR Factory LIKE '武汉国灸科技%' OR Factory LIKE '%奇力康%'			 --从这里剔除
	OR Product_ID IN (7310)							--7310代表剔除新疆鹿角胶(茎鹿)(纸盒)
    OR PRODUCT_ID IN (SELECT Product_ID FROM Products WHERE name LIKE '%瑾植%' AND Isdir = 0 AND DELETED = 0)
  )

--清理会员日 其余 98折里面的杂项
DELETE FROM PM_Detail WHERE billid = @BID98q AND p_id 
IN ( SELECT Product_ID FROM Products WHERE DELETED = 1 OR Isdir = 1 OR OTCFlag > 0 OR (Factory NOT LIKE '武汉国灸科技%' AND Factory NOT LIKE '%奇力康%')
	OR Product_ID IN (8000,8001,8456,19072)
    OR PRODUCT_ID IN (SELECT Product_ID FROM Products WHERE name LIKE '%瑾植%' AND Isdir = 0 AND DELETED = 0)
	)

--清理非会员日98折里面的杂项，全场98折，其中不包含中药饮片
DELETE FROM PM_Detail WHERE billid = @BID98 AND p_id 
IN (SELECT Product_ID FROM Products WHERE Isdir = 1 OR DELETED = 1 OR Parent_id LIKE '000004000001%' OR Product_ID IN (8000,8001,8456,19072)
   OR PRODUCT_ID IN (SELECT Product_ID FROM Products WHERE name LIKE '%瑾植%' AND Isdir = 0 AND DELETED = 0)
    )



--插入会员日,处方药95折的品种，包含冷链
DECLARE CURSOR_CHUFANG CURSOR FOR
	SELECT P.Product_ID,U_ID FROM Products AS P (NOLOCK) 
	LEFT JOIN PM_Detail PMD 
	ON P.Product_ID = PMD.p_id AND PMD.billid = @BID95
	WHERE PMD.p_id IS NULL AND P.DELETED = 0 AND P.Isdir = 0 AND (P.OTCFlag >0 OR P.ColdStore = 1 OR P.Product_ID IN (7310))		--7310代表新疆鹿角胶(茎鹿)(纸盒)加入会员日95折里
	AND P.Product_ID NOT IN (8000,8001,8456,19072)
OPEN CURSOR_CHUFANG
DECLARE @CFPID  INT,@U_ID INT
FETCH NEXT FROM CURSOR_CHUFANG INTO @CFPID,@U_ID
WHILE @@FETCH_STATUS = 0
	BEGIN 
	INSERT INTO [PM_Detail]
			([billid],[p_id],[unitid],[UnitIndex],[discountprice],[discount],[maxqty],[billminqty],[billmaxqty],
			[vipDayQty],[vipDayTimes],[remark],[Dts_Detail_ID])
	VALUES
	(@BID95,@CFPID,@U_ID,'0','0.0000000','0.9500000','0.0000','1.0000','0.0000','0.0000','0',' ','0')
	FETCH NEXT FROM CURSOR_CHUFANG INTO @CFPID,@U_ID
    END
--关闭游标
CLOSE CURSOR_CHUFANG
--释放资源
DEALLOCATE CURSOR_CHUFANG


--插入会员日,非处方药88折的品种
DECLARE CURSOR_FEICHUFANG CURSOR FOR
	SELECT P.Product_ID,U_ID FROM Products P (NOLOCK) 
	LEFT JOIN PM_Detail PMD 
	ON P.Product_ID = PMD.p_id AND PMD.billid = @BID88
	LEFT JOIN 
	(SELECT Product_ID FROM Products WHERE Parent_id LIKE '000004000001%' AND DELETED = 0 AND Isdir = 0) AS ZYYP	--剔除中药饮片
	ON P.Product_ID = ZYYP.Product_ID
	 WHERE PMD.p_id IS NULL AND ZYYP.Product_ID IS NULL AND P.DELETED = 0 AND P.Isdir = 0
	 AND P.OTCFlag = 0 AND P.ColdStore = 0 AND P.Product_ID NOT IN (8000,8001,8456,19072)
	 AND P.Product_ID NOT IN (SELECT Product_ID FROM Products WHERE (Factory LIKE '武汉国灸科技%' OR Factory LIKE '%奇力康%') AND DELETED = 0 AND Isdir = 0)
	 AND P.Product_ID NOT IN (7310)		--不添加新疆鹿角胶(茎鹿)(纸盒)
	 AND P.PRODUCT_ID NOT IN (SELECT Product_ID FROM Products WHERE name LIKE '%瑾植%' AND Isdir = 0 AND DELETED = 0)
OPEN CURSOR_FEICHUFANG
DECLARE @CFPID1  INT,@U_ID1 INT
FETCH NEXT FROM CURSOR_FEICHUFANG INTO @CFPID1,@U_ID1
WHILE @@FETCH_STATUS = 0
	BEGIN 
	INSERT INTO [PM_Detail]
			([billid],[p_id],[unitid],[UnitIndex],[discountprice],[discount],[maxqty],[billminqty],[billmaxqty],
			[vipDayQty],[vipDayTimes],[remark],[Dts_Detail_ID])
	VALUES
	(@BID88,@CFPID1,@U_ID1,'0','0.0000000','0.8800000','0.0000','1.0000','0.0000','0.0000','0',' ','0')
	FETCH NEXT FROM CURSOR_FEICHUFANG INTO @CFPID1,@U_ID1
    END
--关闭游标
CLOSE CURSOR_FEICHUFANG
--释放资源
DEALLOCATE CURSOR_FEICHUFANG


--插入会员日,特定98折的品种
DECLARE CURSOR_HYR98 CURSOR FOR
	SELECT P.Product_ID,U_ID FROM Products P (NOLOCK) 
	LEFT JOIN PM_Detail PMD 
	ON P.Product_ID = PMD.p_id AND PMD.billid = @BID98q
	WHERE PMD.p_id IS NULL AND P.DELETED = 0 AND P.Isdir = 0 AND (Factory LIKE '武汉国灸科技%' OR Factory LIKE '%奇力康%' )
OPEN CURSOR_HYR98
DECLARE @HYR98PID  INT,@U_ID2 INT
FETCH NEXT FROM CURSOR_HYR98 INTO @HYR98PID,@U_ID2
WHILE @@FETCH_STATUS = 0
	BEGIN 
	INSERT INTO [PM_Detail]
			([billid],[p_id],[unitid],[UnitIndex],[discountprice],[discount],[maxqty],[billminqty],[billmaxqty],
			[vipDayQty],[vipDayTimes],[remark],[Dts_Detail_ID])
	VALUES
	(@BID98q,@HYR98PID,@U_ID2,'0','0.0000000','0.9800000','0.0000','1.0000','0.0000','0.0000','0',' ','0')
	FETCH NEXT FROM CURSOR_HYR98 INTO @HYR98PID,@U_ID2
    END
--关闭游标
CLOSE CURSOR_HYR98
--释放资源
DEALLOCATE CURSOR_HYR98


--插入非会员日98折的品种
DECLARE CURSOR_FEIHYR CURSOR FOR
SELECT P.Product_ID,U_ID FROM Products P (NOLOCK) 
	LEFT JOIN PM_Detail PMD 
	ON P.Product_ID = PMD.p_id AND PMD.billid = @BID98
	LEFT JOIN (SELECT Product_ID FROM Products WHERE Parent_id LIKE '000004000001%' AND DELETED = 0 AND Isdir = 0) AS ZYYP
	ON P.Product_ID = ZYYP.Product_ID 
	WHERE PMD.p_id IS NULL AND ZYYP.Product_ID IS NULL AND P.DELETED = 0 AND P.Isdir = 0 AND P.Product_ID NOT IN (8000,8001,8456,19072) 
	AND P.PRODUCT_ID NOT IN (SELECT Product_ID FROM Products WHERE name LIKE '%瑾植%' AND Isdir = 0 AND DELETED = 0)
	--剔除中药饮片后的所有品种
OPEN CURSOR_FEIHYR
DECLARE @FHYRPID  INT,@U_ID3 INT
FETCH NEXT FROM CURSOR_FEIHYR INTO @FHYRPID,@U_ID3
WHILE @@FETCH_STATUS = 0
	BEGIN 
	INSERT INTO [PM_Detail]
			([billid],[p_id],[unitid],[UnitIndex],[discountprice],[discount],[maxqty],[billminqty],[billmaxqty],
			[vipDayQty],[vipDayTimes],[remark],[Dts_Detail_ID])
	VALUES
	(@BID98,@FHYRPID,@U_ID3,'0','0.0000000','0.9800000','0.0000','1.0000','0.0000','0.0000','0',' ','0')
	FETCH NEXT FROM CURSOR_FEIHYR INTO @FHYRPID,@U_ID3
    END
--关闭游标
CLOSE CURSOR_FEIHYR
--释放资源
DEALLOCATE CURSOR_FEIHYR


--将95折后正毛利的处方药品种的每人每日限购数量设置为0
UPDATE PM_Detail SET vipDayQty = 0
FROM PM_Detail PMD,
(
	SELECT DISTINCT p.Product_ID AS P_ID
	FROM s_storehouse AS S, Products AS P, 
	  (SELECT A.P_id,A.retailPrice,A.Y_id, U_id FROM Px_price A WHERE a.Y_id IN 
		  (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B 
		   WHERE A.P_id = B.p_id
		   AND A.retailPrice <> 0)
	   ) AS PXMD	--获得门店的价格体系，Y_id不为0即可,只要基本单位在最后筛选
	WHERE S.p_id = P.product_id AND PXMD.p_id = S.p_id AND PXMD.U_id = P.U_id 
	 AND S.S_id <> 15 AND S.costprice > 0.1		--去掉一些赠品
	 AND P.DELETED = 0 AND P.Isdir = 0 AND (P.OTCFlag > 0 OR P.ColdStore = 1) AND P.Product_ID NOT IN (8000,8001,8456,19072)
	 AND PXMD.retailPrice*0.95-s.costprice >= 0
	) AS FML95				
WHERE FML95.P_ID = PMD.p_id AND PMD.vipDayQty > 0 AND PMD.billid = @BID95

--将88折后正毛利的非处方药品种的每人每日限购数量设置为0
UPDATE PM_Detail SET vipDayQty = 0
FROM PM_Detail PMD,
(
	SELECT DISTINCT p.Product_ID AS P_ID
	FROM s_storehouse AS S, Products AS P, 
	  (SELECT A.P_id,A.retailPrice,A.Y_id, U_id FROM Px_price A WHERE a.Y_id IN 
		  (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B 
		   WHERE A.P_id = B.p_id
		   AND A.retailPrice <> 0)
	   ) AS PXMD	--获得门店的价格体系，Y_id不为0即可,只要基本单位在最后筛选
	WHERE S.p_id = P.product_id AND PXMD.p_id = S.p_id AND PXMD.U_id = P.U_id 
	 AND S.S_id <> 15 AND S.costprice > 0.1		--去掉一些赠品
	 AND P.OTCFlag = 0 AND P.ColdStore = 0 AND P.Product_ID NOT IN (8000,8001,8456,19072)
	 AND P.Product_ID NOT IN (SELECT Product_ID FROM Products WHERE Factory LIKE '武汉国灸科技%' OR Factory LIKE '%奇力康%')
	 AND PXMD.retailPrice*0.88-s.costprice >= 0
	) AS FML88
WHERE FML88.P_ID = PMD.p_id AND PMD.vipDayQty > 0 AND PMD.billid = @BID88


--然后将95折后负毛利的处方药品种的每人每日限购数量设置为2
--三益堂约134种
UPDATE PM_Detail SET vipDayQty = 2
--SELECT * 
FROM PM_Detail PMD,
(
	SELECT DISTINCT p.Product_ID AS P_ID
	--,p.Code,P.name,P.Standard,P.Factory,PXMD.retailPrice*0.95 AS 折95后,PXMD.PrePrice1 AS 配送价,PXMD.PrePrice1-PXMD.retailPrice*0.95 AS 每盒亏
	FROM s_storehouse AS S, Products AS P, 
	  (SELECT A.P_id,A.retailPrice,A.PrePrice1,A.Y_id, U_id FROM Px_price A WHERE a.Y_id IN 
		  (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B 
		   WHERE A.P_id = B.p_id
		   AND A.retailPrice <> 0)
	   ) AS PXMD	--获得门店的价格体系，Y_id不为0即可,只要基本单位在最后筛选
	WHERE S.p_id = P.product_id AND PXMD.p_id = S.p_id AND PXMD.U_id = P.U_id 
	 AND S.S_id <> 15 AND S.costprice > 0.1		--去掉一些赠品
	 AND P.DELETED = 0 AND P.Isdir = 0 AND (P.OTCFlag > 0 OR P.ColdStore = 1) AND P.Product_ID NOT IN (8000,8001,8456,19072)
	 AND PXMD.retailPrice*0.95-s.costprice < 0
	) AS FML95				
WHERE FML95.P_ID = PMD.p_id AND PMD.billid = @BID95
AND PMD.vipDayQty <> 2


--然后将88折后负毛利的非处方药品种的每人每日限购数量设置为2
--三益堂约154种
UPDATE PM_Detail SET vipDayQty = 2
--SELECT * 
FROM PM_Detail PMD,
(
	SELECT DISTINCT p.Product_ID AS P_ID
	,p.Code,P.name,P.Standard,P.Factory,PXMD.retailPrice*0.95 AS 折95后,PXMD.PrePrice1 AS 配送价,PXMD.PrePrice1-PXMD.retailPrice*0.95 AS 每盒亏
	FROM s_storehouse AS S, Products AS P, 
	  (SELECT A.P_id,A.retailPrice,A.PrePrice1,A.Y_id, U_id FROM Px_price A WHERE a.Y_id IN 
		  (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B 
		   WHERE A.P_id = B.p_id
		   AND A.retailPrice <> 0)
	   ) AS PXMD	--获得门店的价格体系，Y_id不为0即可,只要基本单位在最后筛选
	WHERE S.p_id = P.product_id AND PXMD.p_id = S.p_id AND PXMD.U_id = P.U_id 
	 AND S.S_id <> 15 AND S.costprice > 0.1		--去掉一些赠品
	 AND P.OTCFlag = 0 AND P.ColdStore = 0 AND P.Product_ID NOT IN (8000,8001,8456,19072)
	 AND P.Product_ID NOT IN (SELECT Product_ID FROM Products WHERE Factory LIKE '武汉国灸科技%' OR Factory LIKE '%奇力康%')
	 AND PXMD.retailPrice*0.88-s.costprice < 0
	) AS FML88
WHERE FML88.P_ID = PMD.p_id AND PMD.billid = @BID88
AND PMD.vipDayQty <> 2


SET QUOTED_IDENTIFIER OFF
