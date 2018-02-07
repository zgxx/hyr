--2018��2��7��9:05:10
--00_�ŵ��ѯ��Ա�ո�ë��Ʒ�֣��Լ��������ۼۣ�ƽ���ɱ�
SELECT DISTINCT ISNULL(ST.name,'') AS �ŵ�,P.code AS ���,P.name AS ��Ʒ����, P.standard AS ���,
CONVERT(NUMERIC(18,2),PXMD.costp) AS ���ͼ�,CONVERT(NUMERIC(18,2),ST.AVGP) AS ƽ���ɱ���,CONVERT(NUMERIC(18,2),PXMD.retailPrice) AS ���ۼ�,
  CASE WHEN p.OTCFlag > 0 
  THEN (CASE WHEN PXMD.retailPrice*0.95-ST.AVGP < 0 THEN CONVERT(NUMERIC(18,1),ST.AVGP/0.95) ELSE CONVERT(NUMERIC(18,1),PXMD.retailPrice) END)
  ELSE (CASE WHEN PXMD.retailPrice*0.85-ST.AVGP < 0 THEN CONVERT(NUMERIC(18,1),ST.AVGP/0.85) ELSE CONVERT(NUMERIC(18,1),PXMD.retailPrice) END) END
   AS ��Ա�ղ����������ۼ�,
PXMD.retailPrice-PXMD.costp AS ����ë��,
CONVERT(NUMERIC(18,4),(PXMD.retailPrice -ST.AVGP)/PXMD.retailPrice) AS ë����,'|||' AS [|||],
 CASE WHEN p.OTCFlag > 0 THEN CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.95) ELSE CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.85) END AS ��Ա���ۺ����ۼ�,
 CASE WHEN p.OTCFlag > 0 THEN CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.95-ST.AVGP) ELSE CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.85-ST.AVGP) END AS �ۺ�ë��,
 CASE WHEN p.OTCFlag > 0 THEN CONVERT(NUMERIC(18,4),(PXMD.retailPrice*0.95 -ST.AVGP)/PXMD.retailPrice*0.95) 
	  ELSE CONVERT(NUMERIC(18,4),(PXMD.retailPrice*0.85 -ST.AVGP)/PXMD.retailPrice*0.85) END AS �ۺ�ë����, 
ISNULL(CONVERT(VARCHAR(20),CONVERT(NUMERIC(18,0),ST.QUANT)),'') AS �����,
P.factory AS ��������,CASE WHEN p.OTCFlag > 0 THEN '����ҩ' ELSE '�Ǵ�����Ʒ' END AS ����ҩ����,
 CASE WHEN ST.QUANT IS NULL THEN '�޿��' ELSE '�л�' END AS ���
FROM Products P 
LEFT JOIN 
(SELECT ST.p_id ,STO.name,SUM(quantity) AS QUANT,SUM(costtotal)/SUM(quantity) AS AVGP FROM s_storehouse ST,storages STO WHERE s_id <> 15 AND ST.s_id = STO.storage_id GROUP BY p_id,STO.name) ST 
ON ST.p_id = P.Product_ID,
( SELECT A.P_id,A.retailPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,--,A.PrePrice1,A.RecBuyPrice
 A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
 AND A.retailPrice <> 0 AND A.PrePrice1+A.RecBuyPrice <> 0  --�ŵ�۸���ϵ��������ͼ�û�������������
 ) AS PXMD
WHERE P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id AND PXMD.retailPrice <> 0
AND P.Parent_id NOT LIKE '000004000001%'	--�޳���ҩ��Ƭ
AND CASE WHEN p.OTCFlag > 0 THEN CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.95-ST.AVGP) ELSE CONVERT(NUMERIC(18,2),PXMD.retailPrice*0.85-ST.AVGP) END < 0
AND P.Product_ID NOT IN (SELECT p_id FROM PM_Detail WHERE billid IN (SELECT billid FROM PM_Index WHERE billnumber = 'CX-180205-00099')) --�޳��ܲ��ض�����Ʒ��
ORDER BY ��� DESC,����ҩ����,�ۺ�ë��