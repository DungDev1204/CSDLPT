from textwrap import dedent
PAGES=[]
def page(title, body='', table=None, code=None, fig=None, caption=None, note=None):
    PAGES.append(dict(title=title,body=dedent(body).strip(),table=table,code=dedent(code).strip() if code else None,fig=fig,caption=caption,note=note))

page('BÁO CÁO BÀI TẬP LỚN', '''
CƠ SỞ DỮ LIỆU PHÂN TÁN
CƠ SỞ DỮ LIỆU PHÂN TÁN QUẢN LÝ HÀNG KHÔNG THÔNG MINH
Trọng tâm quản lý bán vé máy bay tại nhiều chi nhánh
Nhóm 8
Lớp D24TXCN05-K
Giảng viên hướng dẫn ThS. Mai Ngọc Lương
Tháng 10 năm 2026
''')
page('TÓM TẮT BÁO CÁO', '''
Báo cáo đề xuất cơ sở dữ liệu phân tán cho hệ thống quản lý hàng không thông minh, lấy nghiệp vụ bán vé máy bay tại nhiều chi nhánh làm phạm vi triển khai. Hệ thống phải đáp ứng hai nhu cầu đồng thời: xử lý dữ liệu bán hàng gần nơi phát sinh và kiểm soát thống nhất số ghế của từng chuyến bay. Nếu các chi nhánh tự phát hành vé từ bản sao chưa cập nhật, cùng một ghế có thể được bán nhiều lần; vì vậy, lựa chọn vị trí lưu trữ phải đi cùng quy tắc sở hữu và cập nhật dữ liệu.
Phương án gồm một máy chủ trung tâm và ba máy chủ chi nhánh tại Hà Nội, Đà Nẵng, TP Hồ Chí Minh. Hồ sơ khách hàng giao dịch, nhân viên, đơn bán và chi tiết đơn được phân mảnh theo chi nhánh. Danh mục sân bay, đường bay, máy bay và lịch bay được nhân bản phục vụ tra cứu. Kho ghế, giữ chỗ, vé và giao dịch thanh toán có một nơi ghi chính thức tại trung tâm. Các chi nhánh gửi yêu cầu nghiệp vụ đến nơi này; bản sao dùng để đọc và lập báo cáo, không dùng làm căn cứ cuối cùng để phát hành vé.
Nội dung trình bày cơ sở lý thuyết, yêu cầu nghiệp vụ, mô hình quan hệ, chứng minh tính đúng của phân mảnh, lược đồ định vị, luồng đồng bộ, mã T-SQL minh họa và kế hoạch kiểm thử. Chức năng thông minh được thể hiện bằng phát hiện đơn cần đối soát, cảnh báo chuyến bay có tỷ lệ lấp đầy cao và tổng hợp dữ liệu hỗ trợ ra quyết định. Các chức năng này dùng quy tắc và truy vấn, chưa phải mô hình học máy.
Kết quả của báo cáo là một thiết kế có thể tổ chức thành bài thực hành SQL Server 2022. Tiêu chí ưu tiên là không bán vượt sức chứa, không xử lý thanh toán lặp, xác định được nguồn của dữ liệu và phục hồi có kiểm soát khi một điểm mất kết nối. Các bảng kiểm thử mô tả dữ liệu đầu vào và kết quả kỳ vọng để nhóm thực hiện, đo đạc và bổ sung minh chứng khi triển khai.
''', table=[['Thành phần','Quyết định thiết kế'],['Hệ quản trị','SQL Server 2022 Developer cho môi trường học tập'],['Phạm vi','Bán vé một chặng tại ba chi nhánh'],['Dữ liệu cục bộ','Khách hàng giao dịch, nhân viên, đơn bán'],['Dữ liệu dùng chung','Danh mục và lịch bay được nhân bản'],['Giao dịch nhạy cảm','Giữ chỗ và phát hành vé tại trung tâm']])
page('THÀNH VIÊN VÀ PHÂN CÔNG', '''
Phân công được xây dựng theo các sản phẩm có thể bàn giao và kiểm tra. Mỗi thành viên chịu trách nhiệm chính cho một phần chuyên môn, đồng thời tham gia rà soát phần liên quan. Trách nhiệm chính không đồng nghĩa với việc làm độc lập: thiết kế bảng, điều kiện phân mảnh và mã giao dịch phải sử dụng cùng tên trường, khóa và quy tắc nghiệp vụ.
Đỗ Thị Hằng phụ trách điều phối bản báo cáo, quản lý mục lục và tập hợp kết quả rà soát. Lê Hoàng Dương và Trần Tiến Dũng thống nhất mô hình dữ liệu trước khi Nguyễn Văn Tùng viết kịch bản triển khai. Ngô Thế Quang xây dựng dữ liệu kiểm thử từ các ràng buộc đã thống nhất; Phan Văn Sang đối chiếu kết quả với nhu cầu sử dụng và chuẩn bị phần trình bày.
''', table=[['Mã sinh viên và thành viên','Nhiệm vụ chính','Sản phẩm bàn giao'],['K24DTCN190\nĐỗ Thị Hằng','Điều phối, lý thuyết và biên tập','Chương 1, bản Word và tài liệu tham khảo'],['K24DTCN168\nPhan Phương Anh','Khảo sát và phân tích nghiệp vụ','Chương 2, use case, ma trận quyền'],['K24DTCN184\nLê Hoàng Dương','Thiết kế CSDL toàn cục','Chương 3, ERD, từ điển dữ liệu'],['K24DTCN182\nTrần Tiến Dũng','Thiết kế phân mảnh và định vị','Chương 4, chứng minh và sơ đồ phân tán'],['K24DTCN246\nNguyễn Văn Tùng','Cài đặt và mã T-SQL','Chương 5, DDL, procedure, cấu hình đồng bộ'],['K24DTCN221\nNgô Thế Quang','Kiểm thử và đánh giá','Chương 6, dữ liệu thử, bảng đối soát'],['K24DTCN223\nPhan Văn Sang','Chức năng thông minh và tổng kết','Truy vấn cảnh báo, kết luận, nội dung thuyết trình']], note='Đây là phân công đề xuất cho nhóm, không phải bảng xác nhận mức độ hoàn thành thực tế.')
page('KẾ HOẠCH PHỐI HỢP CỦA NHÓM', '''
Nhóm thực hiện theo bốn giai đoạn tương đối để có thể điều chỉnh theo lịch học. Giai đoạn đầu thống nhất phạm vi: ba chi nhánh, vé một chặng, thanh toán mô phỏng và dữ liệu khách hàng giả lập. Sau đó hoàn thiện mô hình toàn cục và phân tán. Chỉ khi khóa chính, khóa ngoại và nơi sở hữu dữ liệu đã thống nhất mới chuyển sang viết mã cài đặt.
Ở giai đoạn xây dựng, người phụ trách SQL bàn giao script theo thứ tự chạy, kèm tài khoản dịch vụ cần thiết và yêu cầu cấu hình SQL Server Agent. Người phụ trách kiểm thử không sửa trực tiếp bản script đang được nghiệm thu; lỗi được ghi theo mã tình huống, dữ liệu đầu vào, kết quả quan sát và câu lệnh tái hiện. Cách làm này giúp xác định lỗi do mô hình hay do môi trường.
Trước khi hoàn thiện báo cáo, hai thành viên rà soát chéo mỗi chương. Nội dung kỹ thuật được kiểm tra về tính nhất quán của tên bảng, số điểm phân tán, chiều sao chép và kết quả kỳ vọng. Nội dung trình bày được kiểm tra về nguồn hình, số trang, danh mục hình và mục lục. Nhóm chỉ bổ sung tỷ lệ đóng góp sau khi có sản phẩm và thống nhất nội bộ, tránh gán một tỷ lệ hoàn thành chưa được xác nhận.
Khi thuyết trình, phần lý thuyết cần liên hệ với một tình huống cụ thể. Ví dụ, phân mảnh ngang giải thích bằng đơn bán của từng chi nhánh; giao dịch đồng thời giải thích bằng hai nhân viên cùng đặt ghế cuối; phục hồi giải thích bằng mất kết nối sau khi trung tâm đã xác nhận thanh toán. Mỗi thành viên cần hiểu luồng bán vé hoàn chỉnh để trả lời câu hỏi vượt ra ngoài phần phụ trách.
''', table=[['Giai đoạn','Chủ trì','Điểm kiểm tra'],['1 Khảo sát','Hằng, Phương Anh','Phạm vi, yêu cầu và quy tắc nghiệp vụ'],['2 Thiết kế','Dương, Dũng','ERD, khóa, phân mảnh và nơi ghi'],['3 Xây dựng','Tùng, Quang','Script, dữ liệu thử và nhật ký thực nghiệm'],['4 Hoàn thiện','Sang và cả nhóm','Đối soát, báo cáo, thuyết trình']], note='Các giai đoạn dùng thứ tự tương đối; ngày bàn giao cụ thể do nhóm thống nhất theo hạn nộp.')
page('MỤC LỤC')
page('DANH MỤC HÌNH VÀ THUẬT NGỮ', '''
Các sơ đồ thiết kế trong báo cáo biểu diễn mô hình đề xuất của nhóm. Hình cơ chế transactional replication được lấy từ tài liệu chính thức của Microsoft để làm rõ đường đi của dữ liệu giữa Publisher, Distributor và Subscriber. Những sơ đồ còn lại được dựng theo tên bảng và luồng nghiệp vụ của đề tài, không phải ảnh chụp của hệ thống đã triển khai.
''', table=[['Ký hiệu','Ý nghĩa trong báo cáo'],['CSDL','Cơ sở dữ liệu'],['CSDLPT','Cơ sở dữ liệu phân tán'],['ERD','Sơ đồ thực thể và quan hệ'],['PK và FK','Khóa chính và khóa ngoại'],['ACID','Nguyên tử, nhất quán, cô lập, bền vững'],['S0','Máy chủ trung tâm tại Hà Nội'],['S1 S2 S3','Chi nhánh Hà Nội, Đà Nẵng, TP Hồ Chí Minh'],['Publisher','Nơi công bố dữ liệu để sao chép'],['Distributor','Nơi lưu và chuyển lệnh sao chép'],['Subscriber','Nơi nhận bản sao'],['Idempotency','Gọi lại cùng yêu cầu không tạo thêm tác dụng'],['UTC','Mốc thời gian chuẩn dùng khi lưu dữ liệu']], note='Danh mục hình: Hình 1 cơ chế replication trang 9; Hình 2 quy trình bán vé trang 16; Hình 3 ERD trang 20; Hình 4 kiến trúc phân tán trang 28; Hình 5 phân mảnh theo chi nhánh trang 29; Hình 6 máy trạng thái giữ chỗ trang 40.')
page('CHƯƠNG 1 CƠ SỞ LÝ THUYẾT\n1.1 Cơ sở dữ liệu phân tán', '''
Cơ sở dữ liệu phân tán là tập dữ liệu có quan hệ với nhau nhưng được lưu tại nhiều điểm xử lý và được khai thác như một hệ thống thống nhất. Tính phân tán ở đây không chỉ là có nhiều máy tính: mỗi điểm có thể lưu một phần dữ liệu, duy trì bản sao hoặc thực hiện một phần giao dịch. Người dùng cần nhận được kết quả đúng dù dữ liệu vật lý nằm tại các điểm khác nhau.
Với hệ thống bán vé, chi nhánh Đà Nẵng tạo hồ sơ khách hàng và đơn bán tại nơi phát sinh nghiệp vụ. Chi nhánh vẫn cần biết lịch bay do trung tâm công bố và cần đặt chỗ trên kho ghế chung. Khi lập báo cáo toàn hãng, trung tâm phải tổng hợp các đơn từ ba chi nhánh mà không đếm lại các bản sao. Vì vậy, hệ thống có cả xử lý cục bộ và xử lý liên điểm.
Ba mức trong suốt có giá trị trực tiếp với đề tài. Trong suốt vị trí cho phép người dùng tra cứu mà không cần nhớ địa chỉ máy chủ chứa bảng. Trong suốt phân mảnh cho phép xem một quan hệ tổng thể dù nó được chia thành nhiều mảnh. Trong suốt nhân bản giúp hệ thống lựa chọn bản sao phù hợp khi đọc. Tuy nhiên, trong suốt không được che giấu độ trễ khi người dùng cần quyết định phát hành vé.
Phân tán đem lại khả năng xử lý gần người sử dụng và phân chia trách nhiệm vận hành. Đổi lại, hệ thống phải giải quyết sự cố mạng, dữ liệu bản sao chậm cập nhật, khó duy trì khóa ngoại liên điểm và khó khôi phục một giao dịch đã hoàn thành một phần. Một thiết kế phù hợp cần nêu rõ giới hạn hoạt động khi mất mạng, thay vì chỉ khẳng định hệ thống luôn sẵn sàng.
Trong báo cáo, dữ liệu của các chi nhánh là các mảnh có chủ sở hữu riêng; dữ liệu tra cứu là bản sao; dữ liệu ghế có một nơi ghi. Cách phân biệt này là nền tảng để tránh xung đột và xác định nơi đối soát khi phát hiện sai lệch.
''', table=[['Tiêu chí','Tập trung','Phân tán trong đề tài'],['Lưu trữ đơn bán','Một máy chủ','Ba mảnh chi nhánh'],['Đọc lịch bay','Qua trung tâm','Qua bản sao tại chi nhánh'],['Giữ chỗ','Một giao dịch trung tâm','Vẫn xác nhận tại S0'],['Sự cố mạng','Khó truy cập từ xa','Cục bộ hoạt động ở phạm vi cho phép']])
page('1.2 Phân mảnh và điều kiện đúng đắn', '''
Phân mảnh ngang chia một quan hệ theo tập bản ghi. Nếu SalesOrder có thuộc tính BranchID, ba mảnh tương ứng với HN, DN và HCM được tạo bằng ba điều kiện chọn. Mỗi đơn bán thuộc một chi nhánh chủ quản nên điều kiện này dễ kiểm tra và thuận lợi cho việc truy vấn cục bộ. Phân mảnh phải được xác định từ ngữ nghĩa nghiệp vụ, không chỉ từ nhu cầu chia đều số dòng.
Phân mảnh ngang dẫn xuất dùng quan hệ chủ để xác định mảnh của quan hệ phụ thuộc. SalesItem không cần thêm một nơi sở hữu riêng: chi tiết đơn được đặt cùng máy chủ với SalesOrder qua OrderID. Khi một đơn có nhiều hành khách, tất cả chi tiết được lưu cùng mảnh của đơn. Quy tắc này giảm truyền dữ liệu khi xem đầy đủ một giao dịch bán hàng.
Phân mảnh dọc chia tập thuộc tính nhưng phải giữ khóa để tái thiết. Với CustomerProfile, thông tin phục vụ bán hàng và thông tin liên hệ có thể tách thành CustomerPublic và CustomerPrivate. Cả hai giữ CustomerID; phép nối theo khóa khôi phục bản ghi. Cách chia này hỗ trợ giới hạn quyền truy cập thông tin nhạy cảm nhưng không tự thay thế cơ chế phân quyền.
Ba điều kiện đánh giá gồm tính đầy đủ, khả năng tái thiết và tính tách biệt. Đầy đủ nghĩa là không mất dữ liệu cần thiết. Tái thiết nghĩa là khôi phục được quan hệ gốc bằng phép hợp hoặc phép nối. Tách biệt nghĩa là một bản ghi chỉ thuộc một mảnh ngang chính; với mảnh dọc, khóa có thể xuất hiện ở nhiều mảnh để nối. Bản sao không được hiểu là một mảnh chủ khác.
Trong thiết kế này, BranchID không được để trống và chỉ nhận một trong ba giá trị hợp lệ. Chuyển quyền sở hữu đơn sang chi nhánh khác không phải thao tác cập nhật thông thường, vì có thể làm mất tính đồng vị trí giữa đơn và chi tiết. Thay vào đó, nơi bán ban đầu được giữ cố định để truy vết lịch sử.
''', table=[['Kiểu','Quan hệ áp dụng','Phép tái thiết'],['Ngang nguyên thủy','SalesOrder theo BranchID','Hợp ba mảnh'],['Ngang dẫn xuất','SalesItem theo đơn cha','Hợp các mảnh chi tiết'],['Dọc tùy chọn','Hồ sơ công khai và liên hệ','Nối một một theo CustomerID'],['Nhân bản','Danh mục và lịch bay','Chọn nguồn gốc, không cộng các bản sao']])
page('1.3 Nhân bản và đồng bộ dữ liệu', '''
Nhân bản duy trì nhiều bản dữ liệu để giảm truy cập từ xa và phục vụ báo cáo. Một bản sao có thể đúng về cấu trúc nhưng chưa phản ánh thay đổi mới nhất. Trong hệ thống đặt vé, sự khác biệt vài giây giữa kho ghế gốc và bản sao cũng có thể làm quyết định bán hàng sai. Bởi vậy, mục tiêu đọc nhanh và mục tiêu xác nhận ghế phải được xử lý bằng các đường truy cập khác nhau.
SQL Server cung cấp snapshot replication, transactional replication và merge replication. Snapshot phù hợp khi cần chuyển một bộ dữ liệu tại một thời điểm; transactional chuyển thay đổi từ giao dịch nguồn; merge phục vụ những trường hợp có cập nhật ở nhiều nơi và cần hợp nhất. Đề tài chọn transactional replication một chiều cho danh mục và luồng báo cáo. Việc lựa chọn và vai trò ba loại được tham khảo tại [2], [3], [4].
Hình 1 mô tả thành phần kỹ thuật của transactional replication. Trong phương án đề xuất, trung tâm là Publisher của danh mục, còn từng chi nhánh là Publisher của phần dữ liệu bán hàng do mình sở hữu. Các luồng sử dụng bảng nguồn và bảng nhận khác nhau, không công bố lại bản sao ngược về nơi phát sinh.
Tính nhất quán của dữ liệu trong một publication không có nghĩa tất cả chi nhánh cùng cập nhật ở một thời điểm. Khi một chi nhánh mất kết nối, bản sao tiếp tục cũ cho đến khi nhận đủ thay đổi. Giao diện cần thể hiện thời điểm đồng bộ gần nhất và dừng xác nhận giữ chỗ nếu không liên lạc được với S0.
''', fig='trnsact.png', caption='Hình 1 Thành phần transactional replication. Nguồn Microsoft Learn [2], ảnh gốc trnsact.gif; chú giải và áp dụng cho đề tài do nhóm diễn giải.', note='Các nhãn trên ảnh: Publisher là nơi nguồn; Distributor là nơi phân phối; Subscriber là nơi nhận bản sao.')
page('1.4 Giao dịch và kiểm soát đồng thời', '''
Giao dịch bán vé phải bảo vệ một tập thay đổi có quan hệ với nhau. Ví dụ, khi tạo giữ chỗ, hệ thống vừa tăng số ghế đang giữ vừa ghi thời hạn giữ chỗ. Nếu chỉ một trong hai thao tác thành công, kho ghế và lịch sử nghiệp vụ sẽ lệch nhau. Một giao dịch cục bộ trên S0 giúp hai thao tác cùng thành công hoặc cùng bị hủy.
Tính nguyên tử bảo vệ tập thay đổi; tính nhất quán duy trì các ràng buộc; tính cô lập kiểm soát ảnh hưởng giữa giao dịch đồng thời; tính bền vững giữ kết quả sau khi commit. ACID không tự bảo đảm mọi quy tắc bán hàng: lập trình viên vẫn phải mô tả điều kiện không vượt sức chứa và đặt điều kiện vào cùng giao dịch với cập nhật ghế.
Hai chi nhánh cùng đọc thấy còn một ghế là tình huống điển hình. Nếu cả hai tăng bộ đếm bằng thao tác dựa trên giá trị đã đọc, tổng số ghế có thể vượt giới hạn. Mã minh họa sử dụng UPDATE có điều kiện trên chính dòng Inventory: chỉ tăng Held khi Capacity trừ Held trừ Sold lớn hơn hoặc bằng số lượng yêu cầu. Số dòng cập nhật quyết định thành công, không dùng số ghế ở bản sao để quyết định.
Khóa còn được dùng khi xử lý lại cùng RequestID. Một khóa ứng dụng theo mã yêu cầu ngăn hai lần gọi đồng thời tạo hai bản giữ chỗ. Đối với chuyển từ giữ sang bán và giải phóng giữ chỗ, giao dịch khóa bản ghi giữ chỗ trước rồi cập nhật kho ghế theo cùng một thứ tự. Các cơ chế khóa SQL Server được tham khảo tại [5], [6].
Không giữ giao dịch SQL đang mở trong lúc chờ khách hàng nhập thông tin hoặc chờ cổng thanh toán trả lời. Sau khi giữ chỗ được commit, thời hạn được lưu thành dữ liệu. Thanh toán là bước riêng; hệ thống kiểm tra lại hiệu lực giữ chỗ trong một giao dịch ngắn để xác nhận. Thiết kế này tránh khóa kéo dài theo thời gian thao tác của người dùng.
''', table=[['Tình huống','Cơ chế xử lý'],['Hai người mua ghế cuối','UPDATE có điều kiện trên nguồn ghi'],['Gọi lại cùng yêu cầu','RequestID duy nhất và khóa ứng dụng'],['Xác nhận đồng thời với hết hạn','Khóa giữ chỗ và kiểm tra trạng thái'],['Lỗi giữa nhiều câu lệnh','XACT_ABORT, TRY CATCH và ROLLBACK'],['Chờ thanh toán bên ngoài','Không giữ transaction SQL đang mở']])
page('1.5 Sự cố mạng và phục hồi', '''
Trong hệ thống nhiều điểm, mất phản hồi không đủ để kết luận giao dịch thất bại. Chi nhánh có thể gửi yêu cầu giữ chỗ, S0 đã commit, nhưng phản hồi bị mất trên mạng. Nếu nhân viên lập một yêu cầu mới ngay lập tức, cùng một khách hàng có thể bị giữ hai lần. Trạng thái cần hiển thị là chưa xác định, sau đó tra cứu bằng RequestID cũ.
Thất bại trước commit có thể được rollback trong cơ sở dữ liệu cục bộ. Thất bại sau commit cần xử lý bằng truy vết và đối soát. Đối với luồng nhiều cơ sở dữ liệu, báo cáo sử dụng trạng thái nghiệp vụ và các bước bù có kiểm soát, thay vì giả định sao chép bất đồng bộ làm cho tất cả điểm commit cùng lúc.
Sao lưu và replication có mục đích khác nhau. Bản sao giúp đọc gần nơi sử dụng, nhưng thao tác xóa nhầm ở nguồn cũng có thể được truyền sang nơi nhận. Bản sao không thay thế bản sao lưu độc lập và thử phục hồi. Kế hoạch sao lưu cần xác định điểm khôi phục mục tiêu, thời gian khôi phục mục tiêu và người được quyền thực hiện.
RPO là khoảng dữ liệu có thể mất so với thời điểm sự cố; RTO là thời gian cần để khôi phục dịch vụ. Trong bài thực hành, nhóm đặt mục tiêu minh họa RPO 15 phút và RTO 60 phút, sau đó dùng thử phục hồi để đánh giá. Đây là mục tiêu thiết kế, chưa phải mức dịch vụ đã đo. Mô hình FULL cùng chuỗi bản sao lưu log phục vụ phục hồi theo thời điểm khi được cấu hình đúng [9], [10].
Khi S0 ngừng hoạt động, các chi nhánh vẫn có thể xem lịch đã đồng bộ, lập hồ sơ và lưu đơn nháp. Hệ thống dừng giữ chỗ, phát hành và hoàn tiền chính thức. Chỉ sau khi phục hồi nguồn ghi và đối soát các yêu cầu chưa rõ kết quả mới mở lại chức năng bán. Không tự nâng một Subscriber có dữ liệu cũ thành nguồn ghi để tiếp tục bán vé.
''', table=[['Loại sự cố','Phản ứng mong muốn'],['Mất mạng trước gửi','Lưu nháp và thông báo chưa gửi'],['Mất phản hồi sau commit','Tra cứu lại cùng mã yêu cầu'],['Replication dừng','Cảnh báo độ trễ, không ghi lên bản sao'],['Xóa nhầm dữ liệu','Phục hồi trên DB riêng rồi đối soát'],['Máy chủ S0 lỗi','Dừng giao dịch ghế đến khi khôi phục']])
page('1.6 Lựa chọn công nghệ', '''
SQL Server 2022 được chọn để giữ sự tương thích với hướng triển khai của báo cáo mẫu. Developer Edition hỗ trợ môi trường phát triển và kiểm thử, phù hợp để nhóm mô phỏng nhiều điểm bằng các instance hoặc máy ảo. Bản này dùng cho học tập và thử nghiệm theo điều kiện cấp phép của Microsoft, không được xem là lựa chọn giấy phép cho hệ thống sản xuất [11].
SSMS được dùng để tạo bảng, chạy script, kiểm tra job và xem Replication Monitor. SQL Server Agent quản lý các job liên quan đến sao chép và tác vụ hết hạn giữ chỗ. SQL Server Replication cần được cài cùng Database Engine; cài riêng SSMS không tạo ra một máy chủ dữ liệu. Nhóm cần kiểm tra phiên bản và thành phần trên từng điểm trước khi tạo publication.
Linked Server được dùng trong truy vấn báo cáo và kiểm tra tái thiết. Một truy vấn liên điểm không tự thay thế quy trình nghiệp vụ có idempotency. Đặc biệt, sử dụng giao dịch ghi qua nhiều máy chủ có thể đòi hỏi MS DTC; đây là một nhánh triển khai khác cần cấu hình và kiểm thử riêng [7]. Thiết kế mặc định tránh ghi phân tán qua Linked Server trong luồng bán vé.
Lớp ứng dụng có thể được xây bằng một API đơn giản để chuyển RequestID, BranchID, FlightID, FareClass và Quantity đến S0. Công nghệ giao diện không quyết định tính đúng của kho ghế; tính đúng được bảo vệ tại cơ sở dữ liệu chủ quản. Các đoạn mã trong báo cáo tập trung vào T-SQL và hợp đồng gọi nghiệp vụ để nhóm có thể bổ sung giao diện sau.
Mô hình ba chi nhánh giúp bài thực hành có đủ tình huống phân mảnh và mất kết nối nhưng vẫn kiểm soát được phạm vi. Trung tâm và chi nhánh Hà Nội là hai điểm logic riêng, kể cả khi cùng đặt trên một máy vật lý. Nếu chỉ dùng nhiều database trên một instance, nhóm có thể minh họa cấu trúc phân mảnh, nhưng chưa chứng minh được khả năng chịu lỗi mạng giữa các máy chủ độc lập.
''', table=[['Thành phần','Vai trò'],['SQL Server 2022 Developer','Lưu dữ liệu và thực hiện giao dịch'],['SSMS','Quản trị, chạy T-SQL, quan sát trạng thái'],['SQL Server Agent','Job replication và hết hạn giữ chỗ'],['Transactional replication','Chuyển danh mục và dữ liệu báo cáo'],['API nghiệp vụ','Định tuyến yêu cầu đến S0'],['Linked Server','Tra cứu liên điểm và tái thiết minh họa']])

page('CHƯƠNG 2 PHÂN TÍCH HỆ THỐNG\n2.1 Bối cảnh và phạm vi', '''
Hệ thống phục vụ một đơn vị hàng không giả định có ba chi nhánh bán vé. Chi nhánh Hà Nội mang mã HN, chi nhánh Đà Nẵng mang mã DN và chi nhánh TP Hồ Chí Minh mang mã HCM. Trung tâm tại Hà Nội quản lý danh mục và nguồn ghế thống nhất. Các mã và quy mô này là thông số mô hình để xây dựng bài thực hành, không mô tả một hãng đang vận hành thực tế.
Nghiệp vụ chính bắt đầu từ tra cứu chuyến bay và giá, lập hồ sơ khách hàng, tạo đơn nháp, giữ chỗ có thời hạn, nhận kết quả thanh toán rồi phát hành vé. Hệ thống hỗ trợ hủy giữ chỗ và hoàn vé theo quy tắc mô phỏng. Kết quả bán hàng được tổng hợp theo chi nhánh và thời gian để phục vụ quản lý.
Đề tài tập trung vào vé một chặng và sức chứa theo hạng ghế. Một đơn được gắn với một chuyến bay và một hạng; nhiều hành khách được biểu diễn bằng nhiều dòng chi tiết. Mỗi vé đại diện cho một hành khách. Không triển khai liên danh nhiều hãng, nối chuyến, quản lý phi hành đoàn, điều hành kiểm soát không lưu hoặc hệ thống bảo trì kỹ thuật máy bay. Các nghiệp vụ này có thể bổ sung nhưng cần mô hình dữ liệu riêng.
Yếu tố thông minh được đưa vào phạm vi bằng ba khả năng: cảnh báo độ trễ đồng bộ, phát hiện trạng thái đơn không khớp với giao dịch trung tâm và thống kê tỷ lệ lấp đầy để gợi ý chuyến thay thế. Việc gợi ý chỉ hỗ trợ nhân viên, không tự đổi chuyến của khách. Hệ thống không khẳng định dự đoán nhu cầu bằng AI khi chưa có dữ liệu huấn luyện và phương pháp đánh giá.
Trong giai đoạn học tập, thanh toán được mô phỏng bằng mã giao dịch bên ngoài và trạng thái thành công hoặc thất bại. Mọi thông tin hành khách dùng dữ liệu giả lập; không đưa giấy tờ cá nhân thật vào script hoặc ảnh minh chứng. Phạm vi này đủ để đánh giá thiết kế phân tán và giao dịch mà không cần tích hợp dịch vụ thanh toán thực.
''', table=[['Trong phạm vi','Ngoài phạm vi'],['Bán vé một chặng','Liên danh và vé nối chuyến'],['Quản lý kho ghế theo hạng','Chọn số ghế cụ thể trên sơ đồ cabin'],['Giữ chỗ và phát hành','Thanh toán tiền thật'],['Đơn bán và báo cáo chi nhánh','Điều hành an toàn bay'],['Cảnh báo dựa trên quy tắc','Mô hình dự báo học máy']])
page('2.2 Tác nhân và trách nhiệm', '''
Khách hàng cung cấp thông tin hành khách, lựa chọn chuyến bay và xác nhận phương án mua. Trong bài thực hành, khách hàng có thể thao tác qua nhân viên; nếu bổ sung cổng tự phục vụ, quyền của khách vẫn chỉ giới hạn ở các đơn được phép truy cập. Không cho khách kết nối trực tiếp đến SQL Server hoặc xem toàn bộ dữ liệu chi nhánh.
Nhân viên bán vé lập hồ sơ giao dịch và đơn tại chi nhánh của mình. Nhân viên được gửi yêu cầu giữ chỗ và phát hành thông qua API được cấp quyền, không được trực tiếp sửa Held hoặc Sold. Quyền thao tác dữ liệu không chỉ phụ thuộc chức danh mà còn phụ thuộc BranchID của phiên làm việc.
Quản lý chi nhánh xem báo cáo đơn bán và các ngoại lệ của đơn thuộc chi nhánh. Người này có thể phê duyệt yêu cầu hủy theo phạm vi nghiệp vụ nhưng không tự sửa giá trị tồn ghế để làm báo cáo khớp. Mọi chỉnh sửa sau bán cần lý do và nhật ký. Trụ sở chính tổng hợp dữ liệu và công bố danh mục, lịch bay, chính sách giá.
Kế toán phụ trách đối soát thanh toán và hoàn tiền. Một giao dịch có thể được ghi nhận thành công ở trung tâm nhưng trạng thái đơn tại chi nhánh chưa cập nhật; kế toán cần tra cứu nguồn gốc trước khi thực hiện thao tác bù. Quyền hoàn tiền không đồng nghĩa với quyền thay đổi dữ liệu khách hàng hoặc lịch bay.
Quản trị cơ sở dữ liệu cấu hình kết nối, sao lưu, phục hồi và replication. Tài khoản ứng dụng, tài khoản agent và tài khoản quản trị phải tách biệt để có thể xác định nguồn của thao tác. Trong quá trình trình diễn, nhóm có thể dùng tài khoản quản trị để thiết lập môi trường, nhưng các ca kiểm thử phân quyền phải chạy bằng tài khoản nghiệp vụ riêng.
''', table=[['Tác nhân','Dữ liệu cần dùng','Giới hạn'],['Khách hàng','Thông tin chuyến và đơn của mình','Không xem đơn của người khác'],['Nhân viên bán vé','Hồ sơ, đơn, lịch bay','Chỉ đơn của chi nhánh'],['Quản lý chi nhánh','Báo cáo và yêu cầu hủy','Không sửa kho ghế'],['Kế toán','Payment, Refund, đối soát','Không tự phát hành vé'],['Quản trị danh mục','Sân bay, đường bay, giá','Không sửa số liệu thanh toán'],['DBA','Hạ tầng và bản sao lưu','Thao tác đặc quyền phải có nhật ký']])
page('2.3 Yêu cầu chức năng', '''
Yêu cầu chức năng được đánh mã để liên kết với thiết kế và kiểm thử. Nhóm dùng các mã này trong bảng nghiệm thu, nhờ đó một chức năng có thể được kiểm tra bằng dữ liệu đầu vào và kết quả rõ ràng. Đối với chức năng bán vé, kết quả không chỉ là hiển thị thông báo thành công; trạng thái đơn, kho ghế, vé và thanh toán phải phù hợp với nhau.
Tra cứu chuyến bay được phép dùng bản sao lịch bay và giá. Giá hiển thị là thông tin tham khảo cho đến khi S0 xác nhận giữ chỗ với một đơn giá cố định. Tạo đơn lưu thông tin ở chi nhánh và gửi mã yêu cầu ổn định đến trung tâm. Khi khách thay đổi số lượng hoặc chuyến bay, hệ thống phải tạo một yêu cầu mới sau khi giải quyết giữ chỗ cũ.
Chức năng hủy chia thành hủy giữ chỗ chưa bán và yêu cầu hoàn vé đã bán. Hai chức năng tác động đến các bộ đếm khác nhau: hủy giữ làm giảm Held, hoàn vé hợp lệ làm giảm Sold. Chỉ hiển thị trạng thái hoàn tất khi giao dịch nguồn đã được xác nhận, không dựa vào việc nhân viên nhấn nút.
Danh mục và lịch bay có phiên bản cập nhật để chi nhánh biết mức độ mới của dữ liệu. Khi một chuyến đã có vé bán, thay đổi đường bay hoặc máy bay cần quy trình kiểm tra riêng; không xóa cứng bản ghi có lịch sử. Báo cáo chỉ tính các khoản thanh toán thành công, trừ các khoản hoàn tiền thành công theo thời điểm quy định.
''', table=[['Mã','Chức năng','Tiêu chí chấp nhận'],['F01','Tra cứu chuyến','Đúng chặng, ngày, hạng và trạng thái'],['F02','Lập hồ sơ và đơn','Đơn thuộc đúng chi nhánh'],['F03','Giữ chỗ','Không vượt ghế; có hạn dùng'],['F04','Xác nhận thanh toán','Không ghi lặp mã giao dịch'],['F05','Phát hành vé','Một vé cho mỗi dòng hành khách'],['F06','Hủy và hoàn','Đúng trạng thái, có nhật ký'],['F07','Quản lý danh mục','Một nguồn ghi, bản sao cập nhật'],['F08','Báo cáo đa điểm','Không tính trùng bản sao'],['F09','Cảnh báo ngoại lệ','Xác định được đơn và nguồn đối soát']])
page('2.4 Quy trình bán vé', '''
Nhân viên tra cứu chuyến bay trên dữ liệu đọc của chi nhánh, xác nhận danh sách hành khách rồi lưu SalesOrder ở trạng thái DRAFT. OrderID dùng định danh duy nhất; BranchID được lấy từ phiên đăng nhập, không lấy tự do từ ô nhập liệu. SalesItem lưu các hành khách thuộc đơn. Đây là giao dịch cục bộ nên chi nhánh vẫn có thể tạo nháp khi đường truyền đến trung tâm bị gián đoạn.
Khi gửi yêu cầu giữ chỗ, ứng dụng tạo RequestID một lần và giữ nguyên mã này trong mọi lần thử lại. S0 kiểm tra chuyến bay, hạng, giá, số lượng và cập nhật kho ghế trong cùng giao dịch. Nếu thành công, hệ thống trả HoldID, ExpiresAt và UnitPrice. Chi nhánh chuyển đơn sang HELD sau khi ghi nhận phản hồi; mất phản hồi chuyển đơn sang PENDING_RECONCILE để tra cứu lại.
Khách thanh toán trong thời gian giữ. Hệ thống xác minh kết quả thanh toán rồi gửi ExternalRef cùng HoldID đến S0. Giao dịch xác nhận khóa bản giữ, kiểm tra chưa hết hạn, chuyển Held sang Sold, tạo bản ghi thanh toán và số vé. Chi nhánh cập nhật đơn thành ISSUED sau khi đọc kết quả nguồn. Nếu giữ đã hết hạn nhưng tiền đã được nhận, hệ thống đưa vào hàng đối soát để hoàn hoặc xử lý thủ công.
Luồng hủy giữ, hết hạn và phát hành đều đi qua S0. Chi nhánh không trực tiếp giảm bộ đếm từ bản sao. Quy trình này bảo đảm một nơi quyết định trạng thái ghế, trong khi thông tin bán hàng và báo cáo vẫn phân tán theo chi nhánh.
''', fig='workflow.png', caption='Hình 2 Quy trình bán vé và đường xử lý khi mất phản hồi. Sơ đồ do nhóm thiết kế.', note='PENDING_RECONCILE là trạng thái chờ đối soát; đây chưa phải thành công hoặc thất bại cuối cùng.')
page('2.5 Ma trận quyền nghiệp vụ', '''
Ma trận quyền mô tả thao tác được phép theo vai trò. Việc thực thi cần kết hợp quyền cơ sở dữ liệu, kiểm tra quyền ở API và lọc theo chi nhánh. Một tài khoản có quyền chạy procedure giữ chỗ không được nhận quyền UPDATE trực tiếp trên Inventory, vì quyền này có thể bỏ qua điều kiện kiểm tra sức chứa.
Tại mỗi chi nhánh, CustomerProfile, Employee, SalesOrder và SalesItem chỉ chứa dữ liệu của chi nhánh chủ quản. Tuy nhiên, kiểm tra BranchID vẫn cần thiết trong API để ngăn chuyển yêu cầu sang database khác bằng cách thay đổi tham số. Chi nhánh không đọc bảng CustomerPrivate của chi nhánh khác khi chỉ cần tìm lịch bay hoặc số lượng vé.
Ở trung tâm, tài khoản replication được cấp quyền theo vai trò và công việc agent cần thực hiện. Tài khoản báo cáo chỉ có SELECT trên các bảng nhận và view tổng hợp. Tài khoản vận hành thanh toán được gọi procedure đối soát hoặc hoàn, không được xóa bản ghi Payment. DBA dùng tài khoản đặc quyền riêng để thiết lập và khắc phục sự cố.
Quyền cần được kiểm thử bằng hành động bị từ chối. Ví dụ, tài khoản bán vé tại DN cố sửa Inventory phải thất bại; tài khoản báo cáo cố tạo Payment phải thất bại; người dùng đổi BranchID từ DN sang HCM phải bị API từ chối. Chỉ kiểm tra thao tác được phép chưa đủ để chứng minh cơ chế phân quyền hoạt động.
''', table=[['Đối tượng','Bán vé','QL chi nhánh','Kế toán','QL danh mục'],['Hồ sơ chi nhánh','Đọc và sửa','Đọc','Đọc tối thiểu','Không'],['Đơn chi nhánh','Lập và gửi','Đọc, duyệt hủy','Đọc để đối soát','Không'],['Inventory','Qua procedure','Đọc','Đọc','Đọc'],['Payment Refund','Gửi yêu cầu','Đọc','Qua procedure','Không'],['Danh mục lịch bay','Đọc','Đọc','Đọc','Sửa tại S0'],['Báo cáo chi nhánh','Đọc hạn chế','Đọc','Đọc','Đọc hạn chế'],['Cấu hình replication','Không','Không','Không','Không']], note='DBA cấu hình hạ tầng riêng. Bảng trên mô tả quyền nghiệp vụ; quyền cuối cùng còn được giới hạn theo BranchID.')
page('2.6 Tần suất truy cập và yêu cầu chất lượng', '''
Định vị dữ liệu cần dựa vào nơi phát sinh truy cập. Bảng dưới sử dụng một bộ giả định tải để so sánh phương án: mỗi ngày có nhiều lượt tra cứu hơn lượt bán, và đơn của chi nhánh chủ yếu được xử lý tại chính chi nhánh đó. Các giá trị không phải số liệu thống kê của hãng hàng không; nhóm phải thay bằng dữ liệu đo nếu có môi trường triển khai.
Giả sử HN có 1.200 lượt tra cứu và 180 đơn, DN có 800 lượt tra cứu và 120 đơn, HCM có 1.600 lượt tra cứu và 240 đơn mỗi ngày. Nhân bản lịch bay giúp các lượt tra cứu không phải chuyển mọi yêu cầu đến S0. Ngược lại, giữ chỗ vẫn cần S0 dù làm tăng số yêu cầu liên điểm, bởi chi phí sai lệch ghế lớn hơn lợi ích giảm độ trễ.
Mục tiêu phản hồi cục bộ được đặt ở mức p95 không quá 2 giây, xác nhận giữ chỗ trực tuyến không quá 3 giây trong tải thử đã xác định, và độ trễ danh mục không quá 30 giây ở điều kiện bình thường. Các ngưỡng là mục tiêu nghiệm thu, không phải kết quả đạt được. Khi đo, phải ghi số client, cấu hình máy, độ trễ mạng và kích thước dữ liệu.
Yêu cầu tính toàn vẹn có ưu tiên cao hơn thời gian phản hồi. Tỷ lệ bán vượt sức chứa phải bằng không trong tập kiểm thử đồng thời. Cùng RequestID hoặc ExternalRef không được tạo nhiều bản ghi nguồn. Khi hệ thống không xác định được kết quả, trạng thái chờ đối soát phải được thể hiện rõ để nhân viên không thu tiền hoặc đặt lại một cách thiếu kiểm soát.
''', table=[['Nghiệp vụ mỗi ngày','HN','DN','HCM','Vị trí xử lý'],['Tra cứu chuyến giả định','1.200','800','1.600','Bản sao chi nhánh'],['Đơn bán giả định','180','120','240','Mảnh chi nhánh'],['Giữ chỗ giả định','200','140','270','S0'],['Lập báo cáo chi nhánh','8','8','8','Mảnh cục bộ'],['Tổng hợp toàn hệ thống','4','4','4','Kho báo cáo S0']], note='p95 là phân vị 95 của thời gian phản hồi. Phải đo trên cùng một kịch bản tải để so sánh phương án.')
page('2.7 Quy tắc nghiệp vụ và hợp đồng dữ liệu', '''
Quy tắc đầu tiên là tổng số ghế đang giữ và đã bán không vượt Capacity, đồng thời các bộ đếm không âm. Quantity là số nguyên dương. FlightID và FareClass xác định một kho ghế; giá giữ chỗ được chốt tại S0. Thay đổi giá danh mục sau thời điểm giữ không làm thay đổi UnitPrice của một giữ chỗ đã hợp lệ.
Mỗi RequestID chỉ đại diện cho một bộ tham số BranchID, OrderID, FlightID, FareClass và Quantity. Nếu gọi lại cùng mã nhưng khác tham số, S0 phải từ chối thay vì trả một kết quả cũ không tương ứng. Mỗi ExternalRef chỉ đại diện cho một giao dịch thanh toán; callback trùng được trả lại kết quả đã xử lý. Idempotency không chỉ là tạo một chỉ mục UNIQUE mà còn phải kiểm tra nội dung yêu cầu.
Giữ chỗ chuyển từ ACTIVE sang CONFIRMED, EXPIRED hoặc CANCELLED đúng một lần. Xác nhận chỉ hợp lệ khi thời gian UTC của S0 nhỏ hơn ExpiresAt. Job hết hạn và procedure xác nhận phải sử dụng cùng quy tắc ranh giới thời gian. Vé đã phát hành không bị xóa cứng; hoàn vé tạo một lịch sử hoàn và cập nhật trạng thái vé.
Đơn bán có một chi nhánh gốc cố định. Hồ sơ khách hàng trong phạm vi đề tài là hồ sơ giao dịch cục bộ; cùng một người có thể xuất hiện ở hai chi nhánh. CustomerID không có ý nghĩa là định danh một con người duy nhất toàn hãng. Nếu mở rộng chương trình khách hàng thân thiết, nhóm cần thêm định danh khách hàng trung tâm và cơ chế hợp nhất hồ sơ.
Ngày giờ lưu bằng datetime2 theo UTC; khi hiển thị tại Việt Nam, ứng dụng chuyển sang giờ địa phương. Tiền dùng decimal thay vì float. Những dữ liệu không thể kiểm tra bằng FK cục bộ, như OrderID ở trung tâm và FlightID trong mảnh chi nhánh, được xác minh qua dịch vụ và job đối soát. Không mô tả FK liên máy chủ như một ràng buộc SQL Server được thực thi tự động.
''', table=[['Mã','Bất biến hoặc quy tắc'],['R01','0 ≤ Held + Sold ≤ Capacity'],['R02','RequestID duy nhất và tham số không đổi'],['R03','ExternalRef không được xử lý lặp'],['R04','ACTIVE chỉ chuyển sang một trạng thái kết thúc'],['R05','Số vé phát hành bằng Quantity của giữ chỗ'],['R06','Đơn và chi tiết cùng chi nhánh'],['R07','Báo cáo doanh thu dùng nguồn Payment Refund']])
page('CHƯƠNG 3 THIẾT KẾ CƠ SỞ DỮ LIỆU TOÀN CỤC\n3.1 Mô hình thực thể và quan hệ', '''
Mô hình toàn cục gồm nhóm danh mục, nhóm nghiệp vụ nguồn tại trung tâm và nhóm bán hàng chi nhánh. Airport, Route, Aircraft, Flight và Fare mô tả sản phẩm bán. Inventory lưu sức chứa theo chuyến và hạng. SeatHold, Ticket, Payment và Refund biểu diễn quá trình giữ, bán và hoàn. Branch, Employee, CustomerProfile, SalesOrder và SalesItem mô tả nơi phát sinh đơn và hành khách.
Route có hai quan hệ đến Airport tương ứng điểm đi và điểm đến. Một Route có nhiều Flight; một Aircraft có thể phục vụ nhiều Flight ở các thời điểm khác nhau. Flight và FareClass tạo khóa ghép của Inventory và Fare. Trong phạm vi bài tập, hạng ghế gồm ECO và BUS; tổng sức chứa các hạng không được vượt sức chứa máy bay theo cấu hình khai thác.
SeatHold thuộc một kho ghế, một chi nhánh và một OrderID. Ticket thuộc một giữ chỗ và có ItemNo để tương ứng với dòng hành khách trong đơn. Payment thuộc một giữ chỗ; Refund thuộc một vé. Các quan hệ OrderID giữa S0 và chi nhánh là liên kết logic được dịch vụ kiểm tra, không phải khóa ngoại vật lý xuyên máy chủ.
''', fig='erd.png', caption='Hình 3 Mô hình dữ liệu toàn cục. Nét liền là liên kết có thể thực thi bằng FK khi cùng DB; nét đứt là liên kết logic liên điểm.', note='ERD rút gọn các thuộc tính để dễ đọc. Từ điển dữ liệu tại mục 3.2 đến 3.6 quy định khóa và ý nghĩa chi tiết.')
page('3.2 Danh mục và lịch bay', '''
Danh mục được quản lý tại S0 và nhân bản một chiều đến ba chi nhánh. Nhóm chọn khóa ngắn cho sân bay, đường bay và chi nhánh để dễ đọc trong bài thực hành; định danh chuyến bay vẫn tách khỏi số hiệu thương mại. FlightID xác định một lần khai thác, còn FlightNo có thể lặp lại vào các ngày khác nhau.
AirportCode được dùng như mã sân bay trong dữ liệu mô phỏng. Một Route không cho phép cùng mã sân bay ở điểm đi và điểm đến. Aircraft lưu số đăng ký và sức chứa cấu hình; không lưu số ghế còn lại của chuyến bay vì giá trị đó thuộc Inventory. Khi thay đổi máy bay của chuyến đã bán, hệ thống phải kiểm tra sức chứa mới thay vì cập nhật không điều kiện.
Flight lưu DepartureUtc, ArrivalUtc, RouteID, AircraftID và Status. ArrivalUtc phải lớn hơn DepartureUtc. Các trạng thái minh họa gồm OPEN, CLOSED và CANCELLED. Việc chuyển sang CANCELLED không xóa vé đã phát hành mà tạo công việc xử lý các khách hàng bị ảnh hưởng. Ngày tra cứu địa phương phải được chuyển sang khoảng thời gian UTC trước khi truy vấn.
Fare lưu đơn giá theo chuyến và hạng. Giá hiện hành phục vụ tra cứu và tạo giữ chỗ; UnitPrice tại SeatHold lưu giá đã chốt để có thể đối soát sau này. Vì giá hiện hành và giá chốt có ý nghĩa khác nhau, đây không phải việc lặp dữ liệu thiếu kiểm soát. Sử dụng Price decimal(18,2), không dùng float trong tính tiền.
''', table=[['Bảng','Khóa','Thuộc tính chính và ràng buộc'],['Branch','BranchID','Tên, địa điểm; HN DN HCM'],['Airport','AirportCode','AirportName, City'],['Route','RouteID','OriginCode, DestCode; hai sân bay khác nhau'],['Aircraft','AircraftID','Registration UNIQUE, TotalSeats > 0'],['Flight','FlightID','FlightNo, giờ UTC, trạng thái, FK Route Aircraft'],['Fare','FlightID FareClass','Price > 0, Currency mặc định VND']], note='Danh mục giả lập chỉ phục vụ mô hình học tập; mã khai thác và lịch bay không phải thông tin lịch bay thương mại hiện hành.')
page('3.3 Kho ghế theo chuyến bay', '''
Inventory là quan hệ quan trọng nhất đối với tính đúng của bán vé. Một dòng xác định số ghế của một FlightID và FareClass. Capacity là số ghế được mở bán; Held là tổng số đang giữ trong các giữ chỗ ACTIVE; Sold là số vé ISSUED chưa được hoàn theo quy tắc mô phỏng. Giá trị còn bán được bằng Capacity trừ Held trừ Sold.
Không lưu Available như một cột độc lập có thể sửa. Truy vấn có thể tính giá trị này hoặc dùng computed column, nhưng nguồn dữ liệu vẫn là ba bộ đếm được bảo vệ. Ràng buộc CHECK kiểm tra Capacity dương, Held và Sold không âm, tổng không vượt Capacity. Cùng với điều kiện UPDATE, CHECK là lớp bảo vệ khi xảy ra lỗi lập trình.
Tổng Held cần khớp với tổng Quantity của SeatHold ACTIVE; Sold cần khớp với số Ticket ở trạng thái ISSUED. Các CHECK trên một dòng Inventory không tự kiểm tra được hai quan hệ này. Vì vậy, procedure phải cập nhật theo giao dịch, đồng thời job đối soát phát hiện sai lệch. Không sửa trực tiếp các bộ đếm chỉ để làm câu truy vấn đối soát trả về bằng nhau.
Inventory có một nguồn ghi tại S0. Bản sao của kho ghế, nếu được công bố để hiển thị, luôn được đánh dấu là tham khảo. Nhân viên tại DN thấy còn ghế trên bản sao nhưng yêu cầu giữ tại S0 có thể bị từ chối do ghế vừa được chi nhánh khác giữ. Đây là tình huống bình thường của dữ liệu đọc bất đồng bộ, không phải lý do cho phép bỏ qua kiểm tra nguồn.
Thay đổi Capacity chỉ được thực hiện trước hoặc sau một quy trình kiểm tra. Nếu Capacity mới nhỏ hơn Held cộng Sold, hệ thống phải từ chối và yêu cầu xử lý khách bị ảnh hưởng. Trong bài thực hành cơ bản, dữ liệu cấu hình không thay đổi sau khi mở bán để tập trung vào kiểm thử đồng thời.
''', table=[['Trường','Kiểu','Ý nghĩa'],['FlightID','varchar(20)','Khóa chuyến bay'],['FareClass','varchar(3)','ECO hoặc BUS'],['Capacity','int','Sức chứa mở bán'],['Held','int','Ghế thuộc giữ chỗ ACTIVE'],['Sold','int','Vé ISSUED chưa hoàn'],['UpdatedAt','datetime2(3)','Thời điểm thay đổi UTC'],['Version','rowversion','Phiên bản kỹ thuật cho kiểm soát cập nhật']], code='''
CHECK (Capacity > 0 AND Held >= 0 AND Sold >= 0
       AND Held + Sold <= Capacity)
-- Available = Capacity - Held - Sold
''')
page('3.4 Khách hàng và nhân viên chi nhánh', '''
CustomerProfile lưu hồ sơ giao dịch tại một chi nhánh. CustomerID là uniqueidentifier, BranchID là mã nơi sở hữu. Trong mô hình này, hệ thống không sử dụng số điện thoại hoặc số giấy tờ làm khóa chính. Các giá trị này có thể thay đổi, có thể thiếu hoặc được dùng chung trong một gia đình, nên không phù hợp để xác định mọi hồ sơ một cách chắc chắn.
FullName và BirthDate hỗ trợ lập đơn; Phone, Email và DocumentNo được giới hạn quyền truy cập. Có thể tách một một thành CustomerPublic và CustomerPrivate ở mức mở rộng. Bản báo cáo giữ bảng cơ bản để đơn giản hóa thực hành và sử dụng view giới hạn cột cho tài khoản báo cáo. Thông tin nhạy cảm không được nhân bản đầy đủ vào kho phân tích khi chỉ cần thống kê số đơn.
Employee thuộc một BranchID, có EmployeeID duy nhất, FullName, Position và IsActive. Nhân viên nghỉ việc được đánh dấu không hoạt động; không xóa bản ghi đang được SalesOrder tham chiếu. Tài khoản đăng nhập hệ thống là đối tượng bảo mật riêng, không đồng nhất với EmployeeID. Ánh xạ giữa tài khoản và nhân viên cần được quản lý khi cấp quyền.
Một khách có thể mua vé cho nhiều hành khách. CustomerProfile đại diện người giao dịch; PassengerName và PassengerDocument tại SalesItem đại diện người sẽ sử dụng vé. Không giả định người mua luôn là hành khách. Nội dung giấy tờ trong dữ liệu kiểm thử dùng chuỗi giả lập và được che khi chụp màn hình trình diễn.
''', table=[['Bảng và trường','Kiểu','Quy tắc'],['CustomerID','uniqueidentifier','PK, sinh một lần'],['BranchID','varchar(3)','Không rỗng; thuộc mảnh hiện tại'],['FullName','nvarchar(100)','Tên người giao dịch'],['BirthDate','date','Có thể rỗng trong mô hình cơ bản'],['Phone Email','varchar(30) nvarchar(150)','Thông tin liên hệ, hạn chế quyền'],['DocumentNo','nvarchar(30)','Giấy tờ giả lập; không dùng làm PK'],['EmployeeID','varchar(20)','PK, mã có tiền tố chi nhánh'],['Employee.IsActive','bit','Ngăn nhân viên ngừng hoạt động lập đơn mới']])
page('3.5 Đơn bán và chi tiết hành khách', '''
SalesOrder là phần dữ liệu gốc do chi nhánh tạo. Đơn có OrderID, BranchID, CustomerID, EmployeeID, FlightID, FareClass, Quantity, RequestID, HoldID, Status và CreatedAt. CustomerID và EmployeeID dùng FK cục bộ. FlightID và HoldID là tham chiếu logic đến dữ liệu trung tâm; bản sao Flight có thể hỗ trợ kiểm tra, nhưng xác nhận nghiệp vụ vẫn đi qua S0.
SalesItem có khóa ghép OrderID và ItemNo. Mỗi dòng lưu tên hành khách, giấy tờ mô phỏng, đơn giá đã chốt và TicketID khi đã phát hành. ItemNo bắt đầu từ 1 và tăng trong phạm vi một đơn. Số dòng của một đơn phải bằng Quantity trước khi gửi giữ chỗ; người mua không được gửi Quantity lớn hơn danh sách đã xác nhận.
Status của đơn phản ánh góc nhìn tại chi nhánh: DRAFT, HELD, ISSUED, CANCELLED hoặc PENDING_RECONCILE. Trạng thái chờ đối soát cần một trường hoặc bảng theo dõi LastError và LastCheckedAt để xác định lần xử lý tiếp theo. Không đổi đơn thành CANCELLED chỉ vì lời gọi S0 hết thời gian chờ, bởi giao dịch nguồn có thể đã thành công.
S0 lưu OrderID để liên kết kết quả nghiệp vụ với đơn gốc mà không cần sao chép toàn bộ hồ sơ. Khi xác nhận, Ticket có ItemNo tương ứng với SalesItem. Sau khi S0 trả kết quả, chi nhánh cập nhật TicketID cho các dòng trong một giao dịch cục bộ. Nếu cập nhật này thất bại, tác vụ đối soát dùng HoldID để đọc lại danh sách vé đã phát hành.
Thông tin tiền chính thức nằm ở Payment và Refund tại S0. Tổng giá trị dòng đơn là dữ liệu mô tả thỏa thuận bán; nó không tự chứng minh rằng khách đã trả tiền. Báo cáo doanh thu sử dụng nguồn giao dịch tài chính để tránh tính cả đơn nháp, giữ chỗ hết hạn hoặc đơn đã hoàn.
''', table=[['Quan hệ','Khóa','Liên kết'],['SalesOrder','OrderID','FK cục bộ CustomerID EmployeeID'],['SalesOrder.RequestID','UNIQUE','Mã yêu cầu gửi S0'],['SalesOrder.HoldID','Có thể rỗng','Tham chiếu logic SeatHold'],['SalesItem','OrderID ItemNo','FK cục bộ đến SalesOrder'],['SalesItem.TicketID','Có thể rỗng','Tham chiếu logic Ticket'],['SalesItem.UnitPrice','decimal(18,2)','Giá tại thời điểm giữ thành công']])
page('3.6 Giữ chỗ vé và giao dịch tài chính', '''
SeatHold lưu RequestID duy nhất để kiểm soát thử lại. Bản giữ có HoldID, OrderID, BranchID, FlightID, FareClass, Quantity, UnitPrice, Status, CreatedAt và ExpiresAt. Khóa ngoại từ SeatHold đến Inventory và Branch được thực thi ở S0. Không đặt FK vật lý từ SeatHold đến SalesOrder ở một máy chủ khác.
Ticket được tạo khi giữ chỗ được xác nhận thanh toán. TicketID là định danh vé; HoldID và ItemNo có UNIQUE để không phát hành hai vé cho cùng dòng hành khách. Trạng thái vé gồm ISSUED và REFUNDED trong mô hình cơ bản. Không dùng mã vé của một hãng thật hoặc gán giá trị giả lập như chứng từ thương mại hợp lệ.
Payment có PaymentID, HoldID, ExternalRef, Amount, Status và PaidAt. Mô hình cơ bản chỉ lưu thanh toán thành công tại bảng nguồn; các lần thất bại được ghi vào nhật ký ứng dụng hoặc bảng PaymentAttempt mở rộng. ExternalRef có UNIQUE; HoldID có UNIQUE để một giữ chỗ chỉ có một thanh toán thành công. Amount được tính từ Quantity và UnitPrice tại giữ chỗ, không tin trực tiếp số tiền phía giao diện gửi lên.
Refund có RefundID, TicketID, ExternalRef, Amount, Status và RefundedAt. Mỗi vé chỉ được hoàn một lần trong phạm vi cơ bản; UNIQUE trên TicketID ngăn hoàn lặp. Hoàn một phần, phí thay đổi và nhiều lần hoàn cho một vé là phạm vi mở rộng cần bảng phân bổ riêng. Quy tắc mô phỏng hoàn toàn bộ đơn giá đã trả và giải phóng một ghế nếu chuyến chưa đóng.
Nhật ký nghiệp vụ lưu mã yêu cầu, tác nhân, trạng thái trước sau và thời điểm UTC. Không ghi dữ liệu thẻ hoặc thông tin bí mật vào nhật ký. Tác vụ đối soát truy tìm đường liên kết OrderID, RequestID, HoldID và TicketID để xác định sự kiện bị thiếu ở chi nhánh.
''', table=[['Quan hệ','Khóa hoặc UNIQUE','Mục đích'],['SeatHold','PK HoldID; UQ RequestID','Một kết quả cho một yêu cầu'],['Ticket','PK TicketID; UQ HoldID ItemNo','Một vé trên một dòng'],['Payment','PK PaymentID; UQ ExternalRef HoldID','Không ghi thanh toán trùng'],['Refund','PK RefundID; UQ ExternalRef TicketID','Không hoàn cùng vé nhiều lần'],['AuditEvent','PK EventID','Truy vết thao tác và trạng thái']])
page('3.7 Chuẩn hóa và tính toàn vẹn', '''
Thiết kế tránh lưu danh sách hành khách dưới dạng chuỗi trong một cột. SalesItem biểu diễn mỗi hành khách bằng một dòng, giúp kiểm tra số lượng, phát hành từng vé và hoàn từng vé. Đây là cách bảo đảm thuộc tính nguyên tử và truy vấn có cấu trúc theo hướng chuẩn thứ nhất.
Khóa ghép SalesItem là OrderID và ItemNo. PassengerName phụ thuộc vào toàn bộ khóa này, còn tên chi nhánh phụ thuộc BranchID nên không đặt trong SalesItem. Với Inventory, Capacity, Held và Sold phụ thuộc tổ hợp FlightID và FareClass; tên sân bay hay loại máy bay được giữ ở danh mục và truy vấn bằng phép nối.
SalesOrder lưu BranchID để thể hiện nơi bán lịch sử dù nhân viên có thể chuyển chi nhánh về sau. SeatHold lưu UnitPrice để giữ giá đã chốt dù Fare.Price thay đổi. Những trường này là dữ liệu lịch sử có ý nghĩa riêng, cần giải thích rõ để tránh coi mọi trường lặp là lỗi chuẩn hóa. Ngược lại, không lưu cả AirportName trong Flight rồi cho sửa độc lập vì sẽ gây bất nhất danh mục.
Các phụ thuộc hàm chính gồm OrderID xác định thuộc tính đơn, CustomerID xác định hồ sơ cục bộ, FlightID xác định lịch khai thác, và cặp FlightID FareClass xác định giá hiện hành cùng kho ghế. Kiểm tra chuẩn hóa tập trung vào việc mỗi bảng mô tả một đối tượng hoặc một sự kiện rõ ràng. Bảng Payment không đồng thời chứa thông tin máy bay hoặc họ tên nhân viên.
Ràng buộc ở SQL bao gồm PK, FK cục bộ, UNIQUE, NOT NULL và CHECK. Ràng buộc liên bảng về tổng ghế, số hành khách và quyền chi nhánh cần procedure hoặc tác vụ kiểm tra. CHECK không được mô tả như cơ chế có thể truy vấn bảng khác để bảo vệ toàn bộ quy trình. Mỗi quy tắc phải có nơi thực thi và tình huống kiểm thử tương ứng.
''', table=[['Phụ thuộc hoặc quy tắc','Nơi bảo vệ'],['OrderID → dữ liệu đơn','PK SalesOrder'],['OrderID ItemNo → hành khách','PK SalesItem'],['RequestID → một SeatHold','UNIQUE và procedure kiểm tra tham số'],['Held + Sold ≤ Capacity','CHECK và UPDATE có điều kiện'],['Số dòng đơn = Quantity','Procedure/API trước khi gửi'],['Tổng Held khớp các giữ ACTIVE','Giao dịch nguồn và job đối soát'],['Chỉ chi nhánh gốc xử lý đơn','API, quyền DB và nhật ký']])
page('3.8 Thiết kế chỉ mục và truy vấn', '''
Chỉ mục được chọn theo điều kiện truy vấn thực tế. Inventory dùng PK trên FlightID và FareClass để mỗi yêu cầu giữ chỗ cập nhật đúng một dòng. SeatHold có UNIQUE trên RequestID cho tra cứu lại và chỉ mục theo Status, ExpiresAt cho tác vụ hết hạn. SalesOrder có chỉ mục theo BranchID, CreatedAt để lập báo cáo trong một khoảng ngày.
Flight cần truy vấn theo RouteID và DepartureUtc khi tra cứu chặng. Chỉ mục có thể bao gồm Status và FlightNo để giảm đọc bảng nhưng không nên thêm tất cả cột vào mọi chỉ mục. Mỗi chỉ mục làm tăng chi phí ghi, dung lượng và dữ liệu sao chép; lựa chọn cuối cùng cần dựa trên kế hoạch thực thi và tải thử.
Điều kiện thời gian dùng khoảng nửa mở: CreatedAt lớn hơn hoặc bằng mốc đầu và nhỏ hơn mốc cuối. Cách này tránh lỗi bỏ sót phần mili giây cuối ngày. Không bọc cột bằng CAST hoặc CONVERT trong điều kiện chính nếu có thể chuyển khoảng ngày ở phía tham số, vì biểu thức trên cột có thể làm việc sử dụng chỉ mục kém hiệu quả.
rowversion phục vụ phát hiện cập nhật dựa trên phiên bản cũ, không đại diện cho thời gian đồng bộ và không phải timestamp theo nghĩa ngày giờ. Khi nhân viên sửa hồ sơ, câu UPDATE có thể thêm điều kiện Version bằng phiên bản đã đọc; nếu không có dòng được cập nhật, giao diện yêu cầu tải lại để tránh ghi đè thông tin mới.
Nhóm cần lưu execution plan trước và sau khi thêm chỉ mục. Giảm số logical reads là bằng chứng hữu ích, nhưng không thay thế đo thời gian phản hồi và tác động lên ghi. Chỉ mục lọc có thể phù hợp cho tập trạng thái nhỏ khi điều kiện ổn định; cơ chế và giới hạn được tham khảo tại [8].
''', code='''
CREATE INDEX IX_Flight_Route_Departure
ON dbo.Flight(RouteID, DepartureUtc)
INCLUDE (FlightNo, Status);

CREATE INDEX IX_SeatHold_Expiry
ON dbo.SeatHold(Status, ExpiresAt)
INCLUDE (FlightID, FareClass, Quantity);

CREATE INDEX IX_SalesOrder_Branch_Date
ON dbo.SalesOrder(BranchID, CreatedAt)
INCLUDE (Status, HoldID);
''', note='Các chỉ mục là phương án ban đầu. Kiểm thử trên dữ liệu và tham số đại diện trước khi giữ hoặc bổ sung.')
page('CHƯƠNG 4 THIẾT KẾ CƠ SỞ DỮ LIỆU PHÂN TÁN\n4.1 Kiến trúc các điểm xử lý', '''
Kiến trúc gồm S0 là nguồn danh mục và nghiệp vụ ghế, S1 là chi nhánh HN, S2 là chi nhánh DN, S3 là chi nhánh HCM. S0 và S1 đều ở Hà Nội nhưng có trách nhiệm logic khác nhau. Trên bài thực hành, chúng có thể là hai instance; khi triển khai trên các máy riêng, tên máy và địa chỉ phải được ghi lại trong cấu hình thực tế.
Chi nhánh nhận danh mục vào database AirReference và lưu dữ liệu gốc của mình trong AirBranch. S0 lưu AirCore cho giao dịch chính thức và AirReporting cho các mảnh báo cáo nhận từ chi nhánh. Việc tách database nguồn và database nhận giúp tránh công bố lại bảng Subscriber thành dữ liệu nguồn, đồng thời giới hạn quyền theo vai trò.
Đường tra cứu dùng dữ liệu bản sao. Đường giữ chỗ, xác nhận và hoàn đi qua API đến AirCore. Đường replication chuyển danh mục từ S0 xuống và chuyển bảng bán hàng chi nhánh lên các schema riêng tại AirReporting. Không sử dụng replication để gửi lệnh đặt vé hoặc chờ nó quay về như một cơ chế xác nhận nghiệp vụ.
''', fig='topology.png', caption='Hình 4 Kiến trúc bốn điểm logic và ba chi nhánh. Mũi tên xanh là luồng sao chép, mũi tên tối là lời gọi nghiệp vụ.', note='AirCore là nguồn xác nhận ghế; AirReporting là nơi nhận dữ liệu để tổng hợp. Hai database có mục đích riêng.')
page('4.2 Phân mảnh ngang nguyên thủy', '''
SalesOrder được phân mảnh theo chi nhánh phát sinh. Đặt R là quan hệ toàn cục các đơn, p1 là BranchID bằng HN, p2 là BranchID bằng DN và p3 là BranchID bằng HCM. Mỗi mảnh Ri gồm các bản ghi của R thỏa pi. Bộ điều kiện này bao phủ toàn bộ miền chi nhánh được khai báo và đôi một loại trừ nhau.
CustomerProfile và Employee được chia theo BranchID với cùng tập điều kiện. Mỗi chi nhánh chỉ tạo hoặc sửa hồ sơ thuộc mình. Nếu một nhân viên chuyển nơi làm việc, việc thay đổi hồ sơ hiện hành không làm thay đổi BranchID lịch sử của các đơn đã phát sinh. Trong bản triển khai tối giản, nhóm không thực hiện di chuyển mảnh tự động.
BranchID bắt buộc có giá trị; chi nhánh mới phải được thêm vào mô hình phân mảnh trước khi tạo đơn cho nơi đó. Không cho phép giá trị OTHER hoặc NULL âm thầm rơi ngoài ba mảnh. S0 cũng có thể thực hiện bán hàng thông qua vai trò S1; không tạo một mảnh thứ tư có dữ liệu bán không được định danh.
''', fig='fragments.png', caption='Hình 5 Phân mảnh quan hệ SalesOrder theo ba giá trị BranchID.', code='''
R_HN  = SELECT * FROM SalesOrder WHERE BranchID = 'HN';
R_DN  = SELECT * FROM SalesOrder WHERE BranchID = 'DN';
R_HCM = SELECT * FROM SalesOrder WHERE BranchID = 'HCM';
-- Đây là ký pháp minh họa, không phải lệnh gán T-SQL.
''', note='Định vị: R_HN tại S1, R_DN tại S2, R_HCM tại S3. Bản nhận tại S0 phục vụ báo cáo, không trở thành chủ của mảnh.')
page('4.3 Phân mảnh ngang dẫn xuất', '''
SalesItem phụ thuộc SalesOrder qua OrderID. Nếu chi tiết được chia theo một thuộc tính độc lập như sân bay đi, một đơn có thể bị tách sang nhiều nơi và phải nối qua mạng mỗi lần hiển thị. Phân mảnh dẫn xuất đặt chi tiết cùng mảnh của đơn, giúp giao dịch tạo đơn và thêm hành khách được thực hiện cục bộ.
Với O_HN là mảnh đơn Hà Nội và I là quan hệ toàn cục SalesItem, mảnh I_HN là các dòng I có OrderID tồn tại trong O_HN. Đây là phép nửa nối theo OrderID. Tương tự cho DN và HCM. Mỗi OrderID thuộc đúng một mảnh đơn nên mỗi dòng chi tiết cũng chỉ thuộc một mảnh dẫn xuất.
Khóa ngoại cục bộ SalesItem.OrderID đến SalesOrder.OrderID bảo vệ việc không tạo chi tiết mồ côi trong mỗi chi nhánh. Ràng buộc này chỉ bảo vệ trong database sở hữu; các bản nhận báo cáo tại S0 cần kiểm tra sau khi cả đơn và chi tiết đã được chuyển. Các article liên quan nên nằm trong cùng publication để duy trì thứ tự giao dịch của một luồng nguồn.
Khi lưu hồ sơ hành khách cho đơn, hệ thống không phân mảnh theo hộ khẩu hoặc sân bay đến. Chủ sở hữu là nơi phát sinh giao dịch bán, không phải nơi hành khách sinh sống. Quy tắc này nhất quán với trách nhiệm lập hóa đơn, chăm sóc khách và giải quyết khiếu nại tại nơi bán.
Một order chuyển sang trạng thái kết thúc vẫn thuộc mảnh gốc. Lưu trữ lịch sử theo thời gian là một bước khác có thể dùng bảng lưu trữ hoặc partition nội bộ, nhưng không làm thay đổi định nghĩa mảnh ngang theo chi nhánh. Phân mảnh liên điểm và partition bên trong một database cần được trình bày như hai cơ chế khác nhau.
''', code='''
-- Cách chọn mảnh dẫn xuất trên quan hệ toàn cục minh họa
SELECT i.*
FROM SalesItem AS i
WHERE EXISTS (
    SELECT 1 FROM SalesOrder AS o
    WHERE o.OrderID = i.OrderID AND o.BranchID = 'DN'
);
''', table=[['Quan hệ chủ','Quan hệ phụ','Điều kiện dẫn xuất'],['SalesOrder_HN','SalesItem_HN','OrderID thuộc SalesOrder_HN'],['SalesOrder_DN','SalesItem_DN','OrderID thuộc SalesOrder_DN'],['SalesOrder_HCM','SalesItem_HCM','OrderID thuộc SalesOrder_HCM']], note='EXISTS biểu diễn phép nửa nối; không làm nhân số dòng khi chọn mảnh.')
page('4.4 Phân mảnh dọc và giới hạn dữ liệu cá nhân', '''
Phân mảnh dọc được đề xuất như bước mở rộng cho CustomerProfile. CustomerPublic gồm CustomerID, BranchID, FullName và BirthDate; CustomerPrivate gồm CustomerID, Phone, Email và DocumentNo. CustomerID phải xuất hiện ở cả hai mảnh để nối lại. Mỗi mảnh có PK riêng trên CustomerID và quan hệ một một được kiểm tra tại cùng chi nhánh.
Với mô hình này, báo cáo số lượng khách và đơn chỉ cần CustomerPublic hoặc một view đã loại bỏ thông tin nhạy cảm. Nhân viên được phân công chăm sóc khách mới được đọc CustomerPrivate. Không chuyển toàn bộ số giấy tờ vào AirReporting chỉ để đếm khách mua; lựa chọn thuộc tính cần công bố phải xuất phát từ mục đích báo cáo.
Tái thiết hồ sơ dùng INNER JOIN nếu cả hai mảnh luôn có một bản ghi cho mỗi CustomerID. Nếu thông tin liên hệ là tùy chọn và mảnh private không có dòng, INNER JOIN sẽ làm mất hồ sơ; lúc đó phải chọn quy tắc tạo dòng private rỗng hoặc dùng LEFT JOIN và mô tả ngữ nghĩa rõ ràng. Bài tập lý thuyết dưới đây giả định hai mảnh có cùng tập khóa.
Phân mảnh dọc không tự mã hóa dữ liệu và không tự hạn chế tài khoản quản trị. Cơ chế thực tế cần quyền trên bảng hoặc view, kiểm soát API và nhật ký đọc dữ liệu. Các ảnh trình diễn che DocumentNo và không hiển thị thông tin cá nhân thật. Nếu nhóm chưa triển khai bước mở rộng, phải giữ nó ở mục phương án, không ghi như cấu trúc đang chạy.
''', code='''
-- Quan hệ tái thiết ở mức phương án mở rộng
SELECT p.CustomerID, p.BranchID, p.FullName, p.BirthDate,
       s.Phone, s.Email, s.DocumentNo
FROM dbo.CustomerPublic AS p
JOIN dbo.CustomerPrivate AS s
  ON s.CustomerID = p.CustomerID;
''', table=[['Mảnh','Thuộc tính','Nơi định vị'],['CustomerPublic_i','Khóa, chi nhánh, họ tên, ngày sinh','Chi nhánh i'],['CustomerPrivate_i','Khóa, điện thoại, email, giấy tờ','Chi nhánh i'],['View báo cáo','Khóa hoặc số đếm tối thiểu','AirReporting S0']], note='Mã cài đặt cơ bản sử dụng CustomerProfile một bảng. Phân mảnh dọc là phương án nâng cấp có kiểm soát.')
page('4.5 Chứng minh tính đúng của phân mảnh', '''
Tính đầy đủ của SalesOrder được bảo đảm khi miền BranchID chỉ gồm HN, DN, HCM và không nhận NULL. Với mọi đơn o thuộc quan hệ toàn cục, BranchID của o phải bằng đúng một trong ba giá trị, nên o xuất hiện trong ít nhất một mảnh. Nếu mở thêm chi nhánh mà không cập nhật điều kiện, lập luận này không còn đúng; vì vậy, quản lý miền phân mảnh là một phần của cấu hình hệ thống.
Tính tách biệt xuất phát từ việc một giá trị BranchID không thể đồng thời bằng hai chuỗi khác nhau. Giao của R_HN với R_DN, R_HN với R_HCM và R_DN với R_HCM đều rỗng. Bản nhận tại AirReporting có thể chứa cùng OrderID với bản nguồn, nhưng đó là nhân bản của cùng mảnh; khi tái thiết chỉ chọn một bản cho mỗi mảnh.
Khả năng tái thiết của phân mảnh ngang được biểu diễn bằng phép hợp R_HN, R_DN và R_HCM. Trong T-SQL sử dụng UNION ALL khi dữ liệu chủ đã tách biệt và OrderID được tạo duy nhất. UNION có thể che lỗi do trùng dòng bằng cách loại bản ghi trùng, nên không dùng nó để thay thế kiểm tra tính tách biệt.
Đối với SalesItem, mọi dòng có OrderID tham chiếu một đơn tồn tại. Đơn đó thuộc đúng một mảnh chủ; vì vậy dòng chi tiết thuộc đúng một mảnh dẫn xuất. Phép hợp ba mảnh chi tiết tái thiết toàn bộ I. Nếu tồn tại dòng mồ côi trong quan hệ toàn cục, tính đầy đủ của dẫn xuất không còn bảo đảm; FK nguồn và kiểm tra nhận dữ liệu là điều kiện cần.
Đối với phân mảnh dọc, mỗi mảnh giữ CustomerID duy nhất và cùng tập khóa. Phép nối theo CustomerID không tạo tích Descartes và không làm tăng số dòng vì khóa của hai phía đều duy nhất. Kiểm tra số khóa thiếu ở từng phía phải được thực hiện trước khi khẳng định tái thiết không mất thông tin.
''', table=[['Kiểm tra','Truy vấn hoặc điều kiện'],['Bao phủ miền','BranchID IN (HN, DN, HCM), NOT NULL'],['Trùng khóa giữa mảnh','GROUP BY OrderID HAVING COUNT(*) > 1'],['Chi tiết mồ côi','LEFT JOIN đơn, lọc OrderID đơn IS NULL'],['Tái thiết ngang','COUNT nguồn = tổng COUNT ba mảnh'],['Dọc thiếu khóa','EXCEPT giữa hai tập CustomerID'],['Dọc tăng dòng','Khóa duy nhất tại cả hai mảnh']])
page('4.6 Lược đồ định vị và nguồn ghi', '''
Lược đồ định vị chỉ rõ mỗi quan hệ có bản gốc ở đâu, bản sao ở đâu và ai được cập nhật. Danh mục tồn tại tại S0 và có bản sao tại S1, S2, S3. Inventory, SeatHold, Ticket, Payment và Refund có bản nguồn tại S0. Trong mô hình cơ bản, chi nhánh tra cứu trạng thái ghế và vé qua API; có thể thêm bản sao tham khảo khi cần mở rộng đọc.
SalesOrder, SalesItem, CustomerProfile và Employee có bản nguồn theo chi nhánh. AirReporting nhận SalesOrder và SalesItem vào schema hn, dn, hcm tương ứng. Chỉ các thuộc tính cần cho báo cáo được công bố; hồ sơ giấy tờ không cần đưa vào luồng báo cáo. Một view hợp ba schema cung cấp góc nhìn toàn cục cho quản lý.
Không cập nhật trực tiếp schema hn, dn, hcm tại AirReporting. Nếu phát hiện sai đơn, thao tác sửa phải đi về chi nhánh sở hữu rồi được sao chép lại. Khi sửa ở bản nhận, giá trị có thể bị lệnh replication sau đó ghi đè và không tạo một lịch sử nguồn đúng. Tài khoản báo cáo vì vậy được cấp SELECT, không có quyền ghi vào các bảng nhận.
Nguồn danh mục và nguồn bán hàng được tách khỏi kho báo cáo để ngăn vòng lặp sao chép. Chi nhánh có thể là Subscriber của publication danh mục và đồng thời Publisher của đơn bán, nhưng các vai trò này áp dụng cho các database và bảng khác nhau. Đây không phải cấu hình mọi bảng đều nhiều nguồn ghi.
''', table=[['Quan hệ','Nguồn ghi','Bản sao hoặc nơi đọc'],['Branch Airport Route Aircraft','S0 AirCore','S1 S2 S3 AirReference'],['Flight Fare','S0 AirCore','S1 S2 S3 AirReference'],['Inventory SeatHold','S0 AirCore','Đọc qua API nguồn'],['Ticket Payment Refund','S0 AirCore','Đọc qua API và view báo cáo'],['SalesOrder SalesItem HN','S1 AirBranch','S0 AirReporting.hn'],['SalesOrder SalesItem DN','S2 AirBranch','S0 AirReporting.dn'],['SalesOrder SalesItem HCM','S3 AirBranch','S0 AirReporting.hcm'],['CustomerProfile Employee','Chi nhánh chủ quản','Không sao chép giấy tờ vào báo cáo']])
page('4.7 Ánh xạ và tái thiết quan hệ toàn cục', '''
Lược đồ ánh xạ liên kết tên quan hệ toàn cục với các mảnh vật lý. Ở AirReporting, view vSalesOrderGlobal hợp ba bảng nhận. Các cột phải có cùng thứ tự, kiểu dữ liệu và ý nghĩa. BranchID đi cùng mỗi dòng để xác định nguồn, dù bảng vật lý đã nằm trong schema tên chi nhánh.
Nhóm chọn uniqueidentifier cho OrderID để không phải cấp một dải IDENTITY chung qua mạng. Việc sinh ID duy nhất cần thực hiện trước khi lưu đơn và giữ nguyên khi gửi trung tâm. Với mã nhân viên, tiền tố chi nhánh cũng giúp đọc dữ liệu thử. Không dùng số tự tăng giống nhau ở ba điểm rồi coi số đó là khóa toàn cục.
View tái thiết từ bản nhận có độ trễ của replication. Nếu cần kiểm tra dữ liệu mới nhất tại các nguồn, nhóm dùng Linked Server để đọc trực tiếp ba mảnh và so sánh với AirReporting. Khi một điểm không truy cập được, truy vấn nguồn trực tiếp có thể thất bại; báo cáo từ bản nhận có thể tiếp tục nhưng phải hiện mốc đồng bộ của từng luồng.
UNION ALL là phép hợp trong ánh xạ; không nối ba bảng theo OrderID vì các mảnh ngang chứa các tập đơn khác nhau. Khi nối đơn toàn cục với chi tiết toàn cục, dùng OrderID duy nhất và kiểm tra BranchID nhất quán để phát hiện dữ liệu sai nguồn. Không tổng hợp cả bản nguồn qua Linked Server và bản sao trong AirReporting vào cùng một view doanh thu.
''', code='''
CREATE VIEW dbo.vSalesOrderGlobal AS
SELECT OrderID, BranchID, HoldID, Status, CreatedAt
FROM hn.SalesOrder
UNION ALL
SELECT OrderID, BranchID, HoldID, Status, CreatedAt
FROM dn.SalesOrder
UNION ALL
SELECT OrderID, BranchID, HoldID, Status, CreatedAt
FROM hcm.SalesOrder;
GO

SELECT BranchID, COUNT_BIG(*) AS OrderCount
FROM dbo.vSalesOrderGlobal
WHERE CreatedAt >= @FromUtc AND CreatedAt < @ToUtc
GROUP BY BranchID;
''', note='Chỉ tạo view sau khi ba bảng nhận đã được tạo với cấu trúc tương thích. Biến thời gian phải được khai báo hoặc truyền qua procedure.')
page('4.8 Đồng bộ và xử lý xung đột', '''
Publication P_REFERENCE chuyển danh mục từ AirCore sang AirReference tại từng chi nhánh. Các publication P_SALES_HN, P_SALES_DN, P_SALES_HCM chuyển đơn và chi tiết từ chi nhánh về schema tương ứng ở AirReporting. Dữ liệu được công bố một chiều theo chủ sở hữu; bản nhận chỉ phục vụ đọc. Vì không cho nhiều điểm ghi cùng một bản ghi nguồn, mô hình giảm được xung đột hợp nhất.
Transactional replication không phải cơ chế ngăn bán trùng ghế giữa nhiều nguồn ghi. Tài liệu về peer-to-peer của Microsoft nêu các xung đột có thể phát sinh khi nhiều nơi sửa cùng dòng [12]. Do đó, báo cáo không chọn last write wins cho Inventory: việc giữ lại giá trị ghi sau không khôi phục được cam kết bán đã gửi cho khách hàng trước đó.
Các luồng replication có thể đạt đến trạng thái mới nhất ở những thời điểm khác nhau. Báo cáo liên chi nhánh cần ghi nhận watermark của từng luồng, ví dụ thời gian xử lý gần nhất và độ trễ tracer token. Khi một chi nhánh chậm, quản lý phải biết tổng hợp đang dùng dữ liệu cũ của nơi đó. Ngưỡng cảnh báo 30 giây chỉ là mục tiêu bài thực hành và được đo lại khi chạy [13].
Nếu publication hoặc subscription lỗi, nhóm kiểm tra agent, quyền thư mục snapshot, tên instance, kết nối mạng và lịch sử job. Không sửa các bảng nhận bằng tay để bỏ qua lỗi cấu trúc; khôi phục đồng bộ theo nguyên nhân và kiểm tra lại số dòng, tập khóa, tổng tiền. Tái khởi tạo subscription cần xem xét khả năng ghi đè dữ liệu nhận và thực hiện trên các bảng báo cáo đã tách riêng.
Đối với lỗi trạng thái đơn và kết quả S0, tác vụ đối soát nghiệp vụ độc lập với replication. Cùng RequestID luôn tra được HoldID và kết quả đã phát hành tại nguồn. Chi nhánh áp dụng kết quả này để sửa trạng thái cục bộ. Đồng bộ dữ liệu báo cáo và đối soát giao dịch là hai trách nhiệm bổ sung cho nhau.
''', table=[['Luồng','Nguồn','Đích','Cách xử lý lỗi'],['Danh mục','S0','S1 S2 S3','Dừng nhận, hiển thị dữ liệu cũ'],['Đơn HN','S1','S0 schema hn','Giám sát agent và đối soát'],['Đơn DN','S2','S0 schema dn','Giám sát agent và đối soát'],['Đơn HCM','S3','S0 schema hcm','Giám sát agent và đối soát'],['Kết quả giữ và vé','S0 API','Chi nhánh','Tra cứu lại bằng mã yêu cầu']])
page('CHƯƠNG 5 PHƯƠNG ÁN CÀI ĐẶT\n5.1 Chuẩn bị môi trường thực hành', '''
Nhóm chuẩn bị bốn điểm logic S0 đến S3 với SQL Server 2022 Developer và các thành phần Database Engine, Replication, SQL Server Agent. Có thể dùng bốn máy ảo hoặc các instance tách biệt trên một máy đủ tài nguyên. Bốn instance trên cùng máy phù hợp để học cấu hình, nhưng không tạo ra bằng chứng về khả năng chịu sự cố của bốn máy vật lý độc lập.
Tên đề xuất là AIR_S0, AIR_HN, AIR_DN và AIR_HCM. Khi cài đặt thật, nhóm ghi tên instance, địa chỉ, cổng TCP, tài khoản dịch vụ và phiên bản bản vá vào bảng môi trường. Không đưa mật khẩu vào báo cáo. Dùng tài khoản riêng cho ứng dụng và replication; ưu tiên xác thực Windows khi môi trường cho phép.
Chỉ mở cổng SQL và đường kết nối cần thiết giữa các máy được phép. Không tắt toàn bộ tường lửa như một bước cấu hình chuẩn. Nếu dùng named instance, có thể đặt cổng tĩnh để dễ kiểm tra; SQL Browser và UDP 1434 chỉ cần khi cơ chế phân giải tên instance thực tế yêu cầu. Trên mạng không tin cậy, sử dụng đường kết nối được bảo vệ và chứng chỉ phù hợp.
Tạo thư mục snapshot riêng, ví dụ D:\\AirLab\\ReplSnapshot, rồi cấp quyền tối thiểu cho tài khoản agent cần ghi hoặc đọc. Khi nhiều máy nhận snapshot qua chia sẻ mạng, đường dẫn UNC và quyền share cùng quyền NTFS phải tương thích. Kiểm tra quyền bằng chính tài khoản dịch vụ, không chỉ bằng tài khoản quản trị đang đăng nhập.
Trước khi tạo publication, nhóm chạy thử kết nối đến từng điểm và một truy vấn SELECT đơn giản. Tiếp theo kiểm tra SQL Server Agent hoạt động, dung lượng đĩa và quyền thư mục snapshot. Trình tự này tách lỗi hạ tầng khỏi lỗi cấu hình replication; nếu dữ liệu chưa đến Subscriber, nhóm có thể xác định bước nào chưa thỏa điều kiện.
''', table=[['Điểm','Database đề xuất','Trách nhiệm'],['AIR_S0','AirCore, AirReporting, distribution','Danh mục, ghế, nghiệp vụ và báo cáo'],['AIR_HN','AirBranch, AirReference','Mảnh HN và bản sao danh mục'],['AIR_DN','AirBranch, AirReference','Mảnh DN và bản sao danh mục'],['AIR_HCM','AirBranch, AirReference','Mảnh HCM và bản sao danh mục']], note='Tên máy, cổng và thư mục là cấu hình minh họa; thay bằng giá trị thực tế khi nhóm triển khai.')
page('5.2 Tạo database và bảng nguồn ghế', '''
Tạo AirCore tại S0 và các bảng danh mục trước, sau đó tạo Inventory. Cấu trúc Inventory dưới đây thể hiện khóa kho ghế, các bộ đếm và ràng buộc quan trọng. Flight phải tồn tại trước khi tạo FK. FareClass được kiểm tra theo miền ECO, BUS; Branch được tạo riêng với HN, DN, HCM.
Lựa chọn collation nhất quán trên các điểm giúp tránh lỗi so sánh chuỗi khi hợp dữ liệu và thực hiện truy vấn Linked Server. Dữ liệu tiếng Việt dùng nvarchar; mã kỹ thuật như BranchID hoặc FlightID dùng varchar với độ dài thống nhất. Ngày giờ có hậu tố Utc hoặc quy ước UTC để người đọc không nhầm với giờ trên máy trạm.
CHECK bảo vệ giá trị của một dòng Inventory, nhưng không tự kiểm chứng tổng số ghế khai thác của các hạng so với Aircraft. Trước khi mở bán, procedure cấu hình hoặc truy vấn kiểm tra phải đối chiếu tổng Capacity theo FlightID với sức chứa máy bay. Tài khoản bán vé không có quyền thay đổi Capacity.
''', code='''
CREATE DATABASE AirCore;
GO
USE AirCore;
GO
-- Tạo Branch, Airport, Route, Aircraft, Flight, Fare trước.
CREATE TABLE dbo.Inventory (
  FlightID varchar(20) NOT NULL,
  FareClass varchar(3) NOT NULL,
  Capacity int NOT NULL,
  Held int NOT NULL CONSTRAINT DF_Inv_Held DEFAULT 0,
  Sold int NOT NULL CONSTRAINT DF_Inv_Sold DEFAULT 0,
  UpdatedAt datetime2(3) NOT NULL
    CONSTRAINT DF_Inv_Time DEFAULT SYSUTCDATETIME(),
  Version rowversion,
  CONSTRAINT PK_Inventory PRIMARY KEY(FlightID, FareClass),
  CONSTRAINT FK_Inventory_Flight FOREIGN KEY(FlightID)
    REFERENCES dbo.Flight(FlightID),
  CONSTRAINT CK_Inventory_Class CHECK(FareClass IN ('ECO','BUS')),
  CONSTRAINT CK_Inventory_Count CHECK(
    Capacity > 0 AND Held >= 0 AND Sold >= 0
    AND Held + Sold <= Capacity)
);
''', note='Đoạn mã trình bày bảng nguồn ghế; không phải script dựng toàn bộ danh mục. Từ điển dữ liệu chương 3 quy định các bảng cần tạo trước.')
page('5.3 Tạo mảnh đơn bán tại chi nhánh', '''
Mỗi điểm tạo AirBranch với cùng cấu trúc bảng nhưng ràng buộc BranchID riêng. Ví dụ dưới dùng DN; khi triển khai HN và HCM phải thay giá trị CHECK tương ứng. Không dùng cùng script có CHECK DN cho cả ba điểm. CustomerProfile và Employee của chi nhánh cần tồn tại trước khi bổ sung FK của SalesOrder.
OrderID và RequestID được sinh trước khi lưu đơn. RequestID có UNIQUE; HoldID còn rỗng khi đơn nháp và được cập nhật khi S0 đã trả giữ chỗ. SalesItem dùng khóa ghép để số thứ tự hành khách duy nhất trong một đơn. Quantity được đối chiếu với số dòng trước khi gửi yêu cầu đến trung tâm.
Các cột CustomerID, EmployeeID và CreatedAt được giữ trong cấu trúc đầy đủ; ví dụ tập trung vào các trường liên quan đến phân mảnh và trạng thái. Bản nhận ở AirReporting phải có các cột công bố với cùng kiểu. CHECK chi nhánh tại nguồn giúp phát hiện dữ liệu đi nhầm nơi ngay khi ghi.
''', code='''
CREATE TABLE dbo.SalesOrder (
  OrderID uniqueidentifier NOT NULL PRIMARY KEY,
  BranchID varchar(3) NOT NULL CHECK (BranchID='DN'),
  CustomerID uniqueidentifier NOT NULL,
  EmployeeID varchar(20) NOT NULL,
  FlightID varchar(20) NOT NULL,
  FareClass varchar(3) NOT NULL,
  Quantity int NOT NULL CHECK (Quantity > 0),
  RequestID uniqueidentifier NOT NULL UNIQUE,
  HoldID uniqueidentifier NULL,
  Status varchar(20) NOT NULL CHECK (Status IN
    ('DRAFT','HELD','ISSUED','CANCELLED','PENDING_RECONCILE')),
  CreatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
  FOREIGN KEY(CustomerID) REFERENCES dbo.CustomerProfile(CustomerID),
  FOREIGN KEY(EmployeeID) REFERENCES dbo.Employee(EmployeeID)
);
CREATE TABLE dbo.SalesItem (
  OrderID uniqueidentifier NOT NULL,
  ItemNo int NOT NULL CHECK(ItemNo > 0),
  PassengerName nvarchar(100) NOT NULL,
  PassengerDocument nvarchar(30) NULL,
  UnitPrice decimal(18,2) NULL,
  TicketID uniqueidentifier NULL,
  PRIMARY KEY(OrderID, ItemNo),
  FOREIGN KEY(OrderID) REFERENCES dbo.SalesOrder(OrderID)
);
''')
page('5.4 Giao dịch giữ chỗ tại trung tâm', '''
Procedure giữ chỗ chạy tại S0, không chạy trên Subscriber. Trước khi tăng Held, hệ thống kiểm tra Quantity dương, mã chi nhánh hợp lệ, chuyến đang mở và giá hạng còn hiệu lực. Khóa ứng dụng theo RequestID được lấy trong transaction; nếu cùng yêu cầu đã tồn tại, procedure đối chiếu tham số và trả lại kết quả cũ.
Điểm quyết định chống bán vượt sức chứa là UPDATE có điều kiện trên Inventory. SQL Server thực hiện kiểm tra và tăng Held tại dòng nguồn trong giao dịch; @@ROWCOUNT bằng 0 nghĩa là không thể cấp ghế. Việc thêm SeatHold phải nằm trong cùng transaction để không xuất hiện bộ đếm tăng nhưng thiếu bản ghi giữ chỗ.
Đoạn mã dưới là phần xử lý sau kiểm tra idempotency và danh mục. Phụ lục A trình bày hợp đồng procedure và cách thử lại. Phạm vi minh họa giữ 10 phút; thời hạn thực tế phải theo chính sách hãng. Câu trả kết quả được đọc theo HoldID mới hoặc RequestID để caller nhận cùng một kết quả khi phản hồi lần đầu bị mất.
''', code='''
SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;
  -- Kiểm tra RequestID và khóa ứng dụng trước đoạn này.
  UPDATE dbo.Inventory
  SET Held = Held + @Quantity, UpdatedAt=SYSUTCDATETIME()
  WHERE FlightID=@FlightID AND FareClass=@FareClass
    AND Capacity - Held - Sold >= @Quantity;
  IF @@ROWCOUNT <> 1
    THROW 51001, N'Khong du ghe de giu cho', 1;

  DECLARE @Now datetime2(3)=SYSUTCDATETIME();
  INSERT dbo.SeatHold
    (HoldID,RequestID,OrderID,BranchID,FlightID,FareClass,
     Quantity,UnitPrice,Status,CreatedAt,ExpiresAt)
  VALUES
    (@HoldID,@RequestID,@OrderID,@BranchID,@FlightID,@FareClass,
     @Quantity,@UnitPrice,'ACTIVE',@Now,DATEADD(minute,10,@Now));
  COMMIT;
END TRY
BEGIN CATCH
  IF XACT_STATE() <> 0 ROLLBACK;
  THROW;
END CATCH;
''', note='Không gọi cổng thanh toán bên ngoài trong transaction này. Các biến là tham số hoặc biến đã khai báo của procedure đầy đủ.')
page('5.5 Xác nhận hết hạn và hoàn vé', '''
Xác nhận thanh toán, hủy và hết hạn là các phép chuyển trạng thái loại trừ nhau. Procedure xác nhận khóa SeatHold, kiểm tra ACTIVE và ExpiresAt lớn hơn thời gian S0 hiện tại. Sau đó giảm Held, tăng Sold, tạo Payment và Quantity vé trong một transaction. Callback cùng ExternalRef phải trả kết quả cũ nếu HoldID và Amount khớp; khác nội dung thì bị từ chối.
Tác vụ hết hạn chọn bản giữ ACTIVE có ExpiresAt nhỏ hơn hoặc bằng thời điểm UTC. Trong mỗi giao dịch ngắn, tác vụ khóa bản giữ, kiểm tra lại trạng thái rồi giảm Held đúng Quantity và chuyển thành EXPIRED. Job không được giảm ghế dựa trên danh sách đã đọc từ lâu vì một bản giữ có thể đã được xác nhận trong lúc chờ.
Hoàn vé mô phỏng khóa Ticket, kiểm tra ISSUED và chính sách, tạo Refund rồi giảm Sold một ghế. ExternalRef của hoàn và TicketID đều duy nhất. Chỉ hoàn tất khi hệ thống xác minh hoàn tiền thành công; nếu tích hợp cổng thực, trạng thái PENDING và cơ chế đối soát cần được bổ sung. Trong mô phỏng, quy tắc hoàn toàn bộ giá vé giúp tập trung vào kiểm soát đồng thời.
''', fig='states.png', caption='Hình 6 Máy trạng thái SeatHold và tác động lên bộ đếm ghế.', table=[['Chuyển trạng thái','Điều kiện','Held','Sold'],['Tạo ACTIVE','Đủ ghế, chuyến mở','+q','0'],['ACTIVE → CONFIRMED','Thanh toán hợp lệ, chưa hết hạn','−q','+q'],['ACTIVE → EXPIRED','Đã đến hạn','−q','0'],['ACTIVE → CANCELLED','Khách hủy trước xác nhận','−q','0'],['Hoàn Ticket ISSUED','Chính sách cho phép','0','−1']], note='Mọi phép chuyển trên đều chạy tại S0. Khi xác nhận và hết hạn đồng thời, chỉ một transaction được chuyển trạng thái thành công.')
page('5.6 Cấu hình publication danh mục', '''
Tại S0, mở Replication trong SSMS và cấu hình Distributor sau khi kiểm tra SQL Server Agent. Bài thực hành có thể dùng local Distributor; hệ thống quy mô lớn cần đánh giá tách riêng tài nguyên. Khai báo thư mục snapshot đã được cấp quyền cho agent, không dùng thư mục có dữ liệu cá nhân hoặc tài liệu của người dùng.
Tạo New Publication cho AirCore và chọn Transactional publication. Chọn các article danh mục Branch, Airport, Route, Aircraft, Flight và Fare. Mỗi bảng công bố cần khóa phù hợp; đối chiếu PK và các phụ thuộc trước khi tạo snapshot. Không chọn Inventory chỉ để cho phép chi nhánh cập nhật kho ghế qua bản sao.
Đặt publication name P_REFERENCE và cấu hình tài khoản Snapshot Agent, Log Reader Agent theo quyền cần thiết. Chạy Snapshot Agent để tạo bộ dữ liệu ban đầu; kiểm tra trạng thái và lỗi trong lịch sử agent. Các bước và thành phần kỹ thuật có thể đối chiếu với hướng dẫn chính thức [14]. Bảng dưới là danh sách cấu hình cần nghiệm thu khi nhóm thao tác.
Tại chi nhánh, tạo AirReference và subscription nhận P_REFERENCE. Tài khoản ứng dụng chỉ có SELECT trên bản sao danh mục; cập nhật vẫn đi qua vai trò quản lý ở S0. Thay đổi tên sân bay giả lập tại S0, chờ agent chuyển đến các chi nhánh rồi ghi thời gian quan sát. Không dùng kết quả của một lần cập nhật nhỏ để kết luận mọi tải đều đạt ngưỡng.
Replication không tự tạo một giao diện thống nhất cho các chức năng bán hàng. Sau khi danh mục nhận được, nhóm vẫn phải kiểm tra API đến S0, procedure giữ chỗ và quyền ứng dụng. Thành công của Snapshot Agent chỉ chứng minh bước tạo snapshot, không chứng minh toàn bộ luồng phát hành vé.
''', table=[['Hạng mục','Giá trị hoặc kiểm tra'],['Publisher','S0 AirCore'],['Publication','P_REFERENCE, transactional'],['Articles','Branch Airport Route Aircraft Flight Fare'],['Subscriber','S1 S2 S3 AirReference'],['Snapshot folder','Đường dẫn cấu hình có quyền agent'],['Quyền ứng dụng chi nhánh','Chỉ đọc bản sao'],['Minh chứng cần lưu','Agent thành công và thay đổi đến ba nơi']])
page('5.7 Đồng bộ đơn từ chi nhánh lên báo cáo', '''
Tại mỗi chi nhánh, cấu hình publication riêng từ AirBranch, gồm SalesOrder và SalesItem. P_SALES_HN xuất dữ liệu S1, P_SALES_DN xuất dữ liệu S2 và P_SALES_HCM xuất dữ liệu S3. Chọn một Distributor phù hợp cho từng Publisher; trong bài thực hành có thể dùng local Distributor tại chi nhánh để minh họa rõ nơi phát sinh.
Tại S0, tạo AirReporting với các schema hn, dn, hcm. Khi cấu hình article, đặt destination_owner và destination_table đúng schema đích. Cùng tên SalesOrder từ ba nguồn không được nhận vào một dbo.SalesOrder chung bằng cấu hình mặc định. Nếu nhận chung mà không có cơ chế hợp nhất rõ ràng, snapshot của một nguồn có thể ghi đè hoặc tạo xung đột với nguồn khác.
Đơn và chi tiết cùng nguồn được công bố trong cùng publication. Kiểm tra thuộc tính sao chép schema, thứ tự tạo bảng và khóa ngoại của bản nhận để tránh snapshot thất bại. CustomerProfile và Employee không bắt buộc nhận vào báo cáo; nếu FK được sao chép sang đích nhưng bảng tham chiếu không có, nhóm cần thiết kế lại schema options của article hoặc bảng nhận.
Chỉ dùng các bảng nhận cho báo cáo và vSalesOrderGlobal. Khi nhóm cần sửa đơn, quay lại AirBranch nguồn. Với một đơn ở trạng thái PENDING_RECONCILE, việc replica đã chuyển đơn lên S0 không có nghĩa S0 đã giữ hoặc bán ghế; phải đọc SeatHold và Payment trong AirCore bằng mã yêu cầu.
Sau khi snapshot hoàn tất, chạy một giao dịch tạo đơn với hai chi tiết tại từng chi nhánh. S0 phải nhận đúng số dòng vào đúng schema. Kiểm tra BranchID của từng bảng nhận và truy vấn tìm OrderID trùng giữa ba schema. Thử dừng Distribution Agent của một chi nhánh để quan sát dữ liệu cũ và cơ chế cảnh báo.
''', table=[['Publication','Nguồn','Bảng đích đơn','Bảng đích chi tiết'],['P_SALES_HN','S1 AirBranch','hn.SalesOrder','hn.SalesItem'],['P_SALES_DN','S2 AirBranch','dn.SalesOrder','dn.SalesItem'],['P_SALES_HCM','S3 AirBranch','hcm.SalesOrder','hcm.SalesItem']], note='Tên schema đích là một phần bắt buộc của cấu hình article. Không mặc định cả ba luồng đều nhận vào schema dbo.')
page('5.8 Linked Server và truy vấn liên điểm', '''
Linked Server phục vụ truy vấn dữ liệu nguồn tại các điểm khác hoặc đối chiếu với bản nhận. Trên S0 tạo LS_HN, LS_DN, LS_HCM với Microsoft OLE DB Driver for SQL Server phù hợp môi trường. Cấu hình tài khoản chỉ đọc được ánh xạ tới mỗi nguồn; không bật quyền ghi cho tài khoản báo cáo chỉ để làm truy vấn thử.
Câu lệnh dưới đọc đơn DN bằng tên bốn thành phần và lọc thời gian. Với dữ liệu lớn, kiểm tra execution plan để biết điều kiện lọc có được thực hiện gần nguồn hay không. Có thể sử dụng OPENQUERY cho truy vấn tĩnh tại nguồn, nhưng tham số hóa cần xử lý cẩn thận; không ghép trực tiếp giá trị người dùng vào chuỗi SQL.
Giao dịch ghi liên máy chủ có thể cần MS DTC và các thiết lập mạng riêng [7]. Việc tắt transaction promotion để làm hết lỗi kết nối không tạo ra tính nguyên tử thay thế. Nếu bài thực hành mở rộng sang BEGIN DISTRIBUTED TRANSACTION, nhóm phải thử rollback tại các điểm và ghi lại môi trường hỗ trợ.
Phương án cơ bản giữ transaction ghế tại S0 và dùng idempotency giữa các bước ứng dụng. Linked Server chỉ đọc; báo cáo không khẳng định các cập nhật ở AirBranch và AirCore cùng commit bằng một transaction SQL. Sự khác biệt này cần được giải thích khi trình bày thiết kế, vì nhiều máy chủ có kết nối không đồng nghĩa với mọi nghiệp vụ có giao dịch phân tán nguyên tử.
''', code='''
-- Chạy tại S0 sau khi DBA tạo và ánh xạ LS_DN.
SELECT OrderID, BranchID, HoldID, Status, CreatedAt
FROM [LS_DN].[AirBranch].[dbo].[SalesOrder]
WHERE CreatedAt >= '2026-10-01T00:00:00'
  AND CreatedAt <  '2026-11-01T00:00:00';

-- Đối chiếu khóa bản nhận với nguồn khi kết nối hoạt động.
SELECT OrderID FROM AirReporting.dn.SalesOrder
EXCEPT
SELECT OrderID FROM [LS_DN].[AirBranch].[dbo].[SalesOrder];
''', note='EXCEPT chỉ tìm khóa có ở bản nhận nhưng không ở nguồn. Cần chạy thêm chiều ngược lại và so sánh thuộc tính, sau khi đồng bộ đã theo kịp.')
page('5.9 Bảo mật sao lưu và vận hành', '''
Tài khoản bán vé tại trung tâm được cấp EXECUTE trên procedure nghiệp vụ và quyền đọc kết quả cần thiết, không được cấp UPDATE Inventory trực tiếp. Tài khoản chi nhánh được giới hạn database chủ quản. Các login dành cho agent được tách khỏi login ứng dụng; mật khẩu do người quản trị đặt trong môi trường, không chèn vào script hoặc báo cáo.
Đường kết nối cần mã hóa và xác thực máy chủ bằng chứng chỉ phù hợp. Dữ liệu kiểm thử sử dụng tên hành khách và mã giấy tờ giả lập; ảnh màn hình che thông tin nhạy cảm. Khi lưu nhật ký, ghi RequestID và trạng thái để đối soát mà không cần ghi đầy đủ giấy tờ hay bí mật thanh toán.
Lịch sao lưu minh họa gồm full mỗi ngày, differential theo khoảng phù hợp và transaction log mỗi 15 phút cho database dùng FULL. Cần có full backup khởi đầu và chuỗi log liên tục theo cấu hình [9], [10]. Tệp được lưu ngoài vị trí dữ liệu chính và kiểm tra phục hồi trên database khác để đánh giá khả năng sử dụng thực tế.
Sau khi phục hồi AirCore, nhóm đối soát Inventory với SeatHold và Ticket, kiểm tra yêu cầu chưa rõ kết quả rồi mới cho bán lại. Phục hồi dữ liệu nguồn không tự phục hồi cấu hình replication; publication, subscription, agent và quyền cần được kiểm tra theo hướng dẫn môi trường. DBCC CHECKDB và thử phục hồi là hai bước khác nhau, không thay thế cho nhau.
''', code='''
-- Tài khoản thực tế được DBA tạo riêng.
CREATE ROLE booking_executor;
GRANT EXECUTE ON dbo.usp_CreateHold TO booking_executor;
DENY UPDATE ON dbo.Inventory TO booking_executor;

-- Ví dụ sao lưu: thư mục đã tồn tại và SQL service có quyền.
BACKUP DATABASE AirCore
TO DISK=N'D:\\AirLab\\Backup\\AirCore_full.bak'
WITH CHECKSUM;

-- Sau khi bật FULL và có full backup khởi đầu:
BACKUP LOG AirCore
TO DISK=N'D:\\AirLab\\Backup\\AirCore_log.trn'
WITH CHECKSUM;
''', note='Tên tệp sao lưu phải có thời gian hoặc quy tắc lưu giữ khi vận hành. Không ghi đè bản sao duy nhất trước khi xác minh bản mới.')
page('CHƯƠNG 6 KIỂM THỬ VÀ ĐÁNH GIÁ\n6.1 Bộ dữ liệu và phương pháp', '''
Bộ dữ liệu thử được tổ chức theo hai mức. Mức nhỏ giúp kiểm tra đúng từng quy tắc bằng vài chuyến bay và số ghế dễ tính. Mức tải giúp đo thời gian phản hồi khi dữ liệu tăng. Không dùng một bộ dữ liệu rất lớn ngay từ đầu vì sẽ khó xác định lỗi thiết kế cơ bản và khó đối chiếu bằng tay.
Mức nhỏ gồm ba chi nhánh, ba sân bay giả lập theo mã HAN, DAD, SGN, ba đường bay và ba chuyến trong tương lai của kịch bản. Chuyến TEST01 có Capacity ECO bằng 10 và BUS bằng 2; TEST02 có ECO bằng 1 để thử ghế cuối; TEST03 đóng bán để thử từ chối. Các thời điểm chạy phải được điều chỉnh so với ngày thực nghiệm, không mặc định lịch bay còn mở.
Mỗi chi nhánh có hai nhân viên, ba khách giả lập và các đơn với OrderID, RequestID riêng. Dùng tên Khách thử HN 01 hoặc tương tự để nhận biết nguồn. Không đưa mã giấy tờ thật vào dữ liệu mẫu. Với kiểm thử ghế cuối, hai session mở từ hai chi nhánh nhưng đều gọi procedure nguồn trên S0.
Trước mỗi ca, nhóm ghi trạng thái ban đầu; sau mỗi ca, ghi kết quả gọi, trạng thái nguồn và bộ đếm. Với lỗi mạng, cần ghi điểm gây lỗi trước hay sau commit. Các bảng của chương này là kế hoạch nghiệm thu và kết quả kỳ vọng, chưa phải nhật ký thực nghiệm đã chạy trên SQL Server.
Sau mỗi nhóm ca, chạy truy vấn bất biến: kho ghế không âm và không vượt sức chứa, RequestID không trùng, ExternalRef không trùng, tổng Held bằng các giữ ACTIVE và số vé khớp Quantity của giữ đã xác nhận. Mọi sai lệch phải được giữ lại dữ liệu và truy vết trước khi đặt lại môi trường.
''', table=[['Tập','Quy mô đề xuất','Mục đích'],['Nhỏ','3 chi nhánh, 3 chuyến, 9 khách','Kiểm tra quy tắc và tính toán bằng tay'],['Ghế cuối','TEST02 ECO Capacity 1','Hai session tranh chấp cùng kho'],['Lặp yêu cầu','Một RequestID, gọi nhiều lần','Không tăng Held thêm'],['Đồng bộ','Một đơn 2 hành khách mỗi chi nhánh','Đúng schema, không mất chi tiết'],['Tải','10.000 rồi 100.000 đơn giả lập','So sánh truy vấn và chỉ mục']])
page('6.2 Kiểm thử chức năng và ràng buộc', '''
Kiểm thử chức năng dùng cả tình huống hợp lệ và tình huống bị từ chối. Khi tạo một đơn hợp lệ, SalesOrder và các SalesItem phải cùng xuất hiện sau commit. Khi dữ liệu chi nhánh sai hoặc hành khách thiếu, hệ thống phải từ chối trước khi gửi giữ chỗ. Mỗi ca cần xác minh cơ sở dữ liệu, không chỉ nhìn thông báo trên màn hình.
Đối với giữ chỗ, Quantity bằng 0 hoặc âm phải bị từ chối. Yêu cầu giữ vượt số ghế còn lại phải không làm thay đổi Inventory và không tạo SeatHold. Yêu cầu cho chuyến CLOSED bị từ chối. Khi giữ hợp lệ, Held tăng đúng số lượng và ExpiresAt được tính theo thời gian S0.
Đối với phát hành, số Ticket bằng Quantity của giữ chỗ và mỗi ItemNo chỉ có một Ticket. Payment.Amount bằng Quantity nhân UnitPrice đã chốt. Nếu giá Fare thay đổi sau khi giữ, số tiền xác nhận vẫn dùng giá đã chốt. Các ca hủy và hoàn cần kiểm tra bộ đếm tương ứng để phát hiện nhầm lẫn giữa Held và Sold.
Các trường hợp mất phản hồi không được xếp chung với yêu cầu thất bại. Caller cần đọc lại bằng RequestID; chỉ khi nguồn xác định không có kết quả mới quyết định gửi yêu cầu theo chính sách. Ca kiểm thử này liên kết trực tiếp với khả năng không tạo tác dụng lặp.
''', table=[['Mã ca','Đầu vào','Kết quả kỳ vọng'],['TC01','Đơn DN, 2 hành khách','Một đơn và 2 chi tiết tại DN'],['TC02','Ghi BranchID HN vào mảnh DN','CHECK hoặc API từ chối'],['TC03','Giữ 2 ghế khi còn 10','Held +2; một giữ ACTIVE'],['TC04','Quantity 0 hoặc âm','Từ chối, bộ đếm giữ nguyên'],['TC05','Giữ 11 ghế khi còn 10','Rollback, không thêm giữ'],['TC06','Giữ trên chuyến CLOSED','Từ chối trước cập nhật ghế'],['TC07','Xác nhận giữ 2 ghế','Held −2, Sold +2, có 2 vé'],['TC08','Giá danh mục đổi sau giữ','Payment dùng giá chốt'],['TC09','Hủy giữ ACTIVE','Held giảm, trạng thái CANCELLED'],['TC10','Hoàn một vé hợp lệ','Sold −1; một Refund']])
page('6.3 Kiểm thử đồng thời và tính lặp an toàn', '''
Ca ghế cuối sử dụng TEST02 ECO với Capacity bằng 1, Held bằng 0 và Sold bằng 0. Hai session gửi yêu cầu Quantity bằng 1 cùng lúc nhưng khác RequestID. Kết quả hợp lệ là đúng một giữ thành công và một yêu cầu bị từ chối; sau ca Held bằng 1, Sold bằng 0. Không chấp nhận cả hai thành công rồi giải quyết xung đột bằng replication.
Ca lặp yêu cầu gửi cùng RequestID hai lần, trước tiên tuần tự rồi đồng thời. Kết quả phải là cùng HoldID, cùng thời hạn gốc và Held tăng một lần. Lần gọi lại không gia hạn giữ chỗ tự động. Nếu cùng RequestID nhưng Quantity khác, hệ thống phải từ chối, không trả dữ liệu cũ như thể yêu cầu mới đã được xử lý.
Ca xác nhận và hết hạn cần điều khiển thời điểm của giữ chỗ. Một session gọi xác nhận, session còn lại chạy giải phóng hết hạn khi đến ranh giới. Kết quả cuối chỉ có CONFIRMED hoặc EXPIRED; không vừa phát hành vé vừa giảm Held hai lần. CHECK ngăn bộ đếm âm là lớp cuối, còn thứ tự khóa và kiểm tra trạng thái là cơ chế chính.
Ca callback trùng dùng cùng ExternalRef của thanh toán thành công. Cùng nội dung phải trả lại kết quả đã xử lý; khác HoldID hoặc Amount phải bị từ chối. Hai mã thanh toán khác nhau cho cùng HoldID cũng không tạo hai Payment thành công trong mô hình một lần thanh toán. UNIQUE HoldID và transaction xác nhận phải cùng bảo vệ quy tắc này.
Khi gặp deadlock hoặc timeout khóa, ghi mã lỗi và thử lại theo số lần giới hạn với cùng mã yêu cầu. Không tạo RequestID mới khi retry. Chỉ số đánh giá quan trọng là bất biến giữ vững sau các lỗi, không phải tỷ lệ mọi lời gọi đều thành công ngay lần đầu.
''', table=[['Mã ca','Song song','Bất biến cuối'],['CC01','Hai yêu cầu tranh ghế cuối','Đúng 1 thành công'],['CC02','Hai lần cùng RequestID','Một HoldID, Held tăng một lần'],['CC03','Cùng mã, khác Quantity','Yêu cầu khác nội dung bị từ chối'],['CC04','Confirm và Expire','Một trạng thái cuối, không âm ghế'],['CC05','Hai callback cùng ExternalRef','Một Payment, một bộ vé'],['CC06','Hai hoàn cho cùng TicketID','Một Refund, Sold giảm một lần']])
page('6.4 Kiểm thử sự cố và đồng bộ', '''
Kiểm thử mạng cần xác định rõ điểm gây lỗi. Nếu mất kết nối trước khi yêu cầu được gửi, đơn vẫn là nháp và không có giữ nguồn. Nếu phản hồi bị mất sau commit, chi nhánh phải chuyển sang chờ đối soát và tra lại mã cũ. Hai trường hợp có cùng biểu hiện timeout trên giao diện nhưng dữ liệu nguồn khác nhau.
Đối với replication, dừng agent của DN, tạo một đơn tại DN rồi quan sát bản nhận AirReporting.dn. HN và HCM vẫn có thể chuyển dữ liệu theo luồng riêng; bảng DN giữ mốc cũ. Sau khi bật lại agent và chuyển hết thay đổi, số dòng cùng tập khóa phải khớp nguồn. Không ghi thủ công đơn thiếu vào bảng nhận rồi xem đó là phục hồi thành công.
Ca thiếu quyền snapshot mô phỏng bằng tài khoản thử và thư mục riêng; không thay quyền của môi trường đang sử dụng ngoài phạm vi bài thực hành. Lỗi phải được nhận diện trong lịch sử agent. Sau khi sửa quyền, chạy lại đúng bước và đối chiếu dữ liệu, không bỏ qua trạng thái agent bằng cách tắt kiểm tra.
Ca phục hồi dùng bản sao lưu và database thử riêng. Nhóm ghi thời điểm bắt đầu, điểm dữ liệu phục hồi, thời gian mở lại và các yêu cầu chưa xác định. Kiểm tra toàn vẹn kỹ thuật xong cần chạy đối soát nghiệp vụ. Chỉ khi dữ liệu ghế và giao dịch khớp mới chuyển trạng thái hệ thống trở lại cho phép bán.
''', table=[['Mã ca','Sự cố','Kết quả kỳ vọng'],['FT01','Mất mạng trước gửi','Nháp giữ nguyên, không có Hold nguồn'],['FT02','Mất phản hồi sau giữ commit','Tra cùng RequestID, không giữ lần hai'],['FT03','Mất phản hồi sau phát hành','Đọc lại Payment và Ticket nguồn'],['FT04','Dừng agent DN','Báo cáo DN cũ và có cảnh báo'],['FT05','Khởi động lại agent','Bắt kịp, số dòng và khóa khớp'],['FT06','Snapshot thiếu quyền','Lỗi rõ trong lịch sử, không nhận một phần như đủ'],['FT07','S0 ngừng hoạt động','Ngừng giữ bán hoàn; vẫn tra bản sao'],['FT08','Phục hồi từ backup','Đối soát bất biến trước mở lại']])
page('6.5 Đánh giá hiệu năng và tiêu chí nghiệm thu', '''
Hiệu năng được đánh giá theo đường truy cập: tra cứu cục bộ, giữ chỗ tại S0 và báo cáo tổng hợp. Mỗi loại có kích thước dữ liệu, số client và độ trễ mạng riêng. Nhóm cần ghi cấu hình CPU, RAM, ổ đĩa, phiên bản SQL và số điểm thật để người đọc hiểu phạm vi của kết quả.
Kịch bản đo đề xuất bắt đầu với 10 client, sau đó 50 và 100 client nếu máy thử đáp ứng. Mỗi mức chạy một khoảng ổn định, bỏ lượt làm nóng, ghi số yêu cầu thành công, lỗi nghiệp vụ do hết ghế, lỗi kỹ thuật và p50 p95. Lỗi hết ghế có thể là kết quả đúng; không cộng nó vào lỗi kỹ thuật khi đánh giá tính sẵn sàng của API.
Với truy vấn báo cáo, bật STATISTICS IO và TIME trong session kiểm thử để ghi logical reads và thời gian. So sánh trước sau chỉ mục trên cùng bộ dữ liệu, cùng tham số và điều kiện cache có kiểm soát. Không chạy DBCC DROPCLEANBUFFERS trên môi trường chung đang sử dụng chỉ để đo; nếu cần cache lạnh, thực hiện trong môi trường thử riêng.
Ngưỡng p95 tra cứu 2 giây, giữ chỗ 3 giây và độ trễ replication 30 giây là mục tiêu ban đầu. Tính đúng vẫn bắt buộc: bán vượt ghế bằng 0, giao dịch lặp không tạo thêm tác dụng và dữ liệu tái thiết không trùng khóa. Nếu mục tiêu tốc độ chưa đạt, phân tích chỗ chờ khóa, kế hoạch truy vấn và đường truyền trước khi tăng tài nguyên.
''', table=[['Chỉ số','Mục tiêu đề xuất','Bằng chứng cần ghi'],['p95 tra cứu','≤ 2 giây ở tải thử','Log thời gian và số client'],['p95 giữ chỗ','≤ 3 giây ở tải thử','Latency API và thời gian SQL'],['Độ trễ replication','≤ 30 giây bình thường','Tracer token, lịch sử agent'],['Bán vượt ghế','0 trường hợp','Truy vấn bất biến sau tải'],['Tác dụng lặp','0 bản ghi nghiệp vụ thêm','RequestID ExternalRef và số dòng'],['Tái thiết đơn','Không thiếu, không trùng','Tập khóa và tổng số dòng']], code='''
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- Chạy truy vấn báo cáo với tham số thử cố định.
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
''', note='Báo cáo chưa điền số liệu đo. Nhóm bổ sung kết quả và ảnh thực nghiệm sau khi dựng môi trường SQL Server.')
page('6.6 Chức năng quản lý thông minh', '''
Chức năng thông minh trong phạm vi đề tài dùng quy tắc xác định được để phát hiện tình huống cần chú ý. Chỉ số lấp đầy bằng Sold chia Capacity; số ghế khả dụng bằng Capacity trừ Held trừ Sold. Khi tỷ lệ bán cao, hệ thống gợi ý nhân viên xem chuyến khác cùng chặng, nhưng không tự đổi đơn hoặc hủy giữ chỗ của khách.
Ngưỡng lấp đầy 80 phần trăm là cấu hình minh họa. Một chuyến ít ghế mở bán có thể vượt ngưỡng với số vé nhỏ, nên báo cáo luôn hiển thị cả Capacity và Sold. Giá trị tại bản sao chỉ phục vụ tham khảo; nếu chuyển sang đặt chuyến thay thế, yêu cầu giữ vẫn phải được S0 xác nhận.
Chức năng đối soát tìm đơn HELD nhưng giữ nguồn đã EXPIRED, đơn ISSUED chưa có vé tương ứng hoặc đơn PENDING_RECONCILE còn quá thời gian xử lý. Những ngoại lệ này không tự chứng minh lỗi tài chính; chúng chỉ đưa vào danh sách kiểm tra. Tác vụ đọc nguồn chính thức rồi áp dụng kết quả, không suy ra bán thành công từ bản nhận đơn.
Một hướng mở rộng là dự báo nhu cầu từ lịch sử vé, ngày bay và thời điểm mua. Muốn đánh giá mô hình, cần tách dữ liệu huấn luyện và kiểm thử theo thời gian, xác định thước đo và tránh dùng dữ liệu tương lai. Báo cáo hiện tại không đưa độ chính xác dự báo hoặc hiệu quả kinh doanh khi chưa thực hiện thí nghiệm đó.
''', code='''
-- Cảnh báo tại nguồn AirCore; không tự thay đổi giao dịch.
SELECT i.FlightID, i.FareClass, i.Capacity, i.Sold,
       i.Capacity-i.Held-i.Sold AS Available,
       CAST(100.0*i.Sold/i.Capacity AS decimal(5,2)) AS SoldPct
FROM dbo.Inventory AS i
JOIN dbo.Flight AS f ON f.FlightID=i.FlightID
WHERE f.Status='OPEN' AND f.DepartureUtc>SYSUTCDATETIME()
  AND 100.0*i.Sold/i.Capacity>=80;
''', table=[['Cảnh báo','Dữ liệu cần','Cách sử dụng'],['Lấp đầy cao','Inventory và Flight nguồn','Gợi ý chuyến thay thế'],['Đồng bộ chậm','Tracer token, lịch sử job','Thông báo dữ liệu báo cáo cũ'],['Đơn lệch trạng thái','Order, Hold, Payment, Ticket','Hàng chờ đối soát nghiệp vụ']])
page('KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN', '''
Báo cáo đã xây dựng phương án cơ sở dữ liệu phân tán cho quản lý hàng không thông minh với trọng tâm bán vé tại ba chi nhánh. Thiết kế phân biệt dữ liệu mảnh, dữ liệu nhân bản và dữ liệu có một nguồn ghi. SalesOrder, SalesItem cùng hồ sơ giao dịch được lưu gần nơi phát sinh; danh mục được phân phối để tra cứu; nghiệp vụ giữ chỗ, phát hành và hoàn được quyết định tại S0.
Phân mảnh theo BranchID có tính đầy đủ và tách biệt khi miền chi nhánh được quản lý chặt chẽ. SalesItem dẫn xuất theo đơn để bảo đảm đồng vị trí. Quan hệ toàn cục được tái thiết bằng UNION ALL từ một bản của mỗi mảnh. Bản nhận báo cáo có độ trễ được theo dõi; bản sao không trở thành nguồn ghi chỉ vì nguồn chính tạm thời mất kết nối.
Tính đúng của bán vé dựa vào UPDATE kho ghế có điều kiện, transaction cục bộ, trạng thái giữ chỗ và mã yêu cầu duy nhất. Khi mất phản hồi, hệ thống tra cứu kết quả nguồn bằng mã cũ. Cách này xử lý trường hợp một bước đã commit nhưng bước cập nhật đơn ở chi nhánh chưa hoàn thành, đồng thời tránh đặt lại hoặc thanh toán lại thiếu kiểm soát.
Giới hạn của phương án là phụ thuộc S0 cho các nghiệp vụ ghế. Báo cáo chưa triển khai dự phòng tự động cho nguồn ghi, chưa tích hợp tiền thật và chưa xây dựng mô hình dự báo. Các mã minh họa, kế hoạch cài đặt và tình huống kiểm thử là cơ sở để nhóm dựng môi trường, chạy thực nghiệm và bổ sung minh chứng; kết quả kỳ vọng không thay thế kết quả đo.
Hướng phát triển tiếp theo là hoàn thiện API và giao diện, bổ sung bộ script đầy đủ cho tất cả bảng, procedure xác nhận và hoàn, cấu hình dự phòng nguồn ghi có kiểm soát, cùng kiểm thử phục hồi. Có thể bổ sung chọn ghế cụ thể, vé nhiều chặng và định danh khách hàng toàn hãng, nhưng mỗi bước cần mở rộng bất biến và đánh giá lại phân mảnh.
Về tổ chức, phân công theo chương và sản phẩm giúp bảy thành viên có trách nhiệm rõ ràng. Khi thực nghiệm hoàn thành, nhóm cập nhật bảng nghiệm thu và phần đánh giá bằng dữ liệu thực tế, sau đó rà soát lại tên bảng, số điểm, chiều đồng bộ và mục lục để giữ một bản báo cáo thống nhất.
''', table=[['Mục tiêu','Kết quả thiết kế'],['Phân tích nghiệp vụ','Vai trò, chức năng và 7 quy tắc trọng tâm'],['Thiết kế dữ liệu','Mô hình quan hệ và từ điển dữ liệu'],['Thiết kế phân tán','Mảnh, bản sao, định vị và tái thiết'],['Kiểm soát giao dịch','Một nguồn ghi, mã yêu cầu, trạng thái'],['Đánh giá','Kế hoạch chức năng, đồng thời, lỗi và tải']])
page('TÀI LIỆU THAM KHẢO\nNguồn lý thuyết và triển khai', '''
[1] Bài mẫu do nhóm cung cấp. BTL CSDL PT Báo cáo dự án Hệ thống quản lý bán vé máy bay. Bản PDF 119 trang, bìa ghi Học viện Công nghệ Bưu chính Viễn thông, năm 2023. Dùng tham khảo cấu trúc và phạm vi nghiệp vụ; mô hình và diễn giải trong báo cáo này được viết lại cho nhóm 8.
[2] Microsoft Learn. Transactional Replication. https://learn.microsoft.com/en-us/sql/relational-databases/replication/transactional/transactional-replication?view=sql-server-ver16 . Tham khảo vai trò Publisher, Distributor, Subscriber và cơ chế chuyển thay đổi. Hình 1 lấy từ ảnh trnsact.gif trong kho MicrosoftDocs/sql-docs.
[3] Microsoft Learn. Snapshot Replication. https://learn.microsoft.com/en-us/sql/relational-databases/replication/snapshot-replication?view=sql-server-ver16 . Tham khảo cách sử dụng snapshot và khởi tạo dữ liệu nhận.
[4] Microsoft Learn. Merge Replication. https://learn.microsoft.com/en-us/sql/relational-databases/replication/merge/merge-replication?view=sql-server-ver16 . Tham khảo sự khác biệt của đồng bộ có cập nhật ở nhiều điểm.
[5] Microsoft Learn. Transaction Locking and Row Versioning Guide. https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-transaction-locking-and-row-versioning-guide?view=sql-server-ver16 . Tham khảo giao dịch, khóa và cô lập.
[6] Microsoft Learn. sp_getapplock Transact-SQL. https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-getapplock-transact-sql?view=sql-server-ver16 . Tham khảo khóa ứng dụng theo tên tài nguyên.
[7] Microsoft Learn. BEGIN DISTRIBUTED TRANSACTION Transact-SQL. https://learn.microsoft.com/en-us/sql/t-sql/language-elements/begin-distributed-transaction-transact-sql?view=sql-server-ver16 . Tham khảo giao dịch nhiều điểm và MS DTC.
''', note='Các tài liệu web được đối chiếu ngày 12 tháng 10 năm 2026. Lựa chọn SQL Server 2022 là lựa chọn tương thích bài mẫu, không phải tuyên bố đây là phiên bản mới nhất.')
page('TÀI LIỆU THAM KHẢO\nNguồn vận hành và minh họa', '''
[8] Microsoft Learn. Create Filtered Indexes. https://learn.microsoft.com/en-us/sql/relational-databases/indexes/create-filtered-indexes?view=sql-server-ver16 . Tham khảo thiết kế chỉ mục theo tập dữ liệu cần truy vấn.
[9] Microsoft Learn. Full Database Backups SQL Server. https://learn.microsoft.com/en-us/sql/relational-databases/backup-restore/full-database-backups-sql-server?view=sql-server-ver16 . Tham khảo bản sao lưu đầy đủ và quan hệ với log backup.
[10] Microsoft Learn. Complete Database Restores Full Recovery Model. https://learn.microsoft.com/en-us/sql/relational-databases/backup-restore/complete-database-restores-full-recovery-model?view=sql-server-ver16 . Tham khảo chuỗi phục hồi và mô hình FULL.
[11] Microsoft. SQL Server 2022 Comparison. https://www.microsoft.com/en-ca/sql-server/sql-server-2022-comparison . Tham khảo phạm vi phát triển và kiểm thử của Developer Edition.
[12] Microsoft Learn. Conflict Detection in Peer-to-Peer Replication. https://learn.microsoft.com/en-us/sql/relational-databases/replication/transactional/peer-to-peer-conflict-detection-in-peer-to-peer-replication?view=sql-server-ver16 . Tham khảo nguy cơ xung đột khi nhiều điểm sửa cùng bản ghi.
[13] Microsoft Learn. Measure Latency and Validate Connections Transactional. https://learn.microsoft.com/en-us/sql/relational-databases/replication/monitor/measure-latency-and-validate-connections-for-transactional-replication?view=sql-server-ver16 . Tham khảo tracer token và đo độ trễ replication.
[14] Microsoft Learn. Tutorial Configure Transactional Replication. https://learn.microsoft.com/en-us/sql/relational-databases/replication/lesson-1-publishing-data-using-transactional-replication . Tham khảo trình tự cấu hình publication và subscription trong SSMS.
Nguồn ảnh Hình 1: https://raw.githubusercontent.com/MicrosoftDocs/sql-docs/live/docs/relational-databases/replication/transactional/media/trnsact.gif . Nội dung tài liệu Microsoft Learn theo điều kiện sử dụng của nhà cung cấp; ảnh giữ nguyên nhãn gốc và ghi nguồn. Các Hình 2 đến 6 do nhóm dựng cho mô hình đề tài.
''', note='Đọc hướng dẫn ứng với phiên bản môi trường đang dùng. Các trang có thể cập nhật thêm nội dung cho phiên bản mới; không áp dụng tính năng mới cho SQL Server 2022 khi chưa kiểm tra.')
page('PHỤ LỤC A HỢP ĐỒNG GIỮ CHỖ AN TOÀN', '''
Procedure usp_CreateHold nhận RequestID, OrderID, BranchID, FlightID, FareClass và Quantity. Kết quả gồm HoldID, Status, UnitPrice, Quantity, CreatedAt và ExpiresAt. Caller tạo RequestID một lần và giữ nguyên trong các lần thử lại. Nếu kết quả cũ đã EXPIRED hoặc CANCELLED, procedure trả trạng thái cũ; không cấp một giữ mới hoặc gia hạn dưới cùng mã.
Trước phần UPDATE ở mục 5.4, lấy khóa ứng dụng trong transaction và kiểm tra yêu cầu đã tồn tại. Đối chiếu toàn bộ tham số định danh nội dung. Mã sau minh họa bước này; @LockResult và @Resource cần được khai báo trong procedure. Khi lấy khóa thất bại, THROW và rollback thay vì tiếp tục ghi.
''', code='''
DECLARE @Resource nvarchar(255)=
  N'hold-request:'+CONVERT(nvarchar(36),@RequestID);
DECLARE @LockResult int;
EXEC @LockResult = sys.sp_getapplock
  @Resource=@Resource, @LockMode='Exclusive',
  @LockOwner='Transaction', @LockTimeout=5000;
IF @LockResult < 0
  THROW 51002, N'Khong lay duoc khoa yeu cau', 1;

IF EXISTS(SELECT 1 FROM dbo.SeatHold WHERE RequestID=@RequestID)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM dbo.SeatHold
    WHERE RequestID=@RequestID AND OrderID=@OrderID
      AND BranchID=@BranchID AND FlightID=@FlightID
      AND FareClass=@FareClass AND Quantity=@Quantity)
    THROW 51003, N'Ma yeu cau da dung voi noi dung khac', 1;
  COMMIT;
  SELECT HoldID, Status, UnitPrice, Quantity, CreatedAt, ExpiresAt
  FROM dbo.SeatHold WHERE RequestID=@RequestID;
  RETURN;
END;
''', note='Khóa ứng dụng đặt ở S0 với cùng database và principal cho mọi caller. UNIQUE RequestID vẫn cần để bảo vệ cấu trúc dữ liệu.')
page('PHỤ LỤC B TRUY VẤN ĐỐI SOÁT VÀ MINH CHỨNG', '''
Sau khi chạy các ca thử và tác vụ hết hạn, đối chiếu Held với Quantity của các giữ ACTIVE. Một giữ đã qua hạn nhưng job chưa xử lý vẫn còn ACTIVE và còn chiếm Held; vì vậy truy vấn cộng theo Status, không tự loại theo đồng hồ rồi kết luận bộ đếm sai. Tương tự, Sold được đối chiếu với số Ticket ISSUED chưa hoàn.
Nếu có kết quả sai lệch, giữ nguyên dữ liệu và đọc lịch sử trước khi sửa. Bộ truy vấn dưới phục vụ kiểm tra mô hình đã mô tả; không tự sửa bộ đếm. Nhóm bổ sung ảnh SSMS thể hiện trạng thái trước sau, kết quả ca ghế cuối, idempotency và replication theo đúng mã kiểm thử.
''', code='''
SELECT i.FlightID, i.FareClass, i.Held,
       COALESCE(h.ActiveQty,0) AS ActiveQty
FROM dbo.Inventory AS i
LEFT JOIN (
  SELECT FlightID, FareClass, SUM(Quantity) AS ActiveQty
  FROM dbo.SeatHold WHERE Status='ACTIVE'
  GROUP BY FlightID,FareClass
) AS h ON h.FlightID=i.FlightID AND h.FareClass=i.FareClass
WHERE i.Held<>COALESCE(h.ActiveQty,0);

SELECT i.FlightID, i.FareClass, i.Sold,
       COALESCE(t.IssuedQty,0) AS IssuedQty
FROM dbo.Inventory AS i
LEFT JOIN (
  SELECT h.FlightID,h.FareClass,COUNT(*) AS IssuedQty
  FROM dbo.Ticket AS t
  JOIN dbo.SeatHold AS h ON h.HoldID=t.HoldID
  WHERE t.Status='ISSUED'
  GROUP BY h.FlightID,h.FareClass
) AS t ON t.FlightID=i.FlightID AND t.FareClass=i.FareClass
WHERE i.Sold<>COALESCE(t.IssuedQty,0);
''', table=[['Minh chứng cần bổ sung','Người phụ trách theo phân công'],['Script DDL và procedure đầy đủ','Nguyễn Văn Tùng'],['Ảnh phân mảnh và schema nhận','Trần Tiến Dũng'],['Kết quả TC CC FT và số liệu tải','Ngô Thế Quang'],['Mục lục, nguồn, bản thuyết trình','Đỗ Thị Hằng và Phan Văn Sang']], note='Mục tiêu đối soát sau thử là hai truy vấn trên trả về 0 dòng. Chỉ ghi đạt sau khi có kết quả chạy thực tế.')
PAGES[8]['body'] = '''Nhân bản giúp chi nhánh tra cứu dữ liệu gần nơi sử dụng, nhưng bản sao có thể chậm hơn nguồn. Vì vậy, lịch bay được đọc tại chi nhánh; giữ chỗ và phát hành vẫn phải xác nhận tại S0.
SQL Server có snapshot, transactional và merge replication [2], [3], [4]. Đề tài chọn transactional một chiều: S0 công bố danh mục xuống ba chi nhánh; từng chi nhánh công bố đơn bán lên kho báo cáo riêng. Không dùng sao chép để gửi lệnh đặt vé.
Hình 1 mô tả đường đi từ nguồn đến nơi nhận. Các bản sao nhận thay đổi theo lịch agent; giao diện phải thể hiện độ trễ khi dữ liệu chưa bắt kịp. Cách định vị và xử lý sự cố của các luồng được trình bày ở chương 4.'''
