

--00_批量插入买2送一的促销
DECLARE @BID INT,@MBID INT,@DBID INT,@PNAME VARCHAR(100),@PID INT,@UID INT,@STIME DATETIME,@ETIME DATETIME
SET @STIME = '2017-12-31 00:00:00.000'		--此处为活动开始时间
SET @ETIME = '2018-01-02 00:00:00.000'		--此处为活动结束时间
DECLARE CURSOR_CUXIAO CURSOR FOR 
	SELECT PRODUCT_ID,NAME,U_ID FROM Products WHERE ((name LIKE '%葵花健康%' AND name LIKE '%蛋白质粉%') OR name LIKE '%佰思佳%')
	AND DELETED = 0 AND Isdir = 0 AND Code NOT IN ('31601064','31601065') ORDER BY NAME
OPEN CURSOR_CUXIAO
	FETCH NEXT FROM CURSOR_CUXIAO INTO @PID,@PNAME,@UID
WHILE @@FETCH_STATUS = 0
BEGIN 
	SELECT @MBID = MAX(billid) FROM PM_Index  --获得当前最大billid
	--开始插入PM_Index
	INSERT INTO PM_Index (billdate,billnumber,billtype,e_id,note,auditman,auditdate,billstate,begindate,
	enddate,begintime,endtime,weeks,days,RetailBill,SaleBill,VipType,p_id,MinPQty,MinMoney,SumSpeP,SumDisP,ChangeOne,
	Dts_BillID,Factory,LimitDays,MaxQty,MaxPCount,VipMaxQty,VipMaxPCount)
	VALUES(
	'2017-12-30 00:00:00.000','CX-171230-'+RIGHT('00000'+CONVERT(VARCHAR(6),@MBID+1),5),'12',2,'买二送一,'+@PNAME,
	2,CONVERT(VARCHAR(10),GETDATE(),23),'0',@STIME,@ETIME,'1900-01-01 00:00:00.000',
	'1900-01-01 23:59:59.000','1111111','11111111111111111111111111111111',
	'1','1','-1',@PID,'2.0000','0.0000','1','1','1','0','','1','0.0000','0','0.0000','0')
	SELECT @DBID = MAX(billid) FROM PM_Index   --获得插入后的billid
	
	--开始插入PM_Detail
	INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,
	billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
	VALUES(@DBID,@PID,@UID,0,0.0000000,1.0000000,0.0000,1.0000,0.0000,0.0000,0,'',0)
	
	--插入PM_ClientStock
	INSERT INTO PM_ClientStock (billid,mode,data_id,Dts_Detail_ID)
	VALUES(@DBID,0,0,0),
	(@DBID,1,0,0)
	
	FETCH NEXT FROM CURSOR_CUXIAO INTO @PID,@PNAME,@UID
END
CLOSE CURSOR_CUXIAO
DEALLOCATE CURSOR_CUXIAO

/*
SELECT * FROM PM_Index WHERE billnumber = 'CX-171115-00001'
DELETE FROM PM_Index WHERE billtype = 12 AND billid > 105
DELETE FROM PM_Detail WHERE billid > 105
DELETE FROM PM_ClientStock WHERE billid > 105
*/