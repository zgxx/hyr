--2018��2��12��16:19:02
--00_00_��������2018 ��Ա�� ��ѡ�޹�Ʒ�ֵ���,CX-180101-00020,������ݺŴ��ڣ���ֹͣ����
DECLARE @BID_hyr01 INT,@DBID INT,@STIME DATETIME,@ETIME DATETIME
SELECT @BID_hyr01  = billid FROM PM_Index WHERE billnumber = 'CX-180101-00020'   --��Ա�� ��ѡ�޹�Ʒ�� �ŵ��2018

IF ISNULL(@BID_hyr01,0) > 0
BEGIN 
  SELECT [�е�����]='�˽ű��Ѿ���ִ�й�������ڵ��ݺź�����һ���Ĵ�����'
  SELECT [�������]='�벻Ҫ�ظ�ִ�У�����ɾ��ԭ�е���'
      RETURN		--�Ӹ�return �˳�ִ��SQL
END

SET @STIME = '2018-01-01 00:00:00.000'		--�˴�Ϊ���ʼʱ��
SET @ETIME = '2030-12-31 00:00:00.000'		--�˴�Ϊ�����ʱ��

	--��ʼ����PM_Index
	INSERT INTO PM_Index (billdate,billnumber,billtype,e_id,note,auditman,auditdate,billstate,begindate,
	enddate,begintime,endtime,weeks,days,RetailBill,SaleBill,VipType,p_id,MinPQty,MinMoney,SumSpeP,SumDisP,ChangeOne,
	Dts_BillID,Factory,LimitDays,MaxQty,MaxPCount,VipMaxQty,VipMaxPCount)
	VALUES(
	'2018-01-01 00:00:00.000','CX-180101-00020',17,2,'2018 ��Ա�� ��ѡ�޹�Ʒ��',
	2,'2018-02-16 00:00:00.000',0,@STIME,@ETIME,'1900-01-01 00:00:00.000',
	'1900-01-01 23:59:59.000','1111111','00000100000000010000000001000000',
	'1','0','0',0,'0','0','0','0','0','0','','1','0','0','0','0')
	
	SELECT @DBID = MAX(billid) FROM PM_Index   --��ò�����billid
	
	/*
	--��ʼ����PM_Detail
	INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,
	billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
	VALUES(@DBID,@PID,@UID,0,0.0000000,1.0000000,0.0000,1.0000,0.0000,0.0000,0,'',0)
	*/
	
	--����PM_ClientStock
	INSERT INTO PM_ClientStock (billid,mode,data_id,Dts_Detail_ID)
	SELECT @DBID,0,0,0 UNION ALL SELECT @DBID,1,0,0	

/*
SELECT * FROM PM_Index WHERE billnumber = 'CX-171115-00001'
DELETE FROM PM_Index WHERE billtype = 12 AND billid > 105
DELETE FROM PM_Detail WHERE billid > 105
DELETE FROM PM_ClientStock WHERE billid > 105
*/