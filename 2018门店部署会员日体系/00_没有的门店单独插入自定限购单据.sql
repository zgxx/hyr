--2018年2月12日16:19:02
--00_00_单独插入2018 会员日 自选限购品种单据,CX-180101-00020,如果单据号存在，则停止插入
DECLARE @BID_hyr01 INT,@DBID INT,@STIME DATETIME,@ETIME DATETIME
SELECT @BID_hyr01  = billid FROM PM_Index WHERE billnumber = 'CX-180101-00020'   --会员日 自选限购品种 门店版2018

IF ISNULL(@BID_hyr01,0) > 0
BEGIN 
  SELECT [有点问题]='此脚本已经被执行过，或存在单据号和上面一样的促销单'
  SELECT [解决方法]='请不要重复执行，或先删除原有单据'
      RETURN		--加个return 退出执行SQL
END

SET @STIME = '2018-01-01 00:00:00.000'		--此处为活动开始时间
SET @ETIME = '2030-12-31 00:00:00.000'		--此处为活动结束时间

	--开始插入PM_Index
	INSERT INTO PM_Index (billdate,billnumber,billtype,e_id,note,auditman,auditdate,billstate,begindate,
	enddate,begintime,endtime,weeks,days,RetailBill,SaleBill,VipType,p_id,MinPQty,MinMoney,SumSpeP,SumDisP,ChangeOne,
	Dts_BillID,Factory,LimitDays,MaxQty,MaxPCount,VipMaxQty,VipMaxPCount)
	VALUES(
	'2018-01-01 00:00:00.000','CX-180101-00020',17,2,'2018 会员日 自选限购品种',
	2,'2018-02-16 00:00:00.000',0,@STIME,@ETIME,'1900-01-01 00:00:00.000',
	'1900-01-01 23:59:59.000','1111111','00000100000000010000000001000000',
	'1','0','0',0,'0','0','0','0','0','0','','1','0','0','0','0')
	
	SELECT @DBID = MAX(billid) FROM PM_Index   --获得插入后的billid
	
	/*
	--开始插入PM_Detail
	INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,
	billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
	VALUES(@DBID,@PID,@UID,0,0.0000000,1.0000000,0.0000,1.0000,0.0000,0.0000,0,'',0)
	*/
	
	--插入PM_ClientStock
	INSERT INTO PM_ClientStock (billid,mode,data_id,Dts_Detail_ID)
	SELECT @DBID,0,0,0 UNION ALL SELECT @DBID,1,0,0	

/*
SELECT * FROM PM_Index WHERE billnumber = 'CX-171115-00001'
DELETE FROM PM_Index WHERE billtype = 12 AND billid > 105
DELETE FROM PM_Detail WHERE billid > 105
DELETE FROM PM_ClientStock WHERE billid > 105
*/