--2018年2月7日9:05:10
--00_门店查询会员日负毛利品种，以及建议零售价，平均成本
SELECT DISTINCT ISNULL(ST.name,'') AS 门店,P.code AS 编号,P.name AS 商品名称, P.standard AS 规格,
CONVERT(NUMERIC(18,2),PXMD.costp) AS 配送价,CONVERT(NUMERIC(18,2),ST.AVGP) AS 平均成本价,CONVERT(NUMERIC(18,2),PXMD.retailPrice) AS 零售价,
  CASE WHEN p.OTCFlag > 0 
  THEN (CASE WHEN PXMD.retailPrice*0.95-ST.AVGP < 0 THEN CONVERT(NUMERIC(18,1),ST.AVGP/0.95) ELSE CONVERT(NUMERIC(18,1),PXMD.retailPrice) END)
  ELSE (CASE WHEN PXMD.retailPrice*0.85-ST.AVGP < 0 THEN CONVERT(NUMERIC(18,1),ST.AVGP/0.85) ELSE CONVERT(NUMERIC(18,1),PXMD.retailPrice) END) END
   AS 会员日不亏损建议零售价,
PXMD.retailPrice-PXMD.costp AS 正常毛利,
CONVERT(NUMERIC(18,4),(PXMD.retailPrice -ST.AVGP)/PXMD.retailPrice) AS 毛利率,'|||' AS [|||],
 CASE WHEN p.OTCFlag > 0 THEN CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.95) ELSE CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.85) END AS 会员日折后零售价,
 CASE WHEN p.OTCFlag > 0 THEN CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.95-ST.AVGP) ELSE CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.85-ST.AVGP) END AS 折后毛利,
 CASE WHEN p.OTCFlag > 0 THEN CONVERT(NUMERIC(18,4),(PXMD.retailPrice*0.95 -ST.AVGP)/PXMD.retailPrice*0.95) 
	  ELSE CONVERT(NUMERIC(18,4),(PXMD.retailPrice*0.85 -ST.AVGP)/PXMD.retailPrice*0.85) END AS 折后毛利率, 
ISNULL(CONVERT(VARCHAR(20),CONVERT(NUMERIC(18,0),ST.QUANT)),'') AS 库存量,
P.factory AS 生产厂家,CASE WHEN p.OTCFlag > 0 THEN '处方药' ELSE '非处方商品' END AS 处方药类型,
 CASE WHEN ST.QUANT IS NULL THEN '无库存' ELSE '有货' END AS 库存
FROM Products P 
LEFT JOIN 
(SELECT ST.p_id ,STO.name,SUM(quantity) AS QUANT,SUM(costtotal)/SUM(quantity) AS AVGP FROM s_storehouse ST,storages STO WHERE s_id <> 15 AND ST.s_id = STO.storage_id GROUP BY p_id,STO.name) ST 
ON ST.p_id = P.Product_ID,
( SELECT A.P_id,A.retailPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,--,A.PrePrice1,A.RecBuyPrice
 A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
 AND A.retailPrice <> 0 AND A.PrePrice1+A.RecBuyPrice <> 0  --门店价格体系，如果配送价没有则用最近进价
 ) AS PXMD
WHERE P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id AND PXMD.retailPrice <> 0
AND P.Parent_id NOT LIKE '000004000001%'	--剔除中药饮片
AND CASE WHEN p.OTCFlag > 0 THEN CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.95-ST.AVGP) ELSE CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.85-ST.AVGP) END < 0
AND P.Product_ID NOT IN (SELECT p_id FROM PM_Detail WHERE billid IN (SELECT billid FROM PM_Index WHERE billnumber = 'CX-180205-00099')) --剔除总部特定锁价品种
ORDER BY 库存 DESC,处方药类型,折后毛利