--2018��2��3��11:48:37��zgx
--������ҵϵͳ��ÿ���Զ�������Ʒ�֣�ʱ������8�㿪ʼÿ��4Сʱִ��һ��
 
--��ȡ���ݲ��뱸�ñ�Ϊ���������ϸ׼��
--SELECT * FROM zgxCxTemp
TRUNCATE TABLE zgxCxTemp

/*
SELECT * FROM zgxCxTemp

SELECT Class AS ��������,CASE WHEN type = 0 THEN '�ǻ�Ա��' ELSE '��Ա��' END AS ���,
CASE WHEN profit_rate < 0 THEN '��ë������' ELSE '' END AS ӯ��,COUNT(1) AS �������� FROM zgxCxTemp 
GROUP BY Class,type,CASE WHEN profit_rate < 0 THEN '��ë������' ELSE '' END
ORDER BY ���,��������,ӯ�� DESC

SELECT C.Class AS ��������,CASE WHEN C.type = 0 THEN '�ǻ�Ա��' ELSE '��Ա��' END AS ���,
CASE WHEN C.profit_rate < 0 THEN '��ë������' ELSE '' END AS ӯ��,COUNT(1) AS �п������ FROM zgxCxTemp C,
(SELECT p_id,SUM(1) AS kc FROM s_storehouse GROUP BY p_id) ST  --�ܿ����Ʒ��
 WHERE C.P_ID = ST.p_id
GROUP BY C.Class,C.type,CASE WHEN C.profit_rate < 0 THEN '��ë������' ELSE '' END
ORDER BY ���,��������,ӯ�� DESC

--�����Ʒ�ؼ۴�������Ʒ�Ƿ񱻻�Ա����ϵ�޳�
SELECT * FROM PM_Detail WHERE billid IN 
(SELECT billid FROM PM_Index WHERE billnumber = 'CX-180101-00021') 
AND p_id IN (SELECT Product_ID FROM Products WHERE Code IN ('131842'))

*/

--SET NOCOUNT ON;
INSERT INTO zgxCxTemp
--��Ա��,�Ǵ���ҩ85�۵�Ʒ��
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,ISNULL(PXMD.retailPrice,0) AS retailPrice, ISNULL(PXMD.retailPrice*0.85,0) AS VIPretailPrice,
ISNULL(PXMD.costp,0) AS costp,ISNULL(PXMD.VipPrice,0) AS VipPrice,
CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice*0.85,0) - ISNULL(costp,0))/ISNULL(PXMD.retailPrice*0.85,9999)) AS MLL,  --�ۺ�ë����
0.85 AS CLASS,1 AS type
FROM Products P LEFT JOIN
	( SELECT A.P_id,A.retailPrice,A.VipPrice,CASE WHEN A.PrePrice1 = 0 THEN A.RecBuyPrice ELSE A.PrePrice1 END AS costp,	--,A.PrePrice1,A.RecBuyPrice
	A.Y_id,A.U_id FROM Px_price A,Products P WHERE a.Y_id IN 
	 (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B WHERE A.P_id = B.p_id ) AND P.U_ID = A.U_id AND P.Product_ID = A.P_id
	  AND A.retailPrice > 0 
	 --�ŵ�۸���ϵ��������ͼ�û�������������
	) AS PXMD ON P.Product_ID = PXMD.P_id AND P.U_ID = PXMD.U_id
WHERE P.DELETED = 0 AND P.Isdir = 0 AND P.Product_ID NOT IN (8000,8001,8456,19072,7310)	--�ĸ������޳�,7310�����½�¹�ǽ�(��¹)(ֽ��)
AND P.Parent_id NOT LIKE '000004000001%'	--�޳���ҩ��Ƭ
AND P.OTCFlag = 0 AND P.ColdStore = 0
AND P.Factory NOT LIKE '�人���ĿƼ�%' AND P.Factory NOT LIKE '%������%'
AND P.Product_ID NOT IN (7310)		--������½�¹�ǽ�(��¹)(ֽ��)
AND P.name NOT LIKE '%�ֲ%'
AND P.Product_ID NOT IN (SELECT p_id FROM PM_Detail WHERE billid IN (SELECT billid FROM PM_Index WHERE billnumber = 'CX-180101-00020')) --�����޳��ŵ��2018 ��Ա�� ѡ������Ʒ��
AND P.Product_ID NOT IN (SELECT p_id FROM PM_Detail WHERE billid IN (SELECT billid FROM PM_Index WHERE billnumber = 'CX-180201-00010')) --�����޳���Ʒ�ؼ۴���Ʒ��
ORDER BY MLL


INSERT INTO zgxCxTemp
--��Ա��,����ҩ95�۵�Ʒ�֣���������
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,ISNULL(PXMD.retailPrice,0) AS retailPrice, ISNULL(PXMD.retailPrice*0.95,0) AS VIPretailPrice,
 ISNULL(PXMD.costp,0) AS costp,ISNULL(PXMD.VipPrice,0) AS VipPrice,
CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice*0.95,0) - ISNULL(costp,0))/ISNULL(PXMD.retailPrice*0.95,9999)) AS MLL,  --�ۺ�ë����
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
AND P.Product_ID NOT IN (SELECT p_id FROM PM_Detail WHERE billid IN (SELECT billid FROM PM_Index WHERE billnumber = 'CX-180101-00020')) --�����޳��ŵ��2018 ��Ա�� ѡ������Ʒ��
AND P.Product_ID NOT IN (SELECT p_id FROM PM_Detail WHERE billid IN (SELECT billid FROM PM_Index WHERE billnumber = 'CX-180201-00010')) --�����޳���Ʒ�ؼ۴���Ʒ��
ORDER BY MLL


INSERT INTO zgxCxTemp
--��Ա��,����98�۵�Ʒ��
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,ISNULL(PXMD.retailPrice,0) AS retailPrice,  ISNULL(PXMD.retailPrice*0.98,0) AS VIPretailPrice,
ISNULL(PXMD.costp,0) AS costp,ISNULL(PXMD.VipPrice,0) AS VipPrice,
CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice*0.98,0) - ISNULL(costp,0))/ISNULL(PXMD.retailPrice*0.98,9999)) AS MLL,  --�ۺ�ë����
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
AND P.Product_ID NOT IN (SELECT p_id FROM PM_Detail WHERE billid IN (SELECT billid FROM PM_Index WHERE billnumber = 'CX-180101-00020')) --�����޳��ŵ��2018 ��Ա�� ѡ������Ʒ��
AND P.Product_ID NOT IN (SELECT p_id FROM PM_Detail WHERE billid IN (SELECT billid FROM PM_Index WHERE billnumber = 'CX-180201-00010')) --�����޳���Ʒ�ؼ۴���Ʒ��
ORDER BY MLL


INSERT INTO zgxCxTemp
--�ǻ�Ա��,98�۵�Ʒ��,�����л�Ա����Ʒ������98�ۣ�����ͨ��Ա��ִ��
SELECT DISTINCT P.Product_ID AS P_ID,P.u_id,ISNULL(PXMD.retailPrice,0) AS retailPrice, ISNULL(PXMD.retailPrice*0.98,0) AS VIPretailPrice,
ISNULL(PXMD.costp,0) AS costp,ISNULL(PXMD.VipPrice,0) AS VipPrice,
CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice*0.98,0) - ISNULL(costp,0))/ISNULL(PXMD.retailPrice*0.98,9999)) AS MLL,  --�ۺ�ë����
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
AND P.Product_ID NOT IN (SELECT p_id FROM PM_Detail WHERE billid IN (SELECT billid FROM PM_Index WHERE billnumber = 'CX-180101-00030')) --�����޳��ŵ��2018 �ǻ�Ա�� ѡ������Ʒ��
AND P.Product_ID NOT IN (SELECT p_id FROM PM_Detail WHERE billid IN (SELECT billid FROM PM_Index WHERE billnumber = 'CX-180201-00010')) --�����޳���Ʒ�ؼ۴���Ʒ��
ORDER BY MLL

------------------

--��õ��ݺŶ�Ӧ��billid��׼�����������ϸ
DECLARE @BID_hyr1 INT,@BID_hyr85 INT,@BID_hyr95 INT,@BID_hyr98 INT, @BID_fhyr1 INT,@BID_fhyr98 INT,@BID_tdpz INT
--SELECT @BID_hyr1  = billid FROM PM_Index WHERE billnumber = 'CX-180101-00020'   --�ŵ��2018 ��Ա�� ѡ������Ʒ��
SELECT @BID_hyr1  = 0
SELECT @BID_hyr85 = billid FROM PM_Index WHERE billnumber = 'CX-180101-00021'	 --�ŵ��2018 ��Ա�� �Ǵ���Ʒ��85��
SELECT @BID_hyr95 = billid FROM PM_Index WHERE billnumber = 'CX-180101-00022'	 --�ŵ��2018 ��Ա�� ����ҩ95��
SELECT @BID_hyr98 = billid FROM PM_Index WHERE billnumber = 'CX-180101-00023'   --�ŵ��2018 ��Ա�� ����Ʒ��98��

--SELECT @BID_fhyr1  = billid FROM PM_Index WHERE billnumber = 'CX-180101-00030'   --�ŵ��2018 �ǻ�Ա�� ѡ������Ʒ��
SELECT @BID_fhyr1  = 0
SELECT @BID_fhyr98  = billid FROM PM_Index WHERE billnumber = 'CX-180101-00031'   --�ŵ��2018 �ǻ�Ա�� ��Ա98��

SELECT @BID_tdpz  = billid FROM PM_Index WHERE billnumber = 'CX-180201-00010'   --�ŵ��2018 �ض�Ʒ���ֶ�ָ���۸��޶�50��

IF (@BID_hyr1+@BID_hyr85+@BID_hyr95+@BID_hyr98+@BID_fhyr1+@BID_fhyr98+@BID_tdpz) IS NULL 
--IF (ISNULL(@BID_hyr1,0)+ISNULL(@BID_hyr85,0)+ISNULL(@BID_hyr95,0)+ISNULL(@BID_hyr98,0)+ISNULL(@BID_fhyr1,0)+ISNULL(@BID_fhyr98,0)) > 0
BEGIN 
  SELECT [�е�����]='ĳ����������ɾ�������޸��˵��ݺţ��洢����ֹͣ����'
  SELECT [�������]='ɾ�����е��ݺ��ýű��ؽ�����'
      RETURN		--�Ӹ�return �˳�ִ��SQL
END

--SET NOCOUNT OFF;

--ɾ����Ա����ϵ���ָ�����Ե�Ʒ��
DELETE FROM PM_Detail WHERE billid IN (@BID_hyr85,@BID_hyr95,@BID_hyr98) 
AND (
  P_ID IN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_hyr1))    --�ŵ��2018 ��Ա�� ѡ������Ʒ��
  OR 
  P_ID IN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_tdpz))   --�޳���Ʒ�ؼ۴���Ʒ��
    ) 

--ɾ���ǻ�Ա����ϵ���ָ�����Ե�Ʒ��
DELETE FROM PM_Detail WHERE billid IN (@BID_fhyr98)
AND (
  P_ID IN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_fhyr1))    --�ŵ��2018 ��Ա�� ѡ������Ʒ��
  OR 
  P_ID IN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_tdpz))   --�޳���Ʒ�ؼ۴���Ʒ��
    ) 


--ɾ����Ա����ϵ������Ʒ��
DELETE FROM PM_Detail WHERE billid = @BID_hyr85 AND P_ID NOT IN (SELECT p_id FROM zgxCxTemp C WHERE C.CLASS = 0.85 AND C.type = 1)
DELETE FROM PM_Detail WHERE billid = @BID_hyr95 AND P_ID NOT IN (SELECT p_id FROM zgxCxTemp C WHERE C.CLASS = 0.95 AND C.type = 1)
DELETE FROM PM_Detail WHERE billid = @BID_hyr98 AND P_ID NOT IN (SELECT p_id FROM zgxCxTemp C WHERE C.CLASS = 0.98 AND C.type = 1)

--ɾ���ǻ�Ա����ϵ������Ʒ��
DELETE FROM PM_Detail WHERE billid = @BID_fhyr98 AND P_ID NOT IN (SELECT p_id FROM zgxCxTemp C WHERE C.CLASS = 0.98 AND C.type = 0)


--��ʼ����PM_Detail����ϸ
--��Ա�� �Ǵ���Ʒ��85��
INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
SELECT @BID_hyr85,C.P_ID,C.u_id,0,0,C.class,0,1,0,0,0,C.profit_rate,0
FROM zgxCxTemp C LEFT JOIN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_hyr85)) PMD ON PMD.p_id = C.P_ID
WHERE C.CLASS = 0.85 AND C.type = 1  AND PMD.p_id IS NULL
AND C.P_ID NOT IN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_hyr1))		--�ų��ض�ѡ��Ʒ��

--��Ա�� ����ҩ95��
INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
SELECT @BID_hyr95,C.P_ID,C.u_id,0,0,C.class,0,1,0,0,0,C.profit_rate,0
FROM zgxCxTemp C LEFT JOIN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_hyr95)) PMD ON PMD.p_id = C.P_ID
WHERE C.CLASS = 0.95 AND C.type = 1  AND PMD.p_id IS NULL
AND C.P_ID NOT IN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_hyr1))		--�ų��ض�ѡ��Ʒ��

--��Ա�� ����Ʒ��98��
INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
SELECT @BID_hyr98,C.P_ID,C.u_id,0,0,C.class,0,1,0,0,0,C.profit_rate,0
FROM zgxCxTemp C LEFT JOIN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_hyr98)) PMD ON PMD.p_id = C.P_ID
WHERE C.CLASS = 0.98 AND C.type = 1  AND PMD.p_id IS NULL
AND C.P_ID NOT IN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_hyr1))		--�ų��ض�ѡ��Ʒ��
------
--�ǻ�Ա�� ��Ա98��
INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
SELECT @BID_fhyr98,C.P_ID,C.u_id,0,0,C.class,0,1,0,0,0,C.profit_rate,0
FROM zgxCxTemp C LEFT JOIN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_fhyr98)) PMD ON PMD.p_id = C.P_ID
WHERE C.CLASS = 0.98 AND C.type = 0  AND PMD.p_id IS NULL
AND C.P_ID NOT IN (SELECT p_id FROM PM_Detail WHERE billid IN (@BID_fhyr1))		--�ų��ض�ѡ��Ʒ��


---------------------------------------
--�����޹�

--����Ա��85�ۺ�,��ë����Ʒ�ֵ�ÿ��ÿ���޹���������Ϊ0
UPDATE PM_Detail SET vipDayQty = 0
--SELECT DISTINCT PMD.p_id ,CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice,0) - ISNULL(PXMD.costp,0))/ISNULL(PXMD.retailPrice,9999)) AS MLL  --ë����
FROM PM_Detail PMD,zgxCxTemp C
WHERE PMD.p_id = C.P_ID
AND C.CLASS = 0.85 AND C.type = 1 AND PMD.billid = @BID_hyr85
AND C.profit_rate >= 0
AND vipDayQty <> 0

--����Ա��95�ۺ�,��ë����Ʒ�ֵ�ÿ��ÿ���޹���������Ϊ0
UPDATE PM_Detail SET vipDayQty = 0
--SELECT DISTINCT PMD.p_id ,CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice,0) - ISNULL(PXMD.costp,0))/ISNULL(PXMD.retailPrice,9999)) AS MLL  --ë����
FROM PM_Detail PMD,zgxCxTemp C
WHERE PMD.p_id = C.P_ID 
AND C.CLASS = 0.95 AND C.type = 1 AND PMD.billid = @BID_hyr95
AND C.profit_rate >= 0
AND vipDayQty <> 0

---------
--����Ա��85�ۺ�,��ë����Ʒ�ֵ�ÿ��ÿ���޹���������Ϊ2
UPDATE PM_Detail SET vipDayQty = 2
--SELECT DISTINCT PMD.p_id ,CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice,0) - ISNULL(PXMD.costp,0))/ISNULL(PXMD.retailPrice,9999)) AS MLL  --ë����
FROM PM_Detail PMD,zgxCxTemp C
WHERE PMD.p_id = C.P_ID
AND C.CLASS = 0.85 AND C.type = 1 AND PMD.billid = @BID_hyr85
AND C.profit_rate < 0
AND vipDayQty <> 2


--����Ա��95�ۺ�,��ë����Ʒ�ֵ�ÿ��ÿ���޹���������Ϊ2
UPDATE PM_Detail SET vipDayQty = 2
--SELECT DISTINCT PMD.p_id ,CONVERT(NUMERIC(18,4),(ISNULL(PXMD.retailPrice,0) - ISNULL(PXMD.costp,0))/ISNULL(PXMD.retailPrice,9999)) AS MLL  --ë����
FROM PM_Detail PMD,zgxCxTemp C
WHERE PMD.p_id = C.P_ID
AND C.CLASS = 0.95 AND C.type = 1 AND PMD.billid = @BID_hyr95
AND C.profit_rate < 0
AND vipDayQty <> 2

TRUNCATE TABLE zgxCxTemp
