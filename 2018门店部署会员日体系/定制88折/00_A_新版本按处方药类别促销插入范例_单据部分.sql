--2018��2��26��9:14:59��zgx
--�޸�ָ���ؼ�Ʒ�ֵ�ʱ��Ϊ��Ա��

--�����������,�����������һ�����ݺŴ��ڣ���ֹͣ���뵥��
DECLARE @BID_hyr1 INT,@BID_hyr88 INT,@BID_hyr95 INT,@BID_hyr98 INT, @BID_fhyr1 INT,@BID_fhyr98 INT,@BID_tdpz INT
SELECT @BID_hyr1  = billid FROM PM_Index WHERE billnumber = 'CX-180101-00020'   --2018 ��Ա�� ��ѡ�޹�Ʒ��
--SELECT @BID_hyr1  = 0
SELECT @BID_hyr88 = billid FROM PM_Index WHERE billnumber = 'CX-180101-00021'	 --2018 ��Ա�� �Ǵ���Ʒ��88�� �Զ�������
SELECT @BID_hyr95 = billid FROM PM_Index WHERE billnumber = 'CX-180101-00022'	 --2018 ��Ա�� ����ҩ95�� �Զ�������
SELECT @BID_hyr98 = billid FROM PM_Index WHERE billnumber = 'CX-180101-00023'   --2018 ��Ա�� ����Ʒ��98�� �Զ�������

--SELECT @BID_fhyr1  = billid FROM PM_Index WHERE billnumber = 'CX-180101-00030'   --2018 �ǻ�Ա�� ѡ������Ʒ��
SELECT @BID_fhyr1  = 0
SELECT @BID_fhyr98  = billid FROM PM_Index WHERE billnumber = 'CX-180101-00031'   --2018 �ǻ�Ա�� ��Ա98�� �Զ�������

SELECT @BID_tdpz  = billid FROM PM_Index WHERE billnumber = 'CX-180201-00010'   --�ŵ��2018,�ֶ�ָ���۸�Ʒ��,�޶�50��,�����Զ�ɾ��


--�Ƚ����ִ��۵ı��������ݺţ��ͱ�ע������ʱ��
IF exists (select * from tempdb..sysobjects where id = object_id('tempdb..##CxZKTemp'))
DROP table [dbo].[##CxZKTemp]
CREATE TABLE [dbo].[##CxZKTemp]([ZKL] NUMERIC(18,2) NOT NULL,[BNUM] VARCHAR(10) NOT NULL,[NOTE] VARCHAR(255) NOT NULL,[type] INT NOT NULL)	--typeΪ1�ǻ�Ա�յ���
INSERT INTO ##CxZKTemp (ZKL,BNUM,NOTE,type)
SELECT 1.00,'00020','2018 ��Ա�� ��ѡ�޹�Ʒ��',1 UNION ALL
SELECT 0.88,'00021','2018 ��Ա�� �Ǵ���Ʒ��88�� �Զ�������',1 UNION ALL 
SELECT 0.95,'00022','2018 ��Ա�� ����ҩ95�� �Զ�������',1 UNION ALL 
SELECT 0.98,'00023','2018 ��Ա�� ����Ʒ��98�� �Զ�������',1 UNION ALL 
--SELECT 0.98,'2018 �ǻ�Ա�� ѡ������Ʒ��',0 UNION ALL 
SELECT 0.98,'00031','2018 �ǻ�Ա�� ��Ա98�� �Զ�������',0 UNION ALL 
SELECT 1.00,'00010',CONVERT(VARCHAR(30),GETDATE(),120)+'���ŵ��2018����Ա���ֶ�ָ���۸�Ʒ��,�޶�50��,�����Զ�ɾ��',5	--����������;

--SELECT * FROM ##CxZKTemp

--�Զ����µ��ݱ�ע
UPDATE PM_Index 
SET note = CZK.NOTE
FROM PM_Index PMD, ##CxZKTemp CZK
WHERE RIGHT(PMD.billnumber ,5)= CZK.BNUM
AND PMD.billdate >= '2018-01-01 00:00:00.000'


/*
--�˷���sql2000��֧��
IF exists (select * from tempdb..sysobjects where id = object_id('tempdb..##CxZKTemp'))
DROP table [dbo].[##CxZKTemp]
CREATE TABLE [dbo].[##CxZKTemp]([ZKL] NUMERIC(18,2) NOT NULL,[BNUM] VARCHAR(3) NOT NULL,[NOTE] VARCHAR(80) NOT NULL,[type] INT NOT NULL)	--typeΪ1�ǻ�Ա�յ���
INSERT INTO ##CxZKTemp VALUES 
(1.00,'20','2018 ��Ա�� ��ѡ�޹�Ʒ��',1),
(0.88,'21','2018 ��Ա�� �Ǵ���Ʒ��88�� �Զ�������',1),
(0.95,'22','2018 ��Ա�� ����ҩ95�� �Զ�������',1),
(0.98,'23','2018 ��Ա�� ����Ʒ��98�� �Զ�������',1),
(0.98,'30','2018 �ǻ�Ա�� ѡ������Ʒ��',0),
(0.98,'31','31','2018 �ǻ�Ա�� ��Ա98�� �Զ�������',0)
*/

--IF (@BID_hyr1+@BID_hyr88+@BID_hyr95+@BID_hyr98+@BID_fhyr1+@BID_fhyr98) IS NOT NULL 
IF (ISNULL(@BID_hyr1,0)+ISNULL(@BID_hyr88,0)+ISNULL(@BID_hyr95,0)+ISNULL(@BID_hyr98,0)+ISNULL(@BID_fhyr1,0)+ISNULL(@BID_fhyr98,0)+ISNULL(@BID_tdpz,0)) > 0
BEGIN 
  SELECT [�е�����]='�˽ű��Ѿ���ִ�й�������ڵ��ݺź�����һ���Ĵ�����'
  SELECT [�������]='�벻Ҫ�ظ�ִ�У�����ɾ����Ӧ������'
      RETURN		--�Ӹ�return �˳�ִ��SQL
END

DECLARE @ZKL1 NUMERIC(18,2),@BNUM1 VARCHAR(6),@NOTE1 VARCHAR(80),@DBID1 INT,
@ZKL2 NUMERIC(18,2),@BNUM2 VARCHAR(6),@NOTE2 VARCHAR(80),@DBID2 INT,
@PID INT,@UID INT

--��ʼѭ����������Ʒ�ۿ����ô����ĵ��ݺ���ϸ
--����Ҫ�����Ա�յ����
DECLARE CURSOR_CX_HYR CURSOR FOR 
	SELECT zkl,bnum,note FROM ##CxZKTemp WHERE type = 1
OPEN CURSOR_CX_HYR
	FETCH NEXT FROM CURSOR_CX_HYR INTO @ZKL1,@BNUM1,@NOTE1
WHILE @@FETCH_STATUS = 0
BEGIN

	--����PM_Index
	INSERT INTO PM_Index (billdate,billnumber,billtype,e_id,note,auditman,auditdate,billstate,begindate,
	enddate,begintime,endtime,weeks,days,RetailBill,SaleBill,VipType,p_id,MinPQty,MinMoney,SumSpeP,SumDisP,ChangeOne,
	Dts_BillID,Factory,LimitDays,MaxQty,MaxPCount,VipMaxQty,VipMaxPCount)
	VALUES(
	'2018-01-01 00:00:00.000','CX-180101-'+RIGHT(@BNUM1,5),17,2,@NOTE1,2,CONVERT(VARCHAR(10),GETDATE(),23),'0','2018-01-01 00:00:00.000','2030-12-31 00:00:00.000',
	'1900-01-01 00:00:00.000','1900-01-01 23:59:59.000','1111111','00000100000000010000000001000000','1',0,0,0,'0.0000','0.0000','0','0','0','0',
	' ','1','0.0000','0','0.0000','0')

	SELECT @DBID1 = MAX(billid) FROM PM_Index    --��ò�����billid

	--����PM_ClientStock
	INSERT INTO PM_ClientStock (billid,mode,data_id,Dts_Detail_ID) SELECT @DBID1,0,0,0 UNION ALL SELECT @DBID1,1,0,0
/*
	--��ʼ����PM_Detail
	INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
	SELECT @DBID1,P_ID,u_id,0,0,@ZKL1,0,1,0,0,0,'',0
	FROM zgxCxTemp WHERE CLASS = @ZKL1 AND type = 1
*/
	FETCH NEXT FROM CURSOR_CX_HYR INTO @ZKL1,@BNUM1,@NOTE1
END
CLOSE CURSOR_CX_HYR
DEALLOCATE CURSOR_CX_HYR

--++++++++++++++++++++++++++++++++++++++
--Ҫ����ǻ�Ա�յ�
DECLARE CURSOR_CX_HYR CURSOR FOR 
	SELECT zkl,bnum,note FROM ##CxZKTemp WHERE type = 0
OPEN CURSOR_CX_HYR
	FETCH NEXT FROM CURSOR_CX_HYR INTO @ZKL2,@BNUM2,@NOTE2
WHILE @@FETCH_STATUS = 0
BEGIN

	--����PM_Index
	INSERT INTO PM_Index (billdate,billnumber,billtype,e_id,note,auditman,auditdate,billstate,begindate,
	enddate,begintime,endtime,weeks,days,RetailBill,SaleBill,VipType,p_id,MinPQty,MinMoney,SumSpeP,SumDisP,ChangeOne,
	Dts_BillID,Factory,LimitDays,MaxQty,MaxPCount,VipMaxQty,VipMaxPCount)
	VALUES(
	'2018-01-01 00:00:00.000','CX-180101-'+RIGHT(@BNUM2,5),17,2,@NOTE2,2,CONVERT(VARCHAR(10),GETDATE(),23),'0','2018-01-01 00:00:00.000','2030-12-31 00:00:00.000',
	'1900-01-01 00:00:00.000','1900-01-01 23:59:59.000','1111111','11111011111111101111111110111111','1',0,0,0,'0.0000','0.0000','0','0','0','0',
	' ','1','0.0000','0','0.0000','0')

	SELECT @DBID2 = MAX(billid) FROM PM_Index    --��ò�����billid

	--����PM_ClientStock
	INSERT INTO PM_ClientStock (billid,mode,data_id,Dts_Detail_ID) SELECT @DBID2,0,0,0 UNION ALL SELECT @DBID2,1,0,0
/*
	--��ʼ����PM_Detail
	INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
	SELECT @DBID2,P_ID,u_id,0,0,@ZKL2,0,1,0,0,0,'',0
	FROM zgxCxTemp WHERE CLASS = @ZKL2 AND type = 0
*/
	FETCH NEXT FROM CURSOR_CX_HYR INTO @ZKL2,@BNUM2,@NOTE2
END
CLOSE CURSOR_CX_HYR
DEALLOCATE CURSOR_CX_HYR


--���������Ʒ�ؼ۴����ĵ���
DECLARE @DBIDtj INT
--PM_Index
	INSERT INTO PM_Index (billdate,billnumber,billtype,e_id,note,auditman,auditdate,billstate,begindate,
	enddate,begintime,endtime,weeks,days,RetailBill,SaleBill,VipType,p_id,MinPQty,MinMoney,SumSpeP,SumDisP,ChangeOne,
	Dts_BillID,Factory,LimitDays,MaxQty,MaxPCount,VipMaxQty,VipMaxPCount)
	VALUES(
	'2018-02-01 00:00:00.000','CX-180201-00010',10,2,CONVERT(VARCHAR(20),GETDATE(),120)+'���ŵ��2018����Ա���ֶ�ָ���۸�Ʒ��,�޶�50��,�����Զ�ɾ��',2,CONVERT(VARCHAR(10),GETDATE(),23),'0','2018-02-01 00:00:00.000','2030-12-31 00:00:00.000',
	'1900-01-01 00:00:00.000','1900-01-01 23:59:59.000','1111111','00000100000000010000000001000000','1',0,0,0,'0.0000','0.0000','0','0','0','0',
	' ','1','0.0000','0','0.0000','0')

	SELECT @DBIDtj = MAX(billid) FROM PM_Index WHERE billtype = 10    --��ò�����billid

	--����PM_ClientStock
	INSERT INTO PM_ClientStock (billid,mode,data_id,Dts_Detail_ID) SELECT @DBIDtj,0,0,0 UNION ALL SELECT @DBIDtj,1,0,0
	/*
	--��ʼ����PM_Detail����
	INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
	SELECT @DBIDtj,7034,2,0,5.5,1,0,1,0,0,0,'����Ϊʾ������Ҫɾ��',0
	*/