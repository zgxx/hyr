

--00_�ŵ��ѯ��ë����Ҫ�޳���Ա��Ʒ��
SELECT DISTINCT ISNULL(ST.name,'') AS �ŵ�,P.code AS ���,P.name AS ��Ʒ����, P.standard AS ���,
  CONVERT(NUMERIC(18,2),PXMD.costp) AS �ɱ���,CONVERT(NUMERIC(18,2),PXMD.retailPrice) AS ���ۼ�,PXMD.retailPrice-PXMD.costp AS ë��,
 CONVERT(NUMERIC(18,4),(PXMD.retailPrice -costp)/PXMD.retailPrice) AS ë����,'|||' AS [|||],
 CASE WHEN p.OTCFlag > 0 THEN CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.95) ELSE CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.85) END AS �ۺ����ۼ�,
 CASE WHEN p.OTCFlag > 0 THEN CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.95-PXMD.costp) ELSE CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.85-PXMD.costp) END AS �ۺ�ë��,
 CASE WHEN p.OTCFlag > 0 THEN CONVERT(NUMERIC(18,4),(PXMD.retailPrice*0.95 -costp)/PXMD.retailPrice*0.95) 
	  ELSE CONVERT(NUMERIC(18,4),(PXMD.retailPrice*0.85 -costp)/PXMD.retailPrice*0.85) END AS �ۺ�ë����, 
	  P.factory AS ��������,CASE WHEN p.OTCFlag > 0 THEN '����ҩ' ELSE '�Ǵ�����Ʒ' END AS ����ҩ����,
 ISNULL(CONVERT(VARCHAR(20),CONVERT(NUMERIC(18,0),ST.QUANT)),'') AS �����,CASE WHEN ST.QUANT IS NULL THEN '�޿��' ELSE '�л�' END AS ���
FROM Products P LEFT JOIN (SELECT ST.p_id ,STO.name,SUM(quantity) AS QUANT FROM s_storehouse ST,storages STO WHERE ST.s_id = STO.storage_id GROUP BY p_id,STO.name) ST ON ST.p_id = P.Product_ID,
	(SELECT A.P_id,A.retailPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,--,A.PrePrice1,A.RecBuyPrice
	A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	 AND A.retailPrice <> 0 AND A.PrePrice1+A.RecBuyPrice <> 0
	 --�ŵ�۸���ϵ��������ͼ�û�������������
 ) AS PXMD
WHERE P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id AND PXMD.retailPrice <> 0
AND P.Parent_id NOT LIKE '000004000001%'	--�޳���ҩ��Ƭ
ORDER BY ��� DESC,����ҩ����,�ۺ�ë����