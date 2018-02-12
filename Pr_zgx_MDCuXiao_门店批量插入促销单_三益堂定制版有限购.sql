
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
--EXEC zgx_MDCuXiao       --������ҵϵͳ��ÿ���Զ�������Ʒ�֣�2017��10��25��
--2017��10��25��16:46:28 �޸ģ������½�¹�ǽ�(��¹)(ֽ��)��Ա�ձ��95�ۣ�ƽʱ98��

/*
SELECT * FROM PM_Index WHERE billtype = 17
SELECT * FROM PM_Detail WHERE billid IN (48)
SELECT * FROM PM_Detail WHERE billid IN (45,46,47,48) AND p_id IN (SELECT Product_ID FROM Products WHERE name LIKE '%�ֲ%' AND Isdir = 0 AND DELETED = 0)
*/

--�˴洢����,��ҩ��Ƭ��������,���Ҵ���"������"��"�人���ĿƼ�"�����98��

-----++++++++++++++++++++ʹ��ǰע��!�ȿ��������++++++++++++++++++++++++++-----
--������α�/*��*/ע�͵������Ҫ���ܲ��Ŀհ���ʽ�������´��������ֶ�ִ��һ��
--���´�����ʽ�̶������ⱻ�ܲ����޸ĵĸ��ǣ�Ȼ���ٽ�EXEC zgx_MDCuXiao����ÿ������Ķ�ʱ��ҵϵͳ
/*
UPDATE PM_Index SET note = '�ŵ�� '+note WHERE billnumber 
IN ('CX-170831-00001','CX-170831-00002','CX-170831-00003','CX-170831-00004') AND note NOT LIKE '�ŵ�� %'

UPDATE PM_Index SET Dts_BillID = 0 WHERE note LIKE '�ŵ�� %' AND Dts_BillID <> 0
*/-----++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----





DECLARE @BID95 INT,@BID88 INT,@BID98 INT,@BID98q INT
SELECT @BID95  = billid FROM PM_Index WHERE billnumber = 'CX-170831-00001' AND note LIKE '�ŵ�� %'   --��Ա�� ����ҩ 95��
SELECT @BID88  = billid FROM PM_Index WHERE billnumber = 'CX-170831-00002' AND note LIKE '�ŵ�� %'	 --��Ա�� �Ǵ���ҩ 88��
SELECT @BID98q = billid FROM PM_Index WHERE billnumber = 'CX-170831-00003' AND note LIKE '�ŵ�� %'	 --��Ա�� ������������Ʒ�� 98��
SELECT @BID98  = billid FROM PM_Index WHERE billnumber = 'CX-170831-00004' AND note LIKE '�ŵ�� %'   --�ǻ�Ա�� 98��

IF (@BID95 + @BID88 + @BID98q + @BID98) IS NULL 
BEGIN 
  SELECT [�е�����]='�ŵ굱ǰ��û�ж�Ӧ�ܲ��Ĵ�����,�޷��Զ����¨r(�s���t)�q'
  SELECT [�������]='�ȵ����ܲ��������ݣ���һ������һ����Ȼ��������ѡ���ﹴѡ���ܴ��������ٴ��䣬ôô��'
      RETURN		--�Ӹ�return �˳�ִ��SQL
END


--�����Ա�� ����ҩ 95�������������޳�����
DELETE FROM PM_Detail WHERE billid = @BID95 AND p_id IN 
  (SELECT Product_ID FROM Products WHERE DELETED = 1 OR Isdir = 1 OR (OTCFlag = 0 AND ColdStore = 0) 
    OR Product_ID IN (8000,8001,8456,19072) 
    OR PRODUCT_ID IN (SELECT Product_ID FROM Products WHERE name LIKE '%�ֲ%' AND Isdir = 0 AND DELETED = 0)
    ) --7310�����½�¹�ǽ�(��¹)(ֽ��)���ӻ�Ա��95����ɾ��
    AND p_id NOT IN (7310)

--�����Ա�� �Ǵ���ҩ 88�����������
DELETE FROM PM_Detail WHERE billid = @BID88 AND p_id 
IN (SELECT Product_ID FROM Products WHERE DELETED = 1 OR OTCFlag > 0 OR Isdir = 1
	OR ColdStore = 1 OR Parent_id LIKE '000004000001%'   --�޳���ҩ��Ƭ
	OR Product_ID IN (8000,8001,8456,19072)				 --�޳�����
	OR Factory LIKE '�人���ĿƼ�%' OR Factory LIKE '%������%'			 --�������޳�
	OR Product_ID IN (7310)							--7310�����޳��½�¹�ǽ�(��¹)(ֽ��)
    OR PRODUCT_ID IN (SELECT Product_ID FROM Products WHERE name LIKE '%�ֲ%' AND Isdir = 0 AND DELETED = 0)
  )

--�����Ա�� ���� 98�����������
DELETE FROM PM_Detail WHERE billid = @BID98q AND p_id 
IN ( SELECT Product_ID FROM Products WHERE DELETED = 1 OR Isdir = 1 OR OTCFlag > 0 OR (Factory NOT LIKE '�人���ĿƼ�%' AND Factory NOT LIKE '%������%')
	OR Product_ID IN (8000,8001,8456,19072)
    OR PRODUCT_ID IN (SELECT Product_ID FROM Products WHERE name LIKE '%�ֲ%' AND Isdir = 0 AND DELETED = 0)
	)

--����ǻ�Ա��98����������ȫ��98�ۣ����в�������ҩ��Ƭ
DELETE FROM PM_Detail WHERE billid = @BID98 AND p_id 
IN (SELECT Product_ID FROM Products WHERE Isdir = 1 OR DELETED = 1 OR Parent_id LIKE '000004000001%' OR Product_ID IN (8000,8001,8456,19072)
   OR PRODUCT_ID IN (SELECT Product_ID FROM Products WHERE name LIKE '%�ֲ%' AND Isdir = 0 AND DELETED = 0)
    )



--�����Ա��,����ҩ95�۵�Ʒ�֣���������
DECLARE CURSOR_CHUFANG CURSOR FOR
	SELECT P.Product_ID,U_ID FROM Products AS P (NOLOCK) 
	LEFT JOIN PM_Detail PMD 
	ON P.Product_ID = PMD.p_id AND PMD.billid = @BID95
	WHERE PMD.p_id IS NULL AND P.DELETED = 0 AND P.Isdir = 0 AND (P.OTCFlag >0 OR P.ColdStore = 1 OR P.Product_ID IN (7310))		--7310�����½�¹�ǽ�(��¹)(ֽ��)�����Ա��95����
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
--�ر��α�
CLOSE CURSOR_CHUFANG
--�ͷ���Դ
DEALLOCATE CURSOR_CHUFANG


--�����Ա��,�Ǵ���ҩ88�۵�Ʒ��
DECLARE CURSOR_FEICHUFANG CURSOR FOR
	SELECT P.Product_ID,U_ID FROM Products P (NOLOCK) 
	LEFT JOIN PM_Detail PMD 
	ON P.Product_ID = PMD.p_id AND PMD.billid = @BID88
	LEFT JOIN 
	(SELECT Product_ID FROM Products WHERE Parent_id LIKE '000004000001%' AND DELETED = 0 AND Isdir = 0) AS ZYYP	--�޳���ҩ��Ƭ
	ON P.Product_ID = ZYYP.Product_ID
	 WHERE PMD.p_id IS NULL AND ZYYP.Product_ID IS NULL AND P.DELETED = 0 AND P.Isdir = 0
	 AND P.OTCFlag = 0 AND P.ColdStore = 0 AND P.Product_ID NOT IN (8000,8001,8456,19072)
	 AND P.Product_ID NOT IN (SELECT Product_ID FROM Products WHERE (Factory LIKE '�人���ĿƼ�%' OR Factory LIKE '%������%') AND DELETED = 0 AND Isdir = 0)
	 AND P.Product_ID NOT IN (7310)		--������½�¹�ǽ�(��¹)(ֽ��)
	 AND P.PRODUCT_ID NOT IN (SELECT Product_ID FROM Products WHERE name LIKE '%�ֲ%' AND Isdir = 0 AND DELETED = 0)
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
--�ر��α�
CLOSE CURSOR_FEICHUFANG
--�ͷ���Դ
DEALLOCATE CURSOR_FEICHUFANG


--�����Ա��,�ض�98�۵�Ʒ��
DECLARE CURSOR_HYR98 CURSOR FOR
	SELECT P.Product_ID,U_ID FROM Products P (NOLOCK) 
	LEFT JOIN PM_Detail PMD 
	ON P.Product_ID = PMD.p_id AND PMD.billid = @BID98q
	WHERE PMD.p_id IS NULL AND P.DELETED = 0 AND P.Isdir = 0 AND (Factory LIKE '�人���ĿƼ�%' OR Factory LIKE '%������%' )
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
--�ر��α�
CLOSE CURSOR_HYR98
--�ͷ���Դ
DEALLOCATE CURSOR_HYR98


--����ǻ�Ա��98�۵�Ʒ��
DECLARE CURSOR_FEIHYR CURSOR FOR
SELECT P.Product_ID,U_ID FROM Products P (NOLOCK) 
	LEFT JOIN PM_Detail PMD 
	ON P.Product_ID = PMD.p_id AND PMD.billid = @BID98
	LEFT JOIN (SELECT Product_ID FROM Products WHERE Parent_id LIKE '000004000001%' AND DELETED = 0 AND Isdir = 0) AS ZYYP
	ON P.Product_ID = ZYYP.Product_ID 
	WHERE PMD.p_id IS NULL AND ZYYP.Product_ID IS NULL AND P.DELETED = 0 AND P.Isdir = 0 AND P.Product_ID NOT IN (8000,8001,8456,19072) 
	AND P.PRODUCT_ID NOT IN (SELECT Product_ID FROM Products WHERE name LIKE '%�ֲ%' AND Isdir = 0 AND DELETED = 0)
	--�޳���ҩ��Ƭ�������Ʒ��
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
--�ر��α�
CLOSE CURSOR_FEIHYR
--�ͷ���Դ
DEALLOCATE CURSOR_FEIHYR


--��95�ۺ���ë���Ĵ���ҩƷ�ֵ�ÿ��ÿ���޹���������Ϊ0
UPDATE PM_Detail SET vipDayQty = 0
FROM PM_Detail PMD,
(
	SELECT DISTINCT p.Product_ID AS P_ID
	FROM s_storehouse AS S, Products AS P, 
	  (SELECT A.P_id,A.retailPrice,A.Y_id, U_id FROM Px_price A WHERE a.Y_id IN 
		  (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B 
		   WHERE A.P_id = B.p_id
		   AND A.retailPrice <> 0)
	   ) AS PXMD	--����ŵ�ļ۸���ϵ��Y_id��Ϊ0����,ֻҪ������λ�����ɸѡ
	WHERE S.p_id = P.product_id AND PXMD.p_id = S.p_id AND PXMD.U_id = P.U_id 
	 AND S.S_id <> 15 AND S.costprice > 0.1		--ȥ��һЩ��Ʒ
	 AND P.DELETED = 0 AND P.Isdir = 0 AND (P.OTCFlag > 0 OR P.ColdStore = 1) AND P.Product_ID NOT IN (8000,8001,8456,19072)
	 AND PXMD.retailPrice*0.95-s.costprice >= 0
	) AS FML95				
WHERE FML95.P_ID = PMD.p_id AND PMD.vipDayQty > 0 AND PMD.billid = @BID95

--��88�ۺ���ë���ķǴ���ҩƷ�ֵ�ÿ��ÿ���޹���������Ϊ0
UPDATE PM_Detail SET vipDayQty = 0
FROM PM_Detail PMD,
(
	SELECT DISTINCT p.Product_ID AS P_ID
	FROM s_storehouse AS S, Products AS P, 
	  (SELECT A.P_id,A.retailPrice,A.Y_id, U_id FROM Px_price A WHERE a.Y_id IN 
		  (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B 
		   WHERE A.P_id = B.p_id
		   AND A.retailPrice <> 0)
	   ) AS PXMD	--����ŵ�ļ۸���ϵ��Y_id��Ϊ0����,ֻҪ������λ�����ɸѡ
	WHERE S.p_id = P.product_id AND PXMD.p_id = S.p_id AND PXMD.U_id = P.U_id 
	 AND S.S_id <> 15 AND S.costprice > 0.1		--ȥ��һЩ��Ʒ
	 AND P.OTCFlag = 0 AND P.ColdStore = 0 AND P.Product_ID NOT IN (8000,8001,8456,19072)
	 AND P.Product_ID NOT IN (SELECT Product_ID FROM Products WHERE Factory LIKE '�人���ĿƼ�%' OR Factory LIKE '%������%')
	 AND PXMD.retailPrice*0.88-s.costprice >= 0
	) AS FML88
WHERE FML88.P_ID = PMD.p_id AND PMD.vipDayQty > 0 AND PMD.billid = @BID88


--Ȼ��95�ۺ�ë���Ĵ���ҩƷ�ֵ�ÿ��ÿ���޹���������Ϊ2
--������Լ134��
UPDATE PM_Detail SET vipDayQty = 2
--SELECT * 
FROM PM_Detail PMD,
(
	SELECT DISTINCT p.Product_ID AS P_ID
	--,p.Code,P.name,P.Standard,P.Factory,PXMD.retailPrice*0.95 AS ��95��,PXMD.PrePrice1 AS ���ͼ�,PXMD.PrePrice1-PXMD.retailPrice*0.95 AS ÿ�п�
	FROM s_storehouse AS S, Products AS P, 
	  (SELECT A.P_id,A.retailPrice,A.PrePrice1,A.Y_id, U_id FROM Px_price A WHERE a.Y_id IN 
		  (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B 
		   WHERE A.P_id = B.p_id
		   AND A.retailPrice <> 0)
	   ) AS PXMD	--����ŵ�ļ۸���ϵ��Y_id��Ϊ0����,ֻҪ������λ�����ɸѡ
	WHERE S.p_id = P.product_id AND PXMD.p_id = S.p_id AND PXMD.U_id = P.U_id 
	 AND S.S_id <> 15 AND S.costprice > 0.1		--ȥ��һЩ��Ʒ
	 AND P.DELETED = 0 AND P.Isdir = 0 AND (P.OTCFlag > 0 OR P.ColdStore = 1) AND P.Product_ID NOT IN (8000,8001,8456,19072)
	 AND PXMD.retailPrice*0.95-s.costprice < 0
	) AS FML95				
WHERE FML95.P_ID = PMD.p_id AND PMD.billid = @BID95
AND PMD.vipDayQty <> 2


--Ȼ��88�ۺ�ë���ķǴ���ҩƷ�ֵ�ÿ��ÿ���޹���������Ϊ2
--������Լ154��
UPDATE PM_Detail SET vipDayQty = 2
--SELECT * 
FROM PM_Detail PMD,
(
	SELECT DISTINCT p.Product_ID AS P_ID
	,p.Code,P.name,P.Standard,P.Factory,PXMD.retailPrice*0.95 AS ��95��,PXMD.PrePrice1 AS ���ͼ�,PXMD.PrePrice1-PXMD.retailPrice*0.95 AS ÿ�п�
	FROM s_storehouse AS S, Products AS P, 
	  (SELECT A.P_id,A.retailPrice,A.PrePrice1,A.Y_id, U_id FROM Px_price A WHERE a.Y_id IN 
		  (SELECT max(B.Y_id) AS Y_id FROM Px_price AS B 
		   WHERE A.P_id = B.p_id
		   AND A.retailPrice <> 0)
	   ) AS PXMD	--����ŵ�ļ۸���ϵ��Y_id��Ϊ0����,ֻҪ������λ�����ɸѡ
	WHERE S.p_id = P.product_id AND PXMD.p_id = S.p_id AND PXMD.U_id = P.U_id 
	 AND S.S_id <> 15 AND S.costprice > 0.1		--ȥ��һЩ��Ʒ
	 AND P.OTCFlag = 0 AND P.ColdStore = 0 AND P.Product_ID NOT IN (8000,8001,8456,19072)
	 AND P.Product_ID NOT IN (SELECT Product_ID FROM Products WHERE Factory LIKE '�人���ĿƼ�%' OR Factory LIKE '%������%')
	 AND PXMD.retailPrice*0.88-s.costprice < 0
	) AS FML88
WHERE FML88.P_ID = PMD.p_id AND PMD.billid = @BID88
AND PMD.vipDayQty <> 2


SET QUOTED_IDENTIFIER OFF
