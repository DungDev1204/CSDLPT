/*
  CƠ SỞ DỮ LIỆU PHÂN TÁN QUẢN LÝ HÀNG KHÔNG THÔNG MINH - NHÓM 8
  BẢN CHẠY HOÀN CHỈNH TRÊN MỘT SQL SERVER 2022
  Lớp D24TXCN05-K. Giảng viên: ThS. Mai Ngọc Lương.
  K24DTCN190 - Đỗ Thị Hằng (trưởng nhóm, tổng hợp báo cáo)
  K24DTCN168 - Phan Phương Anh
  K24DTCN184 - Lê Hoàng Dương
  K24DTCN182 - Trần Tiến Dũng
  K24DTCN246 - Nguyễn Văn Tùng
  K24DTCN221 - Ngô Thế Quang
  K24DTCN223 - Phan Văn Sang

  CÁCH CHẠY: mở file trong SSMS, kết nối SQL Server 2022 bằng tài khoản có quyền
  tạo database và các đối tượng, nhấn Ctrl+A rồi F5. Không cần sửa thông số hay bật SQLCMD Mode.
  Chạy toàn bộ file trên cùng một connection để thiết lập và xem các kết quả ở cuối.

  File tự thực hiện:
  - Tạo AirCore, AirReporting; AirBranch_HN/DN/HCM; AirReference_HN/DN/HCM.
  - Tạo bảng, khóa, index, view, procedure, kiểu bảng và vai trò truy cập.
  - Nhập dữ liệu mẫu, bán vé tại ba chi nhánh, hủy một đơn và hoàn một vé.
  - Tạo dữ liệu mẫu hết hạn, giải phóng ghế, sao chép danh mục và các mảnh bán hàng.
  - Truy vấn dữ liệu toàn cục, thu/hoàn, tồn ghế và kiểm tra tính nhất quán.

  Tám database mô phỏng các điểm dữ liệu trên cùng một instance. Sao chép ở đây là
  snapshot cục bộ bằng procedure, không phải transactional replication giữa nhiều máy.
  Thanh toán, hành khách, giấy tờ và chuyến bay đều là dữ liệu giả lập phục vụ bài nộp.
  Chạy lại không xóa database, không đặt lại số ghế, không phát hành hoặc hoàn trùng vé mẫu.
*/
USE master;
GO
SET NOCOUNT ON; SET XACT_ABORT ON;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON; SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
IF OBJECT_ID('tempdb..#RunState') IS NOT NULL DROP TABLE #RunState;
CREATE TABLE #RunState(Ready bit NOT NULL);
INSERT #RunState VALUES(0);
-- PHẦN 1 - Tạo các điểm dữ liệu; giữ nguyên database đã tạo bởi bản trước của nhóm.
BEGIN TRY

IF DB_ID(N'AirCore') IS NULL
BEGIN
 EXEC(N'CREATE DATABASE [AirCore] COLLATE Latin1_General_100_CI_AS_SC;');
 EXEC [AirCore].sys.sp_addextendedproperty @name=N'AirLabProject',@value=N'CSDLPT_NHOM8_V1';
END;
IF NOT EXISTS(SELECT 1 FROM [AirCore].sys.extended_properties
 WHERE class=0 AND name=N'AirLabProject' AND CONVERT(nvarchar(100),value)=N'CSDLPT_NHOM8_V1')
 THROW 51000,N'Database AirCore đã tồn tại và không thuộc dự án của nhóm.',1;

IF DB_ID(N'AirReporting') IS NULL
BEGIN
 EXEC(N'CREATE DATABASE [AirReporting] COLLATE Latin1_General_100_CI_AS_SC;');
 EXEC [AirReporting].sys.sp_addextendedproperty @name=N'AirLabProject',@value=N'CSDLPT_NHOM8_V1';
END;
IF NOT EXISTS(SELECT 1 FROM [AirReporting].sys.extended_properties
 WHERE class=0 AND name=N'AirLabProject' AND CONVERT(nvarchar(100),value)=N'CSDLPT_NHOM8_V1')
 THROW 51000,N'Database AirReporting đã tồn tại và không thuộc dự án của nhóm.',1;

IF DB_ID(N'AirBranch_HN') IS NULL
BEGIN
 EXEC(N'CREATE DATABASE [AirBranch_HN] COLLATE Latin1_General_100_CI_AS_SC;');
 EXEC [AirBranch_HN].sys.sp_addextendedproperty @name=N'AirLabProject',@value=N'CSDLPT_NHOM8_V1';
END;
IF NOT EXISTS(SELECT 1 FROM [AirBranch_HN].sys.extended_properties
 WHERE class=0 AND name=N'AirLabProject' AND CONVERT(nvarchar(100),value)=N'CSDLPT_NHOM8_V1')
 THROW 51000,N'Database AirBranch_HN đã tồn tại và không thuộc dự án của nhóm.',1;

IF DB_ID(N'AirBranch_DN') IS NULL
BEGIN
 EXEC(N'CREATE DATABASE [AirBranch_DN] COLLATE Latin1_General_100_CI_AS_SC;');
 EXEC [AirBranch_DN].sys.sp_addextendedproperty @name=N'AirLabProject',@value=N'CSDLPT_NHOM8_V1';
END;
IF NOT EXISTS(SELECT 1 FROM [AirBranch_DN].sys.extended_properties
 WHERE class=0 AND name=N'AirLabProject' AND CONVERT(nvarchar(100),value)=N'CSDLPT_NHOM8_V1')
 THROW 51000,N'Database AirBranch_DN đã tồn tại và không thuộc dự án của nhóm.',1;

IF DB_ID(N'AirBranch_HCM') IS NULL
BEGIN
 EXEC(N'CREATE DATABASE [AirBranch_HCM] COLLATE Latin1_General_100_CI_AS_SC;');
 EXEC [AirBranch_HCM].sys.sp_addextendedproperty @name=N'AirLabProject',@value=N'CSDLPT_NHOM8_V1';
END;
IF NOT EXISTS(SELECT 1 FROM [AirBranch_HCM].sys.extended_properties
 WHERE class=0 AND name=N'AirLabProject' AND CONVERT(nvarchar(100),value)=N'CSDLPT_NHOM8_V1')
 THROW 51000,N'Database AirBranch_HCM đã tồn tại và không thuộc dự án của nhóm.',1;

IF DB_ID(N'AirReference_HN') IS NULL
BEGIN
 EXEC(N'CREATE DATABASE [AirReference_HN] COLLATE Latin1_General_100_CI_AS_SC;');
 EXEC [AirReference_HN].sys.sp_addextendedproperty @name=N'AirLabProject',@value=N'CSDLPT_NHOM8_V1';
END;
IF NOT EXISTS(SELECT 1 FROM [AirReference_HN].sys.extended_properties
 WHERE class=0 AND name=N'AirLabProject' AND CONVERT(nvarchar(100),value)=N'CSDLPT_NHOM8_V1')
 THROW 51000,N'Database AirReference_HN đã tồn tại và không thuộc dự án của nhóm.',1;

IF DB_ID(N'AirReference_DN') IS NULL
BEGIN
 EXEC(N'CREATE DATABASE [AirReference_DN] COLLATE Latin1_General_100_CI_AS_SC;');
 EXEC [AirReference_DN].sys.sp_addextendedproperty @name=N'AirLabProject',@value=N'CSDLPT_NHOM8_V1';
END;
IF NOT EXISTS(SELECT 1 FROM [AirReference_DN].sys.extended_properties
 WHERE class=0 AND name=N'AirLabProject' AND CONVERT(nvarchar(100),value)=N'CSDLPT_NHOM8_V1')
 THROW 51000,N'Database AirReference_DN đã tồn tại và không thuộc dự án của nhóm.',1;

IF DB_ID(N'AirReference_HCM') IS NULL
BEGIN
 EXEC(N'CREATE DATABASE [AirReference_HCM] COLLATE Latin1_General_100_CI_AS_SC;');
 EXEC [AirReference_HCM].sys.sp_addextendedproperty @name=N'AirLabProject',@value=N'CSDLPT_NHOM8_V1';
END;
IF NOT EXISTS(SELECT 1 FROM [AirReference_HCM].sys.extended_properties
 WHERE class=0 AND name=N'AirLabProject' AND CONVERT(nvarchar(100),value)=N'CSDLPT_NHOM8_V1')
 THROW 51000,N'Database AirReference_HCM đã tồn tại và không thuộc dự án của nhóm.',1;

UPDATE #RunState SET Ready=1;
END TRY
BEGIN CATCH
 PRINT ERROR_MESSAGE();
 -- Dừng thực thi các batch sau trong SSMS nếu khởi tạo thất bại.
 SET NOEXEC ON;
END CATCH;
GO

-- PHẦN 2 - Danh mục nguồn tại S0 [AirCore]
USE [AirCore];
GO
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
IF OBJECT_ID('dbo.Branch','U') IS NULL
CREATE TABLE dbo.Branch(BranchID varchar(3) PRIMARY KEY CHECK(BranchID IN ('HN','DN','HCM')),
 BranchName nvarchar(100) NOT NULL, City nvarchar(100) NOT NULL);
IF OBJECT_ID('dbo.Airport','U') IS NULL
CREATE TABLE dbo.Airport(AirportCode varchar(3) PRIMARY KEY,
 AirportName nvarchar(100) NOT NULL,City nvarchar(100) NOT NULL);
IF OBJECT_ID('dbo.Route','U') IS NULL
CREATE TABLE dbo.Route(RouteID varchar(20) PRIMARY KEY,
 OriginCode varchar(3) NOT NULL REFERENCES dbo.Airport(AirportCode),
 DestCode varchar(3) NOT NULL REFERENCES dbo.Airport(AirportCode),
 CHECK(OriginCode<>DestCode),UNIQUE(OriginCode,DestCode));
IF OBJECT_ID('dbo.Aircraft','U') IS NULL
CREATE TABLE dbo.Aircraft(AircraftID varchar(20) PRIMARY KEY,
 Registration varchar(30) NOT NULL UNIQUE, TotalSeats int NOT NULL CHECK(TotalSeats>0));
IF OBJECT_ID('dbo.Flight','U') IS NULL
CREATE TABLE dbo.Flight(FlightID varchar(20) PRIMARY KEY,FlightNo varchar(20) NOT NULL,
 RouteID varchar(20) NOT NULL REFERENCES dbo.Route(RouteID),
 AircraftID varchar(20) NOT NULL REFERENCES dbo.Aircraft(AircraftID),
 DepartureUtc datetime2(3) NOT NULL,ArrivalUtc datetime2(3) NOT NULL,
 Status varchar(10) NOT NULL CHECK(Status IN ('OPEN','CLOSED','CANCELLED')),
 UpdatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME(),CHECK(ArrivalUtc>DepartureUtc));
IF OBJECT_ID('dbo.Fare','U') IS NULL
CREATE TABLE dbo.Fare(FlightID varchar(20) NOT NULL REFERENCES dbo.Flight(FlightID),
 FareClass varchar(3) NOT NULL CHECK(FareClass IN ('ECO','BUS')),
 Price decimal(18,2) NOT NULL CHECK(Price>0),Currency char(3) NOT NULL DEFAULT 'VND' CHECK(Currency='VND'),
 PRIMARY KEY(FlightID,FareClass));
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.Flight') AND name='IX_Flight_Route_Departure')
CREATE INDEX IX_Flight_Route_Departure ON dbo.Flight(RouteID,DepartureUtc) INCLUDE(FlightNo,Status);
GO

-- Danh mục bản sao tại chi nhánh; ứng dụng chỉ đọc [AirReference_HN]
USE [AirReference_HN];
GO
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
IF OBJECT_ID('dbo.Branch','U') IS NULL
CREATE TABLE dbo.Branch(BranchID varchar(3) PRIMARY KEY CHECK(BranchID IN ('HN','DN','HCM')),
 BranchName nvarchar(100) NOT NULL, City nvarchar(100) NOT NULL);
IF OBJECT_ID('dbo.Airport','U') IS NULL
CREATE TABLE dbo.Airport(AirportCode varchar(3) PRIMARY KEY,
 AirportName nvarchar(100) NOT NULL,City nvarchar(100) NOT NULL);
IF OBJECT_ID('dbo.Route','U') IS NULL
CREATE TABLE dbo.Route(RouteID varchar(20) PRIMARY KEY,
 OriginCode varchar(3) NOT NULL REFERENCES dbo.Airport(AirportCode),
 DestCode varchar(3) NOT NULL REFERENCES dbo.Airport(AirportCode),
 CHECK(OriginCode<>DestCode),UNIQUE(OriginCode,DestCode));
IF OBJECT_ID('dbo.Aircraft','U') IS NULL
CREATE TABLE dbo.Aircraft(AircraftID varchar(20) PRIMARY KEY,
 Registration varchar(30) NOT NULL UNIQUE, TotalSeats int NOT NULL CHECK(TotalSeats>0));
IF OBJECT_ID('dbo.Flight','U') IS NULL
CREATE TABLE dbo.Flight(FlightID varchar(20) PRIMARY KEY,FlightNo varchar(20) NOT NULL,
 RouteID varchar(20) NOT NULL REFERENCES dbo.Route(RouteID),
 AircraftID varchar(20) NOT NULL REFERENCES dbo.Aircraft(AircraftID),
 DepartureUtc datetime2(3) NOT NULL,ArrivalUtc datetime2(3) NOT NULL,
 Status varchar(10) NOT NULL CHECK(Status IN ('OPEN','CLOSED','CANCELLED')),
 UpdatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME(),CHECK(ArrivalUtc>DepartureUtc));
IF OBJECT_ID('dbo.Fare','U') IS NULL
CREATE TABLE dbo.Fare(FlightID varchar(20) NOT NULL REFERENCES dbo.Flight(FlightID),
 FareClass varchar(3) NOT NULL CHECK(FareClass IN ('ECO','BUS')),
 Price decimal(18,2) NOT NULL CHECK(Price>0),Currency char(3) NOT NULL DEFAULT 'VND' CHECK(Currency='VND'),
 PRIMARY KEY(FlightID,FareClass));
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.Flight') AND name='IX_Flight_Route_Departure')
CREATE INDEX IX_Flight_Route_Departure ON dbo.Flight(RouteID,DepartureUtc) INCLUDE(FlightNo,Status);
GO

-- Danh mục bản sao tại chi nhánh; ứng dụng chỉ đọc [AirReference_DN]
USE [AirReference_DN];
GO
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
IF OBJECT_ID('dbo.Branch','U') IS NULL
CREATE TABLE dbo.Branch(BranchID varchar(3) PRIMARY KEY CHECK(BranchID IN ('HN','DN','HCM')),
 BranchName nvarchar(100) NOT NULL, City nvarchar(100) NOT NULL);
IF OBJECT_ID('dbo.Airport','U') IS NULL
CREATE TABLE dbo.Airport(AirportCode varchar(3) PRIMARY KEY,
 AirportName nvarchar(100) NOT NULL,City nvarchar(100) NOT NULL);
IF OBJECT_ID('dbo.Route','U') IS NULL
CREATE TABLE dbo.Route(RouteID varchar(20) PRIMARY KEY,
 OriginCode varchar(3) NOT NULL REFERENCES dbo.Airport(AirportCode),
 DestCode varchar(3) NOT NULL REFERENCES dbo.Airport(AirportCode),
 CHECK(OriginCode<>DestCode),UNIQUE(OriginCode,DestCode));
IF OBJECT_ID('dbo.Aircraft','U') IS NULL
CREATE TABLE dbo.Aircraft(AircraftID varchar(20) PRIMARY KEY,
 Registration varchar(30) NOT NULL UNIQUE, TotalSeats int NOT NULL CHECK(TotalSeats>0));
IF OBJECT_ID('dbo.Flight','U') IS NULL
CREATE TABLE dbo.Flight(FlightID varchar(20) PRIMARY KEY,FlightNo varchar(20) NOT NULL,
 RouteID varchar(20) NOT NULL REFERENCES dbo.Route(RouteID),
 AircraftID varchar(20) NOT NULL REFERENCES dbo.Aircraft(AircraftID),
 DepartureUtc datetime2(3) NOT NULL,ArrivalUtc datetime2(3) NOT NULL,
 Status varchar(10) NOT NULL CHECK(Status IN ('OPEN','CLOSED','CANCELLED')),
 UpdatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME(),CHECK(ArrivalUtc>DepartureUtc));
IF OBJECT_ID('dbo.Fare','U') IS NULL
CREATE TABLE dbo.Fare(FlightID varchar(20) NOT NULL REFERENCES dbo.Flight(FlightID),
 FareClass varchar(3) NOT NULL CHECK(FareClass IN ('ECO','BUS')),
 Price decimal(18,2) NOT NULL CHECK(Price>0),Currency char(3) NOT NULL DEFAULT 'VND' CHECK(Currency='VND'),
 PRIMARY KEY(FlightID,FareClass));
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.Flight') AND name='IX_Flight_Route_Departure')
CREATE INDEX IX_Flight_Route_Departure ON dbo.Flight(RouteID,DepartureUtc) INCLUDE(FlightNo,Status);
GO

-- Danh mục bản sao tại chi nhánh; ứng dụng chỉ đọc [AirReference_HCM]
USE [AirReference_HCM];
GO
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
IF OBJECT_ID('dbo.Branch','U') IS NULL
CREATE TABLE dbo.Branch(BranchID varchar(3) PRIMARY KEY CHECK(BranchID IN ('HN','DN','HCM')),
 BranchName nvarchar(100) NOT NULL, City nvarchar(100) NOT NULL);
IF OBJECT_ID('dbo.Airport','U') IS NULL
CREATE TABLE dbo.Airport(AirportCode varchar(3) PRIMARY KEY,
 AirportName nvarchar(100) NOT NULL,City nvarchar(100) NOT NULL);
IF OBJECT_ID('dbo.Route','U') IS NULL
CREATE TABLE dbo.Route(RouteID varchar(20) PRIMARY KEY,
 OriginCode varchar(3) NOT NULL REFERENCES dbo.Airport(AirportCode),
 DestCode varchar(3) NOT NULL REFERENCES dbo.Airport(AirportCode),
 CHECK(OriginCode<>DestCode),UNIQUE(OriginCode,DestCode));
IF OBJECT_ID('dbo.Aircraft','U') IS NULL
CREATE TABLE dbo.Aircraft(AircraftID varchar(20) PRIMARY KEY,
 Registration varchar(30) NOT NULL UNIQUE, TotalSeats int NOT NULL CHECK(TotalSeats>0));
IF OBJECT_ID('dbo.Flight','U') IS NULL
CREATE TABLE dbo.Flight(FlightID varchar(20) PRIMARY KEY,FlightNo varchar(20) NOT NULL,
 RouteID varchar(20) NOT NULL REFERENCES dbo.Route(RouteID),
 AircraftID varchar(20) NOT NULL REFERENCES dbo.Aircraft(AircraftID),
 DepartureUtc datetime2(3) NOT NULL,ArrivalUtc datetime2(3) NOT NULL,
 Status varchar(10) NOT NULL CHECK(Status IN ('OPEN','CLOSED','CANCELLED')),
 UpdatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME(),CHECK(ArrivalUtc>DepartureUtc));
IF OBJECT_ID('dbo.Fare','U') IS NULL
CREATE TABLE dbo.Fare(FlightID varchar(20) NOT NULL REFERENCES dbo.Flight(FlightID),
 FareClass varchar(3) NOT NULL CHECK(FareClass IN ('ECO','BUS')),
 Price decimal(18,2) NOT NULL CHECK(Price>0),Currency char(3) NOT NULL DEFAULT 'VND' CHECK(Currency='VND'),
 PRIMARY KEY(FlightID,FareClass));
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.Flight') AND name='IX_Flight_Route_Departure')
CREATE INDEX IX_Flight_Route_Departure ON dbo.Flight(RouteID,DepartureUtc) INCLUDE(FlightNo,Status);
GO

-- Mốc sao chép cho mô hình LAB; replication thật dùng tracer token [AirReference_HN]
USE [AirReference_HN];
GO
IF OBJECT_ID('dbo.SyncWatermark','U') IS NULL
CREATE TABLE dbo.SyncWatermark(SourceName sysname PRIMARY KEY,LastCopiedAt datetime2(3) NOT NULL);
GO

-- Mốc sao chép cho mô hình LAB; replication thật dùng tracer token [AirReference_DN]
USE [AirReference_DN];
GO
IF OBJECT_ID('dbo.SyncWatermark','U') IS NULL
CREATE TABLE dbo.SyncWatermark(SourceName sysname PRIMARY KEY,LastCopiedAt datetime2(3) NOT NULL);
GO

-- Mốc sao chép cho mô hình LAB; replication thật dùng tracer token [AirReference_HCM]
USE [AirReference_HCM];
GO
IF OBJECT_ID('dbo.SyncWatermark','U') IS NULL
CREATE TABLE dbo.SyncWatermark(SourceName sysname PRIMARY KEY,LastCopiedAt datetime2(3) NOT NULL);
GO

-- PHẦN 3 - Giữ chỗ, vé, thanh toán, hoàn và nhật ký tại S0 [AirCore]
USE [AirCore];
GO
IF OBJECT_ID('dbo.Inventory','U') IS NULL
CREATE TABLE dbo.Inventory(FlightID varchar(20) NOT NULL,FareClass varchar(3) NOT NULL,
 Capacity int NOT NULL,Held int NOT NULL DEFAULT 0,Sold int NOT NULL DEFAULT 0,
 UpdatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME(),Version rowversion,
 PRIMARY KEY(FlightID,FareClass),
 FOREIGN KEY(FlightID,FareClass) REFERENCES dbo.Fare(FlightID,FareClass),
 CHECK(Capacity>0 AND Held>=0 AND Sold>=0 AND Held+Sold<=Capacity));
IF OBJECT_ID('dbo.SeatHold','U') IS NULL
CREATE TABLE dbo.SeatHold(HoldID uniqueidentifier PRIMARY KEY,
 RequestID uniqueidentifier NOT NULL UNIQUE,OrderID uniqueidentifier NOT NULL,
 BranchID varchar(3) NOT NULL REFERENCES dbo.Branch(BranchID),
 FlightID varchar(20) NOT NULL,FareClass varchar(3) NOT NULL,
 Quantity int NOT NULL CHECK(Quantity>0),UnitPrice decimal(18,2) NOT NULL CHECK(UnitPrice>0),
 Status varchar(10) NOT NULL CHECK(Status IN ('ACTIVE','CONFIRMED','EXPIRED','CANCELLED')),
 CreatedAt datetime2(3) NOT NULL,ExpiresAt datetime2(3) NOT NULL,CHECK(ExpiresAt>CreatedAt),
 FOREIGN KEY(FlightID,FareClass) REFERENCES dbo.Inventory(FlightID,FareClass));
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.SeatHold') AND name='UX_SeatHold_ActiveOrder')
CREATE UNIQUE INDEX UX_SeatHold_ActiveOrder ON dbo.SeatHold(OrderID) WHERE Status='ACTIVE';
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.SeatHold') AND name='IX_SeatHold_Expiry')
CREATE INDEX IX_SeatHold_Expiry ON dbo.SeatHold(Status,ExpiresAt) INCLUDE(FlightID,FareClass,Quantity);
IF OBJECT_ID('dbo.Ticket','U') IS NULL
CREATE TABLE dbo.Ticket(TicketID uniqueidentifier PRIMARY KEY,
 HoldID uniqueidentifier NOT NULL REFERENCES dbo.SeatHold(HoldID),ItemNo int NOT NULL CHECK(ItemNo>0),
 Status varchar(10) NOT NULL CHECK(Status IN ('ISSUED','REFUNDED')),
 IssuedAt datetime2(3) NOT NULL,UNIQUE(HoldID,ItemNo));
IF OBJECT_ID('dbo.Payment','U') IS NULL
CREATE TABLE dbo.Payment(PaymentID uniqueidentifier PRIMARY KEY,
 HoldID uniqueidentifier NOT NULL UNIQUE REFERENCES dbo.SeatHold(HoldID),
 ExternalRef varchar(100) COLLATE Latin1_General_100_BIN2 NOT NULL UNIQUE CHECK(LEN(ExternalRef)>0),
 Amount decimal(18,2) NOT NULL CHECK(Amount>0),Status varchar(10) NOT NULL CHECK(Status='SUCCESS'),
 PaidAt datetime2(3) NOT NULL);
IF OBJECT_ID('dbo.Refund','U') IS NULL
CREATE TABLE dbo.Refund(RefundID uniqueidentifier PRIMARY KEY,
 TicketID uniqueidentifier NOT NULL UNIQUE REFERENCES dbo.Ticket(TicketID),
 ExternalRef varchar(100) COLLATE Latin1_General_100_BIN2 NOT NULL UNIQUE CHECK(LEN(ExternalRef)>0),
 Amount decimal(18,2) NOT NULL CHECK(Amount>0),Status varchar(10) NOT NULL CHECK(Status='SUCCESS'),
 RefundedAt datetime2(3) NOT NULL);
IF OBJECT_ID('dbo.AuditEvent','U') IS NULL
CREATE TABLE dbo.AuditEvent(EventID bigint IDENTITY PRIMARY KEY,EventType varchar(30) NOT NULL,
 EntityID uniqueidentifier NOT NULL,BranchID varchar(3) NULL,
 Actor nvarchar(128) NOT NULL,Message nvarchar(300) NOT NULL,CreatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME());
GO

-- PHẦN 4.1 - Giữ chỗ: UPDATE có điều kiện, RequestID và OrderID khóa riêng [AirCore]
USE [AirCore];
GO
CREATE OR ALTER PROCEDURE dbo.usp_CreateHold
 @RequestID uniqueidentifier,@OrderID uniqueidentifier,@BranchID varchar(3),
 @FlightID varchar(20),@FareClass varchar(3),@Quantity int,
 @HoldID uniqueidentifier OUTPUT,@HoldMinutes int=10
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51001,N'Gọi procedure ngoài transaction của caller.',1;
 IF @RequestID IS NULL OR @OrderID IS NULL OR @BranchID IS NULL OR @FlightID IS NULL OR @FareClass IS NULL
  OR @Quantity IS NULL OR @Quantity NOT BETWEEN 1 AND 500 OR @HoldMinutes IS NULL OR @HoldMinutes NOT BETWEEN 1 AND 10
  THROW 51002,N'Tham số giữ chỗ không hợp lệ.',1;
 SET @HoldID=NULL;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Lock int,@Resource nvarchar(255)=N'hold-request:'+CONVERT(nvarchar(36),@RequestID);
  EXEC @Lock=sys.sp_getapplock @Resource=@Resource,@LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=5000;
  IF @Lock<0 THROW 51003,N'Không lấy được khóa mã yêu cầu.',1;
  SELECT @HoldID=HoldID FROM dbo.SeatHold WHERE RequestID=@RequestID;
  IF @HoldID IS NOT NULL
  BEGIN
   IF NOT EXISTS(SELECT 1 FROM dbo.SeatHold WHERE HoldID=@HoldID AND OrderID=@OrderID
     AND BranchID=@BranchID AND FlightID=@FlightID AND FareClass=@FareClass AND Quantity=@Quantity)
    THROW 51004,N'RequestID đã được dùng với nội dung khác.',1;
   COMMIT; RETURN; -- Trả cùng HoldID; không tự gia hạn thời hạn cũ.
  END;
  SET @Resource=N'hold-order:'+CONVERT(nvarchar(36),@OrderID);
  EXEC @Lock=sys.sp_getapplock @Resource=@Resource,@LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=5000;
  IF @Lock<0 THROW 51003,N'Không lấy được khóa đơn.',1;
  IF NOT EXISTS(SELECT 1 FROM dbo.Branch WHERE BranchID=@BranchID) THROW 51005,N'Chi nhánh không tồn tại.',1;
  IF EXISTS(SELECT 1 FROM dbo.SeatHold WITH(UPDLOCK,HOLDLOCK) WHERE OrderID=@OrderID AND Status IN ('ACTIVE','CONFIRMED'))
    THROW 51006,N'Đơn đã có giữ chỗ đang hoạt động hoặc đã phát hành.',1;
  DECLARE @Now datetime2(3)=SYSUTCDATETIME(),@Price decimal(18,2);
  IF NOT EXISTS(SELECT 1 FROM dbo.Flight WITH(HOLDLOCK) WHERE FlightID=@FlightID AND Status='OPEN' AND DepartureUtc>@Now)
    THROW 51007,N'Chuyến bay không mở bán hoặc đã khởi hành.',1;
  SELECT @Price=Price FROM dbo.Fare WITH(HOLDLOCK) WHERE FlightID=@FlightID AND FareClass=@FareClass;
  IF @Price IS NULL THROW 51008,N'Không có giá cho hạng được yêu cầu.',1;
  UPDATE dbo.Inventory SET Held=Held+@Quantity,UpdatedAt=@Now
  WHERE FlightID=@FlightID AND FareClass=@FareClass AND Capacity-Held-Sold>=@Quantity;
  IF @@ROWCOUNT<>1 THROW 51009,N'Không đủ ghế để giữ chỗ.',1;
  SET @HoldID=NEWID();
  INSERT dbo.SeatHold(HoldID,RequestID,OrderID,BranchID,FlightID,FareClass,Quantity,UnitPrice,Status,CreatedAt,ExpiresAt)
  VALUES(@HoldID,@RequestID,@OrderID,@BranchID,@FlightID,@FareClass,@Quantity,@Price,'ACTIVE',@Now,DATEADD(minute,@HoldMinutes,@Now));
  INSERT dbo.AuditEvent(EventType,EntityID,BranchID,Actor,Message)
  VALUES('CREATE_HOLD',@HoldID,@BranchID,ORIGINAL_LOGIN(),N'Tạo giữ chỗ thành công.');
  COMMIT;
 END TRY
 BEGIN CATCH
  IF XACT_STATE()<>0 ROLLBACK;
  SET @HoldID=NULL; THROW;
 END CATCH;
END;
GO

-- Tra lại kết quả sau timeout bằng chính RequestID cũ [AirCore]
USE [AirCore];
GO
CREATE OR ALTER PROCEDURE dbo.usp_GetHoldByRequest @RequestID uniqueidentifier,@BranchID varchar(3)
AS
BEGIN
 SET NOCOUNT ON;
 SELECT h.*,p.PaymentID,p.ExternalRef,p.Amount,p.PaidAt
 FROM dbo.SeatHold h LEFT JOIN dbo.Payment p ON p.HoldID=h.HoldID
 WHERE h.RequestID=@RequestID AND h.BranchID=@BranchID;
 SELECT t.TicketID,t.HoldID,t.ItemNo,t.Status,t.IssuedAt
 FROM dbo.Ticket t JOIN dbo.SeatHold h ON h.HoldID=t.HoldID
 WHERE h.RequestID=@RequestID AND h.BranchID=@BranchID ORDER BY t.ItemNo;
END;
GO

-- PHẦN 4.2 - Xác nhận tiền đã kiểm chứng và phát hành q vé trong một transaction [AirCore]
USE [AirCore];
GO
CREATE OR ALTER PROCEDURE dbo.usp_ConfirmHold
 @HoldID uniqueidentifier,@BranchID varchar(3),@ExternalRef varchar(100),
 @Amount decimal(18,2),@PaymentID uniqueidentifier OUTPUT
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51001,N'Gọi procedure ngoài transaction của caller.',1;
 SET @ExternalRef=LTRIM(RTRIM(@ExternalRef));
 IF @HoldID IS NULL OR @BranchID IS NULL OR @ExternalRef IS NULL OR LEN(@ExternalRef)=0 OR @Amount IS NULL OR @Amount<=0
  THROW 51010,N'Tham số thanh toán không hợp lệ.',1;
 SET @PaymentID=NULL;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Lock int,@Resource nvarchar(255)=N'payment-ref:'+@ExternalRef;
  EXEC @Lock=sys.sp_getapplock @Resource=@Resource,@LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=5000;
  IF @Lock<0 THROW 51003,N'Không lấy được khóa thanh toán.',1;
  DECLARE @Status varchar(10),@Expiry datetime2(3),@Flight varchar(20),@Class varchar(3),@Q int,@Price decimal(18,2);
  SELECT @Status=Status,@Expiry=ExpiresAt,@Flight=FlightID,@Class=FareClass,@Q=Quantity,@Price=UnitPrice
  FROM dbo.SeatHold WITH(UPDLOCK,HOLDLOCK) WHERE HoldID=@HoldID AND BranchID=@BranchID;
  IF @Status IS NULL THROW 51011,N'Giữ chỗ không tồn tại hoặc sai chi nhánh.',1;
  SELECT @PaymentID=PaymentID FROM dbo.Payment WHERE ExternalRef=@ExternalRef;
  IF @PaymentID IS NOT NULL
  BEGIN
   IF NOT EXISTS(SELECT 1 FROM dbo.Payment WHERE PaymentID=@PaymentID AND HoldID=@HoldID AND Amount=@Amount)
    THROW 51012,N'Mã thanh toán đã được dùng với nội dung khác.',1;
   COMMIT; RETURN;
  END;
  IF EXISTS(SELECT 1 FROM dbo.Payment WHERE HoldID=@HoldID)
    THROW 51013,N'Giữ chỗ đã được thanh toán bằng mã giao dịch khác.',1;
  DECLARE @Now datetime2(3)=SYSUTCDATETIME();
  IF @Status<>'ACTIVE' OR @Expiry<=@Now THROW 51014,N'Giữ chỗ không còn hiệu lực; phải đối soát tiền đã nhận.',1;
  IF NOT EXISTS(SELECT 1 FROM dbo.Flight WITH(HOLDLOCK) WHERE FlightID=@Flight AND Status='OPEN' AND DepartureUtc>@Now)
    THROW 51007,N'Chuyến bay không thể phát hành thêm vé.',1;
  IF @Amount<>CONVERT(decimal(18,2),@Q*@Price) THROW 51015,N'Số tiền không khớp giá đã chốt.',1;
  UPDATE dbo.Inventory SET Held=Held-@Q,Sold=Sold+@Q,UpdatedAt=@Now
  WHERE FlightID=@Flight AND FareClass=@Class AND Held>=@Q;
  IF @@ROWCOUNT<>1 THROW 51016,N'Kho ghế sai lệch; cần đối soát.',1;
  UPDATE dbo.SeatHold SET Status='CONFIRMED' WHERE HoldID=@HoldID;
  SET @PaymentID=NEWID();
  INSERT dbo.Payment VALUES(@PaymentID,@HoldID,@ExternalRef,@Amount,'SUCCESS',@Now);
  DECLARE @Item int=1;
  WHILE @Item<=@Q
  BEGIN
   INSERT dbo.Ticket VALUES(NEWID(),@HoldID,@Item,'ISSUED',@Now);
   SET @Item+=1;
  END;
  INSERT dbo.AuditEvent(EventType,EntityID,BranchID,Actor,Message)
  VALUES('CONFIRM_HOLD',@HoldID,@BranchID,ORIGINAL_LOGIN(),N'Xác nhận thanh toán mô phỏng và phát hành vé.');
  COMMIT;
 END TRY
 BEGIN CATCH
  IF XACT_STATE()<>0 ROLLBACK;
  SET @PaymentID=NULL; THROW;
 END CATCH;
END;
GO

-- PHẦN 4.3 - Hủy/hết hạn khóa SeatHold trước Inventory, cùng thứ tự với xác nhận [AirCore]
USE [AirCore];
GO
CREATE OR ALTER PROCEDURE dbo.usp_ReleaseHold
 @HoldID uniqueidentifier,@BranchID varchar(3),@TargetStatus varchar(10),@Changed bit OUTPUT
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON; SET @Changed=0;
 IF @@TRANCOUNT<>0 THROW 51001,N'Gọi procedure ngoài transaction của caller.',1;
 IF @HoldID IS NULL OR @BranchID IS NULL OR @TargetStatus IS NULL OR @TargetStatus NOT IN ('EXPIRED','CANCELLED')
  THROW 51020,N'Tham số giải phóng giữ chỗ không hợp lệ.',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Status varchar(10),@Expiry datetime2(3),@Flight varchar(20),@Class varchar(3),@Q int;
  SELECT @Status=Status,@Expiry=ExpiresAt,@Flight=FlightID,@Class=FareClass,@Q=Quantity
  FROM dbo.SeatHold WITH(UPDLOCK,HOLDLOCK) WHERE HoldID=@HoldID AND BranchID=@BranchID;
  IF @Status IS NULL THROW 51011,N'Giữ chỗ không tồn tại hoặc sai chi nhánh.',1;
  IF @Status<>'ACTIVE'
  BEGIN
   IF @TargetStatus='CANCELLED' AND @Status='CONFIRMED' THROW 51021,N'Vé đã phát hành; dùng quy trình hoàn vé.',1;
   COMMIT; RETURN;
  END;
  DECLARE @Now datetime2(3)=SYSUTCDATETIME();
  IF @TargetStatus='EXPIRED' AND @Expiry>@Now BEGIN COMMIT; RETURN; END;
  UPDATE dbo.Inventory SET Held=Held-@Q,UpdatedAt=@Now
  WHERE FlightID=@Flight AND FareClass=@Class AND Held>=@Q;
  IF @@ROWCOUNT<>1 THROW 51016,N'Kho ghế sai lệch; cần đối soát.',1;
  UPDATE dbo.SeatHold SET Status=@TargetStatus WHERE HoldID=@HoldID;
  INSERT dbo.AuditEvent(EventType,EntityID,BranchID,Actor,Message)
  VALUES(@TargetStatus,@HoldID,@BranchID,ORIGINAL_LOGIN(),N'Giải phóng ghế đang giữ.');
  COMMIT; SET @Changed=1;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;
GO

-- API hủy giữ chưa phát hành [AirCore]
USE [AirCore];
GO
CREATE OR ALTER PROCEDURE dbo.usp_CancelHold @HoldID uniqueidentifier,@BranchID varchar(3)
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @Changed bit;
 EXEC dbo.usp_ReleaseHold @HoldID,@BranchID,'CANCELLED',@Changed OUTPUT;
END;
GO

-- Job hoặc caller chạy định kỳ; từng giữ được kiểm tra lại trong transaction ngắn [AirCore]
USE [AirCore];
GO
CREATE OR ALTER PROCEDURE dbo.usp_ExpireHolds @BatchSize int=100
AS
BEGIN
 SET NOCOUNT ON;
 IF @BatchSize IS NULL OR @BatchSize NOT BETWEEN 1 AND 1000 THROW 51022,N'BatchSize không hợp lệ.',1;
 DECLARE @Hold uniqueidentifier,@Branch varchar(3),@Changed bit,@Count int=0;
 DECLARE c CURSOR LOCAL STATIC READ_ONLY FOR
 SELECT TOP(@BatchSize) HoldID,BranchID FROM dbo.SeatHold
 WHERE Status='ACTIVE' AND ExpiresAt<=SYSUTCDATETIME() ORDER BY ExpiresAt;
 OPEN c; FETCH NEXT FROM c INTO @Hold,@Branch;
 BEGIN TRY
  WHILE @@FETCH_STATUS=0
  BEGIN
   EXEC dbo.usp_ReleaseHold @Hold,@Branch,'EXPIRED',@Changed OUTPUT;
   SET @Count+=CONVERT(int,@Changed);
   FETCH NEXT FROM c INTO @Hold,@Branch;
  END;
  CLOSE c; DEALLOCATE c;
 END TRY
 BEGIN CATCH CLOSE c; DEALLOCATE c; THROW; END CATCH;
 SELECT @Count AS ExpiredHoldCount;
END;
GO

-- PHẦN 4.4 - Hoàn vé một lần, số tiền lấy từ đơn giá đã chốt [AirCore]
USE [AirCore];
GO
CREATE OR ALTER PROCEDURE dbo.usp_RefundTicket
 @TicketID uniqueidentifier,@BranchID varchar(3),@ExternalRef varchar(100),@RefundID uniqueidentifier OUTPUT
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON; SET @RefundID=NULL;
 IF @@TRANCOUNT<>0 THROW 51001,N'Gọi procedure ngoài transaction của caller.',1;
 SET @ExternalRef=LTRIM(RTRIM(@ExternalRef));
 IF @TicketID IS NULL OR @BranchID IS NULL OR @ExternalRef IS NULL OR LEN(@ExternalRef)=0
  THROW 51030,N'Tham số hoàn vé không hợp lệ.',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Lock int,@Resource nvarchar(255)=N'refund-ref:'+@ExternalRef;
  EXEC @Lock=sys.sp_getapplock @Resource=@Resource,@LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=5000;
  IF @Lock<0 THROW 51003,N'Không lấy được khóa hoàn tiền.',1;
  DECLARE @Status varchar(10),@Flight varchar(20),@Class varchar(3),@Price decimal(18,2);
  SELECT @Status=t.Status,@Flight=h.FlightID,@Class=h.FareClass,@Price=h.UnitPrice
  FROM dbo.Ticket t WITH(UPDLOCK,HOLDLOCK) JOIN dbo.SeatHold h ON h.HoldID=t.HoldID
  WHERE t.TicketID=@TicketID AND h.BranchID=@BranchID;
  IF @Status IS NULL THROW 51031,N'Vé không tồn tại hoặc sai chi nhánh.',1;
  SELECT @RefundID=RefundID FROM dbo.Refund WHERE ExternalRef=@ExternalRef;
  IF @RefundID IS NOT NULL
  BEGIN
   IF NOT EXISTS(SELECT 1 FROM dbo.Refund WHERE RefundID=@RefundID AND TicketID=@TicketID)
    THROW 51032,N'Mã hoàn đã được dùng cho vé khác.',1;
   COMMIT; RETURN;
  END;
  IF @Status<>'ISSUED' THROW 51033,N'Vé đã hoàn hoặc không thể hoàn.',1;
  DECLARE @Now datetime2(3)=SYSUTCDATETIME();
  IF NOT EXISTS(SELECT 1 FROM dbo.Flight WITH(HOLDLOCK) WHERE FlightID=@Flight AND Status='OPEN' AND DepartureUtc>@Now)
    THROW 51034,N'Chỉ mô phỏng hoàn trước khởi hành, khi chuyến còn OPEN.',1;
  UPDATE dbo.Inventory SET Sold=Sold-1,UpdatedAt=@Now
  WHERE FlightID=@Flight AND FareClass=@Class AND Sold>=1;
  IF @@ROWCOUNT<>1 THROW 51016,N'Kho ghế sai lệch; cần đối soát.',1;
  SET @RefundID=NEWID();
  INSERT dbo.Refund VALUES(@RefundID,@TicketID,@ExternalRef,@Price,'SUCCESS',@Now);
  UPDATE dbo.Ticket SET Status='REFUNDED' WHERE TicketID=@TicketID;
  INSERT dbo.AuditEvent(EventType,EntityID,BranchID,Actor,Message)
  VALUES('REFUND_TICKET',@TicketID,@BranchID,ORIGINAL_LOGIN(),N'Hoàn toàn bộ đơn giá và giải phóng một ghế.');
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; SET @RefundID=NULL; THROW; END CATCH;
END;
GO

-- Tra cứu kho ghế nguồn; không dùng bản sao để quyết định cấp ghế [AirCore]
USE [AirCore];
GO
CREATE OR ALTER VIEW dbo.vFlightAvailability AS
SELECT f.FlightID,f.FlightNo,r.OriginCode,r.DestCode,f.DepartureUtc,f.ArrivalUtc,f.Status,
 i.FareClass,i.Capacity,i.Held,i.Sold,i.Capacity-i.Held-i.Sold AS Available,fa.Price,fa.Currency
FROM dbo.Flight f JOIN dbo.Route r ON r.RouteID=f.RouteID
JOIN dbo.Inventory i ON i.FlightID=f.FlightID
JOIN dbo.Fare fa ON fa.FlightID=i.FlightID AND fa.FareClass=i.FareClass;
GO

-- PHẦN 4.5 - Đối soát Held, Sold, số vé và số tiền [AirCore]
USE [AirCore];
GO
CREATE OR ALTER PROCEDURE dbo.usp_CheckInvariants
AS
BEGIN
 SET NOCOUNT ON;
 IF @@TRANCOUNT<>0 THROW 51001,N'Gọi ngoài transaction của caller.',1;
 -- Snapshot đọc ổn định bằng khóa; chỉ chạy đối soát trong cửa sổ kiểm tra.
 -- READ COMMITTED từng câu có thể thấy hai thời điểm khác nhau khi đang ghi.
 SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
 BEGIN TRY
  BEGIN TRAN;
  SELECT i.FlightID,i.FareClass,i.Held,COALESCE(h.Q,0) AS ActiveQty
  FROM dbo.Inventory i LEFT JOIN
   (SELECT FlightID,FareClass,SUM(Quantity) Q FROM dbo.SeatHold WHERE Status='ACTIVE' GROUP BY FlightID,FareClass) h
   ON h.FlightID=i.FlightID AND h.FareClass=i.FareClass WHERE i.Held<>COALESCE(h.Q,0);
  SELECT i.FlightID,i.FareClass,i.Sold,COALESCE(t.Q,0) AS IssuedQty
  FROM dbo.Inventory i LEFT JOIN
   (SELECT h.FlightID,h.FareClass,COUNT(*) Q FROM dbo.Ticket t JOIN dbo.SeatHold h ON h.HoldID=t.HoldID
    WHERE t.Status='ISSUED' GROUP BY h.FlightID,h.FareClass) t
   ON t.FlightID=i.FlightID AND t.FareClass=i.FareClass WHERE i.Sold<>COALESCE(t.Q,0);
  SELECT h.HoldID,h.Quantity,COUNT(t.TicketID) AS TicketCount
  FROM dbo.SeatHold h LEFT JOIN dbo.Ticket t ON t.HoldID=h.HoldID
  WHERE h.Status='CONFIRMED' GROUP BY h.HoldID,h.Quantity HAVING COUNT(t.TicketID)<>h.Quantity;
  SELECT p.PaymentID,p.Amount,h.Quantity*h.UnitPrice AS ExpectedAmount
  FROM dbo.Payment p JOIN dbo.SeatHold h ON h.HoldID=p.HoldID WHERE p.Amount<>h.Quantity*h.UnitPrice OR h.Status<>'CONFIRMED';
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
 -- Các result set phải rỗng; vé REFUNDED vẫn được đếm khi so số vé đã phát hành.
END;
GO

-- PHẦN 5.1 - Mảnh ngang theo chi nhánh và mảnh dẫn xuất SalesItem [AirBranch_HN]
USE [AirBranch_HN];
GO
IF OBJECT_ID('dbo.LocalBranch','U') IS NULL
CREATE TABLE dbo.LocalBranch(BranchID varchar(3) PRIMARY KEY CHECK(BranchID='HN'),BranchName nvarchar(100) NOT NULL);
IF OBJECT_ID('dbo.CustomerProfile','U') IS NULL
CREATE TABLE dbo.CustomerProfile(CustomerID uniqueidentifier PRIMARY KEY,
 BranchID varchar(3) NOT NULL REFERENCES dbo.LocalBranch(BranchID),FullName nvarchar(100) NOT NULL,
 BirthDate date NULL,Phone varchar(30) NULL,Email nvarchar(150) NULL,DocumentNo nvarchar(30) NULL,
 Version rowversion);
IF OBJECT_ID('dbo.Employee','U') IS NULL
CREATE TABLE dbo.Employee(EmployeeID varchar(20) PRIMARY KEY,
 BranchID varchar(3) NOT NULL REFERENCES dbo.LocalBranch(BranchID),FullName nvarchar(100) NOT NULL,
 Position nvarchar(50) NOT NULL,IsActive bit NOT NULL DEFAULT 1);
IF OBJECT_ID('dbo.SalesOrder','U') IS NULL
CREATE TABLE dbo.SalesOrder(OrderID uniqueidentifier PRIMARY KEY,
 BranchID varchar(3) NOT NULL REFERENCES dbo.LocalBranch(BranchID) CHECK(BranchID='HN'),
 CustomerID uniqueidentifier NOT NULL REFERENCES dbo.CustomerProfile(CustomerID),
 EmployeeID varchar(20) NOT NULL REFERENCES dbo.Employee(EmployeeID),
 FlightID varchar(20) NOT NULL,FareClass varchar(3) NOT NULL CHECK(FareClass IN ('ECO','BUS')),
 Quantity int NOT NULL CHECK(Quantity BETWEEN 1 AND 500),RequestID uniqueidentifier NOT NULL UNIQUE,
 HoldID uniqueidentifier NULL,PaymentID uniqueidentifier NULL,
 Status varchar(20) NOT NULL CHECK(Status IN ('DRAFT','HELD','ISSUED','CANCELLED','PENDING_RECONCILE')),
 CreatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
 ExpiresAt datetime2(3) NULL,LastError nvarchar(300) NULL,LastCheckedAt datetime2(3) NULL);
IF OBJECT_ID('dbo.SalesItem','U') IS NULL
CREATE TABLE dbo.SalesItem(OrderID uniqueidentifier NOT NULL REFERENCES dbo.SalesOrder(OrderID),
 ItemNo int NOT NULL CHECK(ItemNo>0),PassengerName nvarchar(100) NOT NULL,
 PassengerDocument nvarchar(30) NULL,UnitPrice decimal(18,2) NULL CHECK(UnitPrice>0),
 TicketID uniqueidentifier NULL,PRIMARY KEY(OrderID,ItemNo));
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.SalesItem') AND name='UX_SalesItem_Ticket')
CREATE UNIQUE INDEX UX_SalesItem_Ticket ON dbo.SalesItem(TicketID) WHERE TicketID IS NOT NULL;
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.SalesOrder') AND name='IX_SalesOrder_Branch_Date')
CREATE INDEX IX_SalesOrder_Branch_Date ON dbo.SalesOrder(BranchID,CreatedAt) INCLUDE(Status,HoldID);
IF OBJECT_ID('dbo.BranchEvent','U') IS NULL
CREATE TABLE dbo.BranchEvent(EventID bigint IDENTITY PRIMARY KEY,OrderID uniqueidentifier NOT NULL,
 EventType varchar(30) NOT NULL,Actor nvarchar(128) NOT NULL,CreatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME());
IF TYPE_ID('dbo.PassengerList') IS NULL
EXEC(N'CREATE TYPE dbo.PassengerList AS TABLE(ItemNo int PRIMARY KEY,PassengerName nvarchar(100) NOT NULL,PassengerDocument nvarchar(30) NULL);');
IF TYPE_ID('dbo.TicketList') IS NULL
EXEC(N'CREATE TYPE dbo.TicketList AS TABLE(ItemNo int PRIMARY KEY,TicketID uniqueidentifier NOT NULL UNIQUE);');
GO

-- PHẦN 5.1 - Mảnh ngang theo chi nhánh và mảnh dẫn xuất SalesItem [AirBranch_DN]
USE [AirBranch_DN];
GO
IF OBJECT_ID('dbo.LocalBranch','U') IS NULL
CREATE TABLE dbo.LocalBranch(BranchID varchar(3) PRIMARY KEY CHECK(BranchID='DN'),BranchName nvarchar(100) NOT NULL);
IF OBJECT_ID('dbo.CustomerProfile','U') IS NULL
CREATE TABLE dbo.CustomerProfile(CustomerID uniqueidentifier PRIMARY KEY,
 BranchID varchar(3) NOT NULL REFERENCES dbo.LocalBranch(BranchID),FullName nvarchar(100) NOT NULL,
 BirthDate date NULL,Phone varchar(30) NULL,Email nvarchar(150) NULL,DocumentNo nvarchar(30) NULL,
 Version rowversion);
IF OBJECT_ID('dbo.Employee','U') IS NULL
CREATE TABLE dbo.Employee(EmployeeID varchar(20) PRIMARY KEY,
 BranchID varchar(3) NOT NULL REFERENCES dbo.LocalBranch(BranchID),FullName nvarchar(100) NOT NULL,
 Position nvarchar(50) NOT NULL,IsActive bit NOT NULL DEFAULT 1);
IF OBJECT_ID('dbo.SalesOrder','U') IS NULL
CREATE TABLE dbo.SalesOrder(OrderID uniqueidentifier PRIMARY KEY,
 BranchID varchar(3) NOT NULL REFERENCES dbo.LocalBranch(BranchID) CHECK(BranchID='DN'),
 CustomerID uniqueidentifier NOT NULL REFERENCES dbo.CustomerProfile(CustomerID),
 EmployeeID varchar(20) NOT NULL REFERENCES dbo.Employee(EmployeeID),
 FlightID varchar(20) NOT NULL,FareClass varchar(3) NOT NULL CHECK(FareClass IN ('ECO','BUS')),
 Quantity int NOT NULL CHECK(Quantity BETWEEN 1 AND 500),RequestID uniqueidentifier NOT NULL UNIQUE,
 HoldID uniqueidentifier NULL,PaymentID uniqueidentifier NULL,
 Status varchar(20) NOT NULL CHECK(Status IN ('DRAFT','HELD','ISSUED','CANCELLED','PENDING_RECONCILE')),
 CreatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
 ExpiresAt datetime2(3) NULL,LastError nvarchar(300) NULL,LastCheckedAt datetime2(3) NULL);
IF OBJECT_ID('dbo.SalesItem','U') IS NULL
CREATE TABLE dbo.SalesItem(OrderID uniqueidentifier NOT NULL REFERENCES dbo.SalesOrder(OrderID),
 ItemNo int NOT NULL CHECK(ItemNo>0),PassengerName nvarchar(100) NOT NULL,
 PassengerDocument nvarchar(30) NULL,UnitPrice decimal(18,2) NULL CHECK(UnitPrice>0),
 TicketID uniqueidentifier NULL,PRIMARY KEY(OrderID,ItemNo));
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.SalesItem') AND name='UX_SalesItem_Ticket')
CREATE UNIQUE INDEX UX_SalesItem_Ticket ON dbo.SalesItem(TicketID) WHERE TicketID IS NOT NULL;
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.SalesOrder') AND name='IX_SalesOrder_Branch_Date')
CREATE INDEX IX_SalesOrder_Branch_Date ON dbo.SalesOrder(BranchID,CreatedAt) INCLUDE(Status,HoldID);
IF OBJECT_ID('dbo.BranchEvent','U') IS NULL
CREATE TABLE dbo.BranchEvent(EventID bigint IDENTITY PRIMARY KEY,OrderID uniqueidentifier NOT NULL,
 EventType varchar(30) NOT NULL,Actor nvarchar(128) NOT NULL,CreatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME());
IF TYPE_ID('dbo.PassengerList') IS NULL
EXEC(N'CREATE TYPE dbo.PassengerList AS TABLE(ItemNo int PRIMARY KEY,PassengerName nvarchar(100) NOT NULL,PassengerDocument nvarchar(30) NULL);');
IF TYPE_ID('dbo.TicketList') IS NULL
EXEC(N'CREATE TYPE dbo.TicketList AS TABLE(ItemNo int PRIMARY KEY,TicketID uniqueidentifier NOT NULL UNIQUE);');
GO

-- PHẦN 5.1 - Mảnh ngang theo chi nhánh và mảnh dẫn xuất SalesItem [AirBranch_HCM]
USE [AirBranch_HCM];
GO
IF OBJECT_ID('dbo.LocalBranch','U') IS NULL
CREATE TABLE dbo.LocalBranch(BranchID varchar(3) PRIMARY KEY CHECK(BranchID='HCM'),BranchName nvarchar(100) NOT NULL);
IF OBJECT_ID('dbo.CustomerProfile','U') IS NULL
CREATE TABLE dbo.CustomerProfile(CustomerID uniqueidentifier PRIMARY KEY,
 BranchID varchar(3) NOT NULL REFERENCES dbo.LocalBranch(BranchID),FullName nvarchar(100) NOT NULL,
 BirthDate date NULL,Phone varchar(30) NULL,Email nvarchar(150) NULL,DocumentNo nvarchar(30) NULL,
 Version rowversion);
IF OBJECT_ID('dbo.Employee','U') IS NULL
CREATE TABLE dbo.Employee(EmployeeID varchar(20) PRIMARY KEY,
 BranchID varchar(3) NOT NULL REFERENCES dbo.LocalBranch(BranchID),FullName nvarchar(100) NOT NULL,
 Position nvarchar(50) NOT NULL,IsActive bit NOT NULL DEFAULT 1);
IF OBJECT_ID('dbo.SalesOrder','U') IS NULL
CREATE TABLE dbo.SalesOrder(OrderID uniqueidentifier PRIMARY KEY,
 BranchID varchar(3) NOT NULL REFERENCES dbo.LocalBranch(BranchID) CHECK(BranchID='HCM'),
 CustomerID uniqueidentifier NOT NULL REFERENCES dbo.CustomerProfile(CustomerID),
 EmployeeID varchar(20) NOT NULL REFERENCES dbo.Employee(EmployeeID),
 FlightID varchar(20) NOT NULL,FareClass varchar(3) NOT NULL CHECK(FareClass IN ('ECO','BUS')),
 Quantity int NOT NULL CHECK(Quantity BETWEEN 1 AND 500),RequestID uniqueidentifier NOT NULL UNIQUE,
 HoldID uniqueidentifier NULL,PaymentID uniqueidentifier NULL,
 Status varchar(20) NOT NULL CHECK(Status IN ('DRAFT','HELD','ISSUED','CANCELLED','PENDING_RECONCILE')),
 CreatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
 ExpiresAt datetime2(3) NULL,LastError nvarchar(300) NULL,LastCheckedAt datetime2(3) NULL);
IF OBJECT_ID('dbo.SalesItem','U') IS NULL
CREATE TABLE dbo.SalesItem(OrderID uniqueidentifier NOT NULL REFERENCES dbo.SalesOrder(OrderID),
 ItemNo int NOT NULL CHECK(ItemNo>0),PassengerName nvarchar(100) NOT NULL,
 PassengerDocument nvarchar(30) NULL,UnitPrice decimal(18,2) NULL CHECK(UnitPrice>0),
 TicketID uniqueidentifier NULL,PRIMARY KEY(OrderID,ItemNo));
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.SalesItem') AND name='UX_SalesItem_Ticket')
CREATE UNIQUE INDEX UX_SalesItem_Ticket ON dbo.SalesItem(TicketID) WHERE TicketID IS NOT NULL;
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.SalesOrder') AND name='IX_SalesOrder_Branch_Date')
CREATE INDEX IX_SalesOrder_Branch_Date ON dbo.SalesOrder(BranchID,CreatedAt) INCLUDE(Status,HoldID);
IF OBJECT_ID('dbo.BranchEvent','U') IS NULL
CREATE TABLE dbo.BranchEvent(EventID bigint IDENTITY PRIMARY KEY,OrderID uniqueidentifier NOT NULL,
 EventType varchar(30) NOT NULL,Actor nvarchar(128) NOT NULL,CreatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME());
IF TYPE_ID('dbo.PassengerList') IS NULL
EXEC(N'CREATE TYPE dbo.PassengerList AS TABLE(ItemNo int PRIMARY KEY,PassengerName nvarchar(100) NOT NULL,PassengerDocument nvarchar(30) NULL);');
IF TYPE_ID('dbo.TicketList') IS NULL
EXEC(N'CREATE TYPE dbo.TicketList AS TABLE(ItemNo int PRIMARY KEY,TicketID uniqueidentifier NOT NULL UNIQUE);');
GO

-- PHẦN 5.2 - Tạo đơn và q hành khách atomically tại chi nhánh [AirBranch_HN]
USE [AirBranch_HN];
GO
CREATE OR ALTER PROCEDURE dbo.usp_CreateOrder
 @OrderID uniqueidentifier,@RequestID uniqueidentifier,@CustomerID uniqueidentifier,
 @EmployeeID varchar(20),@FlightID varchar(20),@FareClass varchar(3),@Passengers dbo.PassengerList READONLY
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51100,N'Gọi procedure ngoài transaction của caller.',1;
 DECLARE @Q int=(SELECT COUNT(*) FROM @Passengers),@Branch varchar(3)=(SELECT BranchID FROM dbo.LocalBranch);
 IF @OrderID IS NULL OR @RequestID IS NULL OR @CustomerID IS NULL OR @EmployeeID IS NULL
  OR @FlightID IS NULL OR @FareClass IS NULL OR @FareClass NOT IN ('ECO','BUS') OR @Q NOT BETWEEN 1 AND 500
  OR EXISTS(SELECT 1 FROM @Passengers WHERE ItemNo<=0 OR LEN(LTRIM(RTRIM(PassengerName)))=0)
  OR (SELECT MIN(ItemNo) FROM @Passengers)<>1 OR (SELECT MAX(ItemNo) FROM @Passengers)<>@Q
  THROW 51101,N'Danh sách hành khách hoặc tham số đơn không hợp lệ.',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Lock int,@Resource nvarchar(255)=N'order:'+CONVERT(nvarchar(36),@OrderID);
  EXEC @Lock=sys.sp_getapplock @Resource=@Resource,@LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=5000;
  IF @Lock<0 THROW 51102,N'Không lấy được khóa đơn.',1;
  IF EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID=@OrderID)
  BEGIN
   IF NOT EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID=@OrderID AND RequestID=@RequestID
    AND CustomerID=@CustomerID AND EmployeeID=@EmployeeID AND FlightID=@FlightID AND FareClass=@FareClass AND Quantity=@Q)
    OR EXISTS(SELECT ItemNo,PassengerName,PassengerDocument FROM @Passengers EXCEPT
       SELECT ItemNo,PassengerName,PassengerDocument FROM dbo.SalesItem WHERE OrderID=@OrderID)
    OR EXISTS(SELECT ItemNo,PassengerName,PassengerDocument FROM dbo.SalesItem WHERE OrderID=@OrderID EXCEPT
       SELECT ItemNo,PassengerName,PassengerDocument FROM @Passengers)
     THROW 51103,N'OrderID đã dùng cho nội dung khác.',1;
   COMMIT; RETURN;
  END;
  IF NOT EXISTS(SELECT 1 FROM dbo.Employee WHERE EmployeeID=@EmployeeID AND BranchID=@Branch AND IsActive=1)
    THROW 51104,N'Nhân viên không hợp lệ.',1;
  IF NOT EXISTS(SELECT 1 FROM dbo.CustomerProfile WHERE CustomerID=@CustomerID AND BranchID=@Branch)
    THROW 51105,N'Khách hàng không thuộc chi nhánh.',1;
  INSERT dbo.SalesOrder(OrderID,BranchID,CustomerID,EmployeeID,FlightID,FareClass,Quantity,RequestID,Status)
  VALUES(@OrderID,@Branch,@CustomerID,@EmployeeID,@FlightID,@FareClass,@Q,@RequestID,'DRAFT');
  INSERT dbo.SalesItem(OrderID,ItemNo,PassengerName,PassengerDocument)
  SELECT @OrderID,ItemNo,PassengerName,PassengerDocument FROM @Passengers;
  INSERT dbo.BranchEvent(OrderID,EventType,Actor) VALUES(@OrderID,'CREATE_ORDER',ORIGINAL_LOGIN());
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;
GO

-- PHẦN 5.2 - Tạo đơn và q hành khách atomically tại chi nhánh [AirBranch_DN]
USE [AirBranch_DN];
GO
CREATE OR ALTER PROCEDURE dbo.usp_CreateOrder
 @OrderID uniqueidentifier,@RequestID uniqueidentifier,@CustomerID uniqueidentifier,
 @EmployeeID varchar(20),@FlightID varchar(20),@FareClass varchar(3),@Passengers dbo.PassengerList READONLY
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51100,N'Gọi procedure ngoài transaction của caller.',1;
 DECLARE @Q int=(SELECT COUNT(*) FROM @Passengers),@Branch varchar(3)=(SELECT BranchID FROM dbo.LocalBranch);
 IF @OrderID IS NULL OR @RequestID IS NULL OR @CustomerID IS NULL OR @EmployeeID IS NULL
  OR @FlightID IS NULL OR @FareClass IS NULL OR @FareClass NOT IN ('ECO','BUS') OR @Q NOT BETWEEN 1 AND 500
  OR EXISTS(SELECT 1 FROM @Passengers WHERE ItemNo<=0 OR LEN(LTRIM(RTRIM(PassengerName)))=0)
  OR (SELECT MIN(ItemNo) FROM @Passengers)<>1 OR (SELECT MAX(ItemNo) FROM @Passengers)<>@Q
  THROW 51101,N'Danh sách hành khách hoặc tham số đơn không hợp lệ.',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Lock int,@Resource nvarchar(255)=N'order:'+CONVERT(nvarchar(36),@OrderID);
  EXEC @Lock=sys.sp_getapplock @Resource=@Resource,@LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=5000;
  IF @Lock<0 THROW 51102,N'Không lấy được khóa đơn.',1;
  IF EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID=@OrderID)
  BEGIN
   IF NOT EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID=@OrderID AND RequestID=@RequestID
    AND CustomerID=@CustomerID AND EmployeeID=@EmployeeID AND FlightID=@FlightID AND FareClass=@FareClass AND Quantity=@Q)
    OR EXISTS(SELECT ItemNo,PassengerName,PassengerDocument FROM @Passengers EXCEPT
       SELECT ItemNo,PassengerName,PassengerDocument FROM dbo.SalesItem WHERE OrderID=@OrderID)
    OR EXISTS(SELECT ItemNo,PassengerName,PassengerDocument FROM dbo.SalesItem WHERE OrderID=@OrderID EXCEPT
       SELECT ItemNo,PassengerName,PassengerDocument FROM @Passengers)
     THROW 51103,N'OrderID đã dùng cho nội dung khác.',1;
   COMMIT; RETURN;
  END;
  IF NOT EXISTS(SELECT 1 FROM dbo.Employee WHERE EmployeeID=@EmployeeID AND BranchID=@Branch AND IsActive=1)
    THROW 51104,N'Nhân viên không hợp lệ.',1;
  IF NOT EXISTS(SELECT 1 FROM dbo.CustomerProfile WHERE CustomerID=@CustomerID AND BranchID=@Branch)
    THROW 51105,N'Khách hàng không thuộc chi nhánh.',1;
  INSERT dbo.SalesOrder(OrderID,BranchID,CustomerID,EmployeeID,FlightID,FareClass,Quantity,RequestID,Status)
  VALUES(@OrderID,@Branch,@CustomerID,@EmployeeID,@FlightID,@FareClass,@Q,@RequestID,'DRAFT');
  INSERT dbo.SalesItem(OrderID,ItemNo,PassengerName,PassengerDocument)
  SELECT @OrderID,ItemNo,PassengerName,PassengerDocument FROM @Passengers;
  INSERT dbo.BranchEvent(OrderID,EventType,Actor) VALUES(@OrderID,'CREATE_ORDER',ORIGINAL_LOGIN());
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;
GO

-- PHẦN 5.2 - Tạo đơn và q hành khách atomically tại chi nhánh [AirBranch_HCM]
USE [AirBranch_HCM];
GO
CREATE OR ALTER PROCEDURE dbo.usp_CreateOrder
 @OrderID uniqueidentifier,@RequestID uniqueidentifier,@CustomerID uniqueidentifier,
 @EmployeeID varchar(20),@FlightID varchar(20),@FareClass varchar(3),@Passengers dbo.PassengerList READONLY
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51100,N'Gọi procedure ngoài transaction của caller.',1;
 DECLARE @Q int=(SELECT COUNT(*) FROM @Passengers),@Branch varchar(3)=(SELECT BranchID FROM dbo.LocalBranch);
 IF @OrderID IS NULL OR @RequestID IS NULL OR @CustomerID IS NULL OR @EmployeeID IS NULL
  OR @FlightID IS NULL OR @FareClass IS NULL OR @FareClass NOT IN ('ECO','BUS') OR @Q NOT BETWEEN 1 AND 500
  OR EXISTS(SELECT 1 FROM @Passengers WHERE ItemNo<=0 OR LEN(LTRIM(RTRIM(PassengerName)))=0)
  OR (SELECT MIN(ItemNo) FROM @Passengers)<>1 OR (SELECT MAX(ItemNo) FROM @Passengers)<>@Q
  THROW 51101,N'Danh sách hành khách hoặc tham số đơn không hợp lệ.',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Lock int,@Resource nvarchar(255)=N'order:'+CONVERT(nvarchar(36),@OrderID);
  EXEC @Lock=sys.sp_getapplock @Resource=@Resource,@LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=5000;
  IF @Lock<0 THROW 51102,N'Không lấy được khóa đơn.',1;
  IF EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID=@OrderID)
  BEGIN
   IF NOT EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID=@OrderID AND RequestID=@RequestID
    AND CustomerID=@CustomerID AND EmployeeID=@EmployeeID AND FlightID=@FlightID AND FareClass=@FareClass AND Quantity=@Q)
    OR EXISTS(SELECT ItemNo,PassengerName,PassengerDocument FROM @Passengers EXCEPT
       SELECT ItemNo,PassengerName,PassengerDocument FROM dbo.SalesItem WHERE OrderID=@OrderID)
    OR EXISTS(SELECT ItemNo,PassengerName,PassengerDocument FROM dbo.SalesItem WHERE OrderID=@OrderID EXCEPT
       SELECT ItemNo,PassengerName,PassengerDocument FROM @Passengers)
     THROW 51103,N'OrderID đã dùng cho nội dung khác.',1;
   COMMIT; RETURN;
  END;
  IF NOT EXISTS(SELECT 1 FROM dbo.Employee WHERE EmployeeID=@EmployeeID AND BranchID=@Branch AND IsActive=1)
    THROW 51104,N'Nhân viên không hợp lệ.',1;
  IF NOT EXISTS(SELECT 1 FROM dbo.CustomerProfile WHERE CustomerID=@CustomerID AND BranchID=@Branch)
    THROW 51105,N'Khách hàng không thuộc chi nhánh.',1;
  INSERT dbo.SalesOrder(OrderID,BranchID,CustomerID,EmployeeID,FlightID,FareClass,Quantity,RequestID,Status)
  VALUES(@OrderID,@Branch,@CustomerID,@EmployeeID,@FlightID,@FareClass,@Q,@RequestID,'DRAFT');
  INSERT dbo.SalesItem(OrderID,ItemNo,PassengerName,PassengerDocument)
  SELECT @OrderID,ItemNo,PassengerName,PassengerDocument FROM @Passengers;
  INSERT dbo.BranchEvent(OrderID,EventType,Actor) VALUES(@OrderID,'CREATE_ORDER',ORIGINAL_LOGIN());
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;
GO

-- Áp dụng phản hồi ACTIVE đã xác minh từ S0; chỉ caller dịch vụ được gọi [AirBranch_HN]
USE [AirBranch_HN];
GO
CREATE OR ALTER PROCEDURE dbo.usp_ApplyHoldResult
 @OrderID uniqueidentifier,@RequestID uniqueidentifier,@HoldID uniqueidentifier,
 @FlightID varchar(20),@FareClass varchar(3),@Quantity int,@UnitPrice decimal(18,2),@ExpiresAt datetime2(3)
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51100,N'Gọi procedure ngoài transaction của caller.',1;
 IF @HoldID IS NULL OR @UnitPrice IS NULL OR @UnitPrice<=0 OR @ExpiresAt IS NULL
  THROW 51106,N'Kết quả giữ chỗ không hợp lệ.',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Status varchar(20),@OldHold uniqueidentifier;
  SELECT @Status=Status,@OldHold=HoldID FROM dbo.SalesOrder WITH(UPDLOCK,HOLDLOCK)
  WHERE OrderID=@OrderID AND RequestID=@RequestID AND FlightID=@FlightID AND FareClass=@FareClass AND Quantity=@Quantity;
  IF @Status IS NULL THROW 51107,N'Kết quả S0 không khớp đơn.',1;
  IF @OldHold IS NOT NULL AND @OldHold<>@HoldID THROW 51108,N'Đơn đã gắn với HoldID khác.',1;
  IF @Status IN ('ISSUED','CANCELLED') BEGIN COMMIT; RETURN; END;
  UPDATE dbo.SalesOrder SET HoldID=@HoldID,ExpiresAt=@ExpiresAt,Status='HELD',LastError=NULL,LastCheckedAt=SYSUTCDATETIME()
  WHERE OrderID=@OrderID;
  UPDATE dbo.SalesItem SET UnitPrice=@UnitPrice WHERE OrderID=@OrderID;
  INSERT dbo.BranchEvent(OrderID,EventType,Actor) VALUES(@OrderID,'APPLY_HOLD',ORIGINAL_LOGIN());
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;
GO

-- Áp dụng phản hồi ACTIVE đã xác minh từ S0; chỉ caller dịch vụ được gọi [AirBranch_DN]
USE [AirBranch_DN];
GO
CREATE OR ALTER PROCEDURE dbo.usp_ApplyHoldResult
 @OrderID uniqueidentifier,@RequestID uniqueidentifier,@HoldID uniqueidentifier,
 @FlightID varchar(20),@FareClass varchar(3),@Quantity int,@UnitPrice decimal(18,2),@ExpiresAt datetime2(3)
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51100,N'Gọi procedure ngoài transaction của caller.',1;
 IF @HoldID IS NULL OR @UnitPrice IS NULL OR @UnitPrice<=0 OR @ExpiresAt IS NULL
  THROW 51106,N'Kết quả giữ chỗ không hợp lệ.',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Status varchar(20),@OldHold uniqueidentifier;
  SELECT @Status=Status,@OldHold=HoldID FROM dbo.SalesOrder WITH(UPDLOCK,HOLDLOCK)
  WHERE OrderID=@OrderID AND RequestID=@RequestID AND FlightID=@FlightID AND FareClass=@FareClass AND Quantity=@Quantity;
  IF @Status IS NULL THROW 51107,N'Kết quả S0 không khớp đơn.',1;
  IF @OldHold IS NOT NULL AND @OldHold<>@HoldID THROW 51108,N'Đơn đã gắn với HoldID khác.',1;
  IF @Status IN ('ISSUED','CANCELLED') BEGIN COMMIT; RETURN; END;
  UPDATE dbo.SalesOrder SET HoldID=@HoldID,ExpiresAt=@ExpiresAt,Status='HELD',LastError=NULL,LastCheckedAt=SYSUTCDATETIME()
  WHERE OrderID=@OrderID;
  UPDATE dbo.SalesItem SET UnitPrice=@UnitPrice WHERE OrderID=@OrderID;
  INSERT dbo.BranchEvent(OrderID,EventType,Actor) VALUES(@OrderID,'APPLY_HOLD',ORIGINAL_LOGIN());
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;
GO

-- Áp dụng phản hồi ACTIVE đã xác minh từ S0; chỉ caller dịch vụ được gọi [AirBranch_HCM]
USE [AirBranch_HCM];
GO
CREATE OR ALTER PROCEDURE dbo.usp_ApplyHoldResult
 @OrderID uniqueidentifier,@RequestID uniqueidentifier,@HoldID uniqueidentifier,
 @FlightID varchar(20),@FareClass varchar(3),@Quantity int,@UnitPrice decimal(18,2),@ExpiresAt datetime2(3)
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51100,N'Gọi procedure ngoài transaction của caller.',1;
 IF @HoldID IS NULL OR @UnitPrice IS NULL OR @UnitPrice<=0 OR @ExpiresAt IS NULL
  THROW 51106,N'Kết quả giữ chỗ không hợp lệ.',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Status varchar(20),@OldHold uniqueidentifier;
  SELECT @Status=Status,@OldHold=HoldID FROM dbo.SalesOrder WITH(UPDLOCK,HOLDLOCK)
  WHERE OrderID=@OrderID AND RequestID=@RequestID AND FlightID=@FlightID AND FareClass=@FareClass AND Quantity=@Quantity;
  IF @Status IS NULL THROW 51107,N'Kết quả S0 không khớp đơn.',1;
  IF @OldHold IS NOT NULL AND @OldHold<>@HoldID THROW 51108,N'Đơn đã gắn với HoldID khác.',1;
  IF @Status IN ('ISSUED','CANCELLED') BEGIN COMMIT; RETURN; END;
  UPDATE dbo.SalesOrder SET HoldID=@HoldID,ExpiresAt=@ExpiresAt,Status='HELD',LastError=NULL,LastCheckedAt=SYSUTCDATETIME()
  WHERE OrderID=@OrderID;
  UPDATE dbo.SalesItem SET UnitPrice=@UnitPrice WHERE OrderID=@OrderID;
  INSERT dbo.BranchEvent(OrderID,EventType,Actor) VALUES(@OrderID,'APPLY_HOLD',ORIGINAL_LOGIN());
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;
GO

-- Áp dụng danh sách vé chính thức; thử lại không tạo thêm vé [AirBranch_HN]
USE [AirBranch_HN];
GO
CREATE OR ALTER PROCEDURE dbo.usp_ApplyIssuedResult
 @OrderID uniqueidentifier,@HoldID uniqueidentifier,@PaymentID uniqueidentifier,@Tickets dbo.TicketList READONLY
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51100,N'Gọi procedure ngoài transaction của caller.',1;
 IF @HoldID IS NULL OR @PaymentID IS NULL THROW 51109,N'Kết quả phát hành không hợp lệ.',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Q int,@Status varchar(20),@OldPayment uniqueidentifier;
  SELECT @Q=Quantity,@Status=Status,@OldPayment=PaymentID FROM dbo.SalesOrder WITH(UPDLOCK,HOLDLOCK)
  WHERE OrderID=@OrderID AND HoldID=@HoldID;
  IF @Q IS NULL THROW 51107,N'Kết quả S0 không khớp đơn.',1;
  IF @Status='CANCELLED' THROW 51110,N'Đơn đã hủy; cần đối soát thay vì tự ghi phát hành.',1;
  IF (SELECT COUNT(*) FROM @Tickets)<>@Q
   OR EXISTS(SELECT ItemNo FROM @Tickets EXCEPT SELECT ItemNo FROM dbo.SalesItem WHERE OrderID=@OrderID)
   THROW 51111,N'Danh sách vé không khớp danh sách hành khách.',1;
  IF @Status='ISSUED'
  BEGIN
   IF @OldPayment<>@PaymentID OR EXISTS(SELECT ItemNo,TicketID FROM @Tickets EXCEPT
       SELECT ItemNo,TicketID FROM dbo.SalesItem WHERE OrderID=@OrderID)
    THROW 51112,N'Đơn đã nhận một kết quả phát hành khác.',1;
   COMMIT; RETURN;
  END;
  UPDATE i SET TicketID=t.TicketID FROM dbo.SalesItem i JOIN @Tickets t ON t.ItemNo=i.ItemNo WHERE i.OrderID=@OrderID;
  UPDATE dbo.SalesOrder SET Status='ISSUED',PaymentID=@PaymentID,LastError=NULL,LastCheckedAt=SYSUTCDATETIME() WHERE OrderID=@OrderID;
  INSERT dbo.BranchEvent(OrderID,EventType,Actor) VALUES(@OrderID,'APPLY_ISSUED',ORIGINAL_LOGIN());
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;
GO

-- Áp dụng danh sách vé chính thức; thử lại không tạo thêm vé [AirBranch_DN]
USE [AirBranch_DN];
GO
CREATE OR ALTER PROCEDURE dbo.usp_ApplyIssuedResult
 @OrderID uniqueidentifier,@HoldID uniqueidentifier,@PaymentID uniqueidentifier,@Tickets dbo.TicketList READONLY
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51100,N'Gọi procedure ngoài transaction của caller.',1;
 IF @HoldID IS NULL OR @PaymentID IS NULL THROW 51109,N'Kết quả phát hành không hợp lệ.',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Q int,@Status varchar(20),@OldPayment uniqueidentifier;
  SELECT @Q=Quantity,@Status=Status,@OldPayment=PaymentID FROM dbo.SalesOrder WITH(UPDLOCK,HOLDLOCK)
  WHERE OrderID=@OrderID AND HoldID=@HoldID;
  IF @Q IS NULL THROW 51107,N'Kết quả S0 không khớp đơn.',1;
  IF @Status='CANCELLED' THROW 51110,N'Đơn đã hủy; cần đối soát thay vì tự ghi phát hành.',1;
  IF (SELECT COUNT(*) FROM @Tickets)<>@Q
   OR EXISTS(SELECT ItemNo FROM @Tickets EXCEPT SELECT ItemNo FROM dbo.SalesItem WHERE OrderID=@OrderID)
   THROW 51111,N'Danh sách vé không khớp danh sách hành khách.',1;
  IF @Status='ISSUED'
  BEGIN
   IF @OldPayment<>@PaymentID OR EXISTS(SELECT ItemNo,TicketID FROM @Tickets EXCEPT
       SELECT ItemNo,TicketID FROM dbo.SalesItem WHERE OrderID=@OrderID)
    THROW 51112,N'Đơn đã nhận một kết quả phát hành khác.',1;
   COMMIT; RETURN;
  END;
  UPDATE i SET TicketID=t.TicketID FROM dbo.SalesItem i JOIN @Tickets t ON t.ItemNo=i.ItemNo WHERE i.OrderID=@OrderID;
  UPDATE dbo.SalesOrder SET Status='ISSUED',PaymentID=@PaymentID,LastError=NULL,LastCheckedAt=SYSUTCDATETIME() WHERE OrderID=@OrderID;
  INSERT dbo.BranchEvent(OrderID,EventType,Actor) VALUES(@OrderID,'APPLY_ISSUED',ORIGINAL_LOGIN());
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;
GO

-- Áp dụng danh sách vé chính thức; thử lại không tạo thêm vé [AirBranch_HCM]
USE [AirBranch_HCM];
GO
CREATE OR ALTER PROCEDURE dbo.usp_ApplyIssuedResult
 @OrderID uniqueidentifier,@HoldID uniqueidentifier,@PaymentID uniqueidentifier,@Tickets dbo.TicketList READONLY
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51100,N'Gọi procedure ngoài transaction của caller.',1;
 IF @HoldID IS NULL OR @PaymentID IS NULL THROW 51109,N'Kết quả phát hành không hợp lệ.',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Q int,@Status varchar(20),@OldPayment uniqueidentifier;
  SELECT @Q=Quantity,@Status=Status,@OldPayment=PaymentID FROM dbo.SalesOrder WITH(UPDLOCK,HOLDLOCK)
  WHERE OrderID=@OrderID AND HoldID=@HoldID;
  IF @Q IS NULL THROW 51107,N'Kết quả S0 không khớp đơn.',1;
  IF @Status='CANCELLED' THROW 51110,N'Đơn đã hủy; cần đối soát thay vì tự ghi phát hành.',1;
  IF (SELECT COUNT(*) FROM @Tickets)<>@Q
   OR EXISTS(SELECT ItemNo FROM @Tickets EXCEPT SELECT ItemNo FROM dbo.SalesItem WHERE OrderID=@OrderID)
   THROW 51111,N'Danh sách vé không khớp danh sách hành khách.',1;
  IF @Status='ISSUED'
  BEGIN
   IF @OldPayment<>@PaymentID OR EXISTS(SELECT ItemNo,TicketID FROM @Tickets EXCEPT
       SELECT ItemNo,TicketID FROM dbo.SalesItem WHERE OrderID=@OrderID)
    THROW 51112,N'Đơn đã nhận một kết quả phát hành khác.',1;
   COMMIT; RETURN;
  END;
  UPDATE i SET TicketID=t.TicketID FROM dbo.SalesItem i JOIN @Tickets t ON t.ItemNo=i.ItemNo WHERE i.OrderID=@OrderID;
  UPDATE dbo.SalesOrder SET Status='ISSUED',PaymentID=@PaymentID,LastError=NULL,LastCheckedAt=SYSUTCDATETIME() WHERE OrderID=@OrderID;
  INSERT dbo.BranchEvent(OrderID,EventType,Actor) VALUES(@OrderID,'APPLY_ISSUED',ORIGINAL_LOGIN());
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;
GO

-- Timeout là chưa xác định kết quả; không tự đổi thành CANCELLED [AirBranch_HN]
USE [AirBranch_HN];
GO
CREATE OR ALTER PROCEDURE dbo.usp_MarkPendingReconcile @OrderID uniqueidentifier,@Message nvarchar(300)
AS
BEGIN
 SET NOCOUNT ON;
 UPDATE dbo.SalesOrder SET Status='PENDING_RECONCILE',LastError=@Message,LastCheckedAt=SYSUTCDATETIME()
 WHERE OrderID=@OrderID AND Status IN ('DRAFT','HELD','PENDING_RECONCILE');
END;
GO

-- Timeout là chưa xác định kết quả; không tự đổi thành CANCELLED [AirBranch_DN]
USE [AirBranch_DN];
GO
CREATE OR ALTER PROCEDURE dbo.usp_MarkPendingReconcile @OrderID uniqueidentifier,@Message nvarchar(300)
AS
BEGIN
 SET NOCOUNT ON;
 UPDATE dbo.SalesOrder SET Status='PENDING_RECONCILE',LastError=@Message,LastCheckedAt=SYSUTCDATETIME()
 WHERE OrderID=@OrderID AND Status IN ('DRAFT','HELD','PENDING_RECONCILE');
END;
GO

-- Timeout là chưa xác định kết quả; không tự đổi thành CANCELLED [AirBranch_HCM]
USE [AirBranch_HCM];
GO
CREATE OR ALTER PROCEDURE dbo.usp_MarkPendingReconcile @OrderID uniqueidentifier,@Message nvarchar(300)
AS
BEGIN
 SET NOCOUNT ON;
 UPDATE dbo.SalesOrder SET Status='PENDING_RECONCILE',LastError=@Message,LastCheckedAt=SYSUTCDATETIME()
 WHERE OrderID=@OrderID AND Status IN ('DRAFT','HELD','PENDING_RECONCILE');
END;
GO

-- Áp dụng kết quả hủy/hết hạn của S0, không chạm bộ đếm cục bộ [AirBranch_HN]
USE [AirBranch_HN];
GO
CREATE OR ALTER PROCEDURE dbo.usp_ApplyCancelledResult @OrderID uniqueidentifier,@HoldID uniqueidentifier
AS
BEGIN
 SET NOCOUNT ON;
 -- Caller chỉ gọi sau khi nguồn trả EXPIRED hoặc CANCELLED đúng HoldID.
 UPDATE dbo.SalesOrder SET Status='CANCELLED',LastError=NULL,LastCheckedAt=SYSUTCDATETIME()
 WHERE OrderID=@OrderID AND HoldID=@HoldID AND Status IN ('HELD','PENDING_RECONCILE','CANCELLED');
 IF @@ROWCOUNT=0 THROW 51113,N'Đơn không thể áp dụng kết quả hủy này.',1;
END;
GO

-- Áp dụng kết quả hủy/hết hạn của S0, không chạm bộ đếm cục bộ [AirBranch_DN]
USE [AirBranch_DN];
GO
CREATE OR ALTER PROCEDURE dbo.usp_ApplyCancelledResult @OrderID uniqueidentifier,@HoldID uniqueidentifier
AS
BEGIN
 SET NOCOUNT ON;
 -- Caller chỉ gọi sau khi nguồn trả EXPIRED hoặc CANCELLED đúng HoldID.
 UPDATE dbo.SalesOrder SET Status='CANCELLED',LastError=NULL,LastCheckedAt=SYSUTCDATETIME()
 WHERE OrderID=@OrderID AND HoldID=@HoldID AND Status IN ('HELD','PENDING_RECONCILE','CANCELLED');
 IF @@ROWCOUNT=0 THROW 51113,N'Đơn không thể áp dụng kết quả hủy này.',1;
END;
GO

-- Áp dụng kết quả hủy/hết hạn của S0, không chạm bộ đếm cục bộ [AirBranch_HCM]
USE [AirBranch_HCM];
GO
CREATE OR ALTER PROCEDURE dbo.usp_ApplyCancelledResult @OrderID uniqueidentifier,@HoldID uniqueidentifier
AS
BEGIN
 SET NOCOUNT ON;
 -- Caller chỉ gọi sau khi nguồn trả EXPIRED hoặc CANCELLED đúng HoldID.
 UPDATE dbo.SalesOrder SET Status='CANCELLED',LastError=NULL,LastCheckedAt=SYSUTCDATETIME()
 WHERE OrderID=@OrderID AND HoldID=@HoldID AND Status IN ('HELD','PENDING_RECONCILE','CANCELLED');
 IF @@ROWCOUNT=0 THROW 51113,N'Đơn không thể áp dụng kết quả hủy này.',1;
END;
GO

-- Chiếu thông tin công khai: minh họa phần thuộc tính được phép đọc [AirBranch_HN]
USE [AirBranch_HN];
GO
CREATE OR ALTER VIEW dbo.vCustomerPublic AS
SELECT CustomerID,BranchID,FullName,BirthDate FROM dbo.CustomerProfile;
GO

-- Chiếu thông tin công khai: minh họa phần thuộc tính được phép đọc [AirBranch_DN]
USE [AirBranch_DN];
GO
CREATE OR ALTER VIEW dbo.vCustomerPublic AS
SELECT CustomerID,BranchID,FullName,BirthDate FROM dbo.CustomerProfile;
GO

-- Chiếu thông tin công khai: minh họa phần thuộc tính được phép đọc [AirBranch_HCM]
USE [AirBranch_HCM];
GO
CREATE OR ALTER VIEW dbo.vCustomerPublic AS
SELECT CustomerID,BranchID,FullName,BirthDate FROM dbo.CustomerProfile;
GO

-- Chiếu thông tin liên hệ: không nhân bản giấy tờ vào kho báo cáo [AirBranch_HN]
USE [AirBranch_HN];
GO
CREATE OR ALTER VIEW dbo.vCustomerPrivate AS
SELECT CustomerID,Phone,Email,DocumentNo FROM dbo.CustomerProfile;
GO

-- Chiếu thông tin liên hệ: không nhân bản giấy tờ vào kho báo cáo [AirBranch_DN]
USE [AirBranch_DN];
GO
CREATE OR ALTER VIEW dbo.vCustomerPrivate AS
SELECT CustomerID,Phone,Email,DocumentNo FROM dbo.CustomerProfile;
GO

-- Chiếu thông tin liên hệ: không nhân bản giấy tờ vào kho báo cáo [AirBranch_HCM]
USE [AirBranch_HCM];
GO
CREATE OR ALTER VIEW dbo.vCustomerPrivate AS
SELECT CustomerID,Phone,Email,DocumentNo FROM dbo.CustomerProfile;
GO

-- PHẦN 6.1 - Bảng nhận ba mảnh, tách schema, không sao chép giấy tờ hành khách [AirReporting]
USE [AirReporting];
GO
IF SCHEMA_ID('hn') IS NULL EXEC(N'CREATE SCHEMA hn AUTHORIZATION dbo');
IF SCHEMA_ID('dn') IS NULL EXEC(N'CREATE SCHEMA dn AUTHORIZATION dbo');
IF SCHEMA_ID('hcm') IS NULL EXEC(N'CREATE SCHEMA hcm AUTHORIZATION dbo');
IF OBJECT_ID('dbo.SyncWatermark','U') IS NULL
CREATE TABLE dbo.SyncWatermark(SourceName sysname PRIMARY KEY,LastCopiedAt datetime2(3) NOT NULL);

IF OBJECT_ID('hn.SalesOrder','U') IS NULL
CREATE TABLE hn.SalesOrder(OrderID uniqueidentifier PRIMARY KEY,BranchID varchar(3) NOT NULL,
 CustomerID uniqueidentifier NOT NULL,EmployeeID varchar(20) NOT NULL,FlightID varchar(20) NOT NULL,
 FareClass varchar(3) NOT NULL,Quantity int NOT NULL,RequestID uniqueidentifier NOT NULL,
 HoldID uniqueidentifier NULL,PaymentID uniqueidentifier NULL,Status varchar(20) NOT NULL,
 CreatedAt datetime2(3) NOT NULL,ExpiresAt datetime2(3) NULL,LastError nvarchar(300) NULL,LastCheckedAt datetime2(3) NULL);
IF OBJECT_ID('hn.SalesItem','U') IS NULL
CREATE TABLE hn.SalesItem(OrderID uniqueidentifier NOT NULL,ItemNo int NOT NULL,
 UnitPrice decimal(18,2) NULL,TicketID uniqueidentifier NULL,PRIMARY KEY(OrderID,ItemNo));

IF OBJECT_ID('dn.SalesOrder','U') IS NULL
CREATE TABLE dn.SalesOrder(OrderID uniqueidentifier PRIMARY KEY,BranchID varchar(3) NOT NULL,
 CustomerID uniqueidentifier NOT NULL,EmployeeID varchar(20) NOT NULL,FlightID varchar(20) NOT NULL,
 FareClass varchar(3) NOT NULL,Quantity int NOT NULL,RequestID uniqueidentifier NOT NULL,
 HoldID uniqueidentifier NULL,PaymentID uniqueidentifier NULL,Status varchar(20) NOT NULL,
 CreatedAt datetime2(3) NOT NULL,ExpiresAt datetime2(3) NULL,LastError nvarchar(300) NULL,LastCheckedAt datetime2(3) NULL);
IF OBJECT_ID('dn.SalesItem','U') IS NULL
CREATE TABLE dn.SalesItem(OrderID uniqueidentifier NOT NULL,ItemNo int NOT NULL,
 UnitPrice decimal(18,2) NULL,TicketID uniqueidentifier NULL,PRIMARY KEY(OrderID,ItemNo));

IF OBJECT_ID('hcm.SalesOrder','U') IS NULL
CREATE TABLE hcm.SalesOrder(OrderID uniqueidentifier PRIMARY KEY,BranchID varchar(3) NOT NULL,
 CustomerID uniqueidentifier NOT NULL,EmployeeID varchar(20) NOT NULL,FlightID varchar(20) NOT NULL,
 FareClass varchar(3) NOT NULL,Quantity int NOT NULL,RequestID uniqueidentifier NOT NULL,
 HoldID uniqueidentifier NULL,PaymentID uniqueidentifier NULL,Status varchar(20) NOT NULL,
 CreatedAt datetime2(3) NOT NULL,ExpiresAt datetime2(3) NULL,LastError nvarchar(300) NULL,LastCheckedAt datetime2(3) NULL);
IF OBJECT_ID('hcm.SalesItem','U') IS NULL
CREATE TABLE hcm.SalesItem(OrderID uniqueidentifier NOT NULL,ItemNo int NOT NULL,
 UnitPrice decimal(18,2) NULL,TicketID uniqueidentifier NULL,PRIMARY KEY(OrderID,ItemNo));
GO

-- Tái thiết quan hệ toàn cục bằng UNION ALL, không hợp thêm bản nguồn [AirReporting]
USE [AirReporting];
GO
CREATE OR ALTER VIEW dbo.vSalesOrderGlobal AS
SELECT * FROM hn.SalesOrder UNION ALL SELECT * FROM dn.SalesOrder UNION ALL SELECT * FROM hcm.SalesOrder;
GO

-- Tái thiết mảnh ngang dẫn xuất [AirReporting]
USE [AirReporting];
GO
CREATE OR ALTER VIEW dbo.vSalesItemGlobal AS
SELECT * FROM hn.SalesItem UNION ALL SELECT * FROM dn.SalesItem UNION ALL SELECT * FROM hcm.SalesItem;
GO

-- PHẦN 6.2 - Báo cáo thu và hoàn chính thức từ S0, không coi đơn nháp là doanh thu [AirCore]
USE [AirCore];
GO
CREATE OR ALTER PROCEDURE dbo.usp_RevenueByBranch @FromUtc datetime2(3),@ToUtc datetime2(3)
AS
BEGIN
 SET NOCOUNT ON;
 IF @FromUtc IS NULL OR @ToUtc IS NULL OR @FromUtc>=@ToUtc THROW 51040,N'Khoảng thời gian không hợp lệ.',1;
 ;WITH p AS(SELECT h.BranchID,SUM(p.Amount) GrossAmount FROM dbo.Payment p JOIN dbo.SeatHold h ON h.HoldID=p.HoldID
  WHERE p.PaidAt>=@FromUtc AND p.PaidAt<@ToUtc GROUP BY h.BranchID),
 r AS(SELECT h.BranchID,SUM(r.Amount) RefundAmount FROM dbo.Refund r JOIN dbo.Ticket t ON t.TicketID=r.TicketID
  JOIN dbo.SeatHold h ON h.HoldID=t.HoldID WHERE r.RefundedAt>=@FromUtc AND r.RefundedAt<@ToUtc GROUP BY h.BranchID)
 SELECT b.BranchID,b.BranchName,COALESCE(p.GrossAmount,0) GrossAmount,COALESCE(r.RefundAmount,0) RefundAmount,
  COALESCE(p.GrossAmount,0)-COALESCE(r.RefundAmount,0) NetCashMovement
 FROM dbo.Branch b LEFT JOIN p ON p.BranchID=b.BranchID LEFT JOIN r ON r.BranchID=b.BranchID;
 -- NetCashMovement là thu trừ hoàn theo thời điểm dòng tiền; có thể âm ở kỳ chỉ có hoàn.
END;
GO

-- Cảnh báo lấp đầy theo quy tắc; không phải mô hình AI [AirCore]
USE [AirCore];
GO
CREATE OR ALTER PROCEDURE dbo.usp_HighLoadFlights @Threshold decimal(5,2)=80
AS
BEGIN
 SET NOCOUNT ON;
 IF @Threshold IS NULL OR @Threshold NOT BETWEEN 0 AND 100 THROW 51041,N'Ngưỡng không hợp lệ.',1;
 SELECT *,CAST(100.0*Sold/Capacity AS decimal(5,2)) SoldPct FROM dbo.vFlightAvailability
 WHERE Status='OPEN' AND DepartureUtc>SYSUTCDATETIME() AND 100.0*Sold/Capacity>=@Threshold;
END;
GO

-- Chỉ LAB: snapshot sao chép thủ công trên một instance, không phải replication liên máy [AirCore]
USE [AirCore];
GO
CREATE OR ALTER PROCEDURE dbo.usp_RefreshLabCopies
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51001,N'Gọi ngoài transaction của caller.',1;
 SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

 IF DB_ID('AirReference_HN') IS NULL OR DB_ID('AirBranch_HN') IS NULL OR DB_ID('AirReporting') IS NULL
  THROW 51042,N'Thủ tục sao chép LAB chỉ chạy trên một instance có đủ tám database.',1;
 IF NOT EXISTS(SELECT 1 FROM [AirReference_HN].sys.extended_properties WHERE class=0 AND name='AirLabProject' AND CONVERT(nvarchar(100),value)='CSDLPT_NHOM8_V1')
  THROW 51042,N'Database bản sao LAB không thuộc dự án.',1;
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
  UPDATE [AirReference_HN].dbo.SyncWatermark SET LastCopiedAt=SYSUTCDATETIME() WHERE SourceName='AirCore';
  IF @@ROWCOUNT=0 INSERT [AirReference_HN].dbo.SyncWatermark VALUES('AirCore',SYSUTCDATETIME());
  UPDATE AirReporting.dbo.SyncWatermark SET LastCopiedAt=SYSUTCDATETIME() WHERE SourceName='HN';
  IF @@ROWCOUNT=0 INSERT AirReporting.dbo.SyncWatermark VALUES('HN',SYSUTCDATETIME());
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;

 IF DB_ID('AirReference_DN') IS NULL OR DB_ID('AirBranch_DN') IS NULL OR DB_ID('AirReporting') IS NULL
  THROW 51042,N'Thủ tục sao chép LAB chỉ chạy trên một instance có đủ tám database.',1;
 IF NOT EXISTS(SELECT 1 FROM [AirReference_DN].sys.extended_properties WHERE class=0 AND name='AirLabProject' AND CONVERT(nvarchar(100),value)='CSDLPT_NHOM8_V1')
  THROW 51042,N'Database bản sao LAB không thuộc dự án.',1;
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
  UPDATE [AirReference_DN].dbo.SyncWatermark SET LastCopiedAt=SYSUTCDATETIME() WHERE SourceName='AirCore';
  IF @@ROWCOUNT=0 INSERT [AirReference_DN].dbo.SyncWatermark VALUES('AirCore',SYSUTCDATETIME());
  UPDATE AirReporting.dbo.SyncWatermark SET LastCopiedAt=SYSUTCDATETIME() WHERE SourceName='DN';
  IF @@ROWCOUNT=0 INSERT AirReporting.dbo.SyncWatermark VALUES('DN',SYSUTCDATETIME());
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;

 IF DB_ID('AirReference_HCM') IS NULL OR DB_ID('AirBranch_HCM') IS NULL OR DB_ID('AirReporting') IS NULL
  THROW 51042,N'Thủ tục sao chép LAB chỉ chạy trên một instance có đủ tám database.',1;
 IF NOT EXISTS(SELECT 1 FROM [AirReference_HCM].sys.extended_properties WHERE class=0 AND name='AirLabProject' AND CONVERT(nvarchar(100),value)='CSDLPT_NHOM8_V1')
  THROW 51042,N'Database bản sao LAB không thuộc dự án.',1;
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
  UPDATE [AirReference_HCM].dbo.SyncWatermark SET LastCopiedAt=SYSUTCDATETIME() WHERE SourceName='AirCore';
  IF @@ROWCOUNT=0 INSERT [AirReference_HCM].dbo.SyncWatermark VALUES('AirCore',SYSUTCDATETIME());
  UPDATE AirReporting.dbo.SyncWatermark SET LastCopiedAt=SYSUTCDATETIME() WHERE SourceName='HCM';
  IF @@ROWCOUNT=0 INSERT AirReporting.dbo.SyncWatermark VALUES('HCM',SYSUTCDATETIME());
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;
GO

-- PHẦN 7 - Dữ liệu mẫu: tương lai 7 ngày, không đặt lại dữ liệu đã bán khi chạy lại [AirCore]
USE [AirCore];
GO
BEGIN
 IF NOT EXISTS(SELECT 1 FROM dbo.Branch WHERE BranchID='HN') INSERT dbo.Branch VALUES('HN',N'Chi nhánh Hà Nội',N'Hà Nội');
 IF NOT EXISTS(SELECT 1 FROM dbo.Branch WHERE BranchID='DN') INSERT dbo.Branch VALUES('DN',N'Chi nhánh Đà Nẵng',N'Đà Nẵng');
 IF NOT EXISTS(SELECT 1 FROM dbo.Branch WHERE BranchID='HCM') INSERT dbo.Branch VALUES('HCM',N'Chi nhánh TP Hồ Chí Minh',N'TP Hồ Chí Minh');
 IF NOT EXISTS(SELECT 1 FROM dbo.Airport WHERE AirportCode='HAN') INSERT dbo.Airport VALUES('HAN',N'Nội Bài',N'Hà Nội');
 IF NOT EXISTS(SELECT 1 FROM dbo.Airport WHERE AirportCode='DAD') INSERT dbo.Airport VALUES('DAD',N'Đà Nẵng',N'Đà Nẵng');
 IF NOT EXISTS(SELECT 1 FROM dbo.Airport WHERE AirportCode='SGN') INSERT dbo.Airport VALUES('SGN',N'Tân Sơn Nhất',N'TP Hồ Chí Minh');
 IF NOT EXISTS(SELECT 1 FROM dbo.Route WHERE RouteID='HAN_DAD') INSERT dbo.Route VALUES('HAN_DAD','HAN','DAD');
 IF NOT EXISTS(SELECT 1 FROM dbo.Route WHERE RouteID='DAD_SGN') INSERT dbo.Route VALUES('DAD_SGN','DAD','SGN');
 IF NOT EXISTS(SELECT 1 FROM dbo.Route WHERE RouteID='HAN_SGN') INSERT dbo.Route VALUES('HAN_SGN','HAN','SGN');
 IF NOT EXISTS(SELECT 1 FROM dbo.Aircraft WHERE AircraftID='LAB_A1') INSERT dbo.Aircraft VALUES('LAB_A1','MO_PHONG_A1',12);
 IF NOT EXISTS(SELECT 1 FROM dbo.Aircraft WHERE AircraftID='LAB_A2') INSERT dbo.Aircraft VALUES('LAB_A2','MO_PHONG_A2',12);
 IF NOT EXISTS(SELECT 1 FROM dbo.Aircraft WHERE AircraftID='LAB_A3') INSERT dbo.Aircraft VALUES('LAB_A3','MO_PHONG_A3',12);
 DECLARE @D datetime2(3)=DATEADD(day,7,SYSUTCDATETIME());
 IF NOT EXISTS(SELECT 1 FROM dbo.Flight WHERE FlightID='TEST01')
  INSERT dbo.Flight(FlightID,FlightNo,RouteID,AircraftID,DepartureUtc,ArrivalUtc,Status)
  VALUES('TEST01','LAB001','HAN_DAD','LAB_A1',@D,DATEADD(hour,2,@D),'OPEN');
 IF NOT EXISTS(SELECT 1 FROM dbo.Flight WHERE FlightID='TEST02')
  INSERT dbo.Flight(FlightID,FlightNo,RouteID,AircraftID,DepartureUtc,ArrivalUtc,Status)
  VALUES('TEST02','LAB002','DAD_SGN','LAB_A2',@D,DATEADD(hour,2,@D),'OPEN');
 IF NOT EXISTS(SELECT 1 FROM dbo.Flight WHERE FlightID='TEST03')
  INSERT dbo.Flight(FlightID,FlightNo,RouteID,AircraftID,DepartureUtc,ArrivalUtc,Status)
  VALUES('TEST03','LAB003','HAN_SGN','LAB_A3',@D,DATEADD(hour,2,@D),'CLOSED');
 IF NOT EXISTS(SELECT 1 FROM dbo.Fare WHERE FlightID='TEST01' AND FareClass='ECO') INSERT dbo.Fare VALUES('TEST01','ECO',1500000,'VND');
 IF NOT EXISTS(SELECT 1 FROM dbo.Fare WHERE FlightID='TEST01' AND FareClass='BUS') INSERT dbo.Fare VALUES('TEST01','BUS',3000000,'VND');
 IF NOT EXISTS(SELECT 1 FROM dbo.Fare WHERE FlightID='TEST02' AND FareClass='ECO') INSERT dbo.Fare VALUES('TEST02','ECO',1000000,'VND');
 IF NOT EXISTS(SELECT 1 FROM dbo.Fare WHERE FlightID='TEST03' AND FareClass='ECO') INSERT dbo.Fare VALUES('TEST03','ECO',2000000,'VND');
 IF NOT EXISTS(SELECT 1 FROM dbo.Inventory WHERE FlightID='TEST01' AND FareClass='ECO') INSERT dbo.Inventory(FlightID,FareClass,Capacity) VALUES('TEST01','ECO',10);
 IF NOT EXISTS(SELECT 1 FROM dbo.Inventory WHERE FlightID='TEST01' AND FareClass='BUS') INSERT dbo.Inventory(FlightID,FareClass,Capacity) VALUES('TEST01','BUS',2);
 IF NOT EXISTS(SELECT 1 FROM dbo.Inventory WHERE FlightID='TEST02' AND FareClass='ECO') INSERT dbo.Inventory(FlightID,FareClass,Capacity) VALUES('TEST02','ECO',1);
 IF NOT EXISTS(SELECT 1 FROM dbo.Inventory WHERE FlightID='TEST03' AND FareClass='ECO') INSERT dbo.Inventory(FlightID,FareClass,Capacity) VALUES('TEST03','ECO',10);
END;
GO

-- Mỗi mảnh có khách và nhân viên giả lập riêng; không dùng giấy tờ thật [AirBranch_HN]
USE [AirBranch_HN];
GO
IF NOT EXISTS(SELECT 1 FROM dbo.LocalBranch WHERE BranchID='HN')
 INSERT dbo.LocalBranch VALUES('HN',N'Chi nhánh HN');
BEGIN
 DECLARE @Customer uniqueidentifier=CASE 'HN'
 WHEN 'HN' THEN '10000000-0000-0000-0000-000000000001'
 WHEN 'DN' THEN '20000000-0000-0000-0000-000000000001'
 ELSE '30000000-0000-0000-0000-000000000001' END;
 IF NOT EXISTS(SELECT 1 FROM dbo.CustomerProfile WHERE CustomerID=@Customer)
  INSERT dbo.CustomerProfile(CustomerID,BranchID,FullName,BirthDate,Phone,Email,DocumentNo)
  VALUES(@Customer,'HN',N'Khách thử HN 01','2000-01-01','TEST_PHONE',N'lab@example.invalid',N'GIAY_TO_GIA_LAP');
 IF NOT EXISTS(SELECT 1 FROM dbo.Employee WHERE EmployeeID='HN_NV01')
  INSERT dbo.Employee VALUES('HN_NV01','HN',N'Nhân viên thử HN 01',N'Bán vé',1);
END;
GO

-- Mỗi mảnh có khách và nhân viên giả lập riêng; không dùng giấy tờ thật [AirBranch_DN]
USE [AirBranch_DN];
GO
IF NOT EXISTS(SELECT 1 FROM dbo.LocalBranch WHERE BranchID='DN')
 INSERT dbo.LocalBranch VALUES('DN',N'Chi nhánh DN');
BEGIN
 DECLARE @Customer uniqueidentifier=CASE 'DN'
 WHEN 'HN' THEN '10000000-0000-0000-0000-000000000001'
 WHEN 'DN' THEN '20000000-0000-0000-0000-000000000001'
 ELSE '30000000-0000-0000-0000-000000000001' END;
 IF NOT EXISTS(SELECT 1 FROM dbo.CustomerProfile WHERE CustomerID=@Customer)
  INSERT dbo.CustomerProfile(CustomerID,BranchID,FullName,BirthDate,Phone,Email,DocumentNo)
  VALUES(@Customer,'DN',N'Khách thử DN 01','2000-01-01','TEST_PHONE',N'lab@example.invalid',N'GIAY_TO_GIA_LAP');
 IF NOT EXISTS(SELECT 1 FROM dbo.Employee WHERE EmployeeID='DN_NV01')
  INSERT dbo.Employee VALUES('DN_NV01','DN',N'Nhân viên thử DN 01',N'Bán vé',1);
END;
GO

-- Mỗi mảnh có khách và nhân viên giả lập riêng; không dùng giấy tờ thật [AirBranch_HCM]
USE [AirBranch_HCM];
GO
IF NOT EXISTS(SELECT 1 FROM dbo.LocalBranch WHERE BranchID='HCM')
 INSERT dbo.LocalBranch VALUES('HCM',N'Chi nhánh HCM');
BEGIN
 DECLARE @Customer uniqueidentifier=CASE 'HCM'
 WHEN 'HN' THEN '10000000-0000-0000-0000-000000000001'
 WHEN 'DN' THEN '20000000-0000-0000-0000-000000000001'
 ELSE '30000000-0000-0000-0000-000000000001' END;
 IF NOT EXISTS(SELECT 1 FROM dbo.CustomerProfile WHERE CustomerID=@Customer)
  INSERT dbo.CustomerProfile(CustomerID,BranchID,FullName,BirthDate,Phone,Email,DocumentNo)
  VALUES(@Customer,'HCM',N'Khách thử HCM 01','2000-01-01','TEST_PHONE',N'lab@example.invalid',N'GIAY_TO_GIA_LAP');
 IF NOT EXISTS(SELECT 1 FROM dbo.Employee WHERE EmployeeID='HCM_NV01')
  INSERT dbo.Employee VALUES('HCM_NV01','HCM',N'Nhân viên thử HCM 01',N'Bán vé',1);
END;
GO

-- PHẦN 9 - Vai trò tách riêng; chưa tạo login hoặc chứa mật khẩu trong file [AirCore]
USE [AirCore];
GO
IF DATABASE_PRINCIPAL_ID('booking_executor') IS NULL CREATE ROLE booking_executor;
IF DATABASE_PRINCIPAL_ID('refund_operator') IS NULL CREATE ROLE refund_operator;
IF DATABASE_PRINCIPAL_ID('maintenance_executor') IS NULL CREATE ROLE maintenance_executor;
IF DATABASE_PRINCIPAL_ID('report_reader') IS NULL CREATE ROLE report_reader;
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
DENY INSERT,UPDATE,DELETE ON dbo.Ticket TO booking_executor;
GO

-- Tách tài khoản lập đơn và dịch vụ áp dụng kết quả đã xác minh từ S0 [AirBranch_HN]
USE [AirBranch_HN];
GO
IF DATABASE_PRINCIPAL_ID('branch_executor') IS NULL CREATE ROLE branch_executor;
IF DATABASE_PRINCIPAL_ID('branch_sync_service') IS NULL CREATE ROLE branch_sync_service;
IF DATABASE_PRINCIPAL_ID('report_reader') IS NULL CREATE ROLE report_reader;
GRANT EXECUTE ON dbo.usp_CreateOrder TO branch_executor;
GRANT EXECUTE,REFERENCES ON TYPE::dbo.PassengerList TO branch_executor;
GRANT SELECT ON dbo.vCustomerPublic TO branch_executor;
GRANT EXECUTE ON dbo.usp_ApplyHoldResult TO branch_sync_service;
GRANT EXECUTE ON dbo.usp_ApplyIssuedResult TO branch_sync_service;
GRANT EXECUTE,REFERENCES ON TYPE::dbo.TicketList TO branch_sync_service;
GRANT EXECUTE ON dbo.usp_MarkPendingReconcile TO branch_sync_service;
GRANT EXECUTE ON dbo.usp_ApplyCancelledResult TO branch_sync_service;
GRANT SELECT ON dbo.SalesOrder TO report_reader;
-- Không cấp SELECT giấy tờ hành khách cho tài khoản báo cáo.
GO

-- Tách tài khoản lập đơn và dịch vụ áp dụng kết quả đã xác minh từ S0 [AirBranch_DN]
USE [AirBranch_DN];
GO
IF DATABASE_PRINCIPAL_ID('branch_executor') IS NULL CREATE ROLE branch_executor;
IF DATABASE_PRINCIPAL_ID('branch_sync_service') IS NULL CREATE ROLE branch_sync_service;
IF DATABASE_PRINCIPAL_ID('report_reader') IS NULL CREATE ROLE report_reader;
GRANT EXECUTE ON dbo.usp_CreateOrder TO branch_executor;
GRANT EXECUTE,REFERENCES ON TYPE::dbo.PassengerList TO branch_executor;
GRANT SELECT ON dbo.vCustomerPublic TO branch_executor;
GRANT EXECUTE ON dbo.usp_ApplyHoldResult TO branch_sync_service;
GRANT EXECUTE ON dbo.usp_ApplyIssuedResult TO branch_sync_service;
GRANT EXECUTE,REFERENCES ON TYPE::dbo.TicketList TO branch_sync_service;
GRANT EXECUTE ON dbo.usp_MarkPendingReconcile TO branch_sync_service;
GRANT EXECUTE ON dbo.usp_ApplyCancelledResult TO branch_sync_service;
GRANT SELECT ON dbo.SalesOrder TO report_reader;
-- Không cấp SELECT giấy tờ hành khách cho tài khoản báo cáo.
GO

-- Tách tài khoản lập đơn và dịch vụ áp dụng kết quả đã xác minh từ S0 [AirBranch_HCM]
USE [AirBranch_HCM];
GO
IF DATABASE_PRINCIPAL_ID('branch_executor') IS NULL CREATE ROLE branch_executor;
IF DATABASE_PRINCIPAL_ID('branch_sync_service') IS NULL CREATE ROLE branch_sync_service;
IF DATABASE_PRINCIPAL_ID('report_reader') IS NULL CREATE ROLE report_reader;
GRANT EXECUTE ON dbo.usp_CreateOrder TO branch_executor;
GRANT EXECUTE,REFERENCES ON TYPE::dbo.PassengerList TO branch_executor;
GRANT SELECT ON dbo.vCustomerPublic TO branch_executor;
GRANT EXECUTE ON dbo.usp_ApplyHoldResult TO branch_sync_service;
GRANT EXECUTE ON dbo.usp_ApplyIssuedResult TO branch_sync_service;
GRANT EXECUTE,REFERENCES ON TYPE::dbo.TicketList TO branch_sync_service;
GRANT EXECUTE ON dbo.usp_MarkPendingReconcile TO branch_sync_service;
GRANT EXECUTE ON dbo.usp_ApplyCancelledResult TO branch_sync_service;
GRANT SELECT ON dbo.SalesOrder TO report_reader;
-- Không cấp SELECT giấy tờ hành khách cho tài khoản báo cáo.
GO

-- Ứng dụng chi nhánh chỉ đọc danh mục [AirReference_HN]
USE [AirReference_HN];
GO
IF DATABASE_PRINCIPAL_ID('reference_reader') IS NULL CREATE ROLE reference_reader;
GRANT SELECT ON SCHEMA::dbo TO reference_reader;
GO

-- Ứng dụng chi nhánh chỉ đọc danh mục [AirReference_DN]
USE [AirReference_DN];
GO
IF DATABASE_PRINCIPAL_ID('reference_reader') IS NULL CREATE ROLE reference_reader;
GRANT SELECT ON SCHEMA::dbo TO reference_reader;
GO

-- Ứng dụng chi nhánh chỉ đọc danh mục [AirReference_HCM]
USE [AirReference_HCM];
GO
IF DATABASE_PRINCIPAL_ID('reference_reader') IS NULL CREATE ROLE reference_reader;
GRANT SELECT ON SCHEMA::dbo TO reference_reader;
GO

-- Kho nhận chỉ đọc; không ghi lại vào các mảnh nguồn [AirReporting]
USE [AirReporting];
GO
IF DATABASE_PRINCIPAL_ID('report_reader') IS NULL CREATE ROLE report_reader;
GRANT SELECT ON dbo.vSalesOrderGlobal TO report_reader;
GRANT SELECT ON dbo.vSalesItemGlobal TO report_reader;
GRANT SELECT ON dbo.SyncWatermark TO report_reader;
GO

-- PHẦN 8 - Tự chạy các nghiệp vụ mẫu tại cả ba chi nhánh
USE [AirCore];
GO
EXEC dbo.usp_RefreshLabCopies;
GO

-- 8.1 - Bán vé DN - Tạo đơn và danh sách hành khách
USE [AirBranch_DN];
GO

-- Nếu bản trước đã tạo đơn mẫu này, giữ nguyên tên và giấy tờ hành khách của đơn cũ.
IF NOT EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID='40000000-0000-0000-0000-000000000001')
BEGIN
 DECLARE @Passengers dbo.PassengerList;
 INSERT @Passengers VALUES (1,N'Hành khách mẫu DN 01-1',N'DOC_MAU_DN_01_1'),(2,N'Hành khách mẫu DN 01-2',N'DOC_MAU_DN_01_2');
 EXEC dbo.usp_CreateOrder @OrderID='40000000-0000-0000-0000-000000000001',@RequestID='50000000-0000-0000-0000-000000000001',
  @CustomerID='20000000-0000-0000-0000-000000000001',@EmployeeID='DN_NV01',@FlightID='TEST01',
  @FareClass='ECO',@Passengers=@Passengers;
END;
ELSE IF NOT EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID='40000000-0000-0000-0000-000000000001' AND RequestID='50000000-0000-0000-0000-000000000001'
 AND CustomerID='20000000-0000-0000-0000-000000000001' AND EmployeeID='DN_NV01' AND FlightID='TEST01'
 AND FareClass='ECO' AND Quantity=2)
 THROW 51103,N'Mã đơn mẫu đã được dùng với thông tin khác.',1;

GO

-- 8.1 - Bán vé DN - Giữ ghế tại trung tâm
USE [AirCore];
GO

DECLARE @HoldID uniqueidentifier;
EXEC dbo.usp_CreateHold @RequestID='50000000-0000-0000-0000-000000000001',@OrderID='40000000-0000-0000-0000-000000000001',
 @BranchID='DN',@FlightID='TEST01',@FareClass='ECO',@Quantity=2,@HoldID=@HoldID OUTPUT;

GO

-- 8.1 - Bán vé DN - Nhận phản hồi giữ chỗ tại chi nhánh
USE [AirBranch_DN];
GO

DECLARE @HoldID uniqueidentifier,@Price decimal(18,2),@Expiry datetime2(3);
SELECT @HoldID=HoldID,@Price=UnitPrice,@Expiry=ExpiresAt
 FROM AirCore.dbo.SeatHold WHERE RequestID='50000000-0000-0000-0000-000000000001';
EXEC dbo.usp_ApplyHoldResult @OrderID='40000000-0000-0000-0000-000000000001',@RequestID='50000000-0000-0000-0000-000000000001',@HoldID=@HoldID,
 @FlightID='TEST01',@FareClass='ECO',@Quantity=2,@UnitPrice=@Price,@ExpiresAt=@Expiry;

GO

-- 8.1 - Bán vé DN - Xác nhận thanh toán giả lập và phát hành vé
USE [AirCore];
GO

DECLARE @HoldID uniqueidentifier,@PaymentID uniqueidentifier,@Amount decimal(18,2);
SELECT @HoldID=HoldID,@Amount=Quantity*UnitPrice FROM dbo.SeatHold WHERE RequestID='50000000-0000-0000-0000-000000000001';
EXEC dbo.usp_ConfirmHold @HoldID=@HoldID,@BranchID='DN',
 @ExternalRef='DEMO_PAY_001',@Amount=@Amount,@PaymentID=@PaymentID OUTPUT;

GO

-- 8.1 - Bán vé DN - Gắn vé chính thức vào từng hành khách
USE [AirBranch_DN];
GO

DECLARE @Tickets dbo.TicketList,@HoldID uniqueidentifier,@PaymentID uniqueidentifier;
SELECT @HoldID=h.HoldID,@PaymentID=p.PaymentID FROM AirCore.dbo.SeatHold h
 JOIN AirCore.dbo.Payment p ON p.HoldID=h.HoldID WHERE h.RequestID='50000000-0000-0000-0000-000000000001';
INSERT @Tickets SELECT ItemNo,TicketID FROM AirCore.dbo.Ticket WHERE HoldID=@HoldID;
EXEC dbo.usp_ApplyIssuedResult @OrderID='40000000-0000-0000-0000-000000000001',@HoldID=@HoldID,@PaymentID=@PaymentID,@Tickets=@Tickets;

GO

-- 8.2 - Bán vé HN - Tạo đơn và danh sách hành khách
USE [AirBranch_HN];
GO

-- Nếu bản trước đã tạo đơn mẫu này, giữ nguyên tên và giấy tờ hành khách của đơn cũ.
IF NOT EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID='40000000-0000-0000-0000-000000000002')
BEGIN
 DECLARE @Passengers dbo.PassengerList;
 INSERT @Passengers VALUES (1,N'Hành khách mẫu HN 02-1',N'DOC_MAU_HN_02_1');
 EXEC dbo.usp_CreateOrder @OrderID='40000000-0000-0000-0000-000000000002',@RequestID='50000000-0000-0000-0000-000000000002',
  @CustomerID='10000000-0000-0000-0000-000000000001',@EmployeeID='HN_NV01',@FlightID='TEST01',
  @FareClass='ECO',@Passengers=@Passengers;
END;
ELSE IF NOT EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID='40000000-0000-0000-0000-000000000002' AND RequestID='50000000-0000-0000-0000-000000000002'
 AND CustomerID='10000000-0000-0000-0000-000000000001' AND EmployeeID='HN_NV01' AND FlightID='TEST01'
 AND FareClass='ECO' AND Quantity=1)
 THROW 51103,N'Mã đơn mẫu đã được dùng với thông tin khác.',1;

GO

-- 8.2 - Bán vé HN - Giữ ghế tại trung tâm
USE [AirCore];
GO

DECLARE @HoldID uniqueidentifier;
EXEC dbo.usp_CreateHold @RequestID='50000000-0000-0000-0000-000000000002',@OrderID='40000000-0000-0000-0000-000000000002',
 @BranchID='HN',@FlightID='TEST01',@FareClass='ECO',@Quantity=1,@HoldID=@HoldID OUTPUT;

GO

-- 8.2 - Bán vé HN - Nhận phản hồi giữ chỗ tại chi nhánh
USE [AirBranch_HN];
GO

DECLARE @HoldID uniqueidentifier,@Price decimal(18,2),@Expiry datetime2(3);
SELECT @HoldID=HoldID,@Price=UnitPrice,@Expiry=ExpiresAt
 FROM AirCore.dbo.SeatHold WHERE RequestID='50000000-0000-0000-0000-000000000002';
EXEC dbo.usp_ApplyHoldResult @OrderID='40000000-0000-0000-0000-000000000002',@RequestID='50000000-0000-0000-0000-000000000002',@HoldID=@HoldID,
 @FlightID='TEST01',@FareClass='ECO',@Quantity=1,@UnitPrice=@Price,@ExpiresAt=@Expiry;

GO

-- 8.2 - Bán vé HN - Xác nhận thanh toán giả lập và phát hành vé
USE [AirCore];
GO

DECLARE @HoldID uniqueidentifier,@PaymentID uniqueidentifier,@Amount decimal(18,2);
SELECT @HoldID=HoldID,@Amount=Quantity*UnitPrice FROM dbo.SeatHold WHERE RequestID='50000000-0000-0000-0000-000000000002';
EXEC dbo.usp_ConfirmHold @HoldID=@HoldID,@BranchID='HN',
 @ExternalRef='DEMO_PAY_HN_001',@Amount=@Amount,@PaymentID=@PaymentID OUTPUT;

GO

-- 8.2 - Bán vé HN - Gắn vé chính thức vào từng hành khách
USE [AirBranch_HN];
GO

DECLARE @Tickets dbo.TicketList,@HoldID uniqueidentifier,@PaymentID uniqueidentifier;
SELECT @HoldID=h.HoldID,@PaymentID=p.PaymentID FROM AirCore.dbo.SeatHold h
 JOIN AirCore.dbo.Payment p ON p.HoldID=h.HoldID WHERE h.RequestID='50000000-0000-0000-0000-000000000002';
INSERT @Tickets SELECT ItemNo,TicketID FROM AirCore.dbo.Ticket WHERE HoldID=@HoldID;
EXEC dbo.usp_ApplyIssuedResult @OrderID='40000000-0000-0000-0000-000000000002',@HoldID=@HoldID,@PaymentID=@PaymentID,@Tickets=@Tickets;

GO

-- 8.3 - Bán vé HCM - Tạo đơn và danh sách hành khách
USE [AirBranch_HCM];
GO

-- Nếu bản trước đã tạo đơn mẫu này, giữ nguyên tên và giấy tờ hành khách của đơn cũ.
IF NOT EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID='40000000-0000-0000-0000-000000000003')
BEGIN
 DECLARE @Passengers dbo.PassengerList;
 INSERT @Passengers VALUES (1,N'Hành khách mẫu HCM 03-1',N'DOC_MAU_HCM_03_1');
 EXEC dbo.usp_CreateOrder @OrderID='40000000-0000-0000-0000-000000000003',@RequestID='50000000-0000-0000-0000-000000000003',
  @CustomerID='30000000-0000-0000-0000-000000000001',@EmployeeID='HCM_NV01',@FlightID='TEST01',
  @FareClass='ECO',@Passengers=@Passengers;
END;
ELSE IF NOT EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID='40000000-0000-0000-0000-000000000003' AND RequestID='50000000-0000-0000-0000-000000000003'
 AND CustomerID='30000000-0000-0000-0000-000000000001' AND EmployeeID='HCM_NV01' AND FlightID='TEST01'
 AND FareClass='ECO' AND Quantity=1)
 THROW 51103,N'Mã đơn mẫu đã được dùng với thông tin khác.',1;

GO

-- 8.3 - Bán vé HCM - Giữ ghế tại trung tâm
USE [AirCore];
GO

DECLARE @HoldID uniqueidentifier;
EXEC dbo.usp_CreateHold @RequestID='50000000-0000-0000-0000-000000000003',@OrderID='40000000-0000-0000-0000-000000000003',
 @BranchID='HCM',@FlightID='TEST01',@FareClass='ECO',@Quantity=1,@HoldID=@HoldID OUTPUT;

GO

-- 8.3 - Bán vé HCM - Nhận phản hồi giữ chỗ tại chi nhánh
USE [AirBranch_HCM];
GO

DECLARE @HoldID uniqueidentifier,@Price decimal(18,2),@Expiry datetime2(3);
SELECT @HoldID=HoldID,@Price=UnitPrice,@Expiry=ExpiresAt
 FROM AirCore.dbo.SeatHold WHERE RequestID='50000000-0000-0000-0000-000000000003';
EXEC dbo.usp_ApplyHoldResult @OrderID='40000000-0000-0000-0000-000000000003',@RequestID='50000000-0000-0000-0000-000000000003',@HoldID=@HoldID,
 @FlightID='TEST01',@FareClass='ECO',@Quantity=1,@UnitPrice=@Price,@ExpiresAt=@Expiry;

GO

-- 8.3 - Bán vé HCM - Xác nhận thanh toán giả lập và phát hành vé
USE [AirCore];
GO

DECLARE @HoldID uniqueidentifier,@PaymentID uniqueidentifier,@Amount decimal(18,2);
SELECT @HoldID=HoldID,@Amount=Quantity*UnitPrice FROM dbo.SeatHold WHERE RequestID='50000000-0000-0000-0000-000000000003';
EXEC dbo.usp_ConfirmHold @HoldID=@HoldID,@BranchID='HCM',
 @ExternalRef='DEMO_PAY_HCM_001',@Amount=@Amount,@PaymentID=@PaymentID OUTPUT;

GO

-- 8.3 - Bán vé HCM - Gắn vé chính thức vào từng hành khách
USE [AirBranch_HCM];
GO

DECLARE @Tickets dbo.TicketList,@HoldID uniqueidentifier,@PaymentID uniqueidentifier;
SELECT @HoldID=h.HoldID,@PaymentID=p.PaymentID FROM AirCore.dbo.SeatHold h
 JOIN AirCore.dbo.Payment p ON p.HoldID=h.HoldID WHERE h.RequestID='50000000-0000-0000-0000-000000000003';
INSERT @Tickets SELECT ItemNo,TicketID FROM AirCore.dbo.Ticket WHERE HoldID=@HoldID;
EXEC dbo.usp_ApplyIssuedResult @OrderID='40000000-0000-0000-0000-000000000003',@HoldID=@HoldID,@PaymentID=@PaymentID,@Tickets=@Tickets;

GO

-- 8.4 - Hủy đơn chưa phát hành - Tạo đơn và danh sách hành khách
USE [AirBranch_HN];
GO

-- Nếu bản trước đã tạo đơn mẫu này, giữ nguyên tên và giấy tờ hành khách của đơn cũ.
IF NOT EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID='40000000-0000-0000-0000-000000000004')
BEGIN
 DECLARE @Passengers dbo.PassengerList;
 INSERT @Passengers VALUES (1,N'Hành khách mẫu HN 04-1',N'DOC_MAU_HN_04_1');
 EXEC dbo.usp_CreateOrder @OrderID='40000000-0000-0000-0000-000000000004',@RequestID='50000000-0000-0000-0000-000000000004',
  @CustomerID='10000000-0000-0000-0000-000000000001',@EmployeeID='HN_NV01',@FlightID='TEST01',
  @FareClass='ECO',@Passengers=@Passengers;
END;
ELSE IF NOT EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID='40000000-0000-0000-0000-000000000004' AND RequestID='50000000-0000-0000-0000-000000000004'
 AND CustomerID='10000000-0000-0000-0000-000000000001' AND EmployeeID='HN_NV01' AND FlightID='TEST01'
 AND FareClass='ECO' AND Quantity=1)
 THROW 51103,N'Mã đơn mẫu đã được dùng với thông tin khác.',1;

GO

-- 8.4 - Hủy đơn chưa phát hành - Giữ ghế tại trung tâm
USE [AirCore];
GO

DECLARE @HoldID uniqueidentifier;
EXEC dbo.usp_CreateHold @RequestID='50000000-0000-0000-0000-000000000004',@OrderID='40000000-0000-0000-0000-000000000004',
 @BranchID='HN',@FlightID='TEST01',@FareClass='ECO',@Quantity=1,@HoldID=@HoldID OUTPUT;

GO

-- 8.4 - Hủy đơn chưa phát hành - Nhận phản hồi giữ chỗ tại chi nhánh
USE [AirBranch_HN];
GO

DECLARE @HoldID uniqueidentifier,@Price decimal(18,2),@Expiry datetime2(3);
SELECT @HoldID=HoldID,@Price=UnitPrice,@Expiry=ExpiresAt
 FROM AirCore.dbo.SeatHold WHERE RequestID='50000000-0000-0000-0000-000000000004';
EXEC dbo.usp_ApplyHoldResult @OrderID='40000000-0000-0000-0000-000000000004',@RequestID='50000000-0000-0000-0000-000000000004',@HoldID=@HoldID,
 @FlightID='TEST01',@FareClass='ECO',@Quantity=1,@UnitPrice=@Price,@ExpiresAt=@Expiry;

GO

-- 8.4 - Hủy giữ chỗ nguồn; trả lại ghế
USE [AirCore];
GO

DECLARE @HoldID uniqueidentifier=(SELECT HoldID FROM dbo.SeatHold WHERE RequestID='50000000-0000-0000-0000-000000000004');
EXEC dbo.usp_CancelHold @HoldID=@HoldID,@BranchID='HN';

GO

-- 8.4 - Cập nhật đơn hủy tại Hà Nội
USE [AirBranch_HN];
GO

DECLARE @HoldID uniqueidentifier=(SELECT HoldID FROM AirCore.dbo.SeatHold WHERE RequestID='50000000-0000-0000-0000-000000000004' AND Status='CANCELLED');
IF @HoldID IS NOT NULL EXEC dbo.usp_ApplyCancelledResult @OrderID='40000000-0000-0000-0000-000000000004',@HoldID=@HoldID;

GO

-- 8.5 - Hoàn vé HCM một lần; giảm Sold, giữ lịch sử phát hành của đơn
USE [AirCore];
GO

DECLARE @TicketID uniqueidentifier,@RefundID uniqueidentifier;
SELECT @TicketID=t.TicketID FROM dbo.Ticket t JOIN dbo.SeatHold h ON h.HoldID=t.HoldID
 WHERE h.RequestID='50000000-0000-0000-0000-000000000003' AND t.ItemNo=1;
EXEC dbo.usp_RefundTicket @TicketID=@TicketID,@BranchID='HCM',
 @ExternalRef='DEMO_REFUND_HCM_001',@RefundID=@RefundID OUTPUT;

GO

-- 8.6 - Giữ chỗ đã hết hạn - Tạo đơn và danh sách hành khách
USE [AirBranch_HCM];
GO

-- Nếu bản trước đã tạo đơn mẫu này, giữ nguyên tên và giấy tờ hành khách của đơn cũ.
IF NOT EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID='40000000-0000-0000-0000-000000000005')
BEGIN
 DECLARE @Passengers dbo.PassengerList;
 INSERT @Passengers VALUES (1,N'Hành khách mẫu HCM 05-1',N'DOC_MAU_HCM_05_1');
 EXEC dbo.usp_CreateOrder @OrderID='40000000-0000-0000-0000-000000000005',@RequestID='50000000-0000-0000-0000-000000000005',
  @CustomerID='30000000-0000-0000-0000-000000000001',@EmployeeID='HCM_NV01',@FlightID='TEST01',
  @FareClass='ECO',@Passengers=@Passengers;
END;
ELSE IF NOT EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID='40000000-0000-0000-0000-000000000005' AND RequestID='50000000-0000-0000-0000-000000000005'
 AND CustomerID='30000000-0000-0000-0000-000000000001' AND EmployeeID='HCM_NV01' AND FlightID='TEST01'
 AND FareClass='ECO' AND Quantity=1)
 THROW 51103,N'Mã đơn mẫu đã được dùng với thông tin khác.',1;

GO

-- 8.6 - Tạo dữ liệu mẫu giữ chỗ đã quá hạn tại trung tâm
USE [AirCore];
GO

-- Dữ liệu kiểm thử có thời hạn trong quá khứ để minh họa hết hạn ngay, không cần chờ 10 phút.
-- Không sửa thời hạn của giữ chỗ thật; chỉ khởi tạo mã yêu cầu mẫu này một lần.
IF NOT EXISTS(SELECT 1 FROM dbo.SeatHold WHERE RequestID='50000000-0000-0000-0000-000000000005')
BEGIN
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Now datetime2(3)=SYSUTCDATETIME(),@Price decimal(18,2);
  SELECT @Price=Price FROM dbo.Fare WHERE FlightID='TEST01' AND FareClass='ECO';
  UPDATE dbo.Inventory SET Held=Held+1,UpdatedAt=@Now
   WHERE FlightID='TEST01' AND FareClass='ECO' AND Capacity-Held-Sold>=1;
  IF @@ROWCOUNT<>1 THROW 51009,N'Không đủ ghế cho dữ liệu kiểm thử hết hạn.',1;
  INSERT dbo.SeatHold(HoldID,RequestID,OrderID,BranchID,FlightID,FareClass,Quantity,UnitPrice,Status,CreatedAt,ExpiresAt)
  VALUES(NEWID(),'50000000-0000-0000-0000-000000000005','40000000-0000-0000-0000-000000000005','HCM','TEST01','ECO',1,@Price,'ACTIVE',DATEADD(minute,-20,@Now),DATEADD(minute,-1,@Now));
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;

GO

-- 8.6 - Gắn mã giữ chỗ mẫu cho đơn tại HCM
USE [AirBranch_HCM];
GO

DECLARE @HoldID uniqueidentifier,@Price decimal(18,2),@Expiry datetime2(3);
SELECT @HoldID=HoldID,@Price=UnitPrice,@Expiry=ExpiresAt FROM AirCore.dbo.SeatHold WHERE RequestID='50000000-0000-0000-0000-000000000005';
EXEC dbo.usp_ApplyHoldResult @OrderID='40000000-0000-0000-0000-000000000005',@RequestID='50000000-0000-0000-0000-000000000005',@HoldID=@HoldID,
 @FlightID='TEST01',@FareClass='ECO',@Quantity=1,@UnitPrice=@Price,@ExpiresAt=@Expiry;

GO

-- 8.6 - Giải phóng các giữ chỗ hết hạn
USE [AirCore];
GO
EXEC dbo.usp_ExpireHolds @BatchSize=100;
GO

-- 8.6 - Cập nhật đơn hết hạn tại HCM
USE [AirBranch_HCM];
GO

DECLARE @HoldID uniqueidentifier=(SELECT HoldID FROM AirCore.dbo.SeatHold WHERE RequestID='50000000-0000-0000-0000-000000000005' AND Status='EXPIRED');
IF @HoldID IS NOT NULL EXEC dbo.usp_ApplyCancelledResult @OrderID='40000000-0000-0000-0000-000000000005',@HoldID=@HoldID;

GO

-- PHẦN 9 - Tự sao chép các mảnh và hiển thị báo cáo nghiệp vụ
USE [AirCore];
GO

EXEC dbo.usp_RefreshLabCopies;
-- Một lần gọi sao chép các bảng danh mục vào ba AirReference và các mảnh bán vào AirReporting.
SELECT N'Kho ghế nguồn' AS KetQua,* FROM dbo.vFlightAvailability ORDER BY FlightID,FareClass;
SELECT N'Giữ chỗ' AS KetQua,HoldID,OrderID,BranchID,FlightID,FareClass,Quantity,Status FROM dbo.SeatHold ORDER BY BranchID,CreatedAt;
SELECT N'Vé' AS KetQua,h.BranchID,t.* FROM dbo.Ticket t JOIN dbo.SeatHold h ON h.HoldID=t.HoldID ORDER BY h.BranchID,t.ItemNo;
SELECT N'Thanh toán' AS KetQua,* FROM dbo.Payment;
SELECT N'Hoàn vé' AS KetQua,* FROM dbo.Refund;
DECLARE @From datetime2(3)='2000-01-01',@To datetime2(3)='2100-01-01';
EXEC dbo.usp_RevenueByBranch @FromUtc=@From,@ToUtc=@To;
EXEC dbo.usp_HighLoadFlights @Threshold=20;
-- Bốn result set đối soát bên dưới đều phải rỗng.
EXEC dbo.usp_CheckInvariants;

GO

-- PHẦN 10 - Truy vấn tái thiết bằng UNION ALL và kiểm tra các mảnh
USE [AirReporting];
GO

SELECT N'Đơn bán toàn cục' AS KetQua,* FROM dbo.vSalesOrderGlobal ORDER BY BranchID,CreatedAt;
SELECT N'Chi tiết toàn cục (không có giấy tờ)' AS KetQua,* FROM dbo.vSalesItemGlobal ORDER BY OrderID,ItemNo;
SELECT N'Thời điểm sao chép' AS KetQua,* FROM dbo.SyncWatermark;
-- Các query phát hiện đơn trùng và chi tiết mồ côi đều phải rỗng.
SELECT OrderID,COUNT(*) AS DuplicateCount FROM dbo.vSalesOrderGlobal GROUP BY OrderID HAVING COUNT(*)>1;
SELECT i.OrderID,i.ItemNo FROM dbo.vSalesItemGlobal i
 LEFT JOIN dbo.vSalesOrderGlobal o ON o.OrderID=i.OrderID WHERE o.OrderID IS NULL;

GO

-- 10 - Bản sao danh mục HN
USE [AirReference_HN];
GO
SELECT FlightID,FlightNo,RouteID,DepartureUtc,Status FROM dbo.Flight ORDER BY FlightID; SELECT * FROM dbo.SyncWatermark;
GO

-- 10 - Bản sao danh mục DN
USE [AirReference_DN];
GO
SELECT FlightID,FlightNo,RouteID,DepartureUtc,Status FROM dbo.Flight ORDER BY FlightID; SELECT * FROM dbo.SyncWatermark;
GO

-- 10 - Bản sao danh mục HCM
USE [AirReference_HCM];
GO
SELECT FlightID,FlightNo,RouteID,DepartureUtc,Status FROM dbo.Flight ORDER BY FlightID; SELECT * FROM dbo.SyncWatermark;
GO

-- 10 - Tái thiết hồ sơ qua hai view chiếu dọc theo CustomerID
USE [AirBranch_HN];
GO

SELECT p.CustomerID,p.BranchID,p.FullName,p.BirthDate,s.Phone,s.Email,s.DocumentNo
 FROM dbo.vCustomerPublic p JOIN dbo.vCustomerPrivate s ON s.CustomerID=p.CustomerID;

GO

-- Khôi phục chế độ thực thi nếu phần khởi tạo đã dừng do trùng tên database ngoài dự án.
SET NOEXEC OFF;
GO
USE master;
GO
IF (SELECT Ready FROM #RunState)<>1
 THROW 51000,N'Không thể khởi tạo dự án. Xem lỗi đầu tiên trong Messages.',1;
-- Chỉ in thông báo hoàn thành khi cả năm tình huống mẫu đã xử lý thành công.
IF (SELECT COUNT(*) FROM AirReporting.dbo.vSalesOrderGlobal
 WHERE OrderID IN ('40000000-0000-0000-0000-000000000001','40000000-0000-0000-0000-000000000002',
                  '40000000-0000-0000-0000-000000000003') AND Status='ISSUED')<>3
 OR (SELECT COUNT(*) FROM AirReporting.dbo.vSalesOrderGlobal
 WHERE OrderID IN ('40000000-0000-0000-0000-000000000004','40000000-0000-0000-0000-000000000005') AND Status='CANCELLED')<>2
 OR NOT EXISTS(SELECT 1 FROM AirCore.dbo.Refund WHERE ExternalRef='DEMO_REFUND_HCM_001')
 THROW 51999,N'Nghiệp vụ mẫu chưa hoàn tất. Xem lỗi trong Messages và kết quả đối soát.',1;
SELECT name AS DatabaseDuAn,state_desc FROM sys.databases
 WHERE name IN ('AirCore','AirReporting','AirBranch_HN','AirBranch_DN','AirBranch_HCM',
                'AirReference_HN','AirReference_DN','AirReference_HCM') ORDER BY name;
PRINT N'HOÀN THÀNH: tạo dữ liệu, bán vé tại ba chi nhánh, hủy đơn, hoàn vé, hết hạn và báo cáo.';
PRINT N'Khi chạy mới: 5 đơn mẫu (3 ISSUED, 2 CANCELLED); 4 vé (3 ISSUED, 1 REFUNDED).';
PRINT N'Kho TEST01/ECO: Held=0, Sold=3, Available=7. Thu=6.000.000; hoàn=1.500.000; thu ròng=4.500.000 VND.';
PRINT N'Chạy lại trên dữ liệu này giữ nguyên các kết quả; dữ liệu bổ sung của bạn được giữ lại.';
GO
