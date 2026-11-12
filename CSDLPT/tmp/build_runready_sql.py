from pathlib import Path
import ast
import textwrap

ROOT=Path(__file__).resolve().parent.parent
source_path=ROOT/'tmp/build_project_sql.py'
records=[]
def raw(s): records.append(('raw',textwrap.dedent(s).strip()))
def deploy(kind,sql,title): records.append(('module',kind,textwrap.dedent(sql).strip(),title))
tree=ast.parse(source_path.read_text(encoding='utf-8').split('\nOUT.write_text(')[0])
tree.body=[n for n in tree.body if not (isinstance(n,ast.FunctionDef) and n.name in ('raw','deploy'))]
exec(compile(tree,str(source_path),'exec'),{'__file__':str(source_path),'raw':raw,'deploy':deploy})

parts=[]
def add(s): parts.append(textwrap.dedent(s).strip()+'\n')
def block(db,sql,title):
    add(f'-- {title}\nUSE [{db}];\nGO\n{sql}\nGO')

add('''
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
''')
targets={'CORE':[('AirCore','')],'REPORT':[('AirReporting','')],
 'BRANCH':[(f'AirBranch_{b}',b) for b in ['HN','DN','HCM']],
 'REFERENCE':[(f'AirReference_{b}',b) for b in ['HN','DN','HCM']]}
for kind in ['CORE','REPORT','BRANCH','REFERENCE']:
    for db,_ in targets[kind]:
        add(f'''
 IF DB_ID(N'{db}') IS NULL
 BEGIN
  EXEC(N'CREATE DATABASE [{db}] COLLATE Latin1_General_100_CI_AS_SC;');
  EXEC [{db}].sys.sp_addextendedproperty @name=N'AirLabProject',@value=N'CSDLPT_NHOM8_V1';
 END;
 IF NOT EXISTS(SELECT 1 FROM [{db}].sys.extended_properties
  WHERE class=0 AND name=N'AirLabProject' AND CONVERT(nvarchar(100),value)=N'CSDLPT_NHOM8_V1')
  THROW 51000,N'Database {db} đã tồn tại và không thuộc dự án của nhóm.',1;
''')
add('''
 UPDATE #RunState SET Ready=1;
END TRY
BEGIN CATCH
 PRINT ERROR_MESSAGE();
 -- Dừng thực thi các batch sau trong SSMS nếu khởi tạo thất bại.
 SET NOEXEC ON;
END CATCH;
GO
''')

for rec in records:
    if rec[0]!='module': continue
    _,kind,body,title=rec
    # A runnable lab does not need placeholders or unconfigured replication/Agent services.
    if any(name in body for name in ['PROCEDURE dbo.usp_CreatePublication',
                                    'PROCEDURE dbo.usp_CreatePushSubscription',
                                    'PROCEDURE dbo.usp_CreateExpiryJob']): continue
    body=body.replace('IF (SELECT SeedData FROM #ProjectOptions)=1\n','')
    for db,branch in targets[kind]:
        block(db,body.replace('{{BRANCH}}',branch),title+f' [{db}]')

# Data and modules are ready. Every demonstration below uses actual generated IDs.
block('AirCore','EXEC dbo.usp_RefreshLabCopies;','PHẦN 8 - Tự chạy các nghiệp vụ mẫu tại cả ba chi nhánh')

def order(branch,num,quantity,title):
    customer={'HN':'10000000','DN':'20000000','HCM':'30000000'}[branch]+'-0000-0000-0000-000000000001'
    oid=f'40000000-0000-0000-0000-{num:012d}'
    rid=f'50000000-0000-0000-0000-{num:012d}'
    passengers=','.join(f"({i},N'Hành khách mẫu {branch} {num:02d}-{i}',N'DOC_MAU_{branch}_{num:02d}_{i}')" for i in range(1,quantity+1))
    block(f'AirBranch_{branch}',f'''
-- Nếu bản trước đã tạo đơn mẫu này, giữ nguyên tên và giấy tờ hành khách của đơn cũ.
IF NOT EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID='{oid}')
BEGIN
 DECLARE @Passengers dbo.PassengerList;
 INSERT @Passengers VALUES {passengers};
 EXEC dbo.usp_CreateOrder @OrderID='{oid}',@RequestID='{rid}',
  @CustomerID='{customer}',@EmployeeID='{branch}_NV01',@FlightID='TEST01',
  @FareClass='ECO',@Passengers=@Passengers;
END;
ELSE IF NOT EXISTS(SELECT 1 FROM dbo.SalesOrder WHERE OrderID='{oid}' AND RequestID='{rid}'
 AND CustomerID='{customer}' AND EmployeeID='{branch}_NV01' AND FlightID='TEST01'
 AND FareClass='ECO' AND Quantity={quantity})
 THROW 51103,N'Mã đơn mẫu đã được dùng với thông tin khác.',1;
''',title+' - Tạo đơn và danh sách hành khách')
    return oid,rid

def hold_and_apply(branch,oid,rid,quantity,title):
    block('AirCore',f'''
DECLARE @HoldID uniqueidentifier;
EXEC dbo.usp_CreateHold @RequestID='{rid}',@OrderID='{oid}',
 @BranchID='{branch}',@FlightID='TEST01',@FareClass='ECO',@Quantity={quantity},@HoldID=@HoldID OUTPUT;
''',title+' - Giữ ghế tại trung tâm')
    block(f'AirBranch_{branch}',f'''
DECLARE @HoldID uniqueidentifier,@Price decimal(18,2),@Expiry datetime2(3);
SELECT @HoldID=HoldID,@Price=UnitPrice,@Expiry=ExpiresAt
 FROM AirCore.dbo.SeatHold WHERE RequestID='{rid}';
EXEC dbo.usp_ApplyHoldResult @OrderID='{oid}',@RequestID='{rid}',@HoldID=@HoldID,
 @FlightID='TEST01',@FareClass='ECO',@Quantity={quantity},@UnitPrice=@Price,@ExpiresAt=@Expiry;
''',title+' - Nhận phản hồi giữ chỗ tại chi nhánh')

for branch,num,quantity,payref in [('DN',1,2,'DEMO_PAY_001'),('HN',2,1,'DEMO_PAY_HN_001'),('HCM',3,1,'DEMO_PAY_HCM_001')]:
    title=f'8.{num} - Bán vé {branch}'
    oid,rid=order(branch,num,quantity,title)
    hold_and_apply(branch,oid,rid,quantity,title)
    block('AirCore',f'''
DECLARE @HoldID uniqueidentifier,@PaymentID uniqueidentifier,@Amount decimal(18,2);
SELECT @HoldID=HoldID,@Amount=Quantity*UnitPrice FROM dbo.SeatHold WHERE RequestID='{rid}';
EXEC dbo.usp_ConfirmHold @HoldID=@HoldID,@BranchID='{branch}',
 @ExternalRef='{payref}',@Amount=@Amount,@PaymentID=@PaymentID OUTPUT;
''',title+' - Xác nhận thanh toán giả lập và phát hành vé')
    block(f'AirBranch_{branch}',f'''
DECLARE @Tickets dbo.TicketList,@HoldID uniqueidentifier,@PaymentID uniqueidentifier;
SELECT @HoldID=h.HoldID,@PaymentID=p.PaymentID FROM AirCore.dbo.SeatHold h
 JOIN AirCore.dbo.Payment p ON p.HoldID=h.HoldID WHERE h.RequestID='{rid}';
INSERT @Tickets SELECT ItemNo,TicketID FROM AirCore.dbo.Ticket WHERE HoldID=@HoldID;
EXEC dbo.usp_ApplyIssuedResult @OrderID='{oid}',@HoldID=@HoldID,@PaymentID=@PaymentID,@Tickets=@Tickets;
''',title+' - Gắn vé chính thức vào từng hành khách')

oid,rid=order('HN',4,1,'8.4 - Hủy đơn chưa phát hành')
hold_and_apply('HN',oid,rid,1,'8.4 - Hủy đơn chưa phát hành')
block('AirCore',f'''
DECLARE @HoldID uniqueidentifier=(SELECT HoldID FROM dbo.SeatHold WHERE RequestID='{rid}');
EXEC dbo.usp_CancelHold @HoldID=@HoldID,@BranchID='HN';
''','8.4 - Hủy giữ chỗ nguồn; trả lại ghế')
block('AirBranch_HN',f'''
DECLARE @HoldID uniqueidentifier=(SELECT HoldID FROM AirCore.dbo.SeatHold WHERE RequestID='{rid}' AND Status='CANCELLED');
IF @HoldID IS NOT NULL EXEC dbo.usp_ApplyCancelledResult @OrderID='{oid}',@HoldID=@HoldID;
''','8.4 - Cập nhật đơn hủy tại Hà Nội')

block('AirCore','''
DECLARE @TicketID uniqueidentifier,@RefundID uniqueidentifier;
SELECT @TicketID=t.TicketID FROM dbo.Ticket t JOIN dbo.SeatHold h ON h.HoldID=t.HoldID
 WHERE h.RequestID='50000000-0000-0000-0000-000000000003' AND t.ItemNo=1;
EXEC dbo.usp_RefundTicket @TicketID=@TicketID,@BranchID='HCM',
 @ExternalRef='DEMO_REFUND_HCM_001',@RefundID=@RefundID OUTPUT;
''','8.5 - Hoàn vé HCM một lần; giảm Sold, giữ lịch sử phát hành của đơn')

oid,rid=order('HCM',5,1,'8.6 - Giữ chỗ đã hết hạn')
block('AirCore',f'''
-- Dữ liệu kiểm thử có thời hạn trong quá khứ để minh họa hết hạn ngay, không cần chờ 10 phút.
-- Không sửa thời hạn của giữ chỗ thật; chỉ khởi tạo mã yêu cầu mẫu này một lần.
IF NOT EXISTS(SELECT 1 FROM dbo.SeatHold WHERE RequestID='{rid}')
BEGIN
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @Now datetime2(3)=SYSUTCDATETIME(),@Price decimal(18,2);
  SELECT @Price=Price FROM dbo.Fare WHERE FlightID='TEST01' AND FareClass='ECO';
  UPDATE dbo.Inventory SET Held=Held+1,UpdatedAt=@Now
   WHERE FlightID='TEST01' AND FareClass='ECO' AND Capacity-Held-Sold>=1;
  IF @@ROWCOUNT<>1 THROW 51009,N'Không đủ ghế cho dữ liệu kiểm thử hết hạn.',1;
  INSERT dbo.SeatHold(HoldID,RequestID,OrderID,BranchID,FlightID,FareClass,Quantity,UnitPrice,Status,CreatedAt,ExpiresAt)
  VALUES(NEWID(),'{rid}','{oid}','HCM','TEST01','ECO',1,@Price,'ACTIVE',DATEADD(minute,-20,@Now),DATEADD(minute,-1,@Now));
  COMMIT;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;
''','8.6 - Tạo dữ liệu mẫu giữ chỗ đã quá hạn tại trung tâm')
block('AirBranch_HCM',f'''
DECLARE @HoldID uniqueidentifier,@Price decimal(18,2),@Expiry datetime2(3);
SELECT @HoldID=HoldID,@Price=UnitPrice,@Expiry=ExpiresAt FROM AirCore.dbo.SeatHold WHERE RequestID='{rid}';
EXEC dbo.usp_ApplyHoldResult @OrderID='{oid}',@RequestID='{rid}',@HoldID=@HoldID,
 @FlightID='TEST01',@FareClass='ECO',@Quantity=1,@UnitPrice=@Price,@ExpiresAt=@Expiry;
''','8.6 - Gắn mã giữ chỗ mẫu cho đơn tại HCM')
block('AirCore','EXEC dbo.usp_ExpireHolds @BatchSize=100;','8.6 - Giải phóng các giữ chỗ hết hạn')
block('AirBranch_HCM',f'''
DECLARE @HoldID uniqueidentifier=(SELECT HoldID FROM AirCore.dbo.SeatHold WHERE RequestID='{rid}' AND Status='EXPIRED');
IF @HoldID IS NOT NULL EXEC dbo.usp_ApplyCancelledResult @OrderID='{oid}',@HoldID=@HoldID;
''','8.6 - Cập nhật đơn hết hạn tại HCM')

block('AirCore','''
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
''','PHẦN 9 - Tự sao chép các mảnh và hiển thị báo cáo nghiệp vụ')
block('AirReporting','''
SELECT N'Đơn bán toàn cục' AS KetQua,* FROM dbo.vSalesOrderGlobal ORDER BY BranchID,CreatedAt;
SELECT N'Chi tiết toàn cục (không có giấy tờ)' AS KetQua,* FROM dbo.vSalesItemGlobal ORDER BY OrderID,ItemNo;
SELECT N'Thời điểm sao chép' AS KetQua,* FROM dbo.SyncWatermark;
-- Các query phát hiện đơn trùng và chi tiết mồ côi đều phải rỗng.
SELECT OrderID,COUNT(*) AS DuplicateCount FROM dbo.vSalesOrderGlobal GROUP BY OrderID HAVING COUNT(*)>1;
SELECT i.OrderID,i.ItemNo FROM dbo.vSalesItemGlobal i
 LEFT JOIN dbo.vSalesOrderGlobal o ON o.OrderID=i.OrderID WHERE o.OrderID IS NULL;
''','PHẦN 10 - Truy vấn tái thiết bằng UNION ALL và kiểm tra các mảnh')
for branch in ['HN','DN','HCM']:
    block(f'AirReference_{branch}',"SELECT FlightID,FlightNo,RouteID,DepartureUtc,Status FROM dbo.Flight ORDER BY FlightID; SELECT * FROM dbo.SyncWatermark;",f'10 - Bản sao danh mục {branch}')
block('AirBranch_HN','''
SELECT p.CustomerID,p.BranchID,p.FullName,p.BirthDate,s.Phone,s.Email,s.DocumentNo
 FROM dbo.vCustomerPublic p JOIN dbo.vCustomerPrivate s ON s.CustomerID=p.CustomerID;
''','10 - Tái thiết hồ sơ qua hai view chiếu dọc theo CustomerID')
add('''
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
''')

out=ROOT/'output/Truy_van_xay_dung_CSDLPT_Nhom_8.sql'
sql='\n'.join(parts)
assert '#ApplySql' not in sql and '#ProjectOptions' not in sql and '{{BRANCH}}' not in sql
assert 'THAY_GUID' not in sql and 'SERVER_S0' not in sql
out.write_text(sql,encoding='utf-8-sig')
print(f'Created {out.name}: {len(sql.splitlines())} lines, direct T-SQL')
