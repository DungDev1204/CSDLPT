"""Requested second revision of the report, preserving the first source."""
from copy import deepcopy
import re
from content import PAGES as ORIGINAL

PAGES=deepcopy(ORIGINAL[:51])
MEMBERS=[
 ('K24DTCN190','Đỗ Thị Hằng'),
 ('K24DTCN168','Phan Phương Anh'),
 ('K24DTCN184','Lê Hoàng Dương'),
 ('K24DTCN182','Trần Tiến Dũng'),
 ('K24DTCN246','Nguyễn Văn Tùng'),
 ('K24DTCN221','Ngô Thế Quang'),
 ('K24DTCN223','Phan Văn Sang')]
LEADER='Đỗ Thị Hằng'
ASSIGNMENTS={
 'Đỗ Thị Hằng':['1.1','2.1','3.2','4.6','5.6','6.1'],
 'Phan Phương Anh':['1.2','2.2','3.4','4.2','5.3','6.2'],
 'Lê Hoàng Dương':['1.3','2.3','3.1','3.7','5.2','5.7'],
 'Trần Tiến Dũng':['1.4','2.4','3.5','4.3','4.7','6.3'],
 'Nguyễn Văn Tùng':['1.5','2.7','3.3','4.5','5.4','5.5'],
 'Ngô Thế Quang':['2.5','3.6','3.8','4.4','5.9','6.4'],
 'Phan Văn Sang':['2.6','4.1','4.8','5.1','5.8','6.5']}
OWNERS={section:name for name,sections in ASSIGNMENTS.items() for section in sections}
assert len(OWNERS)==42 and all(len(x)==6 for x in ASSIGNMENTS.values())

PAGES[2]['body']='''Khối lượng chuyên môn được chia đều cho bảy thành viên. Mỗi người phụ trách sáu mục riêng, cùng tham gia hai mục chung và rà soát chéo sản phẩm của một thành viên khác. Phần việc chuyên môn của trưởng nhóm được phân công theo cùng mức như các thành viên còn lại.
Đỗ Thị Hằng là trưởng nhóm và là người phụ trách tổng hợp báo cáo. Các thành viên bàn giao nội dung chuyên môn, sơ đồ hoặc bảng thiết kế, mã SQL hoặc hướng dẫn thao tác liên quan và các tình huống kiểm tra của phần mình. Trưởng nhóm ghép các sản phẩm, thống nhất cách trình bày, cập nhật mục lục và hoàn thiện bản báo cáo Word cùng PDF.
Hai mục chung là 1.6 Lựa chọn công nghệ và 6.6 Chức năng quản lý thông minh. Cả bảy thành viên cùng thống nhất nội dung và kiểm tra tính tương thích giữa các phần. Kết luận được thảo luận chung, sau đó trưởng nhóm tổng hợp vào báo cáo.'''
PAGES[2]['table']=[['Thành viên và mã sinh viên','Các mục chuyên môn phụ trách','Khối lượng']]
for sid,name in MEMBERS:
    extra=''
    PAGES[2]['table'].append([name+'\n'+sid,', '.join(ASSIGNMENTS[name])+extra,'6 mục riêng\n2 mục chung\n1 lượt rà soát chéo'])
PAGES[2]['note']=None
PAGES[3]['body']='''Nhóm thống nhất phạm vi và tên bảng trước khi triển khai các phần chuyên môn. Cả bảy thành viên đều tham gia phân tích, thiết kế, xây dựng minh họa và kiểm tra trong phạm vi sáu mục của mình. Hai mục chung được thảo luận cùng nhau để lựa chọn công nghệ và xác định các chức năng thông minh phù hợp với mô hình.
Mỗi thành viên bàn giao bốn nhóm sản phẩm theo cùng yêu cầu: nội dung giải thích của sáu mục, sơ đồ hoặc bảng thiết kế liên quan, mã SQL hoặc hướng dẫn thao tác minh họa và tối thiểu ba tình huống kiểm tra. Những mục thiên về lý thuyết phải có ví dụ gắn với hệ thống bán vé; những mục thiên về cài đặt phải giải thích quy tắc dữ liệu được bảo vệ.
Nhóm rà soát chéo theo vòng: Đỗ Thị Hằng kiểm tra phần Phan Phương Anh; Phan Phương Anh kiểm tra phần Lê Hoàng Dương; Lê Hoàng Dương kiểm tra phần Trần Tiến Dũng; Trần Tiến Dũng kiểm tra phần Nguyễn Văn Tùng; Nguyễn Văn Tùng kiểm tra phần Ngô Thế Quang; Ngô Thế Quang kiểm tra phần Phan Văn Sang; Phan Văn Sang kiểm tra phần Đỗ Thị Hằng. Mỗi người ghi lỗi và đề xuất sửa theo cùng mẫu.
Đỗ Thị Hằng tổng hợp báo cáo sau khi nhận đủ các sản phẩm và phản hồi rà soát. Trưởng nhóm thống nhất tên bảng, thuật ngữ, hình, định dạng và số trang. Các thành viên chịu trách nhiệm giải thích, sửa nội dung phần mình và xác nhận nội dung được tổng hợp đúng. Khi thuyết trình, mỗi người trình bày phần chuyên môn đã phụ trách và cần hiểu quy trình bán vé toàn hệ thống.'''
PAGES[3]['table']=[['Giai đoạn','Người thực hiện','Sản phẩm cần có'],['1 Thống nhất mô hình','Cả 7 thành viên','Phạm vi, tên bảng và quy tắc chung'],['2 Làm phần chuyên môn','Mỗi người 6 mục riêng','Nội dung, sơ đồ hoặc bảng, minh họa'],['3 Kiểm tra và rà soát','Cả 7 thành viên theo vòng','Tối thiểu 3 tình huống và phản hồi'],['4 Tổng hợp báo cáo','Đỗ Thị Hằng','Bản Word, PDF và mục lục cập nhật']]
PAGES[3]['note']='Tất cả thành viên cùng làm chuyên môn; trưởng nhóm nhận thêm trách nhiệm tổng hợp báo cáo.'
PAGES[5]['title']='THUẬT NGỮ VÀ KÝ HIỆU'
PAGES[5]['body']='''Các thuật ngữ dưới đây được sử dụng thống nhất trong toàn bộ báo cáo. S0 là điểm xử lý trung tâm; S1, S2, S3 là ba chi nhánh. Khóa chính và khóa ngoại dùng để mô tả quan hệ dữ liệu; các tham chiếu giữa máy chủ được phân biệt với khóa ngoại cục bộ.
Danh mục, mảnh dữ liệu và bản sao có trách nhiệm khác nhau. Nguồn ghi quyết định kết quả giao dịch; bản sao hỗ trợ đọc và báo cáo. Mã yêu cầu giữ nguyên trong các lần thử lại để không tạo thêm tác dụng nghiệp vụ.'''
PAGES[5]['note']=None

for original_no,p in enumerate(PAGES,1):
    p['original_no']=original_no
    sec=re.search(r'(?m)^(\d+\.\d+) ',p['title'])
    if sec:
        code=sec.group(1)
        if code in OWNERS:
            name=OWNERS[code];sid=next(s for s,n in MEMBERS if n==name)
            p['owner_line']='Thành viên phụ trách: '+name+' | '+sid
            p['owner']=name
        else:
            assert code in ('1.6','6.6')
            p['owner_line']='Thành viên thực hiện: Cả nhóm gồm '+', '.join(n for s,n in MEMBERS)+'.'
            p['owner']='Cả nhóm'
    elif original_no==51:
        p['owner_line']='Tổng hợp báo cáo: Đỗ Thị Hằng | Trưởng nhóm'
    for key in ('body','caption','note'):
        if not p.get(key):continue
        s=p[key]
        s=re.sub(r'\s*\[\d+\](?:\s*,\s*\[\d+\])*','',s)
        s=s.replace('Các cơ chế khóa SQL Server được tham khảo tại.','Các cơ chế khóa được áp dụng tại nguồn ghi SQL Server.')
        s=s.replace('cơ chế và giới hạn được tham khảo tại.','việc lựa chọn cần dựa trên điều kiện truy vấn thực tế.')
        s=s.replace('Phụ lục A trình bày hợp đồng procedure và cách thử lại.','Mỗi RequestID phải được kiểm tra cùng toàn bộ tham số; gọi lại cùng nội dung trả kết quả cũ, còn khác nội dung phải bị từ chối.')
        p[key]=s
    if original_no==51:
        p['body']=p['body'].replace('Về tổ chức, phân công theo chương và sản phẩm giúp bảy thành viên có trách nhiệm rõ ràng.','Về tổ chức, mỗi thành viên phụ trách sáu mục riêng và cùng làm hai mục chung. Đỗ Thị Hằng tổng hợp và hoàn thiện báo cáo với vai trò trưởng nhóm.')

# Two readable TOC pages replace the former dense one-page table of contents.
PAGES[4]['title']='MỤC LỤC\nPhần đầu và chương 1 đến chương 3'
PAGES[4]['toc_part']=1
toc2=dict(title='MỤC LỤC\nChương 4 đến chương 6 và kết luận',body='',table=None,code=None,fig=None,caption=None,note=None,toc_part=2,original_no=0)
PAGES.insert(5,toc2)
assert len(PAGES)==52
