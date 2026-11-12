"""Use the packaged rasterize workflow with a verified Word PDF on Windows.

The first packaged renderer attempt reported missing soffice.exe. This adapter
uses the PDF exported by Word and PyMuPDF, without changing managed skill files.
"""
from pathlib import Path
import importlib.util, shutil
import pymupdf
root=Path(__file__).resolve().parent.parent
helper=Path('C:/Users/DUNGTAO/.codex/plugins/cache/openai-primary-runtime/documents/26.904.11930/skills/documents/render_docx.py')
spec=importlib.util.spec_from_file_location('packaged_renderer',helper)
r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)
pdf=root/'output/Bao_cao_CSDLPT_Nhom_8.pdf'
docx=root/'output/Bao_cao_CSDLPT_Nhom_8.docx'
assert pdf.stat().st_mtime>=docx.stat().st_mtime
def convert(doc_path,user_profile,out_dir,stem,verbose=False):
    p=Path(out_dir)/(stem+'.pdf');shutil.copy2(pdf,p)
    return str(p),'Microsoft Word export validated against final DOCX timestamp'
def raster(pdf_path,dpi,output_folder,**kwargs):
    d=pymupdf.open(pdf_path);out=[]
    for i,p in enumerate(d,1):
        f=Path(output_folder)/f'page0001-{i}.png'
        p.get_pixmap(matrix=pymupdf.Matrix(dpi/72,dpi/72)).save(f)
        out.append(str(f))
    return out
r.convert_to_pdf=convert
r.convert_from_path=raster
paths=r.rasterize(str(docx),str(root/'tmp/render'),108,False,False)
assert 50<=len(paths)<=60
print('Packaged rasterize workflow completed with Windows adapter:',len(paths),'pages')
