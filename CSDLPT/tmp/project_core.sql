/*
  CƠ SỞ DỮ LIỆU PHÂN TÁN QUẢN LÝ HÀNG KHÔNG THÔNG MINH - NHÓM 8
  SQL Server 2022. File T-SQL thuần: chạy bằng SSMS hoặc sqlcmd; không cần SQLCMD Mode.
  Lớp D24TXCN05-K. Giảng viên: ThS. Mai Ngọc Lương.
  K24DTCN190 - Đỗ Thị Hằng (trưởng nhóm, tổng hợp báo cáo)
  K24DTCN168 - Phan Phương Anh
  K24DTCN184 - Lê Hoàng Dương
  K24DTCN182 - Trần Tiến Dũng
  K24DTCN246 - Nguyễn Văn Tùng
  K24DTCN221 - Ngô Thế Quang
  K24DTCN223 - Phan Văn Sang

  CÁCH CHẠY
  1. Sửa @Node bên dưới rồi Execute toàn bộ file, cùng một connection/session.
     LAB : một instance, 8 database, có mô phỏng sao chép cục bộ.
     CORE: tại S0; tạo AirCore và AirReporting.
     HN / DN / HCM: tại máy chi nhánh; tạo AirBranch và AirReference.
  2. @SeedData=1 tạo dữ liệu giả lập. @RunDemo=1 chạy ví dụ bán vé ở chế độ LAB.
  3. Chạy lại giữ dữ liệu cũ, không DROP database hoặc đặt lại bộ đếm ghế.
     File chỉ nâng cấp procedure/view; không tự di trú schema đã bị sửa bằng tay.
  4. Khi dùng 4 máy: chạy CORE tại S0, HN/DN/HCM tại ba máy còn lại.
     Sau đó cấu hình Distributor, publication và subscription theo phần 10 cuối file.
     Ứng dụng/API gọi các procedure AirCore tại S0; không ghi Inventory ở Subscriber.

  PHẦN 1 cấu hình và database; 2 danh mục; 3 nghiệp vụ trung tâm;
  4 procedure trung tâm; 5 chi nhánh; 6 báo cáo; 7 dữ liệu mẫu;
  8 ví dụ bán vé; 9 quyền và đối soát; 10 replication/Agent và cách thử nhiều session.

  Thanh toán và hoàn tiền là MÔ PHỎNG: ExternalRef là mã giả lập đã được caller xác minh.
  Chưa tích hợp cổng tiền thật, API, giao diện hay dự phòng tự động.
  Chế độ LAB không chứng minh khả năng chịu lỗi mạng giữa các máy độc lập.
*/
USE master;
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON; SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
DECLARE @Node varchar(4)='CORE';  -- LAB | CORE | HN | DN | HCM
DECLARE @SeedData bit=1;
DECLARE @RunDemo bit=0;         -- 1: chạy mẫu bán vé; chỉ hợp lệ với LAB
IF @Node NOT IN ('LAB','CORE','HN','DN','HCM')
  THROW 51000,N'Node không hợp lệ.',1;
IF @RunDemo=1 AND @Node<>'LAB'
  THROW 51000,N'Demo tự động chỉ chạy với Node LAB.',1;
IF OBJECT_ID('tempdb..#ProjectOptions') IS NOT NULL DROP TABLE #ProjectOptions;
IF OBJECT_ID('tempdb..#Targets') IS NOT NULL DROP TABLE #Targets;
CREATE TABLE #ProjectOptions(Node varchar(4),SeedData bit,RunDemo bit);
INSERT #ProjectOptions VALUES(@Node,@SeedData,@RunDemo);
CREATE TABLE #Targets(Kind varchar(10),DbName sysname PRIMARY KEY,BranchID varchar(3));
IF @Node IN ('LAB','CORE')
  INSERT #Targets VALUES('CORE','AirCore',NULL),('REPORT','AirReporting',NULL);
IF @Node='LAB'
  INSERT #Targets VALUES
    ('BRANCH','AirBranch_HN','HN'),('REFERENCE','AirReference_HN','HN'),
    ('BRANCH','AirBranch_DN','DN'),('REFERENCE','AirReference_DN','DN'),
    ('BRANCH','AirBranch_HCM','HCM'),('REFERENCE','AirReference_HCM','HCM');
IF @Node IN ('HN','DN','HCM')
  INSERT #Targets VALUES('BRANCH','AirBranch',@Node),('REFERENCE','AirReference',@Node);
DECLARE @Db sysname,@Sql nvarchar(max),@New bit;
DECLARE databases_cursor CURSOR LOCAL FAST_FORWARD FOR SELECT DbName FROM #Targets;
OPEN databases_cursor;
FETCH NEXT FROM databases_cursor INTO @Db;
BEGIN TRY
WHILE @@FETCH_STATUS=0
BEGIN
  SET @New=CASE WHEN DB_ID(@Db) IS NULL THEN 1 ELSE 0 END;
  IF @New=1
  BEGIN
    SET @Sql=N'CREATE DATABASE '+QUOTENAME(@Db)+N' COLLATE Latin1_General_100_CI_AS_SC;';
    EXEC sys.sp_executesql @Sql;
  END;
  SET @Sql=N'USE '+QUOTENAME(@Db)+N';
    IF @New=1 EXEC sys.sp_addextendedproperty @name=N''AirLabProject'',@value=N''CSDLPT_NHOM8_V1'';
    IF NOT EXISTS(SELECT 1 FROM sys.extended_properties WHERE class=0 AND name=N''AirLabProject'' AND CONVERT(nvarchar(100),value)=N''CSDLPT_NHOM8_V1'')
      THROW 51000,N''Database đã tồn tại nhưng không thuộc dự án này.'',1;';
  EXEC sys.sp_executesql @Sql,N'@New bit',@New;
  FETCH NEXT FROM databases_cursor INTO @Db;
END;
CLOSE databases_cursor; DEALLOCATE databases_cursor;
END TRY
BEGIN CATCH
  -- SSMS có thể tiếp tục batch sau GO: vô hiệu hóa toàn bộ bước ghi còn lại khi khởi tạo lỗi.
  DELETE #Targets;
  UPDATE #ProjectOptions SET Node='FAIL',SeedData=0,RunDemo=0;
  IF CURSOR_STATUS('local','databases_cursor')>=0 CLOSE databases_cursor;
  IF CURSOR_STATUS('local','databases_cursor')>=-1 DEALLOCATE databases_cursor;
  THROW;
END CATCH;
GO
IF OBJECT_ID('tempdb..#ApplySql') IS NOT NULL DROP PROCEDURE #ApplySql;
GO
CREATE PROCEDURE #ApplySql @Kind varchar(10),@Statement nvarchar(max)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Db sysname,@Branch varchar(3),@Sql nvarchar(max),@Body nvarchar(max);
  DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT DbName,BranchID FROM #Targets WHERE Kind=@Kind;
  OPEN c; FETCH NEXT FROM c INTO @Db,@Branch;
  WHILE @@FETCH_STATUS=0
  BEGIN
    SET @Body=REPLACE(@Statement,N'{{BRANCH}}',COALESCE(@Branch,''));
    SET @Sql=N'USE '+QUOTENAME(@Db)+N'; EXEC sys.sp_executesql @Body;';
    EXEC sys.sp_executesql @Sql,N'@Body nvarchar(max)',@Body;
    FETCH NEXT FROM c INTO @Db,@Branch;
  END;
  CLOSE c; DEALLOCATE c;
END;
GO


-- PHẦN 2 - Danh mục nguồn tại S0
EXEC #ApplySql @Kind='CORE', @Statement=N'SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
IF OBJECT_ID(''dbo.Branch'',''U'') IS NULL
CREATE TABLE dbo.Branch(BranchID varchar(3) PRIMARY KEY CHECK(BranchID IN (''HN'',''DN'',''HCM'')),
 BranchName nvarchar(100) NOT NULL, City nvarchar(100) NOT NULL);
IF OBJECT_ID(''dbo.Airport'',''U'') IS NULL
CREATE TABLE dbo.Airport(AirportCode varchar(3) PRIMARY KEY,
 AirportName nvarchar(100) NOT NULL,City nvarchar(100) NOT NULL);
IF OBJECT_ID(''dbo.Route'',''U'') IS NULL
CREATE TABLE dbo.Route(RouteID varchar(20) PRIMARY KEY,
 OriginCode varchar(3) NOT NULL REFERENCES dbo.Airport(AirportCode),
 DestCode varchar(3) NOT NULL REFERENCES dbo.Airport(AirportCode),
 CHECK(OriginCode<>DestCode),UNIQUE(OriginCode,DestCode));
IF OBJECT_ID(''dbo.Aircraft'',''U'') IS NULL
CREATE TABLE dbo.Aircraft(AircraftID varchar(20) PRIMARY KEY,
 Registration varchar(30) NOT NULL UNIQUE, TotalSeats int NOT NULL CHECK(TotalSeats>0));
IF OBJECT_ID(''dbo.Flight'',''U'') IS NULL
CREATE TABLE dbo.Flight(FlightID varchar(20) PRIMARY KEY,FlightNo varchar(20) NOT NULL,
 RouteID varchar(20) NOT NULL REFERENCES dbo.Route(RouteID),
 AircraftID varchar(20) NOT NULL REFERENCES dbo.Aircraft(AircraftID),
 DepartureUtc datetime2(3) NOT NULL,ArrivalUtc datetime2(3) NOT NULL,
 Status varchar(10) NOT NULL CHECK(Status IN (''OPEN'',''CLOSED'',''CANCELLED'')),
 UpdatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME(),CHECK(ArrivalUtc>DepartureUtc));
IF OBJECT_ID(''dbo.Fare'',''U'') IS NULL
CREATE TABLE dbo.Fare(FlightID varchar(20) NOT NULL REFERENCES dbo.Flight(FlightID),
 FareClass varchar(3) NOT NULL CHECK(FareClass IN (''ECO'',''BUS'')),
 Price decimal(18,2) NOT NULL CHECK(Price>0),Currency char(3) NOT NULL DEFAULT ''VND'' CHECK(Currency=''VND''),
 PRIMARY KEY(FlightID,FareClass));
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(''dbo.Flight'') AND name=''IX_Flight_Route_Departure'')
CREATE INDEX IX_Flight_Route_Departure ON dbo.Flight(RouteID,DepartureUtc) INCLUDE(FlightNo,Status);';
GO


-- Danh mục bản sao tại chi nhánh; ứng dụng chỉ đọc
EXEC #ApplySql @Kind='REFERENCE', @Statement=N'SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
IF OBJECT_ID(''dbo.Branch'',''U'') IS NULL
CREATE TABLE dbo.Branch(BranchID varchar(3) PRIMARY KEY CHECK(BranchID IN (''HN'',''DN'',''HCM'')),
 BranchName nvarchar(100) NOT NULL, City nvarchar(100) NOT NULL);
IF OBJECT_ID(''dbo.Airport'',''U'') IS NULL
CREATE TABLE dbo.Airport(AirportCode varchar(3) PRIMARY KEY,
 AirportName nvarchar(100) NOT NULL,City nvarchar(100) NOT NULL);
IF OBJECT_ID(''dbo.Route'',''U'') IS NULL
CREATE TABLE dbo.Route(RouteID varchar(20) PRIMARY KEY,
 OriginCode varchar(3) NOT NULL REFERENCES dbo.Airport(AirportCode),
 DestCode varchar(3) NOT NULL REFERENCES dbo.Airport(AirportCode),
 CHECK(OriginCode<>DestCode),UNIQUE(OriginCode,DestCode));
IF OBJECT_ID(''dbo.Aircraft'',''U'') IS NULL
CREATE TABLE dbo.Aircraft(AircraftID varchar(20) PRIMARY KEY,
 Registration varchar(30) NOT NULL UNIQUE, TotalSeats int NOT NULL CHECK(TotalSeats>0));
IF OBJECT_ID(''dbo.Flight'',''U'') IS NULL
CREATE TABLE dbo.Flight(FlightID varchar(20) PRIMARY KEY,FlightNo varchar(20) NOT NULL,
 RouteID varchar(20) NOT NULL REFERENCES dbo.Route(RouteID),
 AircraftID varchar(20) NOT NULL REFERENCES dbo.Aircraft(AircraftID),
 DepartureUtc datetime2(3) NOT NULL,ArrivalUtc datetime2(3) NOT NULL,
 Status varchar(10) NOT NULL CHECK(Status IN (''OPEN'',''CLOSED'',''CANCELLED'')),
 UpdatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME(),CHECK(ArrivalUtc>DepartureUtc));
IF OBJECT_ID(''dbo.Fare'',''U'') IS NULL
CREATE TABLE dbo.Fare(FlightID varchar(20) NOT NULL REFERENCES dbo.Flight(FlightID),
 FareClass varchar(3) NOT NULL CHECK(FareClass IN (''ECO'',''BUS'')),
 Price decimal(18,2) NOT NULL CHECK(Price>0),Currency char(3) NOT NULL DEFAULT ''VND'' CHECK(Currency=''VND''),
 PRIMARY KEY(FlightID,FareClass));
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(''dbo.Flight'') AND name=''IX_Flight_Route_Departure'')
CREATE INDEX IX_Flight_Route_Departure ON dbo.Flight(RouteID,DepartureUtc) INCLUDE(FlightNo,Status);';
GO


-- Mốc sao chép cho mô hình LAB; replication thật dùng tracer token
EXEC #ApplySql @Kind='REFERENCE', @Statement=N'IF OBJECT_ID(''dbo.SyncWatermark'',''U'') IS NULL
CREATE TABLE dbo.SyncWatermark(SourceName sysname PRIMARY KEY,LastCopiedAt datetime2(3) NOT NULL);';
GO


-- PHẦN 3 - Giữ chỗ, vé, thanh toán, hoàn và nhật ký tại S0
EXEC #ApplySql @Kind='CORE', @Statement=N'IF OBJECT_ID(''dbo.Inventory'',''U'') IS NULL
CREATE TABLE dbo.Inventory(FlightID varchar(20) NOT NULL,FareClass varchar(3) NOT NULL,
 Capacity int NOT NULL,Held int NOT NULL DEFAULT 0,Sold int NOT NULL DEFAULT 0,
 UpdatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME(),Version rowversion,
 PRIMARY KEY(FlightID,FareClass),
 FOREIGN KEY(FlightID,FareClass) REFERENCES dbo.Fare(FlightID,FareClass),
 CHECK(Capacity>0 AND Held>=0 AND Sold>=0 AND Held+Sold<=Capacity));
IF OBJECT_ID(''dbo.SeatHold'',''U'') IS NULL
CREATE TABLE dbo.SeatHold(HoldID uniqueidentifier PRIMARY KEY,
 RequestID uniqueidentifier NOT NULL UNIQUE,OrderID uniqueidentifier NOT NULL,
 BranchID varchar(3) NOT NULL REFERENCES dbo.Branch(BranchID),
 FlightID varchar(20) NOT NULL,FareClass varchar(3) NOT NULL,
 Quantity int NOT NULL CHECK(Quantity>0),UnitPrice decimal(18,2) NOT NULL CHECK(UnitPrice>0),
 Status varchar(10) NOT NULL CHECK(Status IN (''ACTIVE'',''CONFIRMED'',''EXPIRED'',''CANCELLED'')),
 CreatedAt datetime2(3) NOT NULL,ExpiresAt datetime2(3) NOT NULL,CHECK(ExpiresAt>CreatedAt),
 FOREIGN KEY(FlightID,FareClass) REFERENCES dbo.Inventory(FlightID,FareClass));
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(''dbo.SeatHold'') AND name=''UX_SeatHold_ActiveOrder'')
CREATE UNIQUE INDEX UX_SeatHold_ActiveOrder ON dbo.SeatHold(OrderID) WHERE Status=''ACTIVE'';
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(''dbo.SeatHold'') AND name=''IX_SeatHold_Expiry'')
CREATE INDEX IX_SeatHold_Expiry ON dbo.SeatHold(Status,ExpiresAt) INCLUDE(FlightID,FareClass,Quantity);
IF OBJECT_ID(''dbo.Ticket'',''U'') IS NULL
CREATE TABLE dbo.Ticket(TicketID uniqueidentifier PRIMARY KEY,
 HoldID uniqueidentifier NOT NULL REFERENCES dbo.SeatHold(HoldID),ItemNo int NOT NULL CHECK(ItemNo>0),
 Status varchar(10) NOT NULL CHECK(Status IN (''ISSUED'',''REFUNDED'')),
 IssuedAt datetime2(3) NOT NULL,UNIQUE(HoldID,ItemNo));
IF OBJECT_ID(''dbo.Payment'',''U'') IS NULL
CREATE TABLE dbo.Payment(PaymentID uniqueidentifier PRIMARY KEY,
 HoldID uniqueidentifier NOT NULL UNIQUE REFERENCES dbo.SeatHold(HoldID),
 ExternalRef varchar(100) COLLATE Latin1_General_100_BIN2 NOT NULL UNIQUE CHECK(LEN(ExternalRef)>0),
 Amount decimal(18,2) NOT NULL CHECK(Amount>0),Status varchar(10) NOT NULL CHECK(Status=''SUCCESS''),
 PaidAt datetime2(3) NOT NULL);
IF OBJECT_ID(''dbo.Refund'',''U'') IS NULL
CREATE TABLE dbo.Refund(RefundID uniqueidentifier PRIMARY KEY,
 TicketID uniqueidentifier NOT NULL UNIQUE REFERENCES dbo.Ticket(TicketID),
 ExternalRef varchar(100) COLLATE Latin1_General_100_BIN2 NOT NULL UNIQUE CHECK(LEN(ExternalRef)>0),
 Amount decimal(18,2) NOT NULL CHECK(Amount>0),Status varchar(10) NOT NULL CHECK(Status=''SUCCESS''),
 RefundedAt datetime2(3) NOT NULL);
IF OBJECT_ID(''dbo.AuditEvent'',''U'') IS NULL
CREATE TABLE dbo.AuditEvent(EventID bigint IDENTITY PRIMARY KEY,EventType varchar(30) NOT NULL,
 EntityID uniqueidentifier NOT NULL,BranchID varchar(3) NULL,
 Actor nvarchar(128) NOT NULL,Message nvarchar(300) NOT NULL,CreatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME());';
GO


-- PHẦN 4.1 - Giữ chỗ: UPDATE có điều kiện, RequestID và OrderID khóa riêng
EXEC #ApplySql @Kind='CORE', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_CreateHold
 @RequestID uniqueidentifier,@OrderID uniqueidentifier,@BranchID varchar(3),
 @FlightID varchar(20),@FareClass varchar(3),@Quantity int,
 @HoldID uniqueidentifier OUTPUT,@HoldMinutes int=10
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51001,N''Gọi procedure ngoài transaction của caller.'',1;
 IF @RequestID IS NULL OR @OrderID IS NULL OR @BranchID IS NULL OR @FlightID IS NULL OR @FareClass IS NULL
  OR @Quantity IS NULL OR @Quantity NOT BETWEEN 1 AND 500 OR @HoldMinutes IS NULL OR @HoldMinutes NOT BETWEEN 1 AND 10
  THROW 51002,N''Tham số giữ chỗ không hợp lệ.'',1;
 SET @HoldID=NULL;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Lock int,@Resource nvarchar(255)=N''hold-request:''+CONVERT(nvarchar(36),@RequestID);
  EXEC @Lock=sys.sp_getapplock @Resource=@Resource,@LockMode=''Exclusive'',@LockOwner=''Transaction'',@LockTimeout=5000;
  IF @Lock<0 THROW 51003,N''Không lấy được khóa mã yêu cầu.'',1;
  SELECT @HoldID=HoldID FROM dbo.SeatHold WHERE RequestID=@RequestID;
  IF @HoldID IS NOT NULL
  BEGIN
   IF NOT EXISTS(SELECT 1 FROM dbo.SeatHold WHERE HoldID=@HoldID AND OrderID=@OrderID
     AND BranchID=@BranchID AND FlightID=@FlightID AND FareClass=@FareClass AND Quantity=@Quantity)
    THROW 51004,N''RequestID đã được dùng với nội dung khác.'',1;
   COMMIT; RETURN; -- Trả cùng HoldID; không tự gia hạn thời hạn cũ.
  END;
  SET @Resource=N''hold-order:''+CONVERT(nvarchar(36),@OrderID);
  EXEC @Lock=sys.sp_getapplock @Resource=@Resource,@LockMode=''Exclusive'',@LockOwner=''Transaction'',@LockTimeout=5000;
  IF @Lock<0 THROW 51003,N''Không lấy được khóa đơn.'',1;
  IF NOT EXISTS(SELECT 1 FROM dbo.Branch WHERE BranchID=@BranchID) THROW 51005,N''Chi nhánh không tồn tại.'',1;
  IF EXISTS(SELECT 1 FROM dbo.SeatHold WITH(UPDLOCK,HOLDLOCK) WHERE OrderID=@OrderID AND Status IN (''ACTIVE'',''CONFIRMED''))
    THROW 51006,N''Đơn đã có giữ chỗ đang hoạt động hoặc đã phát hành.'',1;
  DECLARE @Now datetime2(3)=SYSUTCDATETIME(),@Price decimal(18,2);
  IF NOT EXISTS(SELECT 1 FROM dbo.Flight WITH(HOLDLOCK) WHERE FlightID=@FlightID AND Status=''OPEN'' AND DepartureUtc>@Now)
    THROW 51007,N''Chuyến bay không mở bán hoặc đã khởi hành.'',1;
  SELECT @Price=Price FROM dbo.Fare WITH(HOLDLOCK) WHERE FlightID=@FlightID AND FareClass=@FareClass;
  IF @Price IS NULL THROW 51008,N''Không có giá cho hạng được yêu cầu.'',1;
  UPDATE dbo.Inventory SET Held=Held+@Quantity,UpdatedAt=@Now
  WHERE FlightID=@FlightID AND FareClass=@FareClass AND Capacity-Held-Sold>=@Quantity;
  IF @@ROWCOUNT<>1 THROW 51009,N''Không đủ ghế để giữ chỗ.'',1;
  SET @HoldID=NEWID();
  INSERT dbo.SeatHold(HoldID,RequestID,OrderID,BranchID,FlightID,FareClass,Quantity,UnitPrice,Status,CreatedAt,ExpiresAt)
  VALUES(@HoldID,@RequestID,@OrderID,@BranchID,@FlightID,@FareClass,@Quantity,@Price,''ACTIVE'',@Now,DATEADD(minute,@HoldMinutes,@Now));
  INSERT dbo.AuditEvent(EventType,EntityID,BranchID,Actor,Message)
  VALUES(''CREATE_HOLD'',@HoldID,@BranchID,ORIGINAL_LOGIN(),N''Tạo giữ chỗ thành công.'');
  COMMIT;
 END TRY
 BEGIN CATCH
  IF XACT_STATE()<>0 ROLLBACK;
  SET @HoldID=NULL; THROW;
 END CATCH;
END;';
GO


-- Tra lại kết quả sau timeout bằng chính RequestID cũ
EXEC #ApplySql @Kind='CORE', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_GetHoldByRequest @RequestID uniqueidentifier,@BranchID varchar(3)
AS
BEGIN
 SET NOCOUNT ON;
 SELECT h.*,p.PaymentID,p.ExternalRef,p.Amount,p.PaidAt
 FROM dbo.SeatHold h LEFT JOIN dbo.Payment p ON p.HoldID=h.HoldID
 WHERE h.RequestID=@RequestID AND h.BranchID=@BranchID;
 SELECT t.TicketID,t.HoldID,t.ItemNo,t.Status,t.IssuedAt
 FROM dbo.Ticket t JOIN dbo.SeatHold h ON h.HoldID=t.HoldID
 WHERE h.RequestID=@RequestID AND h.BranchID=@BranchID ORDER BY t.ItemNo;
END;';
GO


-- PHẦN 4.2 - Xác nhận tiền đã kiểm chứng và phát hành q vé trong một transaction
EXEC #ApplySql @Kind='CORE', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_ConfirmHold
 @HoldID uniqueidentifier,@BranchID varchar(3),@ExternalRef varchar(100),
 @Amount decimal(18,2),@PaymentID uniqueidentifier OUTPUT
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51001,N''Gọi procedure ngoài transaction của caller.'',1;
 SET @ExternalRef=LTRIM(RTRIM(@ExternalRef));
 IF @HoldID IS NULL OR @BranchID IS NULL OR @ExternalRef IS NULL OR LEN(@ExternalRef)=0 OR @Amount IS NULL OR @Amount<=0
  THROW 51010,N''Tham số thanh toán không hợp lệ.'',1;
 SET @PaymentID=NULL;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Lock int,@Resource nvarchar(255)=N''payment-ref:''+@ExternalRef;
  EXEC @Lock=sys.sp_getapplock @Resource=@Resource,@LockMode=''Exclusive'',@LockOwner=''Transaction'',@LockTimeout=5000;
  IF @Lock<0 THROW 51003,N''Không lấy được khóa thanh toán.'',1;
  DECLARE @Status varchar(10),@Expiry datetime2(3),@Flight varchar(20),@Class varchar(3),@Q int,@Price decimal(18,2);
  SELECT @Status=Status,@Expiry=ExpiresAt,@Flight=FlightID,@Class=FareClass,@Q=Quantity,@Price=UnitPrice
  FROM dbo.SeatHold WITH(UPDLOCK,HOLDLOCK) WHERE HoldID=@HoldID AND BranchID=@BranchID;
  IF @Status IS NULL THROW 51011,N''Giữ chỗ không tồn tại hoặc sai chi nhánh.'',1;
  SELECT @PaymentID=PaymentID FROM dbo.Payment WHERE ExternalRef=@ExternalRef;
  IF @PaymentID IS NOT NULL
  BEGIN
   IF NOT EXISTS(SELECT 1 FROM dbo.Payment WHERE PaymentID=@PaymentID AND HoldID=@HoldID AND Amount=@Amount)
    THROW 51012,N''Mã thanh toán đã được dùng với nội dung khác.'',1;
   COMMIT; RETURN;
  END;
  IF EXISTS(SELECT 1 FROM dbo.Payment WHERE HoldID=@HoldID)
    THROW 51013,N''Giữ chỗ đã được thanh toán bằng mã giao dịch khác.'',1;
  DECLARE @Now datetime2(3)=SYSUTCDATETIME();
  IF @Status<>''ACTIVE'' OR @Expiry<=@Now THROW 51014,N''Giữ chỗ không còn hiệu lực; phải đối soát tiền đã nhận.'',1;
  IF NOT EXISTS(SELECT 1 FROM dbo.Flight WITH(HOLDLOCK) WHERE FlightID=@Flight AND Status=''OPEN'' AND DepartureUtc>@Now)
    THROW 51007,N''Chuyến bay không thể phát hành thêm vé.'',1;
  IF @Amount<>CONVERT(decimal(18,2),@Q*@Price) THROW 51015,N''Số tiền không khớp giá đã chốt.'',1;
  UPDATE dbo.Inventory SET Held=Held-@Q,Sold=Sold+@Q,UpdatedAt=@Now
  WHERE FlightID=@Flight AND FareClass=@Class AND Held>=@Q;
  IF @@ROWCOUNT<>1 THROW 51016,N''Kho ghế sai lệch; cần đối soát.'',1;
  UPDATE dbo.SeatHold SET Status=''CONFIRMED'' WHERE HoldID=@HoldID;
  SET @PaymentID=NEWID();
  INSERT dbo.Payment VALUES(@PaymentID,@HoldID,@ExternalRef,@Amount,''SUCCESS'',@Now);
  DECLARE @Item int=1;
  WHILE @Item<=@Q
  BEGIN
   INSERT dbo.Ticket VALUES(NEWID(),@HoldID,@Item,''ISSUED'',@Now);
   SET @Item+=1;
  END;
  INSERT dbo.AuditEvent(EventType,EntityID,BranchID,Actor,Message)
  VALUES(''CONFIRM_HOLD'',@HoldID,@BranchID,ORIGINAL_LOGIN(),N''Xác nhận thanh toán mô phỏng và phát hành vé.'');
  COMMIT;
 END TRY
 BEGIN CATCH
  IF XACT_STATE()<>0 ROLLBACK;
  SET @PaymentID=NULL; THROW;
 END CATCH;
END;';
GO


-- PHẦN 4.3 - Hủy/hết hạn khóa SeatHold trước Inventory, cùng thứ tự với xác nhận
EXEC #ApplySql @Kind='CORE', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_ReleaseHold
 @HoldID uniqueidentifier,@BranchID varchar(3),@TargetStatus varchar(10),@Changed bit OUTPUT
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON; SET @Changed=0;
 IF @@TRANCOUNT<>0 THROW 51001,N''Gọi procedure ngoài transaction của caller.'',1;
 IF @HoldID IS NULL OR @BranchID IS NULL OR @TargetStatus IS NULL OR @TargetStatus NOT IN (''EXPIRED'',''CANCELLED'')
  THROW 51020,N''Tham số giải phóng giữ chỗ không hợp lệ.'',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Status varchar(10),@Expiry datetime2(3),@Flight varchar(20),@Class varchar(3),@Q int;
  SELECT @Status=Status,@Expiry=ExpiresAt,@Flight=FlightID,@Class=FareClass,@Q=Quantity
  FROM dbo.SeatHold WITH(UPDLOCK,HOLDLOCK) WHERE HoldID=@HoldID AND BranchID=@BranchID;
  IF @Status IS NULL THROW 51011,N''Giữ chỗ không tồn tại hoặc sai chi nhánh.'',1;
  IF @Status<>''ACTIVE''
  BEGIN
   IF @TargetStatus=''CANCELLED'' AND @Status=''CONFIRMED'' THROW 51021,N''Vé đã phát hành; dùng quy trình hoàn vé.'',1;
   COMMIT; RETURN;
  END;
  DECLARE @Now datetime2(3)=SYSUTCDATETIME();
  IF @TargetStatus=''EXPIRED'' AND @Expiry>@Now BEGIN COMMIT; RETURN; END;
  UPDATE dbo.Inventory SET Held=Held-@Q,UpdatedAt=@Now
  WHERE FlightID=@Flight AND FareClass=@Class AND Held>=@Q;
  IF @@ROWCOUNT<>1 THROW 51016,N''Kho ghế sai lệch; cần đối soát.'',1;
  UPDATE dbo.SeatHold SET Status=@TargetStatus WHERE HoldID=@HoldID;
  INSERT dbo.AuditEvent(EventType,EntityID,BranchID,Actor,Message)
  VALUES(@TargetStatus,@HoldID,@BranchID,ORIGINAL_LOGIN(),N''Giải phóng ghế đang giữ.'');
  COMMIT; SET @Changed=1;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;';
GO


-- API hủy giữ chưa phát hành
EXEC #ApplySql @Kind='CORE', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_CancelHold @HoldID uniqueidentifier,@BranchID varchar(3)
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @Changed bit;
 EXEC dbo.usp_ReleaseHold @HoldID,@BranchID,''CANCELLED'',@Changed OUTPUT;
END;';
GO


-- Job hoặc caller chạy định kỳ; từng giữ được kiểm tra lại trong transaction ngắn
EXEC #ApplySql @Kind='CORE', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_ExpireHolds @BatchSize int=100
AS
BEGIN
 SET NOCOUNT ON;
 IF @BatchSize IS NULL OR @BatchSize NOT BETWEEN 1 AND 1000 THROW 51022,N''BatchSize không hợp lệ.'',1;
 DECLARE @Hold uniqueidentifier,@Branch varchar(3),@Changed bit,@Count int=0;
 DECLARE c CURSOR LOCAL STATIC READ_ONLY FOR
 SELECT TOP(@BatchSize) HoldID,BranchID FROM dbo.SeatHold
 WHERE Status=''ACTIVE'' AND ExpiresAt<=SYSUTCDATETIME() ORDER BY ExpiresAt;
 OPEN c; FETCH NEXT FROM c INTO @Hold,@Branch;
 BEGIN TRY
  WHILE @@FETCH_STATUS=0
  BEGIN
   EXEC dbo.usp_ReleaseHold @Hold,@Branch,''EXPIRED'',@Changed OUTPUT;
   SET @Count+=CONVERT(int,@Changed);
   FETCH NEXT FROM c INTO @Hold,@Branch;
  END;
  CLOSE c; DEALLOCATE c;
 END TRY
 BEGIN CATCH CLOSE c; DEALLOCATE c; THROW; END CATCH;
 SELECT @Count AS ExpiredHoldCount;
END;';
GO


-- PHẦN 4.4 - Hoàn vé một lần, số tiền lấy từ đơn giá đã chốt
EXEC #ApplySql @Kind='CORE', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_RefundTicket
 @TicketID uniqueidentifier,@BranchID varchar(3),@ExternalRef varchar(100),@RefundID uniqueidentifier OUTPUT
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON; SET @RefundID=NULL;
 IF @@TRANCOUNT<>0 THROW 51001,N''Gọi procedure ngoài transaction của caller.'',1;
 SET @ExternalRef=LTRIM(RTRIM(@ExternalRef));
 IF @TicketID IS NULL OR @BranchID IS NULL OR @ExternalRef IS NULL OR LEN(@ExternalRef)=0
  THROW 51030,N''Tham số hoàn vé không hợp lệ.'',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Lock int,@Resource nvarchar(255)=N''refund-ref:''+@ExternalRef;
  EXEC @Lock=sys.sp_getapplock @Resource=@Resource,@LockMode=''Exclusive'',@LockOwner=''Transaction'',@LockTimeout=5000;
  IF @Lock<0 THROW 51003,N''Không lấy được khóa hoàn tiền.'',1;
  DECLARE @Status varchar(10),@Flight varchar(20),@Class varchar(3),@Price decimal(18,2);
  SELECT @Status=t.Status,@Flight=h.FlightID,@Class=h.FareClass,@Price=h.UnitPrice
  FROM dbo.Ticket t WITH(UPDLOCK,HOLDLOCK) JOIN dbo.SeatHold h ON h.HoldID=t.HoldID
  WHERE t.TicketID=@TicketID AND h.BranchID=@BranchID;
  IF @Status IS NULL THROW 51031,N''Vé không tồn tại hoặc sai chi nhánh.'',1;
  SELECT @RefundID=RefundID FROM dbo.Refund WHERE ExternalRef=@ExternalRef;
  IF @RefundID IS NOT NULL
  BEGIN
   IF NOT EXISTS(SELECT 1 FROM dbo.Refund WHERE RefundID=@RefundID AND TicketID=@TicketID)
    THROW 51032,N''Mã hoàn đã được dùng cho vé khác.'',1;
   COMMIT; RETURN;
  END;
  IF @Status<>''ISSUED'' THROW 51033,N''Vé đã hoàn hoặc không thể hoàn.'',1;
  DECLARE @Now datetime2(3)=SYSUTCDATETIME();
  IF NOT EXISTS(SELECT 1 FROM dbo.Flight WITH(HOLDLOCK) WHERE FlightID=@Flight AND Status=''OPEN'' AND DepartureUtc>@Now)
    THROW 51034,N''Chỉ mô phỏng hoàn trước khởi hành, khi chuyến còn OPEN.'',1;
  UPDATE dbo.Inventory SET Sold=Sold-1,UpdatedAt=@Now
  WHERE FlightID=@Flight AND FareClass=@Class AND Sold>=1;
  IF @@ROWCOUNT<>1 THROW 51016,N''Kho ghế sai lệch; cần đối soát.'',1;
  SET @RefundID=NEWID();
  INSERT dbo.Refund VALUES(@RefundID,@TicketID,@ExternalRef,@Price,''SUCCESS'',@Now);
  UPDATE dbo.Ticket SET Status=''REFUNDED'' WHERE TicketID=@TicketID;
  INSERT dbo.AuditEvent(EventType,EntityID,BranchID,Actor,Message)
  VALUES(''REFUND_TICKET'',@TicketID,@BranchID,ORIGINAL_LOGIN(),N''Hoàn toàn bộ đơn giá và giải phóng một ghế.'');
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; SET @RefundID=NULL; THROW; END CATCH;
END;';
GO


-- Tra cứu kho ghế nguồn; không dùng bản sao để quyết định cấp ghế
EXEC #ApplySql @Kind='CORE', @Statement=N'CREATE OR ALTER VIEW dbo.vFlightAvailability AS
SELECT f.FlightID,f.FlightNo,r.OriginCode,r.DestCode,f.DepartureUtc,f.ArrivalUtc,f.Status,
 i.FareClass,i.Capacity,i.Held,i.Sold,i.Capacity-i.Held-i.Sold AS Available,fa.Price,fa.Currency
FROM dbo.Flight f JOIN dbo.Route r ON r.RouteID=f.RouteID
JOIN dbo.Inventory i ON i.FlightID=f.FlightID
JOIN dbo.Fare fa ON fa.FlightID=i.FlightID AND fa.FareClass=i.FareClass;';
GO


-- PHẦN 4.5 - Đối soát Held, Sold, số vé và số tiền
EXEC #ApplySql @Kind='CORE', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_CheckInvariants
AS
BEGIN
 SET NOCOUNT ON;
 IF @@TRANCOUNT<>0 THROW 51001,N''Gọi ngoài transaction của caller.'',1;
 -- Snapshot đọc ổn định bằng khóa; chỉ chạy đối soát trong cửa sổ kiểm tra.
 -- READ COMMITTED từng câu có thể thấy hai thời điểm khác nhau khi đang ghi.
 SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
 BEGIN TRY
  BEGIN TRAN;
  SELECT i.FlightID,i.FareClass,i.Held,COALESCE(h.Q,0) AS ActiveQty
  FROM dbo.Inventory i LEFT JOIN
   (SELECT FlightID,FareClass,SUM(Quantity) Q FROM dbo.SeatHold WHERE Status=''ACTIVE'' GROUP BY FlightID,FareClass) h
   ON h.FlightID=i.FlightID AND h.FareClass=i.FareClass WHERE i.Held<>COALESCE(h.Q,0);
  SELECT i.FlightID,i.FareClass,i.Sold,COALESCE(t.Q,0) AS IssuedQty
  FROM dbo.Inventory i LEFT JOIN
   (SELECT h.FlightID,h.FareClass,COUNT(*) Q FROM dbo.Ticket t JOIN dbo.SeatHold h ON h.HoldID=t.HoldID
    WHERE t.Status=''ISSUED'' GROUP BY h.FlightID,h.FareClass) t
   ON t.FlightID=i.FlightID AND t.FareClass=i.FareClass WHERE i.Sold<>COALESCE(t.Q,0);
  SELECT h.HoldID,h.Quantity,COUNT(t.TicketID) AS TicketCount
  FROM dbo.SeatHold h LEFT JOIN dbo.Ticket t ON t.HoldID=h.HoldID
  WHERE h.Status=''CONFIRMED'' GROUP BY h.HoldID,h.Quantity HAVING COUNT(t.TicketID)<>h.Quantity;
  SELECT p.PaymentID,p.Amount,h.Quantity*h.UnitPrice AS ExpectedAmount
  FROM dbo.Payment p JOIN dbo.SeatHold h ON h.HoldID=p.HoldID WHERE p.Amount<>h.Quantity*h.UnitPrice OR h.Status<>''CONFIRMED'';
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
 -- Các result set phải rỗng; vé REFUNDED vẫn được đếm khi so số vé đã phát hành.
END;';
GO


-- PHẦN 5.1 - Mảnh ngang theo chi nhánh và mảnh dẫn xuất SalesItem
EXEC #ApplySql @Kind='BRANCH', @Statement=N'IF OBJECT_ID(''dbo.LocalBranch'',''U'') IS NULL
CREATE TABLE dbo.LocalBranch(BranchID varchar(3) PRIMARY KEY CHECK(BranchID=''{{BRANCH}}''),BranchName nvarchar(100) NOT NULL);
IF OBJECT_ID(''dbo.CustomerProfile'',''U'') IS NULL
CREATE TABLE dbo.CustomerProfile(CustomerID uniqueidentifier PRIMARY KEY,
 BranchID varchar(3) NOT NULL REFERENCES dbo.LocalBranch(BranchID),FullName nvarchar(100) NOT NULL,
 BirthDate date NULL,Phone varchar(30) NULL,Email nvarchar(150) NULL,DocumentNo nvarchar(30) NULL,
 Version rowversion);
IF OBJECT_ID(''dbo.Employee'',''U'') IS NULL
CREATE TABLE dbo.Employee(EmployeeID varchar(20) PRIMARY KEY,
 BranchID varchar(3) NOT NULL REFERENCES dbo.LocalBranch(BranchID),FullName nvarchar(100) NOT NULL,
 Position nvarchar(50) NOT NULL,IsActive bit NOT NULL DEFAULT 1);
IF OBJECT_ID(''dbo.SalesOrder'',''U'') IS NULL
CREATE TABLE dbo.SalesOrder(OrderID uniqueidentifier PRIMARY KEY,
 BranchID varchar(3) NOT NULL REFERENCES dbo.LocalBranch(BranchID) CHECK(BranchID=''{{BRANCH}}''),
 CustomerID uniqueidentifier NOT NULL REFERENCES dbo.CustomerProfile(CustomerID),
 EmployeeID varchar(20) NOT NULL REFERENCES dbo.Employee(EmployeeID),
 FlightID varchar(20) NOT NULL,FareClass varchar(3) NOT NULL CHECK(FareClass IN (''ECO'',''BUS'')),
 Quantity int NOT NULL CHECK(Quantity BETWEEN 1 AND 500),RequestID uniqueidentifier NOT NULL UNIQUE,
 HoldID uniqueidentifier NULL,PaymentID uniqueidentifier NULL,
 Status varchar(20) NOT NULL CHECK(Status IN (''DRAFT'',''HELD'',''ISSUED'',''CANCELLED'',''PENDING_RECONCILE'')),
 CreatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
 ExpiresAt datetime2(3) NULL,LastError nvarchar(300) NULL,LastCheckedAt datetime2(3) NULL);
IF OBJECT_ID(''dbo.SalesItem'',''U'') IS NULL
CREATE TABLE dbo.SalesItem(OrderID uniqueidentifier NOT NULL REFERENCES dbo.SalesOrder(OrderID),
 ItemNo int NOT NULL CHECK(ItemNo>0),PassengerName nvarchar(100) NOT NULL,
 PassengerDocument nvarchar(30) NULL,UnitPrice decimal(18,2) NULL CHECK(UnitPrice>0),
 TicketID uniqueidentifier NULL,PRIMARY KEY(OrderID,ItemNo));
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(''dbo.SalesItem'') AND name=''UX_SalesItem_Ticket'')
CREATE UNIQUE INDEX UX_SalesItem_Ticket ON dbo.SalesItem(TicketID) WHERE TicketID IS NOT NULL;
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(''dbo.SalesOrder'') AND name=''IX_SalesOrder_Branch_Date'')
CREATE INDEX IX_SalesOrder_Branch_Date ON dbo.SalesOrder(BranchID,CreatedAt) INCLUDE(Status,HoldID);
IF OBJECT_ID(''dbo.BranchEvent'',''U'') IS NULL
CREATE TABLE dbo.BranchEvent(EventID bigint IDENTITY PRIMARY KEY,OrderID uniqueidentifier NOT NULL,
 EventType varchar(30) NOT NULL,Actor nvarchar(128) NOT NULL,CreatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME());
IF TYPE_ID(''dbo.PassengerList'') IS NULL
EXEC(N''CREATE TYPE dbo.PassengerList AS TABLE(ItemNo int PRIMARY KEY,PassengerName nvarchar(100) NOT NULL,PassengerDocument nvarchar(30) NULL);'');
IF TYPE_ID(''dbo.TicketList'') IS NULL
EXEC(N''CREATE TYPE dbo.TicketList AS TABLE(ItemNo int PRIMARY KEY,TicketID uniqueidentifier NOT NULL UNIQUE);'');';
GO


-- PHẦN 5.2 - Tạo đơn và q hành khách atomically tại chi nhánh
EXEC #ApplySql @Kind='BRANCH', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_CreateOrder
 @OrderID uniqueidentifier,@RequestID uniqueidentifier,@CustomerID uniqueidentifier,
 @EmployeeID varchar(20),@FlightID varchar(20),@FareClass varchar(3),@Passengers dbo.PassengerList READONLY
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51100,N''Gọi procedure ngoài transaction của caller.'',1;
 DECLARE @Q int=(SELECT COUNT(*) FROM @Passengers),@Branch varchar(3)=(SELECT BranchID FROM dbo.LocalBranch);
 IF @OrderID IS NULL OR @RequestID IS NULL OR @CustomerID IS NULL OR @EmployeeID IS NULL
  OR @FlightID IS NULL OR @FareClass IS NULL OR @FareClass NOT IN (''ECO'',''BUS'') OR @Q NOT BETWEEN 1 AND 500
  OR EXISTS(SELECT 1 FROM @Passengers WHERE ItemNo<=0 OR LEN(LTRIM(RTRIM(PassengerName)))=0)
  OR (SELECT MIN(ItemNo) FROM @Passengers)<>1 OR (SELECT MAX(ItemNo) FROM @Passengers)<>@Q
  THROW 51101,N''Danh sách hành khách hoặc tham số đơn không hợp lệ.'',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Lock int,@Resource nvarchar(255)=N''order:''+CONVERT(nvarchar(36),@OrderID);
  EXEC @Lock=sys.sp_getapplock @Resource=@Resource,@LockMode=''Exclusive'',@LockOwner=''Transaction'',@LockTimeout=5000;
  IF @Lock<0 THROW 51102,N''Không lấy được khóa đơn.'',1;
  IF EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID=@OrderID)
  BEGIN
   IF NOT EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID=@OrderID AND RequestID=@RequestID
    AND CustomerID=@CustomerID AND EmployeeID=@EmployeeID AND FlightID=@FlightID AND FareClass=@FareClass AND Quantity=@Q)
    OR EXISTS(SELECT ItemNo,PassengerName,PassengerDocument FROM @Passengers EXCEPT
       SELECT ItemNo,PassengerName,PassengerDocument FROM dbo.SalesItem WHERE OrderID=@OrderID)
    OR EXISTS(SELECT ItemNo,PassengerName,PassengerDocument FROM dbo.SalesItem WHERE OrderID=@OrderID EXCEPT
       SELECT ItemNo,PassengerName,PassengerDocument FROM @Passengers)
     THROW 51103,N''OrderID đã dùng cho nội dung khác.'',1;
   COMMIT; RETURN;
  END;
  IF NOT EXISTS(SELECT 1 FROM dbo.Employee WHERE EmployeeID=@EmployeeID AND BranchID=@Branch AND IsActive=1)
    THROW 51104,N''Nhân viên không hợp lệ.'',1;
  IF NOT EXISTS(SELECT 1 FROM dbo.CustomerProfile WHERE CustomerID=@CustomerID AND BranchID=@Branch)
    THROW 51105,N''Khách hàng không thuộc chi nhánh.'',1;
  INSERT dbo.SalesOrder(OrderID,BranchID,CustomerID,EmployeeID,FlightID,FareClass,Quantity,RequestID,Status)
  VALUES(@OrderID,@Branch,@CustomerID,@EmployeeID,@FlightID,@FareClass,@Q,@RequestID,''DRAFT'');
  INSERT dbo.SalesItem(OrderID,ItemNo,PassengerName,PassengerDocument)
  SELECT @OrderID,ItemNo,PassengerName,PassengerDocument FROM @Passengers;
  INSERT dbo.BranchEvent(OrderID,EventType,Actor) VALUES(@OrderID,''CREATE_ORDER'',ORIGINAL_LOGIN());
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;';
GO


-- Áp dụng phản hồi ACTIVE đã xác minh từ S0; chỉ caller dịch vụ được gọi
EXEC #ApplySql @Kind='BRANCH', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_ApplyHoldResult
 @OrderID uniqueidentifier,@RequestID uniqueidentifier,@HoldID uniqueidentifier,
 @FlightID varchar(20),@FareClass varchar(3),@Quantity int,@UnitPrice decimal(18,2),@ExpiresAt datetime2(3)
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51100,N''Gọi procedure ngoài transaction của caller.'',1;
 IF @HoldID IS NULL OR @UnitPrice IS NULL OR @UnitPrice<=0 OR @ExpiresAt IS NULL
  THROW 51106,N''Kết quả giữ chỗ không hợp lệ.'',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Status varchar(20),@OldHold uniqueidentifier;
  SELECT @Status=Status,@OldHold=HoldID FROM dbo.SalesOrder WITH(UPDLOCK,HOLDLOCK)
  WHERE OrderID=@OrderID AND RequestID=@RequestID AND FlightID=@FlightID AND FareClass=@FareClass AND Quantity=@Quantity;
  IF @Status IS NULL THROW 51107,N''Kết quả S0 không khớp đơn.'',1;
  IF @OldHold IS NOT NULL AND @OldHold<>@HoldID THROW 51108,N''Đơn đã gắn với HoldID khác.'',1;
  IF @Status IN (''ISSUED'',''CANCELLED'') BEGIN COMMIT; RETURN; END;
  UPDATE dbo.SalesOrder SET HoldID=@HoldID,ExpiresAt=@ExpiresAt,Status=''HELD'',LastError=NULL,LastCheckedAt=SYSUTCDATETIME()
  WHERE OrderID=@OrderID;
  UPDATE dbo.SalesItem SET UnitPrice=@UnitPrice WHERE OrderID=@OrderID;
  INSERT dbo.BranchEvent(OrderID,EventType,Actor) VALUES(@OrderID,''APPLY_HOLD'',ORIGINAL_LOGIN());
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;';
GO


-- Áp dụng danh sách vé chính thức; thử lại không tạo thêm vé
EXEC #ApplySql @Kind='BRANCH', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_ApplyIssuedResult
 @OrderID uniqueidentifier,@HoldID uniqueidentifier,@PaymentID uniqueidentifier,@Tickets dbo.TicketList READONLY
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51100,N''Gọi procedure ngoài transaction của caller.'',1;
 IF @HoldID IS NULL OR @PaymentID IS NULL THROW 51109,N''Kết quả phát hành không hợp lệ.'',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Q int,@Status varchar(20),@OldPayment uniqueidentifier;
  SELECT @Q=Quantity,@Status=Status,@OldPayment=PaymentID FROM dbo.SalesOrder WITH(UPDLOCK,HOLDLOCK)
  WHERE OrderID=@OrderID AND HoldID=@HoldID;
  IF @Q IS NULL THROW 51107,N''Kết quả S0 không khớp đơn.'',1;
  IF @Status=''CANCELLED'' THROW 51110,N''Đơn đã hủy; cần đối soát thay vì tự ghi phát hành.'',1;
  IF (SELECT COUNT(*) FROM @Tickets)<>@Q
   OR EXISTS(SELECT ItemNo FROM @Tickets EXCEPT SELECT ItemNo FROM dbo.SalesItem WHERE OrderID=@OrderID)
   THROW 51111,N''Danh sách vé không khớp danh sách hành khách.'',1;
  IF @Status=''ISSUED''
  BEGIN
   IF @OldPayment<>@PaymentID OR EXISTS(SELECT ItemNo,TicketID FROM @Tickets EXCEPT
       SELECT ItemNo,TicketID FROM dbo.SalesItem WHERE OrderID=@OrderID)
    THROW 51112,N''Đơn đã nhận một kết quả phát hành khác.'',1;
   COMMIT; RETURN;
  END;
  UPDATE i SET TicketID=t.TicketID FROM dbo.SalesItem i JOIN @Tickets t ON t.ItemNo=i.ItemNo WHERE i.OrderID=@OrderID;
  UPDATE dbo.SalesOrder SET Status=''ISSUED'',PaymentID=@PaymentID,LastError=NULL,LastCheckedAt=SYSUTCDATETIME() WHERE OrderID=@OrderID;
  INSERT dbo.BranchEvent(OrderID,EventType,Actor) VALUES(@OrderID,''APPLY_ISSUED'',ORIGINAL_LOGIN());
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;';
GO


-- Timeout là chưa xác định kết quả; không tự đổi thành CANCELLED
EXEC #ApplySql @Kind='BRANCH', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_MarkPendingReconcile @OrderID uniqueidentifier,@Message nvarchar(300)
AS
BEGIN
 SET NOCOUNT ON;
 UPDATE dbo.SalesOrder SET Status=''PENDING_RECONCILE'',LastError=@Message,LastCheckedAt=SYSUTCDATETIME()
 WHERE OrderID=@OrderID AND Status IN (''DRAFT'',''HELD'',''PENDING_RECONCILE'');
END;';
GO


-- Áp dụng kết quả hủy/hết hạn của S0, không chạm bộ đếm cục bộ
EXEC #ApplySql @Kind='BRANCH', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_ApplyCancelledResult @OrderID uniqueidentifier,@HoldID uniqueidentifier
AS
BEGIN
 SET NOCOUNT ON;
 -- Caller chỉ gọi sau khi nguồn trả EXPIRED hoặc CANCELLED đúng HoldID.
 UPDATE dbo.SalesOrder SET Status=''CANCELLED'',LastError=NULL,LastCheckedAt=SYSUTCDATETIME()
 WHERE OrderID=@OrderID AND HoldID=@HoldID AND Status IN (''HELD'',''PENDING_RECONCILE'',''CANCELLED'');
 IF @@ROWCOUNT=0 THROW 51113,N''Đơn không thể áp dụng kết quả hủy này.'',1;
END;';
GO


-- Chiếu thông tin công khai: minh họa phần thuộc tính được phép đọc
EXEC #ApplySql @Kind='BRANCH', @Statement=N'CREATE OR ALTER VIEW dbo.vCustomerPublic AS
SELECT CustomerID,BranchID,FullName,BirthDate FROM dbo.CustomerProfile;';
GO


-- Chiếu thông tin liên hệ: không nhân bản giấy tờ vào kho báo cáo
EXEC #ApplySql @Kind='BRANCH', @Statement=N'CREATE OR ALTER VIEW dbo.vCustomerPrivate AS
SELECT CustomerID,Phone,Email,DocumentNo FROM dbo.CustomerProfile;';
GO


-- PHẦN 6.1 - Bảng nhận ba mảnh, tách schema, không sao chép giấy tờ hành khách
EXEC #ApplySql @Kind='REPORT', @Statement=N'IF SCHEMA_ID(''hn'') IS NULL EXEC(N''CREATE SCHEMA hn AUTHORIZATION dbo'');
IF SCHEMA_ID(''dn'') IS NULL EXEC(N''CREATE SCHEMA dn AUTHORIZATION dbo'');
IF SCHEMA_ID(''hcm'') IS NULL EXEC(N''CREATE SCHEMA hcm AUTHORIZATION dbo'');
IF OBJECT_ID(''dbo.SyncWatermark'',''U'') IS NULL
CREATE TABLE dbo.SyncWatermark(SourceName sysname PRIMARY KEY,LastCopiedAt datetime2(3) NOT NULL);

IF OBJECT_ID(''hn.SalesOrder'',''U'') IS NULL
CREATE TABLE hn.SalesOrder(OrderID uniqueidentifier PRIMARY KEY,BranchID varchar(3) NOT NULL,
 CustomerID uniqueidentifier NOT NULL,EmployeeID varchar(20) NOT NULL,FlightID varchar(20) NOT NULL,
 FareClass varchar(3) NOT NULL,Quantity int NOT NULL,RequestID uniqueidentifier NOT NULL,
 HoldID uniqueidentifier NULL,PaymentID uniqueidentifier NULL,Status varchar(20) NOT NULL,
 CreatedAt datetime2(3) NOT NULL,ExpiresAt datetime2(3) NULL,LastError nvarchar(300) NULL,LastCheckedAt datetime2(3) NULL);
IF OBJECT_ID(''hn.SalesItem'',''U'') IS NULL
CREATE TABLE hn.SalesItem(OrderID uniqueidentifier NOT NULL,ItemNo int NOT NULL,
 UnitPrice decimal(18,2) NULL,TicketID uniqueidentifier NULL,PRIMARY KEY(OrderID,ItemNo));

IF OBJECT_ID(''dn.SalesOrder'',''U'') IS NULL
CREATE TABLE dn.SalesOrder(OrderID uniqueidentifier PRIMARY KEY,BranchID varchar(3) NOT NULL,
 CustomerID uniqueidentifier NOT NULL,EmployeeID varchar(20) NOT NULL,FlightID varchar(20) NOT NULL,
 FareClass varchar(3) NOT NULL,Quantity int NOT NULL,RequestID uniqueidentifier NOT NULL,
 HoldID uniqueidentifier NULL,PaymentID uniqueidentifier NULL,Status varchar(20) NOT NULL,
 CreatedAt datetime2(3) NOT NULL,ExpiresAt datetime2(3) NULL,LastError nvarchar(300) NULL,LastCheckedAt datetime2(3) NULL);
IF OBJECT_ID(''dn.SalesItem'',''U'') IS NULL
CREATE TABLE dn.SalesItem(OrderID uniqueidentifier NOT NULL,ItemNo int NOT NULL,
 UnitPrice decimal(18,2) NULL,TicketID uniqueidentifier NULL,PRIMARY KEY(OrderID,ItemNo));

IF OBJECT_ID(''hcm.SalesOrder'',''U'') IS NULL
CREATE TABLE hcm.SalesOrder(OrderID uniqueidentifier PRIMARY KEY,BranchID varchar(3) NOT NULL,
 CustomerID uniqueidentifier NOT NULL,EmployeeID varchar(20) NOT NULL,FlightID varchar(20) NOT NULL,
 FareClass varchar(3) NOT NULL,Quantity int NOT NULL,RequestID uniqueidentifier NOT NULL,
 HoldID uniqueidentifier NULL,PaymentID uniqueidentifier NULL,Status varchar(20) NOT NULL,
 CreatedAt datetime2(3) NOT NULL,ExpiresAt datetime2(3) NULL,LastError nvarchar(300) NULL,LastCheckedAt datetime2(3) NULL);
IF OBJECT_ID(''hcm.SalesItem'',''U'') IS NULL
CREATE TABLE hcm.SalesItem(OrderID uniqueidentifier NOT NULL,ItemNo int NOT NULL,
 UnitPrice decimal(18,2) NULL,TicketID uniqueidentifier NULL,PRIMARY KEY(OrderID,ItemNo));';
GO


-- Tái thiết quan hệ toàn cục bằng UNION ALL, không hợp thêm bản nguồn
EXEC #ApplySql @Kind='REPORT', @Statement=N'CREATE OR ALTER VIEW dbo.vSalesOrderGlobal AS
SELECT * FROM hn.SalesOrder UNION ALL SELECT * FROM dn.SalesOrder UNION ALL SELECT * FROM hcm.SalesOrder;';
GO


-- Tái thiết mảnh ngang dẫn xuất
EXEC #ApplySql @Kind='REPORT', @Statement=N'CREATE OR ALTER VIEW dbo.vSalesItemGlobal AS
SELECT * FROM hn.SalesItem UNION ALL SELECT * FROM dn.SalesItem UNION ALL SELECT * FROM hcm.SalesItem;';
GO


-- PHẦN 6.2 - Báo cáo thu và hoàn chính thức từ S0, không coi đơn nháp là doanh thu
EXEC #ApplySql @Kind='CORE', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_RevenueByBranch @FromUtc datetime2(3),@ToUtc datetime2(3)
AS
BEGIN
 SET NOCOUNT ON;
 IF @FromUtc IS NULL OR @ToUtc IS NULL OR @FromUtc>=@ToUtc THROW 51040,N''Khoảng thời gian không hợp lệ.'',1;
 ;WITH p AS(SELECT h.BranchID,SUM(p.Amount) GrossAmount FROM dbo.Payment p JOIN dbo.SeatHold h ON h.HoldID=p.HoldID
  WHERE p.PaidAt>=@FromUtc AND p.PaidAt<@ToUtc GROUP BY h.BranchID),
 r AS(SELECT h.BranchID,SUM(r.Amount) RefundAmount FROM dbo.Refund r JOIN dbo.Ticket t ON t.TicketID=r.TicketID
  JOIN dbo.SeatHold h ON h.HoldID=t.HoldID WHERE r.RefundedAt>=@FromUtc AND r.RefundedAt<@ToUtc GROUP BY h.BranchID)
 SELECT b.BranchID,b.BranchName,COALESCE(p.GrossAmount,0) GrossAmount,COALESCE(r.RefundAmount,0) RefundAmount,
  COALESCE(p.GrossAmount,0)-COALESCE(r.RefundAmount,0) NetCashMovement
 FROM dbo.Branch b LEFT JOIN p ON p.BranchID=b.BranchID LEFT JOIN r ON r.BranchID=b.BranchID;
 -- NetCashMovement là thu trừ hoàn theo thời điểm dòng tiền; có thể âm ở kỳ chỉ có hoàn.
END;';
GO


-- Cảnh báo lấp đầy theo quy tắc; không phải mô hình AI
EXEC #ApplySql @Kind='CORE', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_HighLoadFlights @Threshold decimal(5,2)=80
AS
BEGIN
 SET NOCOUNT ON;
 IF @Threshold IS NULL OR @Threshold NOT BETWEEN 0 AND 100 THROW 51041,N''Ngưỡng không hợp lệ.'',1;
 SELECT *,CAST(100.0*Sold/Capacity AS decimal(5,2)) SoldPct FROM dbo.vFlightAvailability
 WHERE Status=''OPEN'' AND DepartureUtc>SYSUTCDATETIME() AND 100.0*Sold/Capacity>=@Threshold;
END;';
GO


-- Chỉ LAB: snapshot sao chép thủ công trên một instance, không phải replication liên máy
EXEC #ApplySql @Kind='CORE', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_RefreshLabCopies
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51001,N''Gọi ngoài transaction của caller.'',1;
 SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

 IF DB_ID(''AirReference_HN'') IS NULL OR DB_ID(''AirBranch_HN'') IS NULL OR DB_ID(''AirReporting'') IS NULL
  THROW 51042,N''Thủ tục sao chép LAB chỉ chạy trên một instance có đủ tám database.'',1;
 IF NOT EXISTS(SELECT 1 FROM [AirReference_HN].sys.extended_properties WHERE class=0 AND name=''AirLabProject'' AND CONVERT(nvarchar(100),value)=''CSDLPT_NHOM8_V1'')
  THROW 51042,N''Database bản sao LAB không thuộc dự án.'',1;
 BEGIN TRY
  BEGIN TRAN;
  DELETE [AirReference_HN].dbo.[Fare];
  DELETE [AirReference_HN].dbo.[Flight];
  DELETE [AirReference_HN].dbo.[Route];
  DELETE [AirReference_HN].dbo.[Aircraft];
  DELETE [AirReference_HN].dbo.[Airport];
  DELETE [AirReference_HN].dbo.[Branch];
  INSERT [AirReference_HN].dbo.[Branch] SELECT * FROM dbo.[Branch];
  INSERT [AirReference_HN].dbo.[Airport] SELECT * FROM dbo.[Airport];
  INSERT [AirReference_HN].dbo.[Aircraft] SELECT * FROM dbo.[Aircraft];
  INSERT [AirReference_HN].dbo.[Route] SELECT * FROM dbo.[Route];
  INSERT [AirReference_HN].dbo.[Flight] SELECT * FROM dbo.[Flight];
  INSERT [AirReference_HN].dbo.[Fare] SELECT * FROM dbo.[Fare];

  DELETE AirReporting.[hn].SalesItem;
  DELETE AirReporting.[hn].SalesOrder;
  INSERT AirReporting.[hn].SalesOrder SELECT * FROM [AirBranch_HN].dbo.SalesOrder;
  INSERT AirReporting.[hn].SalesItem(OrderID,ItemNo,UnitPrice,TicketID)
    SELECT OrderID,ItemNo,UnitPrice,TicketID FROM [AirBranch_HN].dbo.SalesItem;
  UPDATE [AirReference_HN].dbo.SyncWatermark SET LastCopiedAt=SYSUTCDATETIME() WHERE SourceName=''AirCore'';
  IF @@ROWCOUNT=0 INSERT [AirReference_HN].dbo.SyncWatermark VALUES(''AirCore'',SYSUTCDATETIME());
  UPDATE AirReporting.dbo.SyncWatermark SET LastCopiedAt=SYSUTCDATETIME() WHERE SourceName=''HN'';
  IF @@ROWCOUNT=0 INSERT AirReporting.dbo.SyncWatermark VALUES(''HN'',SYSUTCDATETIME());
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;

 IF DB_ID(''AirReference_DN'') IS NULL OR DB_ID(''AirBranch_DN'') IS NULL OR DB_ID(''AirReporting'') IS NULL
  THROW 51042,N''Thủ tục sao chép LAB chỉ chạy trên một instance có đủ tám database.'',1;
 IF NOT EXISTS(SELECT 1 FROM [AirReference_DN].sys.extended_properties WHERE class=0 AND name=''AirLabProject'' AND CONVERT(nvarchar(100),value)=''CSDLPT_NHOM8_V1'')
  THROW 51042,N''Database bản sao LAB không thuộc dự án.'',1;
 BEGIN TRY
  BEGIN TRAN;
  DELETE [AirReference_DN].dbo.[Fare];
  DELETE [AirReference_DN].dbo.[Flight];
  DELETE [AirReference_DN].dbo.[Route];
  DELETE [AirReference_DN].dbo.[Aircraft];
  DELETE [AirReference_DN].dbo.[Airport];
  DELETE [AirReference_DN].dbo.[Branch];
  INSERT [AirReference_DN].dbo.[Branch] SELECT * FROM dbo.[Branch];
  INSERT [AirReference_DN].dbo.[Airport] SELECT * FROM dbo.[Airport];
  INSERT [AirReference_DN].dbo.[Aircraft] SELECT * FROM dbo.[Aircraft];
  INSERT [AirReference_DN].dbo.[Route] SELECT * FROM dbo.[Route];
  INSERT [AirReference_DN].dbo.[Flight] SELECT * FROM dbo.[Flight];
  INSERT [AirReference_DN].dbo.[Fare] SELECT * FROM dbo.[Fare];

  DELETE AirReporting.[dn].SalesItem;
  DELETE AirReporting.[dn].SalesOrder;
  INSERT AirReporting.[dn].SalesOrder SELECT * FROM [AirBranch_DN].dbo.SalesOrder;
  INSERT AirReporting.[dn].SalesItem(OrderID,ItemNo,UnitPrice,TicketID)
    SELECT OrderID,ItemNo,UnitPrice,TicketID FROM [AirBranch_DN].dbo.SalesItem;
  UPDATE [AirReference_DN].dbo.SyncWatermark SET LastCopiedAt=SYSUTCDATETIME() WHERE SourceName=''AirCore'';
  IF @@ROWCOUNT=0 INSERT [AirReference_DN].dbo.SyncWatermark VALUES(''AirCore'',SYSUTCDATETIME());
  UPDATE AirReporting.dbo.SyncWatermark SET LastCopiedAt=SYSUTCDATETIME() WHERE SourceName=''DN'';
  IF @@ROWCOUNT=0 INSERT AirReporting.dbo.SyncWatermark VALUES(''DN'',SYSUTCDATETIME());
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;

 IF DB_ID(''AirReference_HCM'') IS NULL OR DB_ID(''AirBranch_HCM'') IS NULL OR DB_ID(''AirReporting'') IS NULL
  THROW 51042,N''Thủ tục sao chép LAB chỉ chạy trên một instance có đủ tám database.'',1;
 IF NOT EXISTS(SELECT 1 FROM [AirReference_HCM].sys.extended_properties WHERE class=0 AND name=''AirLabProject'' AND CONVERT(nvarchar(100),value)=''CSDLPT_NHOM8_V1'')
  THROW 51042,N''Database bản sao LAB không thuộc dự án.'',1;
 BEGIN TRY
  BEGIN TRAN;
  DELETE [AirReference_HCM].dbo.[Fare];
  DELETE [AirReference_HCM].dbo.[Flight];
  DELETE [AirReference_HCM].dbo.[Route];
  DELETE [AirReference_HCM].dbo.[Aircraft];
  DELETE [AirReference_HCM].dbo.[Airport];
  DELETE [AirReference_HCM].dbo.[Branch];
  INSERT [AirReference_HCM].dbo.[Branch] SELECT * FROM dbo.[Branch];
  INSERT [AirReference_HCM].dbo.[Airport] SELECT * FROM dbo.[Airport];
  INSERT [AirReference_HCM].dbo.[Aircraft] SELECT * FROM dbo.[Aircraft];
  INSERT [AirReference_HCM].dbo.[Route] SELECT * FROM dbo.[Route];
  INSERT [AirReference_HCM].dbo.[Flight] SELECT * FROM dbo.[Flight];
  INSERT [AirReference_HCM].dbo.[Fare] SELECT * FROM dbo.[Fare];

  DELETE AirReporting.[hcm].SalesItem;
  DELETE AirReporting.[hcm].SalesOrder;
  INSERT AirReporting.[hcm].SalesOrder SELECT * FROM [AirBranch_HCM].dbo.SalesOrder;
  INSERT AirReporting.[hcm].SalesItem(OrderID,ItemNo,UnitPrice,TicketID)
    SELECT OrderID,ItemNo,UnitPrice,TicketID FROM [AirBranch_HCM].dbo.SalesItem;
  UPDATE [AirReference_HCM].dbo.SyncWatermark SET LastCopiedAt=SYSUTCDATETIME() WHERE SourceName=''AirCore'';
  IF @@ROWCOUNT=0 INSERT [AirReference_HCM].dbo.SyncWatermark VALUES(''AirCore'',SYSUTCDATETIME());
  UPDATE AirReporting.dbo.SyncWatermark SET LastCopiedAt=SYSUTCDATETIME() WHERE SourceName=''HCM'';
  IF @@ROWCOUNT=0 INSERT AirReporting.dbo.SyncWatermark VALUES(''HCM'',SYSUTCDATETIME());
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;';
GO


-- PHẦN 7 - Dữ liệu mẫu: tương lai 7 ngày, không đặt lại dữ liệu đã bán khi chạy lại
EXEC #ApplySql @Kind='CORE', @Statement=N'IF (SELECT SeedData FROM #ProjectOptions)=1
BEGIN
 IF NOT EXISTS(SELECT 1 FROM dbo.Branch WHERE BranchID=''HN'') INSERT dbo.Branch VALUES(''HN'',N''Chi nhánh Hà Nội'',N''Hà Nội'');
 IF NOT EXISTS(SELECT 1 FROM dbo.Branch WHERE BranchID=''DN'') INSERT dbo.Branch VALUES(''DN'',N''Chi nhánh Đà Nẵng'',N''Đà Nẵng'');
 IF NOT EXISTS(SELECT 1 FROM dbo.Branch WHERE BranchID=''HCM'') INSERT dbo.Branch VALUES(''HCM'',N''Chi nhánh TP Hồ Chí Minh'',N''TP Hồ Chí Minh'');
 IF NOT EXISTS(SELECT 1 FROM dbo.Airport WHERE AirportCode=''HAN'') INSERT dbo.Airport VALUES(''HAN'',N''Nội Bài'',N''Hà Nội'');
 IF NOT EXISTS(SELECT 1 FROM dbo.Airport WHERE AirportCode=''DAD'') INSERT dbo.Airport VALUES(''DAD'',N''Đà Nẵng'',N''Đà Nẵng'');
 IF NOT EXISTS(SELECT 1 FROM dbo.Airport WHERE AirportCode=''SGN'') INSERT dbo.Airport VALUES(''SGN'',N''Tân Sơn Nhất'',N''TP Hồ Chí Minh'');
 IF NOT EXISTS(SELECT 1 FROM dbo.Route WHERE RouteID=''HAN_DAD'') INSERT dbo.Route VALUES(''HAN_DAD'',''HAN'',''DAD'');
 IF NOT EXISTS(SELECT 1 FROM dbo.Route WHERE RouteID=''DAD_SGN'') INSERT dbo.Route VALUES(''DAD_SGN'',''DAD'',''SGN'');
 IF NOT EXISTS(SELECT 1 FROM dbo.Route WHERE RouteID=''HAN_SGN'') INSERT dbo.Route VALUES(''HAN_SGN'',''HAN'',''SGN'');
 IF NOT EXISTS(SELECT 1 FROM dbo.Aircraft WHERE AircraftID=''LAB_A1'') INSERT dbo.Aircraft VALUES(''LAB_A1'',''MO_PHONG_A1'',12);
 IF NOT EXISTS(SELECT 1 FROM dbo.Aircraft WHERE AircraftID=''LAB_A2'') INSERT dbo.Aircraft VALUES(''LAB_A2'',''MO_PHONG_A2'',12);
 IF NOT EXISTS(SELECT 1 FROM dbo.Aircraft WHERE AircraftID=''LAB_A3'') INSERT dbo.Aircraft VALUES(''LAB_A3'',''MO_PHONG_A3'',12);
 DECLARE @D datetime2(3)=DATEADD(day,7,SYSUTCDATETIME());
 IF NOT EXISTS(SELECT 1 FROM dbo.Flight WHERE FlightID=''TEST01'')
  INSERT dbo.Flight(FlightID,FlightNo,RouteID,AircraftID,DepartureUtc,ArrivalUtc,Status)
  VALUES(''TEST01'',''LAB001'',''HAN_DAD'',''LAB_A1'',@D,DATEADD(hour,2,@D),''OPEN'');
 IF NOT EXISTS(SELECT 1 FROM dbo.Flight WHERE FlightID=''TEST02'')
  INSERT dbo.Flight(FlightID,FlightNo,RouteID,AircraftID,DepartureUtc,ArrivalUtc,Status)
  VALUES(''TEST02'',''LAB002'',''DAD_SGN'',''LAB_A2'',@D,DATEADD(hour,2,@D),''OPEN'');
 IF NOT EXISTS(SELECT 1 FROM dbo.Flight WHERE FlightID=''TEST03'')
  INSERT dbo.Flight(FlightID,FlightNo,RouteID,AircraftID,DepartureUtc,ArrivalUtc,Status)
  VALUES(''TEST03'',''LAB003'',''HAN_SGN'',''LAB_A3'',@D,DATEADD(hour,2,@D),''CLOSED'');
 IF NOT EXISTS(SELECT 1 FROM dbo.Fare WHERE FlightID=''TEST01'' AND FareClass=''ECO'') INSERT dbo.Fare VALUES(''TEST01'',''ECO'',1500000,''VND'');
 IF NOT EXISTS(SELECT 1 FROM dbo.Fare WHERE FlightID=''TEST01'' AND FareClass=''BUS'') INSERT dbo.Fare VALUES(''TEST01'',''BUS'',3000000,''VND'');
 IF NOT EXISTS(SELECT 1 FROM dbo.Fare WHERE FlightID=''TEST02'' AND FareClass=''ECO'') INSERT dbo.Fare VALUES(''TEST02'',''ECO'',1000000,''VND'');
 IF NOT EXISTS(SELECT 1 FROM dbo.Fare WHERE FlightID=''TEST03'' AND FareClass=''ECO'') INSERT dbo.Fare VALUES(''TEST03'',''ECO'',2000000,''VND'');
 IF NOT EXISTS(SELECT 1 FROM dbo.Inventory WHERE FlightID=''TEST01'' AND FareClass=''ECO'') INSERT dbo.Inventory(FlightID,FareClass,Capacity) VALUES(''TEST01'',''ECO'',10);
 IF NOT EXISTS(SELECT 1 FROM dbo.Inventory WHERE FlightID=''TEST01'' AND FareClass=''BUS'') INSERT dbo.Inventory(FlightID,FareClass,Capacity) VALUES(''TEST01'',''BUS'',2);
 IF NOT EXISTS(SELECT 1 FROM dbo.Inventory WHERE FlightID=''TEST02'' AND FareClass=''ECO'') INSERT dbo.Inventory(FlightID,FareClass,Capacity) VALUES(''TEST02'',''ECO'',1);
 IF NOT EXISTS(SELECT 1 FROM dbo.Inventory WHERE FlightID=''TEST03'' AND FareClass=''ECO'') INSERT dbo.Inventory(FlightID,FareClass,Capacity) VALUES(''TEST03'',''ECO'',10);
END;';
GO


-- Mỗi mảnh có khách và nhân viên giả lập riêng; không dùng giấy tờ thật
EXEC #ApplySql @Kind='BRANCH', @Statement=N'IF NOT EXISTS(SELECT 1 FROM dbo.LocalBranch WHERE BranchID=''{{BRANCH}}'')
 INSERT dbo.LocalBranch VALUES(''{{BRANCH}}'',N''Chi nhánh {{BRANCH}}'');
IF (SELECT SeedData FROM #ProjectOptions)=1
BEGIN
 DECLARE @Customer uniqueidentifier=CASE ''{{BRANCH}}''
 WHEN ''HN'' THEN ''10000000-0000-0000-0000-000000000001''
 WHEN ''DN'' THEN ''20000000-0000-0000-0000-000000000001''
 ELSE ''30000000-0000-0000-0000-000000000001'' END;
 IF NOT EXISTS(SELECT 1 FROM dbo.CustomerProfile WHERE CustomerID=@Customer)
  INSERT dbo.CustomerProfile(CustomerID,BranchID,FullName,BirthDate,Phone,Email,DocumentNo)
  VALUES(@Customer,''{{BRANCH}}'',N''Khách thử {{BRANCH}} 01'',''2000-01-01'',''TEST_PHONE'',N''lab@example.invalid'',N''GIAY_TO_GIA_LAP'');
 IF NOT EXISTS(SELECT 1 FROM dbo.Employee WHERE EmployeeID=''{{BRANCH}}_NV01'')
  INSERT dbo.Employee VALUES(''{{BRANCH}}_NV01'',''{{BRANCH}}'',N''Nhân viên thử {{BRANCH}} 01'',N''Bán vé'',1);
END;';
GO

-- PHẦN 8 - Demo tuần tự: đơn DN, giữ 2 ghế, thanh toán, nhận 2 vé.
-- Chỉ chạy khi @Node=LAB, @RunDemo=1 và @SeedData=1 ở đầu file.
-- Giữa các bước DB không có transaction SQL xuyên tất cả điểm; ứng dụng phải đối soát khi timeout.
IF (SELECT Node FROM #ProjectOptions)='LAB'
BEGIN
 EXEC AirCore.dbo.usp_RefreshLabCopies;
END;
GO
IF (SELECT RunDemo FROM #ProjectOptions)=1
BEGIN
 EXEC(N'USE AirBranch_DN;
  DECLARE @Passengers dbo.PassengerList;
  INSERT @Passengers VALUES(1,N''Hành khách thử 01'',N''TEST_DOC_01''),(2,N''Hành khách thử 02'',N''TEST_DOC_02'');
  EXEC dbo.usp_CreateOrder @OrderID=''40000000-0000-0000-0000-000000000001'',
   @RequestID=''50000000-0000-0000-0000-000000000001'',@CustomerID=''20000000-0000-0000-0000-000000000001'',
   @EmployeeID=''DN_NV01'',@FlightID=''TEST01'',@FareClass=''ECO'',@Passengers=@Passengers;');
 DECLARE @Hold uniqueidentifier,@Payment uniqueidentifier,@Price decimal(18,2),@Expiry datetime2(3),@Amount decimal(18,2);
 EXEC AirCore.dbo.usp_CreateHold @RequestID='50000000-0000-0000-0000-000000000001',
  @OrderID='40000000-0000-0000-0000-000000000001',@BranchID='DN',@FlightID='TEST01',@FareClass='ECO',@Quantity=2,@HoldID=@Hold OUTPUT;
 SELECT @Price=UnitPrice,@Expiry=ExpiresAt,@Amount=Quantity*UnitPrice FROM AirCore.dbo.SeatHold WHERE HoldID=@Hold;
 EXEC AirBranch_DN.dbo.usp_ApplyHoldResult @OrderID='40000000-0000-0000-0000-000000000001',
  @RequestID='50000000-0000-0000-0000-000000000001',@HoldID=@Hold,@FlightID='TEST01',@FareClass='ECO',@Quantity=2,@UnitPrice=@Price,@ExpiresAt=@Expiry;
 EXEC AirCore.dbo.usp_ConfirmHold @HoldID=@Hold,@BranchID='DN',@ExternalRef='DEMO_PAY_001',@Amount=@Amount,@PaymentID=@Payment OUTPUT;
 EXEC AirBranch_DN.sys.sp_executesql N'
  DECLARE @Tickets dbo.TicketList;
  INSERT @Tickets SELECT ItemNo,TicketID FROM AirCore.dbo.Ticket WHERE HoldID=@H;
  EXEC dbo.usp_ApplyIssuedResult @OrderID=''40000000-0000-0000-0000-000000000001'',@HoldID=@H,@PaymentID=@P,@Tickets=@Tickets;',
  N'@H uniqueidentifier,@P uniqueidentifier',@Hold,@Payment;
 EXEC AirCore.dbo.usp_RefreshLabCopies;
 SELECT * FROM AirCore.dbo.vFlightAvailability;
 SELECT * FROM AirBranch_DN.dbo.SalesOrder;
 SELECT * FROM AirReporting.dbo.vSalesOrderGlobal;
 EXEC AirCore.dbo.usp_CheckInvariants;
END;
GO


-- PHẦN 9 - Vai trò tách riêng; chưa tạo login hoặc chứa mật khẩu trong file
EXEC #ApplySql @Kind='CORE', @Statement=N'IF DATABASE_PRINCIPAL_ID(''booking_executor'') IS NULL CREATE ROLE booking_executor;
IF DATABASE_PRINCIPAL_ID(''refund_operator'') IS NULL CREATE ROLE refund_operator;
IF DATABASE_PRINCIPAL_ID(''maintenance_executor'') IS NULL CREATE ROLE maintenance_executor;
IF DATABASE_PRINCIPAL_ID(''report_reader'') IS NULL CREATE ROLE report_reader;
GRANT EXECUTE ON dbo.usp_CreateHold TO booking_executor;
GRANT EXECUTE ON dbo.usp_ConfirmHold TO booking_executor;
GRANT EXECUTE ON dbo.usp_CancelHold TO booking_executor;
GRANT EXECUTE ON dbo.usp_GetHoldByRequest TO booking_executor;
GRANT SELECT ON dbo.vFlightAvailability TO booking_executor;
GRANT EXECUTE ON dbo.usp_RefundTicket TO refund_operator;
GRANT EXECUTE ON dbo.usp_ExpireHolds TO maintenance_executor;
GRANT EXECUTE ON dbo.usp_CheckInvariants TO maintenance_executor;
GRANT EXECUTE ON dbo.usp_RevenueByBranch TO report_reader;
GRANT EXECUTE ON dbo.usp_HighLoadFlights TO report_reader;
DENY INSERT,UPDATE,DELETE ON dbo.Inventory TO booking_executor;
DENY INSERT,UPDATE,DELETE ON dbo.Payment TO booking_executor;
DENY INSERT,UPDATE,DELETE ON dbo.Ticket TO booking_executor;';
GO


-- Tách tài khoản lập đơn và dịch vụ áp dụng kết quả đã xác minh từ S0
EXEC #ApplySql @Kind='BRANCH', @Statement=N'IF DATABASE_PRINCIPAL_ID(''branch_executor'') IS NULL CREATE ROLE branch_executor;
IF DATABASE_PRINCIPAL_ID(''branch_sync_service'') IS NULL CREATE ROLE branch_sync_service;
IF DATABASE_PRINCIPAL_ID(''report_reader'') IS NULL CREATE ROLE report_reader;
GRANT EXECUTE ON dbo.usp_CreateOrder TO branch_executor;
GRANT EXECUTE,REFERENCES ON TYPE::dbo.PassengerList TO branch_executor;
GRANT SELECT ON dbo.vCustomerPublic TO branch_executor;
GRANT EXECUTE ON dbo.usp_ApplyHoldResult TO branch_sync_service;
GRANT EXECUTE ON dbo.usp_ApplyIssuedResult TO branch_sync_service;
GRANT EXECUTE,REFERENCES ON TYPE::dbo.TicketList TO branch_sync_service;
GRANT EXECUTE ON dbo.usp_MarkPendingReconcile TO branch_sync_service;
GRANT EXECUTE ON dbo.usp_ApplyCancelledResult TO branch_sync_service;
GRANT SELECT ON dbo.SalesOrder TO report_reader;
-- Không cấp SELECT giấy tờ hành khách cho tài khoản báo cáo.';
GO


-- Ứng dụng chi nhánh chỉ đọc danh mục
EXEC #ApplySql @Kind='REFERENCE', @Statement=N'IF DATABASE_PRINCIPAL_ID(''reference_reader'') IS NULL CREATE ROLE reference_reader;
GRANT SELECT ON SCHEMA::dbo TO reference_reader;';
GO


-- Kho nhận chỉ đọc; không ghi lại vào các mảnh nguồn
EXEC #ApplySql @Kind='REPORT', @Statement=N'IF DATABASE_PRINCIPAL_ID(''report_reader'') IS NULL CREATE ROLE report_reader;
GRANT SELECT ON dbo.vSalesOrderGlobal TO report_reader;
GRANT SELECT ON dbo.vSalesItemGlobal TO report_reader;
GRANT SELECT ON dbo.SyncWatermark TO report_reader;';
GO


-- PHẦN 10.1 - Procedure cấu hình publication danh mục cho triển khai nhiều máy
EXEC #ApplySql @Kind='CORE', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_CreatePublication
 @Publication sysname,@IsSales bit,@SnapshotFolder nvarchar(255),
 @PublisherSecurityMode int=1,@PublisherLogin sysname=NULL,@PublisherPassword sysname=NULL
AS
BEGIN
 SET NOCOUNT ON;
 -- DBA chạy sau khi đã Configure Distribution, bật SQL Server Agent và cấp quyền thư mục snapshot.
 IF IS_SRVROLEMEMBER(''sysadmin'')<>1 THROW 51200,N''Cấu hình replication cần sysadmin.'',1;
 IF @Publication IS NULL OR @SnapshotFolder IS NULL OR LEN(@SnapshotFolder)=0
  OR @IsSales IS NULL OR @PublisherSecurityMode NOT IN (0,1)
  THROW 51201,N''Tham số publication không hợp lệ.'',1;
 IF NOT EXISTS(SELECT 1 FROM sys.servers WHERE is_distributor=1)
  THROW 51202,N''Chưa cấu hình Distributor trên instance này.'',1;
 IF @IsSales=1 AND OBJECT_ID(''dbo.LocalBranch'',''U'') IS NULL THROW 51203,N''Publication bán hàng phải tạo ở chi nhánh.'',1;
 IF @IsSales=0 AND OBJECT_ID(''dbo.Inventory'',''U'') IS NULL THROW 51203,N''Publication danh mục phải tạo ở trung tâm.'',1;
 DECLARE @Db sysname=DB_NAME(),@WasPublished bit=(SELECT is_published FROM sys.databases WHERE name=DB_NAME());
 EXEC sys.sp_replicationdboption @dbname=@Db,@optname=N''publish'',@value=N''true'';
 IF EXISTS(SELECT 1 FROM dbo.syspublications WHERE name=@Publication)
  THROW 51204,N''Publication đã tồn tại. Kiểm tra cấu hình hiện có trước khi thay đổi.'',1;
 IF @WasPublished=0
  EXEC sys.sp_addlogreader_agent @publisher_security_mode=@PublisherSecurityMode,
   @publisher_login=@PublisherLogin,@publisher_password=@PublisherPassword;
 EXEC sys.sp_addpublication @publication=@Publication,@status=N''active'',@repl_freq=N''continuous'',
  @allow_push=N''true'',@allow_pull=N''true'',@independent_agent=N''true'',@immediate_sync=N''false'',
  @sync_method=N''concurrent'',@alt_snapshot_folder=@SnapshotFolder;
 DECLARE @Articles TABLE(Name sysname);
 DECLARE @Owner sysname=N''dbo'';
 IF @IsSales=1
 BEGIN
  INSERT @Articles VALUES(''SalesOrder''),(''SalesItem'');
  SELECT @Owner=LOWER(BranchID) FROM dbo.LocalBranch;
 END;
 ELSE INSERT @Articles VALUES(''Branch''),(''Airport''),(''Aircraft''),(''Route''),(''Flight''),(''Fare'');
 DECLARE @Name sysname,@Vertical nvarchar(5);
 DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT Name FROM @Articles;
 OPEN c; FETCH NEXT FROM c INTO @Name;
 WHILE @@FETCH_STATUS=0
 BEGIN
  SET @Vertical=CASE WHEN @IsSales=1 AND @Name=''SalesItem'' THEN N''true'' ELSE N''false'' END;
  -- Có PK/index/UNIQUE và schema đích; không sao chép FK đến bảng không được công bố.
  EXEC sys.sp_addarticle @publication=@Publication,@article=@Name,@source_owner=N''dbo'',@source_object=@Name,
   @destination_owner=@Owner,@destination_table=@Name,@type=N''logbased'',
   @schema_option=0x00000000080040D3,@pre_creation_cmd=N''drop'',@vertical_partition=@Vertical;
  IF @Vertical=N''true''
  BEGIN
   EXEC sys.sp_articlecolumn @publication=@Publication,@article=@Name,@operation=N''add'';
   EXEC sys.sp_articlecolumn @publication=@Publication,@article=@Name,@column=N''PassengerName'',@operation=N''drop'';
   EXEC sys.sp_articlecolumn @publication=@Publication,@article=@Name,@column=N''PassengerDocument'',@operation=N''drop'';
  END;
  FETCH NEXT FROM c INTO @Name;
 END;
 CLOSE c; DEALLOCATE c;
 EXEC sys.sp_addpublication_snapshot @publication=@Publication,@publisher_security_mode=@PublisherSecurityMode,
  @publisher_login=@PublisherLogin,@publisher_password=@PublisherPassword;
 EXEC sys.sp_startpublication_snapshot @publication=@Publication;
END;';
GO


-- Procedure cấu hình publication bán hàng vào schema hn, dn hoặc hcm
EXEC #ApplySql @Kind='BRANCH', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_CreatePublication
 @Publication sysname,@IsSales bit,@SnapshotFolder nvarchar(255),
 @PublisherSecurityMode int=1,@PublisherLogin sysname=NULL,@PublisherPassword sysname=NULL
AS
BEGIN
 SET NOCOUNT ON;
 -- DBA chạy sau khi đã Configure Distribution, bật SQL Server Agent và cấp quyền thư mục snapshot.
 IF IS_SRVROLEMEMBER(''sysadmin'')<>1 THROW 51200,N''Cấu hình replication cần sysadmin.'',1;
 IF @Publication IS NULL OR @SnapshotFolder IS NULL OR LEN(@SnapshotFolder)=0
  OR @IsSales IS NULL OR @PublisherSecurityMode NOT IN (0,1)
  THROW 51201,N''Tham số publication không hợp lệ.'',1;
 IF NOT EXISTS(SELECT 1 FROM sys.servers WHERE is_distributor=1)
  THROW 51202,N''Chưa cấu hình Distributor trên instance này.'',1;
 IF @IsSales=1 AND OBJECT_ID(''dbo.LocalBranch'',''U'') IS NULL THROW 51203,N''Publication bán hàng phải tạo ở chi nhánh.'',1;
 IF @IsSales=0 AND OBJECT_ID(''dbo.Inventory'',''U'') IS NULL THROW 51203,N''Publication danh mục phải tạo ở trung tâm.'',1;
 DECLARE @Db sysname=DB_NAME(),@WasPublished bit=(SELECT is_published FROM sys.databases WHERE name=DB_NAME());
 EXEC sys.sp_replicationdboption @dbname=@Db,@optname=N''publish'',@value=N''true'';
 IF EXISTS(SELECT 1 FROM dbo.syspublications WHERE name=@Publication)
  THROW 51204,N''Publication đã tồn tại. Kiểm tra cấu hình hiện có trước khi thay đổi.'',1;
 IF @WasPublished=0
  EXEC sys.sp_addlogreader_agent @publisher_security_mode=@PublisherSecurityMode,
   @publisher_login=@PublisherLogin,@publisher_password=@PublisherPassword;
 EXEC sys.sp_addpublication @publication=@Publication,@status=N''active'',@repl_freq=N''continuous'',
  @allow_push=N''true'',@allow_pull=N''true'',@independent_agent=N''true'',@immediate_sync=N''false'',
  @sync_method=N''concurrent'',@alt_snapshot_folder=@SnapshotFolder;
 DECLARE @Articles TABLE(Name sysname);
 DECLARE @Owner sysname=N''dbo'';
 IF @IsSales=1
 BEGIN
  INSERT @Articles VALUES(''SalesOrder''),(''SalesItem'');
  SELECT @Owner=LOWER(BranchID) FROM dbo.LocalBranch;
 END;
 ELSE INSERT @Articles VALUES(''Branch''),(''Airport''),(''Aircraft''),(''Route''),(''Flight''),(''Fare'');
 DECLARE @Name sysname,@Vertical nvarchar(5);
 DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT Name FROM @Articles;
 OPEN c; FETCH NEXT FROM c INTO @Name;
 WHILE @@FETCH_STATUS=0
 BEGIN
  SET @Vertical=CASE WHEN @IsSales=1 AND @Name=''SalesItem'' THEN N''true'' ELSE N''false'' END;
  -- Có PK/index/UNIQUE và schema đích; không sao chép FK đến bảng không được công bố.
  EXEC sys.sp_addarticle @publication=@Publication,@article=@Name,@source_owner=N''dbo'',@source_object=@Name,
   @destination_owner=@Owner,@destination_table=@Name,@type=N''logbased'',
   @schema_option=0x00000000080040D3,@pre_creation_cmd=N''drop'',@vertical_partition=@Vertical;
  IF @Vertical=N''true''
  BEGIN
   EXEC sys.sp_articlecolumn @publication=@Publication,@article=@Name,@operation=N''add'';
   EXEC sys.sp_articlecolumn @publication=@Publication,@article=@Name,@column=N''PassengerName'',@operation=N''drop'';
   EXEC sys.sp_articlecolumn @publication=@Publication,@article=@Name,@column=N''PassengerDocument'',@operation=N''drop'';
  END;
  FETCH NEXT FROM c INTO @Name;
 END;
 CLOSE c; DEALLOCATE c;
 EXEC sys.sp_addpublication_snapshot @publication=@Publication,@publisher_security_mode=@PublisherSecurityMode,
  @publisher_login=@PublisherLogin,@publisher_password=@PublisherPassword;
 EXEC sys.sp_startpublication_snapshot @publication=@Publication;
END;';
GO


-- PHẦN 10.2 - Push subscription: cần tên instance thật và quyền agent
EXEC #ApplySql @Kind='CORE', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_CreatePushSubscription
 @Publication sysname,@Subscriber sysname,@SubscriberDatabase sysname,
 @SubscriberSecurityMode int=1,@SubscriberLogin sysname=NULL,@SubscriberPassword sysname=NULL
AS
BEGIN
 SET NOCOUNT ON;
 IF IS_SRVROLEMEMBER(''sysadmin'')<>1 THROW 51200,N''Cấu hình replication cần sysadmin.'',1;
 IF @Subscriber IS NULL OR @SubscriberDatabase IS NULL OR @Publication IS NULL
  OR @SubscriberSecurityMode NOT IN (0,1) THROW 51205,N''Tham số subscription không hợp lệ.'',1;
 EXEC sys.sp_addsubscription @publication=@Publication,@subscriber=@Subscriber,
  @destination_db=@SubscriberDatabase,@subscription_type=N''push'',@sync_type=N''automatic'',@article=N''all'';
 EXEC sys.sp_addpushsubscription_agent @publication=@Publication,@subscriber=@Subscriber,
  @subscriber_db=@SubscriberDatabase,@subscriber_security_mode=@SubscriberSecurityMode,
  @subscriber_login=@SubscriberLogin,@subscriber_password=@SubscriberPassword,@frequency_type=64;
END;';
GO


-- Push dữ liệu bán về AirReporting của S0
EXEC #ApplySql @Kind='BRANCH', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_CreatePushSubscription
 @Publication sysname,@Subscriber sysname,@SubscriberDatabase sysname,
 @SubscriberSecurityMode int=1,@SubscriberLogin sysname=NULL,@SubscriberPassword sysname=NULL
AS
BEGIN
 SET NOCOUNT ON;
 IF IS_SRVROLEMEMBER(''sysadmin'')<>1 THROW 51200,N''Cấu hình replication cần sysadmin.'',1;
 IF @Subscriber IS NULL OR @SubscriberDatabase IS NULL OR @Publication IS NULL
  OR @SubscriberSecurityMode NOT IN (0,1) THROW 51205,N''Tham số subscription không hợp lệ.'',1;
 EXEC sys.sp_addsubscription @publication=@Publication,@subscriber=@Subscriber,
  @destination_db=@SubscriberDatabase,@subscription_type=N''push'',@sync_type=N''automatic'',@article=N''all'';
 EXEC sys.sp_addpushsubscription_agent @publication=@Publication,@subscriber=@Subscriber,
  @subscriber_db=@SubscriberDatabase,@subscriber_security_mode=@SubscriberSecurityMode,
  @subscriber_login=@SubscriberLogin,@subscriber_password=@SubscriberPassword,@frequency_type=64;
END;';
GO


-- PHẦN 10.3 - Tạo job hết hạn mỗi phút; chỉ gọi khi SQL Server Agent đang hoạt động
EXEC #ApplySql @Kind='CORE', @Statement=N'CREATE OR ALTER PROCEDURE dbo.usp_CreateExpiryJob
AS
BEGIN
 SET NOCOUNT ON;
 IF IS_SRVROLEMEMBER(''sysadmin'')<>1 THROW 51200,N''Tạo SQL Agent job cần sysadmin.'',1;
 DECLARE @Job sysname=DB_NAME()+N''_ExpireHolds'',@Db sysname=DB_NAME(),@ID uniqueidentifier,@Schedule sysname;
 SET @Schedule=@Job+N''_EveryMinute'';
 IF EXISTS(SELECT 1 FROM msdb.dbo.sysjobs WHERE name=@Job) RETURN;
 EXEC msdb.dbo.sp_add_job @job_name=@Job,@enabled=1,@description=N''Giải phóng giữ chỗ hết hạn'',@job_id=@ID OUTPUT;
 EXEC msdb.dbo.sp_add_jobstep @job_id=@ID,@step_name=N''Expire'',@subsystem=N''TSQL'',
  @database_name=@Db,@command=N''EXEC dbo.usp_ExpireHolds @BatchSize=100;'';
 EXEC msdb.dbo.sp_add_jobschedule @job_id=@ID,@name=@Schedule,@freq_type=4,@freq_interval=1,
  @freq_subday_type=4,@freq_subday_interval=1,@active_start_time=0;
 EXEC msdb.dbo.sp_add_jobserver @job_id=@ID;
END;';
GO

/*
  CÁC QUERY TRIỂN KHAI NHIỀU MÁY - BÔI CHỌN VÀ CHẠY RIÊNG SAU KHI ĐỔI THÔNG SỐ
  Các câu bên trong comment này không tự chạy trong chế độ LAB.
  1. Trên từng Publisher S0/HN/DN/HCM: cấu hình local Distributor một lần.
     Chọn Replication > Configure Distribution trong SSMS, hoặc dùng các lệnh sau.
     Thư mục snapshot phải tồn tại và tài khoản agent có quyền. Với nhiều máy dùng UNC/share.

  USE master;
  DECLARE @Server sysname=CONVERT(sysname,SERVERPROPERTY('ServerName'));
  DECLARE @Folder nvarchar(255)=N'D:\AirLab\ReplSnapshot'; -- THAY ĐƯỜNG DẪN THẬT
  DECLARE @Password nvarchar(128)=N'NHAP_MAT_KHAU_DISTRIBUTOR_CUA_BAN'; -- KHÔNG NỘP MẬT KHẨU THẬT
  EXEC sys.sp_adddistributor @distributor=@Server,@password=@Password;
  EXEC sys.sp_adddistributiondb @database=N'distribution',@security_mode=1;
  EXEC sys.sp_adddistpublisher @publisher=@Server,@distribution_db=N'distribution',
    @security_mode=1,@working_directory=@Folder;

  2. S0: tạo publication danh mục và ba subscription đến database AirReference.
     Tên máy phải đúng @@SERVERNAME trên mỗi instance; không dùng IP làm tên Publisher thay @@SERVERNAME.
     PublisherSecurityMode/SubscriberSecurityMode=1 dùng Windows Authentication cho agent.
     Nếu dùng SQL Authentication, truyền mode=0 và login/password qua lời gọi riêng, không lưu bí mật trong bài nộp.

  EXEC AirCore.dbo.usp_CreatePublication @Publication=N'P_REFERENCE',@IsSales=0,
    @SnapshotFolder=N'\\SERVER_S0\AirSnapshot';
  EXEC AirCore.dbo.usp_CreatePushSubscription @Publication=N'P_REFERENCE',@Subscriber=N'SERVER_HN',@SubscriberDatabase=N'AirReference';
  EXEC AirCore.dbo.usp_CreatePushSubscription @Publication=N'P_REFERENCE',@Subscriber=N'SERVER_DN',@SubscriberDatabase=N'AirReference';
  EXEC AirCore.dbo.usp_CreatePushSubscription @Publication=N'P_REFERENCE',@Subscriber=N'SERVER_HCM',@SubscriberDatabase=N'AirReference';

  3. Chạy tại từng chi nhánh với publication riêng:
     HN: P_SALES_HN; DN: P_SALES_DN; HCM: P_SALES_HCM.
     destination_owner tự lấy từ LocalBranch: hn/dn/hcm, không cùng nhận vào dbo.

  EXEC AirBranch.dbo.usp_CreatePublication @Publication=N'P_SALES_DN',@IsSales=1,
    @SnapshotFolder=N'\\SERVER_DN\AirSnapshot';
  EXEC AirBranch.dbo.usp_CreatePushSubscription @Publication=N'P_SALES_DN',
    @Subscriber=N'SERVER_S0',@SubscriberDatabase=N'AirReporting';

  4. Bản snapshot có thể tạo lại bảng nhận trong publication; chỉ cấu hình với DB bản sao của dự án.
     Không chạy usp_RefreshLabCopies trên các DB đang dùng transactional replication thật.
     Nếu bản snapshot thay bảng nhận, kiểm tra lại quyền/view sau khi agent hoàn tất.
     Tham khảo Replication Monitor để kiểm tra agent, pending commands và tracer token.

  USE AirCore;
  EXEC sys.sp_posttracertoken @publication=N'P_REFERENCE';
  EXEC dbo.usp_CreateExpiryJob;

  5. Ví dụ Linked Server chỉ đọc tại S0, thay SERVER_DN và quyền mapping thực tế:
  EXEC master.dbo.sp_addlinkedserver @server=N'LS_DN',@srvproduct=N'',
    @provider=N'MSOLEDBSQL',@datasrc=N'SERVER_DN';
  -- DBA ánh xạ tài khoản chỉ đọc bằng sp_addlinkedsrvlogin theo môi trường.
  SELECT OrderID,BranchID,Status,CreatedAt FROM [LS_DN].[AirBranch].[dbo].[SalesOrder];

  6. Gắn login hiện có vào role; không tạo sa hoặc đặt mật khẩu chung trong bài nộp:
  USE AirCore;
  CREATE USER [tai_khoan_ung_dung] FOR LOGIN [tai_khoan_ung_dung];
  ALTER ROLE booking_executor ADD MEMBER [tai_khoan_ung_dung];

  7. Ví dụ sao lưu sau khi DBA tạo thư mục và cấp quyền dịch vụ:
  BACKUP DATABASE AirCore TO DISK=N'D:\AirLab\Backup\AirCore_full.bak' WITH CHECKSUM;
  -- Muốn backup log: chọn recovery model FULL, tạo full backup khởi đầu, giữ chuỗi log.
  BACKUP LOG AirCore TO DISK=N'D:\AirLab\Backup\AirCore_log.trn' WITH CHECKSUM;
*/

/*
  QUERY KIỂM THỬ ĐỂ TRÌNH DIỄN - MỖI KHỐI CHẠY RIÊNG KHI CẦN

  A. Ghế cuối: mở hai cửa sổ SSMS trên S0, chạy đồng thời khối sau ở mỗi cửa sổ.
     TEST02 ECO có Capacity=1. Mỗi cửa sổ dùng NEWID riêng; đúng một yêu cầu thành công.
  USE AirCore;
  DECLARE @R uniqueidentifier=NEWID(),@O uniqueidentifier=NEWID(),@H uniqueidentifier;
  EXEC dbo.usp_CreateHold @R,@O,'HN','TEST02','ECO',1,@H OUTPUT;
  SELECT @R RequestID,@H HoldID;
  SELECT * FROM dbo.Inventory WHERE FlightID='TEST02';

  B. Thử lại: giữ nguyên RequestID/OrderID; kết quả là cùng HoldID và Held chỉ tăng một lần.
  DECLARE @H2 uniqueidentifier;
  EXEC dbo.usp_CreateHold @R,@O,'HN','TEST02','ECO',1,@H2 OUTPUT;
  SELECT @H2;
  -- Cùng RequestID nhưng Quantity=2 phải báo lỗi 51004.

  C. Hủy, hết hạn, hoàn và đối soát:
  EXEC dbo.usp_CancelHold @HoldID=@H,@BranchID='HN';
  EXEC dbo.usp_ExpireHolds @BatchSize=100;
  DECLARE @Refund uniqueidentifier;
  -- Thay ID một vé đã phát hành; lần gọi lại cùng ExternalRef phải trả cùng RefundID.
  EXEC dbo.usp_RefundTicket @TicketID='THAY_GUID_VE',@BranchID='DN',
    @ExternalRef='REFUND_TEST_001',@RefundID=@Refund OUTPUT;
  EXEC dbo.usp_CheckInvariants; -- Tất cả các result set phải rỗng.

  D. Báo cáo tại trung tâm:
  DECLARE @From datetime2(3)=DATEADD(day,-1,SYSUTCDATETIME()),@To datetime2(3)=DATEADD(day,1,SYSUTCDATETIME());
  EXEC dbo.usp_RevenueByBranch @From,@To;
  EXEC dbo.usp_HighLoadFlights @Threshold=80;
  SELECT * FROM AirReporting.dbo.vSalesOrderGlobal;
  SELECT OrderID,COUNT(*) FROM AirReporting.dbo.vSalesOrderGlobal GROUP BY OrderID HAVING COUNT(*)>1;
  SELECT i.OrderID,i.ItemNo FROM AirReporting.dbo.vSalesItemGlobal i
    LEFT JOIN AirReporting.dbo.vSalesOrderGlobal o ON o.OrderID=i.OrderID WHERE o.OrderID IS NULL;

  E. Hồ sơ tái thiết qua chiếu dọc tại chi nhánh (view, chưa tách hai bảng vật lý):
  SELECT p.CustomerID,p.BranchID,p.FullName,p.BirthDate,s.Phone,s.Email,s.DocumentNo
    FROM dbo.vCustomerPublic p JOIN dbo.vCustomerPrivate s ON s.CustomerID=p.CustomerID;

  Nguồn cú pháp: Microsoft Learn SQL Server 2022, sp_getapplock, SQL Server Replication,
  sp_addarticle, sp_addlogreader_agent, sp_addpublication_snapshot, sp_addpushsubscription_agent.
*/
SELECT Node,SeedData,RunDemo FROM #ProjectOptions;
SELECT Kind,DbName,BranchID FROM #Targets ORDER BY Kind,DbName;
IF (SELECT Node FROM #ProjectOptions)='FAIL'
  THROW 51000,N'Khởi tạo thất bại. Kiểm tra lỗi đầu tiên trước khi chạy lại.',1;
PRINT N'Đã hoàn thành cấu trúc, procedure, view, vai trò và dữ liệu mẫu theo Node đã chọn.';
GO
