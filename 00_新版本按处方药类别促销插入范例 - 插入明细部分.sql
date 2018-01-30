
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
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,ISNULL(PXMD.retailPrice,0) AS retailPrice, ISNULL(PXMD.costp,0) AS costp,ISNULL(PXMD.VipPrice,0) AS VipPrice,
CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice,0) - ISNULL(costp,0))/ISNULL(PXMD.retailPrice,9999)) AS MLL,  --ë����
0.95 AS CLASS,1 AS type
FROM Products P LEFT JOIN
( SELECT A.P_id,A.retailPrice,A.VipPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	  AND A.retailPrice > 0 
	 --�ŵ�۸���ϵ��������ͼ�û�������������
 ) AS PXMD ON P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id
WHERE P.DELETED = 0 AND P.Isdir = 0 AND P.Product_ID NOT IN (8000,8001,8456,19072)	--�ĸ������޳�
AND (P.OTCFlag >0 OR P.ColdStore = 1 OR P.Product_ID IN (7310))	--7310�����½�¹�ǽ�(��¹)(ֽ��)�����Ա��95����
ORDER BY MLL DESC


INSERT INTO ##CxTemp
--��Ա��,����98�۵�Ʒ��
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,ISNULL(PXMD.retailPrice,0) AS retailPrice, ISNULL(PXMD.costp,0) AS costp,ISNULL(PXMD.VipPrice,0) AS VipPrice,
CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice,0) - ISNULL(costp,0))/ISNULL(PXMD.retailPrice,9999)) AS MLL,  --ë����
0.98 AS CLASS,1 AS type
FROM Products P LEFT JOIN
( SELECT A.P_id,A.retailPrice,A.VipPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	  AND A.retailPrice > 0 
	 --�ŵ�۸���ϵ��������ͼ�û�������������
 ) AS PXMD ON P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id
WHERE P.DELETED = 0 AND P.Isdir = 0
AND (P.Factory LIKE '�人���ĿƼ�%' OR P.Factory LIKE '%������%')		--�ֶ��������ЩƷ��
ORDER BY MLL DESC


INSERT INTO ##CxTemp
--�ǻ�Ա��,98�۵�Ʒ��,�����л�Ա����Ʒ������98�ۣ�����ͨ��Ա��ִ��
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,ISNULL(PXMD.retailPrice,0) AS retailPrice, ISNULL(PXMD.costp,0) AS costp,ISNULL(PXMD.VipPrice,0) AS VipPrice,
CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice,0) - ISNULL(costp,0))/ISNULL(PXMD.retailPrice,9999)) AS MLL,  --ë����
0.98 AS CLASS,0 AS type
FROM Products P LEFT JOIN
( SELECT A.P_id,A.retailPrice,A.VipPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	  AND A.retailPrice > 0 
	 --�ŵ�۸���ϵ��������ͼ�û�������������
 ) AS PXMD ON P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id
WHERE  P.DELETED = 0 AND P.Isdir = 0
AND (PXMD.VipPrice = 0 OR PXMD.VipPrice IS NULL)		--��Ա�۵�Ʒ�ֲ��������
AND P.Parent_id NOT LIKE '000004000001%' AND P.Product_ID NOT IN (8000,8001,8456,19072) AND P.name NOT LIKE '%�ֲ%'
ORDER BY MLL DESC


