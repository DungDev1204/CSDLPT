import re, sys
from pathlib import Path
from collections import Counter
sys.path.insert(0,str(Path(__file__).resolve().parent))
import pymupdf
from docx import Document
from revised_content import PAGES, ASSIGNMENTS, MEMBERS
root=Path(__file__).resolve().parent.parent
pdf=pymupdf.open(root/'output/Bao_cao_CSDLPT_Nhom_8.pdf')
doc=Document(root/'output/Bao_cao_CSDLPT_Nhom_8.docx')
text='\n'.join(p.text for p in doc.paragraphs)
assert len(pdf)==52
assert 'TÀI LIỆU THAM KHẢO' not in text
assert 'PHỤ LỤC' not in text
assert 'DANH MỤC HÌNH' not in text
assert not re.search(r'\[\d+\]',text)
assert 'Phụ lục' not in text
assert 'tham khảo tại.' not in text
counts=Counter(p['owner'] for p in PAGES if p.get('owner') and p['owner']!='Cả nhóm')
assert all(counts[name]==6 for sid,name in MEMBERS)
assert sum(counts.values())==42
assert sum(p.get('owner')=='Cả nhóm' for p in PAGES)==2
assert 'Đỗ Thị Hằng là trưởng nhóm' in text
norm=lambda x: ''.join(x.split())
for index,page in enumerate(PAGES,1):
    if page.get('toc_part'):continue
    pt=norm(pdf[index-1].get_text())
    for heading in page['title'].split('\n'):
        assert norm(heading) in pt, (index,heading)
    if page.get('owner_line'):
        assert norm(page['owner_line']) in pt,(index,page['owner_line'])
    assert len(pdf[index-1].get_text())>200
for table in doc.tables:
    assert all(len(r.cells)==len(table.rows[0].cells) for r in table.rows)
assignment=doc.tables[1]
assert len(assignment.rows)==8
assert all(all(c.text.strip() for c in row.cells) for row in assignment.rows)
toc_text=[p.text for p in doc.paragraphs if '\t' in p.text]
for i,page in enumerate(PAGES,1):
    if i==1 or page.get('toc_part'):continue
    for heading in page['title'].split('\n'):
        assert heading+'\t'+str(i) in toc_text,(heading,i)
print('Verified 52 pages, 42 individual sections, 6 per member, 2 shared sections, leader Hằng, removed sections, and TOC page numbers.')
