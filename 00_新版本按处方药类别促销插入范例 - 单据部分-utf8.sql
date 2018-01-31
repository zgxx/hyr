

--先将几种打折的比例，单据号，和备注插入临时表
IF exists (select * from tempdb..sysobjects where id = object_id('tempdb..#CxZKTemp'))
DROP table [dbo].[#CxZKTemp]
CREATE TABLE [dbo].[#CxZKTemp]([ZKL] NUMERIC(18,2) NOT NULL,[BNUM] VARCHAR(3) NOT NULL,[NOTE] VARCHAR(80) NOT NULL,[type] INT NOT NULL)	--type为1是会员日当天
INSERT INTO #CxZKTemp VALUES 
(1.00,'20','门店版2018 会员日 选定不打折品种',1),
(0.85,'21','门店版2018 会员日 非处方品种85折',1),
(0.95,'22','门店版2018 会员日 处方药95折',1),
(0.98,'23','门店版2018 会员日 部分品种98折',1),
(0.98,'30','门店版2018 非会员日 选定不打折品种',0),
(0.98,'31','门店版2018 非会员日 会员98折',0)

DECLARE @ZKL1 NUMERIC(18,2),@BNUM1 VARCHAR(3),@NOTE1 VARCHAR(80),@DBID1 INT,
@ZKL2 NUMERIC(18,2),@BNUM2 VARCHAR(3),@NOTE2 VARCHAR(80),@DBID2 INT,
@PID INT,@UID INT

--开始循环，插入单据和明细
--首先要插入会员日当天的
DECLARE CURSOR_CX_HYR CURSOR FOR 
	SELECT zkl,bnum,note FROM #CxZKTemp WHERE type = 1
OPEN CURSOR_CX_HYR
	FETCH NEXT FROM CURSOR_CX_HYR INTO @ZKL1,@BNUM1,@NOTE1
WHILE @@FETCH_STATUS = 0
BEGIN

	--插入PM_Index
	INSERT INTO PM_Index (billdate,billnumber,billtype,e_id,note,auditman,auditdate,billstate,begindate,
	enddate,begintime,endtime,weeks,days,RetailBill,SaleBill,VipType,p_id,MinPQty,MinMoney,SumSpeP,SumDisP,ChangeOne,
	Dts_BillID,Factory,LimitDays,MaxQty,MaxPCount,VipMaxQty,VipMaxPCount)
	VALUES(
	'2018-01-01 00:00:00.000','CX-180101-'+RIGHT('000'+@BNUM1,6),17,2,@NOTE1,2,CONVERT(VARCHAR(10),GETDATE(),23),'0','2018-01-01 00:00:00.000','2030-01-15 00:00:00.000',
	'1900-01-01 00:00:00.000','1900-01-01 23:59:59.000','1111111','00000100000000010000000001000000','1',0,0,0,'0.0000','0.0000','0','0','0','0',
	' ','1','0.0000','0','0.0000','0')

	SELECT @DBID1 = MAX(billid) FROM PM_Index    --获得插入后的billid

	--插入PM_ClientStock
	INSERT INTO PM_ClientStock (billid,mode,data_id,Dts_Detail_ID) VALUES(@DBID1,0,0,0),(@DBID1,1,0,0)
/*
	--开始插入PM_Detail
	INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
	SELECT @DBID1,P_ID,u_id,0,0,@ZKL1,0,1,0,0,0,'',0
	FROM ##CxTemp WHERE CLASS = @ZKL1 AND type = 1
*/
	FETCH NEXT FROM CURSOR_CX_HYR INTO @ZKL1,@BNUM1,@NOTE1
END
CLOSE CURSOR_CX_HYR
DEALLOCATE CURSOR_CX_HYR

--++++++++++++++++++++++++++++++++++++++
--要插入非会员日的
DECLARE CURSOR_CX_HYR CURSOR FOR 
	SELECT zkl,bnum,note FROM #CxZKTemp WHERE type = 0
OPEN CURSOR_CX_HYR
	FETCH NEXT FROM CURSOR_CX_HYR INTO @ZKL2,@BNUM2,@NOTE2
WHILE @@FETCH_STATUS = 0
BEGIN

	--插入PM_Index
	INSERT INTO PM_Index (billdate,billnumber,billtype,e_id,note,auditman,auditdate,billstate,begindate,
	enddate,begintime,endtime,weeks,days,RetailBill,SaleBill,VipType,p_id,MinPQty,MinMoney,SumSpeP,SumDisP,ChangeOne,
	Dts_BillID,Factory,LimitDays,MaxQty,MaxPCount,VipMaxQty,VipMaxPCount)
	VALUES(
	'2018-01-01 00:00:00.000','CX-180101-'+RIGHT('000'+@BNUM2,6),17,2,@NOTE2,2,CONVERT(VARCHAR(10),GETDATE(),23),'0','2018-01-01 00:00:00.000','2030-01-15 00:00:00.000',
	'1900-01-01 00:00:00.000','1900-01-01 23:59:59.000','1111111','11111011111111101111111110111111','1',0,0,0,'0.0000','0.0000','0','0','0','0',
	' ','1','0.0000','0','0.0000','0')

	SELECT @DBID2 = MAX(billid) FROM PM_Index    --获得插入后的billid

	--插入PM_ClientStock
	INSERT INTO PM_ClientStock (billid,mode,data_id,Dts_Detail_ID) VALUES(@DBID2,0,0,0),(@DBID2,1,0,0)
/*
	--开始插入PM_Detail
	INSERT INTO PM_Detail (billid,p_id,unitid,UnitIndex,discountprice,discount,maxqty,billminqty,billmaxqty,vipDayQty,vipDayTimes,remark,Dts_Detail_ID)
	SELECT @DBID2,P_ID,u_id,0,0,@ZKL2,0,1,0,0,0,'',0
	FROM ##CxTemp WHERE CLASS = @ZKL2 AND type = 0
*/
	FETCH NEXT FROM CURSOR_CX_HYR INTO @ZKL2,@BNUM2,@NOTE2
END
CLOSE CURSOR_CX_HYR
DEALLOCATE CURSOR_CX_HYR
