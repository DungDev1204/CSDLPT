from pathlib import Path
import sys, math, re, json
sys.path.insert(0,str(Path(__file__).parent))
from revised_content import PAGES, MEMBERS
from PIL import Image, ImageDraw, ImageFont
from docx import Document
from docx.shared import Cm, Pt, RGBColor, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.text import WD_TAB_ALIGNMENT, WD_TAB_LEADER
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

ROOT=Path(__file__).resolve().parent.parent
ASSET=ROOT/'tmp/source'
OUT=ROOT/'output'
OUT.mkdir(exist_ok=True)
FONT='C:/Windows/Fonts/arial.ttf'
BOLD='C:/Windows/Fonts/arialbd.ttf'
def canvas(w,h):
    im=Image.new('RGB',(w,h),'white'); return im,ImageDraw.Draw(im)
def label(d,xy,s,size=25,bold=False,fill='#172D3E',anchor='mm'):
    f=ImageFont.truetype(BOLD if bold else FONT,size)
    d.multiline_text(xy,s,font=f,fill=fill,anchor=anchor,align='center',spacing=9)
def box(d,b,text,fill='#EDF4F8',size=26):
    d.rounded_rectangle(b,radius=16,fill=fill,outline='#466479',width=3)
    label(d,((b[0]+b[2])/2,(b[1]+b[3])/2),text,size,True)
def arrow(d,a,b,fill='#466479',width=4,dashed=False):
    dx,dy=b[0]-a[0],b[1]-a[1]; length=math.hypot(dx,dy)
    if dashed:
        for n in range(0,int(length),20):
            n2=min(n+10,length); d.line((a[0]+dx*n/length,a[1]+dy*n/length,a[0]+dx*n2/length,a[1]+dy*n2/length),fill=fill,width=width)
    else:d.line((a,b),fill=fill,width=width)
    ux,uy=dx/length,dy/length
    d.polygon([b,(b[0]-ux*17+uy*9,b[1]-uy*17-ux*9),(b[0]-ux*17-uy*9,b[1]-uy*17+ux*9)],fill=fill)

im,d=canvas(1450,740)
nodes=[(45,70,425,195,'Tra cứu và lập đơn\nAirBranch chi nhánh'),(535,70,915,195,'Gửi RequestID\nđến AirCore tại S0'),(1025,70,1405,195,'Giữ chỗ ACTIVE\nchốt giá và thời hạn'),(1025,320,1405,445,'Xác minh thanh toán\nExternalRef duy nhất'),(535,320,915,445,'S0 phát hành vé\nHeld giảm Sold tăng'),(45,320,425,445,'Cập nhật đơn ISSUED\nliên kết TicketID')]
for x1,y1,x2,y2,t in nodes:box(d,(x1,y1,x2,y2),t,size=25)
for a,b in [((425,132),(535,132)),((915,132),(1025,132)),((1215,195),(1215,320)),((1025,382),(915,382)),((535,382),(425,382))]:arrow(d,a,b)
box(d,(405,570,1045,695),'Mất phản hồi → PENDING_RECONCILE\nTra lại cùng RequestID hoặc ExternalRef',fill='#F8F1DF',size=25)
arrow(d,(725,195),(725,570),dashed=True); arrow(d,(235,445),(405,620),dashed=True)
im.save(ASSET/'workflow.png')

im,d=canvas(1500,820)
positions={
'catalog':(30,35,345,170,'Airport Route Aircraft\nPK theo danh mục'),
'flight':(450,35,765,170,'Flight\nPK FlightID'),
'inv':(875,35,1190,170,'Inventory Fare\nPK FlightID FareClass'),
'hold':(875,330,1190,465,'SeatHold\nPK HoldID UQ RequestID'),
'ticket':(450,630,765,765,'Ticket\nUQ HoldID ItemNo'),
'refund':(450,490,765,585,'Refund\nUQ TicketID ExternalRef'),
'payment':(875,630,1190,765,'Payment\nUQ HoldID ExternalRef'),
'customer':(30,330,345,465,'CustomerProfile Employee\nNguồn tại chi nhánh'),
'order':(450,330,765,465,'SalesOrder\nPK OrderID'),
'item':(30,630,345,765,'SalesItem\nPK OrderID ItemNo')}
for key,(x1,y1,x2,y2,t) in positions.items():box(d,(x1,y1,x2,y2),t,fill='#F0F4F7' if key in ['customer','order','item'] else '#E9F2F9',size=23)
for a,b,dash in [((345,102),(450,102),False),((765,102),(875,102),False),((1032,170),(1032,330),False),((1032,465),(1032,630),False),((935,465),(820,600),False),((820,600),(765,650),False),((345,398),(450,398),False),((450,445),(345,650),False),((765,398),(875,398),True),((345,698),(450,698),True)]:arrow(d,a,b,dashed=dash)
arrow(d,(608,630),(608,585))
label(d,(1325,250),'TRUNG TÂM\nDanh mục\nKho ghế\nGiữ chỗ\nVé và tiền',size=23,bold=True)
label(d,(1325,520),'CHI NHÁNH\nHồ sơ\nĐơn\nHành khách',size=23,bold=True)
im.save(ASSET/'erd.png')

im,d=canvas(1450,750)
box(d,(470,40,980,250),'S0 Trung tâm Hà Nội\nAirCore nguồn nghiệp vụ\nAirReporting nhận báo cáo',size=28)
for x,name in [(30,'S1 Hà Nội HN'),(530,'S2 Đà Nẵng DN'),(1030,'S3 TP Hồ Chí Minh HCM')]:
    box(d,(x,490,x+390,700),name+'\nAirBranch nguồn đơn\nAirReference bản sao',size=24)
    arrow(d,(650,250),(x+125,490),fill='#2D7392')
    arrow(d,(x+200,490),(725,250),fill='#2D7392',width=3)
    arrow(d,(x+265,490),(800,250),fill='#172D3E',dashed=True)
label(d,(300,310),'Danh mục ↓\nĐơn bán ↑',size=25)
label(d,(1140,310),'Giữ chỗ và phát hành\nAPI đến S0',size=25)
im.save(ASSET/'topology.png')

im,d=canvas(1450,550)
box(d,(430,35,1020,180),'SalesOrder toàn cục\nBranchID HN DN HCM',size=30)
for x,s in [(35,'HN tại S1'),(535,'DN tại S2'),(1035,'HCM tại S3')]:
    box(d,(x,340,x+375,485),'SalesOrder_'+s.split()[0]+'\n'+s,size=29)
    arrow(d,(725,180),(x+187,340))
im.save(ASSET/'fragments.png')

im,d=canvas(1450,560)
box(d,(40,205,400,355),'ACTIVE\nHeld chiếm q ghế',size=28)
for b,t in [((930,35,1390,165),'CONFIRMED\nHeld −q và Sold +q'),((930,205,1390,335),'EXPIRED\nHeld −q'),((930,390,1390,520),'CANCELLED\nHeld −q')]:box(d,b,t,size=27)
for a,b in [((400,250),(930,100)),((400,280),(930,270)),((400,310),(930,455))]:arrow(d,a,b)
label(d,(640,145),'Thanh toán hợp lệ',size=24)
label(d,(640,250),'Đến thời hạn',size=24)
label(d,(640,430),'Yêu cầu hủy',size=24)
im.save(ASSET/'states.png')

doc=Document(); sec=doc.sections[0]
sec.page_width=Cm(21);sec.page_height=Cm(29.7)
sec.top_margin=Cm(2.1);sec.bottom_margin=Cm(2.1)
sec.left_margin=Cm(2.7);sec.right_margin=Cm(2.0)
sec.header_distance=Cm(.8);sec.footer_distance=Cm(.9)
sec.different_first_page_header_footer=True
for name,size,bold in [('Normal',13,False),('Title',20,True),('Heading 1',15,True),('Heading 2',14,True),('Caption',11,False)]:
    st=doc.styles[name];st.font.name='Times New Roman';st.font.size=Pt(size);st.font.bold=bold;st.font.color.rgb=RGBColor(0,0,0)
    st._element.get_or_add_rPr().get_or_add_rFonts().set(qn('w:eastAsia'),'Times New Roman')
    rf=st._element.get_or_add_rPr().get_or_add_rFonts()
    for attr in ('asciiTheme','hAnsiTheme','eastAsiaTheme','cstheme'):
        rf.attrib.pop(qn('w:'+attr),None)
    st.paragraph_format.space_after=Pt(6)
    st.paragraph_format.line_spacing=1.2 if name=='Normal' else 1.05
    st.paragraph_format.widow_control=True
doc.styles['Normal'].paragraph_format.alignment=WD_ALIGN_PARAGRAPH.JUSTIFY
for st in doc.styles:
    for border in list(st._element.iter(qn('w:pBdr'))):border.getparent().remove(border)
for stname in ['Heading 1','Heading 2']:doc.styles[stname].paragraph_format.keep_with_next=True

f=sec.footer.paragraphs[0];f.alignment=WD_ALIGN_PARAGRAPH.CENTER
run=f.add_run();run.font.name='Times New Roman';run.font.size=Pt(11)
fld=OxmlElement('w:fldSimple');fld.set(qn('w:instr'),'PAGE');run._r.addnext(fld)
doc.core_properties.title='Cơ sở dữ liệu phân tán quản lý hàng không thông minh'
doc.core_properties.author='Nhóm 8 D24TXCN05-K'
doc.core_properties.subject='Báo cáo học phần Cơ sở dữ liệu phân tán'

def para(text,style=None,size=None,bold=False,align=None):
    p=doc.add_paragraph(style=style);r=p.add_run(text)
    if size:r.font.size=Pt(size)
    if bold:r.bold=True
    if align is not None:p.alignment=align
    return p
def cell_set(cell,txt,header=False):
    p=cell.paragraphs[0];p.paragraph_format.space_after=Pt(3);p.paragraph_format.space_before=Pt(3);p.paragraph_format.line_spacing=1.05
    p.alignment=WD_ALIGN_PARAGRAPH.LEFT
    r=p.add_run(str(txt));r.font.name='Times New Roman';r.font.size=Pt(11.2);r.bold=header;r.font.color.rgb=RGBColor(0,0,0)
    cell.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
def make_table(rows):
    t=doc.add_table(rows=1,cols=len(rows[0]));t.alignment=WD_TABLE_ALIGNMENT.CENTER;t.autofit=False
    usable=16.3
    n=len(rows[0]);ratios={2:[.34,.66],3:[.24,.30,.46],4:[.19,.23,.27,.31],5:[.36,.12,.12,.12,.28]}.get(n,[1/n]*n)
    if rows[0][0]=='Chuyển trạng thái':ratios=[.36,.34,.15,.15]
    for col,ratio in zip(t.columns,ratios):col.width=Cm(usable*ratio)
    for ri,row in enumerate(rows):
        cells=t.rows[0].cells if ri==0 else t.add_row().cells
        for j,(cell,txt) in enumerate(zip(cells,row)):
            cell.width=Cm(usable*ratios[j]);cell_set(cell,txt,ri==0)
            tcPr=cell._tc.get_or_add_tcPr()
            shading=OxmlElement('w:shd');shading.set(qn('w:fill'),'DDEAF2' if ri==0 else ('F5F7F9' if ri%2==0 else 'FFFFFF'));tcPr.append(shading)
            borders=OxmlElement('w:tcBorders')
            for edge in ['top','left','bottom','right']:
                e=OxmlElement('w:'+edge);e.set(qn('w:val'),'single');e.set(qn('w:sz'),'4');e.set(qn('w:color'),'D9D9D9');borders.append(e)
            tcPr.append(borders)
            margins=OxmlElement('w:tcMar')
            for edge in ['top','left','bottom','right']:
                e=OxmlElement('w:'+edge);e.set(qn('w:w'),'75');e.set(qn('w:type'),'dxa');margins.append(e)
            tcPr.append(margins)
        pr=t.rows[ri]._tr.get_or_add_trPr();cant=OxmlElement('w:cantSplit');pr.append(cant)
        if ri==0:
            repeat=OxmlElement('w:tblHeader');pr.append(repeat)
    return t

toc=[]
toc_map_path=ROOT/'tmp/toc_page_map_v2.json'
toc_map=json.loads(toc_map_path.read_text(encoding='utf-8')) if toc_map_path.exists() else {}
for idx,pg in enumerate(PAGES,1):
    if pg.get('toc_part'):continue
    if idx!=1:
        for title in pg['title'].split('\n'):
            chapter=re.match(r'CHƯƠNG (\d+)',title)
            sub=re.match(r'(\d+)\.\d+ ',title)
            if chapter:part=1 if int(chapter.group(1))<=3 else 2
            elif sub:part=1 if int(sub.group(1))<=3 else 2
            elif pg.get('original_no')==51:part=2
            else:part=1
            toc.append((title,toc_map.get(title,idx),part))

for idx,pg in enumerate(PAGES,1):
    if idx==1:
        para('BÁO CÁO BÀI TẬP LỚN','Title',align=WD_ALIGN_PARAGRAPH.CENTER)
        p=para('HỌC PHẦN CƠ SỞ DỮ LIỆU PHÂN TÁN',size=15,bold=True,align=WD_ALIGN_PARAGRAPH.CENTER);p.paragraph_format.space_before=Pt(22)
        p=para('CƠ SỞ DỮ LIỆU PHÂN TÁN\nQUẢN LÝ HÀNG KHÔNG THÔNG MINH',size=20,bold=True,align=WD_ALIGN_PARAGRAPH.CENTER);p.paragraph_format.space_before=Pt(36);p.paragraph_format.space_after=Pt(16)
        para('Trọng tâm quản lý bán vé máy bay tại nhiều chi nhánh',size=14,align=WD_ALIGN_PARAGRAPH.CENTER)
        p=para('Nhóm 8   |   Lớp D24TXCN05-K',size=14,bold=True,align=WD_ALIGN_PARAGRAPH.CENTER);p.paragraph_format.space_before=Pt(25)
        para('Giảng viên hướng dẫn ThS. Mai Ngọc Lương',size=14,align=WD_ALIGN_PARAGRAPH.CENTER)
        members=MEMBERS
        p=para('Sinh viên thực hiện',size=14,bold=True,align=WD_ALIGN_PARAGRAPH.CENTER);p.paragraph_format.space_before=Pt(25)
        for sid,name in members:
            p=para(sid+'     '+name,size=13,align=WD_ALIGN_PARAGRAPH.CENTER);p.paragraph_format.space_after=Pt(4)
        p=para('Tháng 10 năm 2026',size=13,align=WD_ALIGN_PARAGRAPH.CENTER);p.paragraph_format.space_before=Pt(30)
        continue
    for li,line in enumerate(pg['title'].split('\n')):
        chapter=line.startswith('CHƯƠNG') or (li==0 and not re.match(r'^\d+\.\d+ ',line))
        hp=para(line,'Heading 1' if chapter else 'Heading 2')
        if li==0:hp.paragraph_format.page_break_before=True
    if pg.get('toc_part'):
        for title,num,part in toc:
            if part!=pg['toc_part']:continue
            is_sub=bool(re.match(r'^\d+\.\d+ ',title))
            is_chapter=title.startswith('CHƯƠNG')
            p=doc.add_paragraph();p.alignment=WD_ALIGN_PARAGRAPH.LEFT
            p.paragraph_format.space_after=Pt(3);p.paragraph_format.line_spacing=1.0
            p.paragraph_format.space_before=Pt(9 if is_chapter else 1)
            p.paragraph_format.left_indent=Cm(.55 if is_sub else 0)
            p.paragraph_format.tab_stops.add_tab_stop(Cm(16.1),WD_TAB_ALIGNMENT.RIGHT,WD_TAB_LEADER.DOTS)
            r=p.add_run(title);r.font.size=Pt(12 if is_sub else 12.5);r.bold=not is_sub
            r=p.add_run('\t');r.font.size=Pt(12)
            r=p.add_run(str(num));r.font.size=Pt(12);r.bold=not is_sub
        continue
    if pg.get('owner_line'):
        p=para(pg['owner_line'],size=11.5,bold=True)
        p.paragraph_format.space_after=Pt(8)
        p.paragraph_format.line_spacing=1.1
        p.paragraph_format.keep_with_next=True
    for text in pg['body'].split('\n'):
        if text.strip():
            p=para(text.strip())
            if pg.get('original_no') in (12,22):
                p.paragraph_format.line_spacing=1.15
                p.paragraph_format.space_after=Pt(5)
                p.runs[0].font.size=Pt(12.5)
    if pg['fig']:
        path=ASSET/pg['fig'];w,h=Image.open(path).size
        maxh=3.2 if pg.get('original_no')!=9 else 5.0
        if pg.get('original_no')==40:maxh=2.0
        width=min(6.3,maxh*w/h)
        p=doc.add_paragraph();p.alignment=WD_ALIGN_PARAGRAPH.CENTER;p.paragraph_format.space_after=Pt(2)
        p.add_run().add_picture(str(path),width=Inches(width))
        if pg['caption']:
            cap=para(pg['caption'],'Caption');cap.alignment=WD_ALIGN_PARAGRAPH.CENTER
    if pg['table'] and pg.get('original_no')!=51:make_table(pg['table'])
    if pg['code']:
        for line in pg['code'].split('\n'):
            p=doc.add_paragraph();p.paragraph_format.space_after=Pt(0);p.paragraph_format.space_before=Pt(0);p.paragraph_format.line_spacing=1.0;p.paragraph_format.alignment=WD_ALIGN_PARAGRAPH.LEFT
            r=p.add_run(line or ' ');r.font.name='Consolas';r.font.size=Pt(9.2)
            shd=OxmlElement('w:shd');shd.set(qn('w:fill'),'F4F5F6');p._p.get_or_add_pPr().append(shd)
        p=doc.add_paragraph();p.paragraph_format.space_after=Pt(1);p.paragraph_format.space_before=Pt(0);p.paragraph_format.line_spacing=1
    if pg['note']:
        p=para(pg['note']);p.paragraph_format.line_spacing=1.1
        for r in p.runs:r.italic=True;r.font.size=Pt(11)

for p in doc.paragraphs:
    for border in list(p._p.iter(qn('w:pBdr'))):border.getparent().remove(border)
doc.save(OUT/'Bao_cao_CSDLPT_Nhom_8.docx')
print('Created DOCX with',len(PAGES),'planned pages')
