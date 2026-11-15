"""Revision 3: align the report with output/Truy_van_xay_dung_CSDLPT_Nhom_8.sql.

The SQL deliverable runs on one SQL Server instance (eight databases, copy by
procedure). The design chapters keep the four-server target, while every place
that describes what was built now names the real databases, procedures and data.
Each section still fits on one page: edits replace text instead of growing it.
"""
import re
from revised_content import PAGES, MEMBERS, ASSIGNMENTS, OWNERS, LEADER

def sec(code):
    """Page whose title contains the section code, e.g. '5.8' or 'KẾT LUẬN'."""
    hits=[p for p in PAGES if re.search(r'(?m)^'+re.escape(code)+r'( |$)',p['title'])]
    assert len(hits)==1,(code,len(hits))
    return hits[0]

def rep(p,key,old,new):
    assert p[key] and old in p[key],(p['title'][:30],key,old[:60])
    p[key]=p[key].replace(old,new,1)

def row(p,first,new):
    for i,r in enumerate(p['table']):
        if r[0]==first:p['table'][i]=new;return
    raise AssertionError((p['title'][:30],first))

LAB_DBS='AirCore, AirReporting, AirBranch_HN/DN/HCM và AirReference_HN/DN/HCM'

# --- Tóm tắt ---------------------------------------------------------------
p=sec('TÓM TẮT BÁO CÁO')
rep(p,'body','Kết quả của báo cáo là một thiết kế có thể tổ chức thành bài thực hành SQL Server 2022. Tiêu chí ưu tiên là không bán vượt sức chứa, không xử lý thanh toán lặp, xác định được nguồn của dữ liệu và phục hồi có kiểm soát khi một điểm mất kết nối. Các bảng kiểm thử mô tả dữ liệu đầu vào và kết quả kỳ vọng để nhóm thực hiện, đo đạc và bổ sung minh chứng khi triển khai.',
 'Thiết kế được cài đặt thành một script T-SQL chạy trọn trên một SQL Server 2022: tám database mô phỏng bốn điểm, các procedure giữ chỗ, xác nhận, hủy, hết hạn, hoàn vé, đối soát và năm đơn mẫu tại ba chi nhánh. Sao chép trong bản nộp là procedure usp_RefreshLabCopies; replication và Linked Server giữa nhiều máy là phương án triển khai thật được trình bày ở chương 4 và 5. Tiêu chí ưu tiên là không bán vượt sức chứa, không xử lý thanh toán lặp và xác định được nguồn của dữ liệu.')
p['table'].append(['Bản cài đặt nộp','8 database trên một instance, sao chép bằng procedure'])

# --- Thuật ngữ ---------------------------------------------------------------
p=sec('THUẬT NGỮ VÀ KÝ HIỆU')
p['table'].append(['Bản LAB','Script nộp: 8 database mô phỏng 4 điểm trên một instance'])

# --- 1.3 ------------------------------------------------------------------
p=sec('1.3')
rep(p,'body','Không dùng sao chép để gửi lệnh đặt vé.','Không dùng sao chép để gửi lệnh đặt vé. Bản LAB mô phỏng hai luồng này bằng procedure sao chép (mục 4.8).')

# --- 1.6 ------------------------------------------------------------------
p=sec('1.6')
rep(p,'body','SQL Server 2022 được chọn để giữ sự tương thích với hướng triển khai của báo cáo mẫu.','SQL Server 2022 được chọn vì có đủ replication, SQL Server Agent và Linked Server cho bước triển khai nhiều máy.')
rep(p,'body','SQL Server Agent quản lý các job liên quan đến sao chép và tác vụ hết hạn giữ chỗ.','Khi triển khai thật, SQL Server Agent chạy job sao chép và job hết hạn giữ chỗ; bản LAB gọi trực tiếp usp_ExpireHolds.')
rep(p,'body','Mô hình ba chi nhánh giúp bài thực hành có đủ tình huống phân mảnh và mất kết nối nhưng vẫn kiểm soát được phạm vi. Trung tâm và chi nhánh Hà Nội là hai điểm logic riêng, kể cả khi cùng đặt trên một máy vật lý. Nếu chỉ dùng nhiều database trên một instance, nhóm có thể minh họa cấu trúc phân mảnh, nhưng chưa chứng minh được khả năng chịu lỗi mạng giữa các máy chủ độc lập.',
 'Bản nộp dùng tám database trên một instance: '+LAB_DBS+'. Cách này minh họa đúng phân mảnh, định vị và luồng nghiệp vụ, nhưng chưa chứng minh khả năng chịu lỗi mạng giữa các máy chủ độc lập.')
row(p,'SQL Server Agent',['SQL Server Agent','Job hết hạn khi triển khai thật'])
row(p,'Transactional replication',['Replication','Bản thật; LAB dùng usp_RefreshLabCopies'])
row(p,'Linked Server',['Linked Server','Bản thật; LAB dùng tên ba phần'])

# --- 2.4 ------------------------------------------------------------------
p=sec('2.4')
rep(p,'body','BranchID được lấy từ phiên đăng nhập, không lấy tự do từ ô nhập liệu.','BranchID được lấy từ bảng LocalBranch của database chi nhánh, không nhận từ tham số nhập.')

# --- 3.1 ------------------------------------------------------------------
p=sec('3.1')
p['body']+='\nBản cài đặt có thêm các bảng phụ trợ: LocalBranch giữ mã chi nhánh của mảnh, AuditEvent tại S0 và BranchEvent tại chi nhánh ghi nhật ký, SyncWatermark ghi mốc sao chép.'

# --- 3.2 ------------------------------------------------------------------
p=sec('3.2')
row(p,'Fare',['Fare','FlightID FareClass','Price > 0, Currency chỉ nhận VND'])

# --- 3.4 ------------------------------------------------------------------
p=sec('3.4')
rep(p,'body','Có thể tách một một thành CustomerPublic và CustomerPrivate ở mức mở rộng. Bản báo cáo giữ bảng cơ bản để đơn giản hóa thực hành và sử dụng view giới hạn cột cho tài khoản báo cáo.',
 'Bản cài đặt giữ một bảng CustomerProfile, có cột Version kiểu rowversion, và tạo hai view chiếu vCustomerPublic, vCustomerPrivate; vai trò branch_executor chỉ được SELECT trên vCustomerPublic.')

# --- 3.5 ------------------------------------------------------------------
p=sec('3.5')
rep(p,'body','FlightID, FareClass, Quantity, RequestID, HoldID, Status và CreatedAt.','FlightID, FareClass, Quantity, RequestID, HoldID, PaymentID, Status, CreatedAt, ExpiresAt, LastError và LastCheckedAt.')
rep(p,'body','Trạng thái chờ đối soát cần một trường hoặc bảng theo dõi LastError và LastCheckedAt để xác định lần xử lý tiếp theo.','usp_MarkPendingReconcile ghi LastError và LastCheckedAt ngay trên SalesOrder để xác định lần xử lý tiếp theo.')
rep(p,'body','; bản sao Flight có thể hỗ trợ kiểm tra, nhưng xác nhận nghiệp vụ vẫn đi qua S0.','; xác nhận nghiệp vụ đi qua S0.')
p['table'].insert(4,['SalesOrder.PaymentID ExpiresAt','Có thể rỗng','Sao kết quả S0 về đơn'])

# --- 3.6 ------------------------------------------------------------------
p=sec('3.6')
rep(p,'body',' Không dùng mã vé của một hãng thật hoặc gán giá trị giả lập như chứng từ thương mại hợp lệ.','')
rep(p,'body','Không đặt FK vật lý từ SeatHold đến SalesOrder ở một máy chủ khác.','Chỉ mục UNIQUE lọc trên OrderID khi Status bằng ACTIVE bảo đảm mỗi đơn có tối đa một giữ chỗ đang hoạt động. Không đặt FK vật lý từ SeatHold đến SalesOrder.')
rep(p,'body','Nhật ký nghiệp vụ lưu mã yêu cầu, tác nhân, trạng thái trước sau và thời điểm UTC.','AuditEvent lưu loại sự kiện, EntityID là HoldID hoặc TicketID, BranchID, tác nhân và thời điểm UTC.')
row(p,'SeatHold',['SeatHold','PK HoldID; UQ RequestID; UQ OrderID khi ACTIVE','Một kết quả cho một yêu cầu'])
row(p,'AuditEvent',['AuditEvent','PK EventID','Loại sự kiện, EntityID, tác nhân'])

# --- 4.1 ------------------------------------------------------------------
p=sec('4.1')
p['body']+='\nTrong bản nộp, bốn điểm logic được mô phỏng bằng tám database trên một instance: S0 gồm AirCore và AirReporting; S1, S2, S3 lần lượt gồm AirBranch_HN, AirBranch_DN, AirBranch_HCM và AirReference_HN, AirReference_DN, AirReference_HCM. Hậu tố chi nhánh thay cho tên máy chủ riêng.'
rep(p,'caption','Hình 4 Kiến trúc bốn điểm logic và ba chi nhánh.','Hình 4 Kiến trúc bốn điểm logic và ba chi nhánh, ghi tên database trong bản LAB.')

# --- 4.2 ------------------------------------------------------------------
p=sec('4.2')
rep(p,'note','Định vị: R_HN tại S1, R_DN tại S2, R_HCM tại S3.','Định vị: R_HN tại S1, R_DN tại S2, R_HCM tại S3; bản LAB là AirBranch_HN, AirBranch_DN, AirBranch_HCM.')

# --- 4.4 ------------------------------------------------------------------
p=sec('4.4')
rep(p,'body','Phân mảnh dọc được đề xuất như bước mở rộng cho CustomerProfile. CustomerPublic gồm CustomerID, BranchID, FullName và BirthDate; CustomerPrivate gồm CustomerID, Phone, Email và DocumentNo. CustomerID phải xuất hiện ở cả hai mảnh để nối lại. Mỗi mảnh có PK riêng trên CustomerID và quan hệ một một được kiểm tra tại cùng chi nhánh.',
 'Phân mảnh dọc CustomerProfile được cài ở mức view tại mỗi AirBranch: vCustomerPublic gồm CustomerID, BranchID, FullName và BirthDate; vCustomerPrivate gồm CustomerID, Phone, Email và DocumentNo. CustomerID xuất hiện ở cả hai mảnh để nối lại. Tách thành hai bảng có PK riêng là bước mở rộng.')
rep(p,'body','Bài tập lý thuyết dưới đây giả định hai mảnh có cùng tập khóa.','Hai view lấy từ cùng một bảng nên luôn có cùng tập khóa.')
rep(p,'body',' Nếu nhóm chưa triển khai bước mở rộng, phải giữ nó ở mục phương án, không ghi như cấu trúc đang chạy.','')
row(p,'CustomerPublic_i',['vCustomerPublic','Khóa, chi nhánh, họ tên, ngày sinh','AirBranch chi nhánh i'])
row(p,'CustomerPrivate_i',['vCustomerPrivate','Khóa, điện thoại, email, giấy tờ','AirBranch chi nhánh i'])
p['code']='''-- Tái thiết hồ sơ qua hai view chiếu dọc (PHẦN 10 của script)
USE AirBranch_HN;
SELECT p.CustomerID, p.BranchID, p.FullName, p.BirthDate,
       s.Phone, s.Email, s.DocumentNo
FROM dbo.vCustomerPublic AS p
JOIN dbo.vCustomerPrivate AS s
  ON s.CustomerID = p.CustomerID;'''
p['note']='Bản cài đặt dùng CustomerProfile một bảng và hai view chiếu. Tách thành hai bảng vật lý là phương án nâng cấp có kiểm soát.'

# --- 4.6 ------------------------------------------------------------------
p=sec('4.6')
row(p,'Branch Airport Route Aircraft',['Branch Airport Route Aircraft','S0 AirCore','AirReference_HN/DN/HCM'])
row(p,'Flight Fare',['Flight Fare','S0 AirCore','AirReference_HN/DN/HCM'])
row(p,'SalesOrder SalesItem HN',['SalesOrder SalesItem HN','S1 AirBranch_HN','S0 AirReporting.hn'])
row(p,'SalesOrder SalesItem DN',['SalesOrder SalesItem DN','S2 AirBranch_DN','S0 AirReporting.dn'])
row(p,'SalesOrder SalesItem HCM',['SalesOrder SalesItem HCM','S3 AirBranch_HCM','S0 AirReporting.hcm'])

# --- 4.7 ------------------------------------------------------------------
p=sec('4.7')
rep(p,'body','Nếu cần kiểm tra dữ liệu mới nhất tại các nguồn, nhóm dùng Linked Server để đọc trực tiếp ba mảnh và so sánh với AirReporting.','Nếu cần dữ liệu mới nhất tại nguồn, bản nhiều máy dùng Linked Server; bản LAB đọc trực tiếp AirBranch_HN, AirBranch_DN, AirBranch_HCM bằng tên ba phần rồi so sánh với AirReporting.')
p['code']='''-- PHẦN 6.1 của script: ba bảng nhận cùng cấu trúc
CREATE OR ALTER VIEW dbo.vSalesOrderGlobal AS
SELECT * FROM hn.SalesOrder UNION ALL
SELECT * FROM dn.SalesOrder UNION ALL
SELECT * FROM hcm.SalesOrder;
GO
CREATE OR ALTER VIEW dbo.vSalesItemGlobal AS
SELECT * FROM hn.SalesItem UNION ALL
SELECT * FROM dn.SalesItem UNION ALL
SELECT * FROM hcm.SalesItem;
GO

SELECT BranchID, COUNT_BIG(*) AS OrderCount
FROM dbo.vSalesOrderGlobal
WHERE CreatedAt >= @FromUtc AND CreatedAt < @ToUtc
GROUP BY BranchID;'''
p['note']='SELECT * dùng được vì hn, dn, hcm được tạo từ cùng một định nghĩa cột. Biến thời gian phải được khai báo hoặc truyền qua procedure.'

# --- 4.8 ------------------------------------------------------------------
p=sec('4.8')
rep(p,'body',' Tài liệu về peer-to-peer của Microsoft nêu các xung đột có thể phát sinh khi nhiều nơi sửa cùng dòng. Do đó, báo cáo',' Vì vậy, báo cáo')
p['body']+='\nTrong bản LAB, các luồng trên được mô phỏng bằng usp_RefreshLabCopies: mỗi lần gọi xóa và chép lại toàn bộ danh mục vào ba AirReference, chép các mảnh đơn vào AirReporting rồi ghi SyncWatermark. Đây là sao chép kiểu snapshot cục bộ, không phải transactional replication.'

# --- 5.1 ------------------------------------------------------------------
p=sec('5.1')
rep(p,'body','Nhóm chuẩn bị bốn điểm logic S0 đến S3 với SQL Server 2022 Developer và các thành phần Database Engine, Replication, SQL Server Agent. Có thể dùng bốn máy ảo hoặc các instance tách biệt trên một máy đủ tài nguyên. Bốn instance trên cùng máy phù hợp để học cấu hình, nhưng không tạo ra bằng chứng về khả năng chịu sự cố của bốn máy vật lý độc lập.',
 'Bản nộp chỉ cần một SQL Server 2022 và SSMS: mở Truy_van_xay_dung_CSDLPT_Nhom_8.sql, nhấn Ctrl+A rồi F5, không cần SQLCMD Mode. Khi tách máy, nhóm chuẩn bị S0 đến S3 với Database Engine, Replication và SQL Server Agent.')
p['table']=[['Điểm','Database bản LAB','Database khi tách máy'],
 ['S0 AIR_S0','AirCore, AirReporting','Thêm distribution'],
 ['S1 AIR_HN','AirBranch_HN, AirReference_HN','AirBranch, AirReference'],
 ['S2 AIR_DN','AirBranch_DN, AirReference_DN','AirBranch, AirReference'],
 ['S3 AIR_HCM','AirBranch_HCM, AirReference_HCM','AirBranch, AirReference']]

# --- 5.2 ------------------------------------------------------------------
p=sec('5.2')
rep(p,'body','Tạo AirCore tại S0 và các bảng danh mục trước, sau đó tạo Inventory. Cấu trúc Inventory dưới đây thể hiện khóa kho ghế, các bộ đếm và ràng buộc quan trọng. Flight phải tồn tại trước khi tạo FK. FareClass được kiểm tra theo miền ECO, BUS; Branch được tạo riêng với HN, DN, HCM.',
 'Script tạo AirCore và các bảng danh mục trước, sau đó tạo Inventory. Mỗi database chỉ được tạo khi chưa tồn tại và được gắn extended property AirLabProject; mỗi bảng dùng IF OBJECT_ID IS NULL nên chạy lại không xóa dữ liệu. Inventory có FK ghép đến Fare(FlightID, FareClass), nên miền ECO, BUS được kiểm tra tại Fare.')
rep(p,'body','Lựa chọn collation nhất quán trên các điểm','Tám database dùng chung collation Latin1_General_100_CI_AS_SC. Collation nhất quán trên các điểm')
rep(p,'body','Trước khi mở bán, procedure cấu hình hoặc truy vấn kiểm tra phải đối chiếu tổng Capacity theo FlightID với sức chứa máy bay.','Bản LAB chưa có procedure đối chiếu tổng Capacity với Aircraft.TotalSeats; dữ liệu mẫu được chọn khớp, ví dụ TEST01 có ECO 10 cộng BUS 2 bằng 12 ghế.')
p['code']='''IF DB_ID(N'AirCore') IS NULL
 EXEC(N'CREATE DATABASE [AirCore] COLLATE Latin1_General_100_CI_AS_SC;');
GO
USE [AirCore];
GO
-- Branch, Airport, Route, Aircraft, Flight, Fare được tạo ở PHẦN 2.
IF OBJECT_ID('dbo.Inventory','U') IS NULL
CREATE TABLE dbo.Inventory(
  FlightID varchar(20) NOT NULL,
  FareClass varchar(3) NOT NULL,
  Capacity int NOT NULL,
  Held int NOT NULL DEFAULT 0,
  Sold int NOT NULL DEFAULT 0,
  UpdatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
  Version rowversion,
  PRIMARY KEY(FlightID,FareClass),
  FOREIGN KEY(FlightID,FareClass)
    REFERENCES dbo.Fare(FlightID,FareClass),
  CHECK(Capacity>0 AND Held>=0 AND Sold>=0
        AND Held+Sold<=Capacity));'''
p['note']='Đoạn mã trích từ PHẦN 1 và PHẦN 3 của file SQL nộp, đã lược phần kiểm tra extended property.'

# --- 5.3 ------------------------------------------------------------------
p=sec('5.3')
rep(p,'body','Mỗi điểm tạo AirBranch với cùng cấu trúc bảng nhưng ràng buộc BranchID riêng. Ví dụ dưới dùng DN; khi triển khai HN và HCM phải thay giá trị CHECK tương ứng. Không dùng cùng script có CHECK DN cho cả ba điểm.',
 'Script tạo AirBranch_HN, AirBranch_DN, AirBranch_HCM cùng cấu trúc; mỗi database có bảng LocalBranch một dòng, SalesOrder tham chiếu LocalBranch và có CHECK BranchID riêng. Ví dụ dưới là AirBranch_DN.')
rep(p,'body','OrderID và RequestID được sinh trước khi lưu đơn. RequestID có UNIQUE; HoldID còn rỗng khi đơn nháp và được cập nhật khi S0 đã trả giữ chỗ. SalesItem dùng khóa ghép để số thứ tự hành khách duy nhất trong một đơn. Quantity được đối chiếu với số dòng trước khi gửi yêu cầu đến trung tâm.',
 'Đơn được tạo qua usp_CreateOrder: procedure nhận danh sách hành khách kiểu bảng PassengerList, tính Quantity bằng số dòng, kiểm tra ItemNo liên tục từ 1, nhân viên đang hoạt động và khách thuộc chi nhánh, rồi ghi SalesOrder, SalesItem và BranchEvent trong một transaction. HoldID, PaymentID và TicketID được điền sau bởi usp_ApplyHoldResult và usp_ApplyIssuedResult.')
rep(p,'body','Các cột CustomerID, EmployeeID và CreatedAt được giữ trong cấu trúc đầy đủ; ví dụ tập trung vào các trường liên quan đến phân mảnh và trạng thái. Bản nhận ở AirReporting phải có các cột công bố với cùng kiểu.','Bản nhận ở AirReporting có cùng cột SalesOrder; SalesItem nhận chỉ giữ OrderID, ItemNo, UnitPrice và TicketID.')
p['code']='''CREATE TABLE dbo.LocalBranch(BranchID varchar(3) PRIMARY KEY
  CHECK(BranchID='DN'),BranchName nvarchar(100) NOT NULL);
CREATE TABLE dbo.SalesOrder(OrderID uniqueidentifier PRIMARY KEY,
  BranchID varchar(3) NOT NULL REFERENCES dbo.LocalBranch(BranchID)
    CHECK(BranchID='DN'),
  CustomerID uniqueidentifier NOT NULL
    REFERENCES dbo.CustomerProfile(CustomerID),
  EmployeeID varchar(20) NOT NULL REFERENCES dbo.Employee(EmployeeID),
  FlightID varchar(20) NOT NULL,
  FareClass varchar(3) NOT NULL CHECK(FareClass IN ('ECO','BUS')),
  Quantity int NOT NULL CHECK(Quantity BETWEEN 1 AND 500),
  RequestID uniqueidentifier NOT NULL UNIQUE,
  HoldID uniqueidentifier NULL, PaymentID uniqueidentifier NULL,
  Status varchar(20) NOT NULL CHECK(Status IN
    ('DRAFT','HELD','ISSUED','CANCELLED','PENDING_RECONCILE')),
  CreatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
  ExpiresAt datetime2(3) NULL, LastError nvarchar(300) NULL,
  LastCheckedAt datetime2(3) NULL);
CREATE TABLE dbo.SalesItem(OrderID uniqueidentifier NOT NULL
    REFERENCES dbo.SalesOrder(OrderID),
  ItemNo int NOT NULL CHECK(ItemNo>0),
  PassengerName nvarchar(100) NOT NULL,
  PassengerDocument nvarchar(30) NULL,
  UnitPrice decimal(18,2) NULL CHECK(UnitPrice>0),
  TicketID uniqueidentifier NULL, PRIMARY KEY(OrderID,ItemNo));
CREATE UNIQUE INDEX UX_SalesItem_Ticket ON dbo.SalesItem(TicketID)
  WHERE TicketID IS NOT NULL;'''

# --- 5.4 ------------------------------------------------------------------
p=sec('5.4')
rep(p,'body','Procedure giữ chỗ chạy tại S0, không chạy trên Subscriber. Trước khi tăng Held, hệ thống kiểm tra Quantity dương, mã chi nhánh hợp lệ, chuyến đang mở và giá hạng còn hiệu lực.',
 'usp_CreateHold chạy tại AirCore, không chạy trên bản sao. Trước khi tăng Held, procedure kiểm tra Quantity từ 1 đến 500, mã chi nhánh hợp lệ, đơn chưa có giữ ACTIVE hoặc CONFIRMED, chuyến OPEN chưa khởi hành và hạng có giá.')
rep(p,'body','Phạm vi minh họa giữ 10 phút; thời hạn thực tế phải theo chính sách hãng. Câu trả kết quả được đọc theo HoldID mới hoặc RequestID để caller nhận cùng một kết quả khi phản hồi lần đầu bị mất.',
 'Đơn giá lấy từ Fare tại S0, không nhận từ caller; thời hạn là @HoldMinutes, từ 1 đến 10, mặc định 10 phút. Khi phản hồi lần đầu bị mất, caller gọi usp_GetHoldByRequest với RequestID cũ để nhận cùng kết quả.')
p['code']='''BEGIN TRY
  BEGIN TRAN;
  EXEC @Lock=sys.sp_getapplock @Resource=@Resource,
    @LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=5000;
  -- RequestID đã có: tham số khớp thì trả HoldID cũ, khác thì 51004.
  -- Khóa theo OrderID, kiểm tra chi nhánh, đơn và chuyến OPEN.
  SELECT @Price=Price FROM dbo.Fare WITH(HOLDLOCK)
  WHERE FlightID=@FlightID AND FareClass=@FareClass;
  IF @Price IS NULL THROW 51008,N'Không có giá cho hạng.',1;
  UPDATE dbo.Inventory SET Held=Held+@Quantity,UpdatedAt=@Now
  WHERE FlightID=@FlightID AND FareClass=@FareClass
    AND Capacity-Held-Sold>=@Quantity;
  IF @@ROWCOUNT<>1 THROW 51009,N'Không đủ ghế để giữ chỗ.',1;
  SET @HoldID=NEWID();
  INSERT dbo.SeatHold(HoldID,RequestID,OrderID,BranchID,FlightID,
    FareClass,Quantity,UnitPrice,Status,CreatedAt,ExpiresAt)
  VALUES(@HoldID,@RequestID,@OrderID,@BranchID,@FlightID,@FareClass,
    @Quantity,@Price,'ACTIVE',@Now,DATEADD(minute,@HoldMinutes,@Now));
  INSERT dbo.AuditEvent(EventType,EntityID,BranchID,Actor,Message)
  VALUES('CREATE_HOLD',@HoldID,@BranchID,ORIGINAL_LOGIN(),N'Tạo giữ chỗ.');
  COMMIT;
END TRY
BEGIN CATCH
  IF XACT_STATE()<>0 ROLLBACK;
  SET @HoldID=NULL; THROW;
END CATCH;'''
p['note']='Không gọi cổng thanh toán bên ngoài trong transaction này. Đoạn trích rút gọn từ PHẦN 4.1 của file SQL nộp.'

# --- 5.5 ------------------------------------------------------------------
p=sec('5.5')
rep(p,'body','Procedure xác nhận khóa SeatHold, kiểm tra ACTIVE và ExpiresAt lớn hơn thời gian S0 hiện tại.','usp_ConfirmHold khóa SeatHold, kiểm tra ACTIVE và ExpiresAt lớn hơn thời gian S0 hiện tại.')
rep(p,'body','Tác vụ hết hạn chọn bản giữ ACTIVE có ExpiresAt nhỏ hơn hoặc bằng thời điểm UTC. Trong mỗi giao dịch ngắn, tác vụ khóa bản giữ, kiểm tra lại trạng thái rồi giảm Held đúng Quantity và chuyển thành EXPIRED.',
 'usp_ExpireHolds chọn tối đa @BatchSize bản giữ ACTIVE đã đến hạn và gọi usp_ReleaseHold cho từng bản; procedure này cũng phục vụ usp_CancelHold, khóa bản giữ, kiểm tra lại trạng thái rồi giảm Held đúng Quantity.')
rep(p,'body','Hoàn vé mô phỏng khóa Ticket, kiểm tra ISSUED và chính sách, tạo Refund rồi giảm Sold một ghế.','usp_RefundTicket khóa Ticket, kiểm tra ISSUED và chuyến còn OPEN chưa khởi hành, tạo Refund rồi giảm Sold một ghế.')

# --- 5.6 ------------------------------------------------------------------
p=sec('5.6')
rep(p,'body','Tại S0, mở Replication trong SSMS và cấu hình Distributor sau khi kiểm tra SQL Server Agent.','Mục này là quy trình khi tách máy; bản LAB chưa tạo publication mà dùng usp_RefreshLabCopies. Tại S0, mở Replication trong SSMS và cấu hình Distributor sau khi kiểm tra SQL Server Agent.')
rep(p,'body','Replication không tự tạo một giao diện thống nhất cho các chức năng bán hàng. Sau khi danh mục nhận được, nhóm vẫn phải kiểm tra API đến S0, procedure giữ chỗ và quyền ứng dụng.','Sau khi danh mục nhận được, nhóm vẫn phải kiểm tra API đến S0, procedure giữ chỗ và quyền ứng dụng.')
row(p,'Subscriber',['Subscriber','S1 S2 S3 AirReference (LAB: _HN/_DN/_HCM)'])

# --- 5.7 ------------------------------------------------------------------
p=sec('5.7')
p['body']+='\nTrong bản LAB, usp_RefreshLabCopies thay ba publication: procedure xóa rồi chép lại hn, dn, hcm.SalesOrder và SalesItem từ AirBranch_HN, AirBranch_DN, AirBranch_HCM, không chép PassengerName, PassengerDocument, rồi ghi SyncWatermark theo HN, DN, HCM.'
for code in ('HN','DN','HCM'):
    r=next(x for x in p['table'] if x[0]=='P_SALES_'+code)
    r[1]=r[1].replace('AirBranch','AirBranch_'+code)

# --- 5.8 ------------------------------------------------------------------
p=sec('5.8')
p['body']+='\nBản nộp chưa tạo LS_HN, LS_DN, LS_HCM vì tám database nằm trên cùng instance. Truy vấn liên điểm được mô phỏng bằng tên ba phần; ví dụ AirBranch_DN đọc AirCore.dbo.SeatHold để áp dụng kết quả giữ chỗ, thay cho lời gọi API.'
p['code']+='''

-- Bản LAB trên một instance: tên ba phần thay cho Linked Server.
SELECT OrderID FROM AirReporting.dn.SalesOrder
EXCEPT
SELECT OrderID FROM AirBranch_DN.dbo.SalesOrder;'''

# --- 5.9 ------------------------------------------------------------------
p=sec('5.9')
p['body']+='\nScript tạo vai trò booking_executor, refund_operator, maintenance_executor, report_reader tại AirCore; branch_executor, branch_sync_service tại AirBranch; reference_reader tại AirReference. Script chưa tạo login, user hay mật khẩu và chưa chạy BACKUP; các lệnh sao lưu dưới đây là hướng dẫn vận hành.'
p['code']=p['code'].replace('''GRANT EXECUTE ON dbo.usp_CreateHold TO booking_executor;
DENY UPDATE ON dbo.Inventory TO booking_executor;''','''GRANT EXECUTE ON dbo.usp_CreateHold TO booking_executor;
GRANT EXECUTE ON dbo.usp_ConfirmHold TO booking_executor;
DENY INSERT,UPDATE,DELETE ON dbo.Inventory TO booking_executor;''')
assert 'DENY INSERT,UPDATE,DELETE' in p['code']

# --- 6.1 ------------------------------------------------------------------
p=sec('6.1')
rep(p,'body','Mỗi chi nhánh có hai nhân viên, ba khách giả lập và các đơn với OrderID, RequestID riêng. Dùng tên Khách thử HN 01 hoặc tương tự để nhận biết nguồn.',
 'Script hiện tạo mỗi chi nhánh một nhân viên HN_NV01, DN_NV01, HCM_NV01 và một khách giả lập như Khách thử HN 01; các đơn có OrderID, RequestID cố định.')
rep(p,'body','Các bảng của chương này là kế hoạch nghiệm thu và kết quả kỳ vọng, chưa phải nhật ký thực nghiệm đã chạy trên SQL Server.','Ngoài các ca chạy tự động ở PHẦN 8 của script, các bảng của chương này là kế hoạch nghiệm thu và kết quả kỳ vọng.')
rep(p,'body','Sau mỗi nhóm ca, chạy truy vấn bất biến:','Sau mỗi nhóm ca, chạy usp_CheckInvariants:')
row(p,'Nhỏ',['Nhỏ','3 chi nhánh, 3 chuyến, 3 khách','Kiểm tra quy tắc và tính toán bằng tay'])
row(p,'Đồng bộ',['Đồng bộ','Đơn DN 2 khách; HN, HCM 1 khách','Đúng schema, không mất chi tiết'])

# --- 6.2 ------------------------------------------------------------------
p=sec('6.2')
rep(p,'body','Mỗi ca cần xác minh cơ sở dữ liệu, không chỉ nhìn thông báo trên màn hình.','Mỗi ca cần xác minh cơ sở dữ liệu. File nộp chạy tự động TC01, TC03, TC07, TC09 và TC10; các ca còn lại cần chạy riêng.')

# --- 6.3 ------------------------------------------------------------------
p=sec('6.3')
p['body']+='\nCác ca CC01 đến CC06 cần hai session SSMS chạy song song nên chưa nằm trong file nộp. Chuyến TEST02 ECO Capacity 1 đã được script tạo sẵn cho CC01.'

# --- 6.4 ------------------------------------------------------------------
p=sec('6.4')
p['body']+='\nFT04 đến FT06 cần replication thật. Trong bản LAB, có thể mô phỏng FT04 bằng cách tạo đơn mới tại AirBranch_DN mà chưa gọi usp_RefreshLabCopies, rồi so dn.SalesOrder và SyncWatermark với nguồn.'

# --- 6.6 ------------------------------------------------------------------
p=sec('6.6')
rep(p,'body','Ngưỡng lấp đầy 80 phần trăm là cấu hình minh họa.','usp_HighLoadFlights nhận @Threshold, mặc định 80 phần trăm; script mẫu gọi với 20 để có kết quả trên dữ liệu nhỏ.')
rep(p,'body','Chức năng đối soát tìm đơn HELD nhưng giữ nguồn đã EXPIRED, đơn ISSUED chưa có vé tương ứng hoặc đơn PENDING_RECONCILE còn quá thời gian xử lý.',
 'usp_CheckInvariants đối soát trong AirCore: Held với giữ ACTIVE, Sold với vé ISSUED, số vé với Quantity, Payment với giá chốt. Đối soát giữa đơn chi nhánh và S0, như đơn HELD nhưng giữ đã EXPIRED, là bước mở rộng.')
row(p,'Đồng bộ chậm',['Đồng bộ chậm','SyncWatermark; bản thật dùng tracer token','Thông báo dữ liệu báo cáo cũ'])
row(p,'Đơn lệch trạng thái',['Đơn lệch kho ghế','Inventory, SeatHold, Ticket, Payment','usp_CheckInvariants'])
p['code']='''-- Cảnh báo tại nguồn AirCore; không tự thay đổi giao dịch.
EXEC dbo.usp_HighLoadFlights @Threshold=80;
-- Bên trong procedure:
-- SELECT *, CAST(100.0*Sold/Capacity AS decimal(5,2)) SoldPct
-- FROM dbo.vFlightAvailability
-- WHERE Status='OPEN' AND DepartureUtc>SYSUTCDATETIME()
--   AND 100.0*Sold/Capacity>=@Threshold;
EXEC dbo.usp_CheckInvariants;  -- bốn result set phải rỗng'''

# --- Kết luận ------------------------------------------------------------
p=sec('KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN')
rep(p,'body','Các mã minh họa, kế hoạch cài đặt và tình huống kiểm thử là cơ sở để nhóm dựng môi trường, chạy thực nghiệm và bổ sung minh chứng; kết quả kỳ vọng không thay thế kết quả đo.',
 'Script nộp chạy trọn trên một instance; khi chạy mới cho 5 đơn mẫu (3 ISSUED, 2 CANCELLED), 4 vé (3 ISSUED, 1 REFUNDED), kho TEST01 ECO Held 0, Sold 3, thu 6.000.000 và hoàn 1.500.000 VND. Phần đo hiệu năng chưa thực hiện.')
rep(p,'body','Hướng phát triển tiếp theo là hoàn thiện API và giao diện, bổ sung bộ script đầy đủ cho tất cả bảng, procedure xác nhận và hoàn, cấu hình dự phòng nguồn ghi có kiểm soát, cùng kiểm thử phục hồi.',
 'Hướng phát triển tiếp theo là dựng bốn instance với replication và Linked Server thật, job Agent hết hạn giữ chỗ, đối soát giữa đơn chi nhánh và S0, kiểm thử đồng thời, kiểm thử phục hồi, rồi hoàn thiện API và giao diện.')
row(p,'Đánh giá',['Đánh giá','Script chạy năm đơn mẫu; kế hoạch đồng thời, lỗi và tải'])
p['table'].insert(5,['Cài đặt','8 database, procedure nghiệp vụ, vai trò, dữ liệu mẫu'])

assert len(PAGES)==52
