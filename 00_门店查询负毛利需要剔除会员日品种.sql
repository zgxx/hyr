

--00_门店查询负毛利需要剔除会员日品种
SELECT DISTINCT ISNULL(ST.name,'') AS 门店,P.code AS 编号,P.name AS 商品名称, P.standard AS 规格,
  CONVERT(NUMERIC(18,2),PXMD.costp) AS 成本价,CONVERT(NUMERIC(18,2),PXMD.retailPrice) AS 零售价,PXMD.retailPrice-PXMD.costp AS 毛利,
 CONVERT(NUMERIC(18,4),(PXMD.retailPrice -costp)/PXMD.retailPrice) AS 毛利率,'|||' AS [|||],
 CASE WHEN p.OTCFlag > 0 THEN CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.95) ELSE CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.85) END AS 折后零售价,
 CASE WHEN p.OTCFlag > 0 THEN CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.95-PXMD.costp) ELSE CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.85-PXMD.costp) END AS 折后毛利,
 CASE WHEN p.OTCFlag > 0 THEN CONVERT(NUMERIC(18,4),(PXMD.retailPrice*0.95 -costp)/PXMD.retailPrice*0.95) 
	  ELSE CONVERT(NUMERIC(18,4),(PXMD.retailPrice*0.85 -costp)/PXMD.retailPrice*0.85) END AS 折后毛利率, 
	  P.factory AS 生产厂家,CASE WHEN p.OTCFlag > 0 THEN '处方药' ELSE '非处方商品' END AS 处方药类型,
 ISNULL(CONVERT(VARCHAR(20),CONVERT(NUMERIC(18,0),ST.QUANT)),'') AS 库存量,CASE WHEN ST.QUANT IS NULL THEN '无库存' ELSE '有货' END AS 库存
FROM Products P LEFT JOIN (SELECT ST.p_id ,STO.name,SUM(quantity) AS QUANT FROM s_storehouse ST,storages STO WHERE ST.s_id = STO.storage_id GROUP BY p_id,STO.name) ST ON ST.p_id = P.Product_ID,
	(SELECT A.P_id,A.retailPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,--,A.PrePrice1,A.RecBuyPrice
	A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	 AND A.retailPrice <> 0 AND A.PrePrice1+A.RecBuyPrice <> 0
	 --门店价格体系，如果配送价没有则用最近进价
 ) AS PXMD
WHERE P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id AND PXMD.retailPrice <> 0
AND P.Parent_id NOT LIKE '000004000001%'	--剔除中药饮片
ORDER BY 库存 DESC,处方药类型,折后毛利率