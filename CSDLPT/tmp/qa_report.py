import pymupdf, json, sys, math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
root=Path(__file__).resolve().parent.parent
qa=root/'tmp/qa';qa.mkdir(exist_ok=True)
d=pymupdf.open(root/'output/Bao_cao_CSDLPT_Nhom_8.pdf')
stats=[]
for n,p in enumerate(d,1):
    pix=p.get_pixmap(matrix=pymupdf.Matrix(1.5,1.5));pix.save(qa/f'page-{n}.png')
    blocks=p.get_text('blocks');main=[b for b in blocks if b[1]<760 and b[3]>50]
    stats.append(dict(page=n,chars=len(p.get_text()),bottom=max([b[3] for b in main],default=0),title=p.get_text().split('\n')[1:4]))
for start in range(0,len(d),6):
    sheet=Image.new('RGB',(1350,1960),'#CBD2D8');dr=ImageDraw.Draw(sheet)
    for j in range(6):
        if start+j>=len(d):break
        im=Image.open(qa/f'page-{start+j+1}.png');im.thumbnail((430,930))
        x=(j%3)*450+10;y=(j//3)*980+35
        sheet.paste(im,(x,y));dr.text((x,y-25),f'PAGE {start+j+1}',fill='black',font=ImageFont.truetype('C:/Windows/Fonts/arialbd.ttf',18))
    sheet.save(qa/f'overview-{start+1}.jpg',quality=88)
(qa/'stats.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding='utf-8')
print('Rendered',len(d),'pages')
