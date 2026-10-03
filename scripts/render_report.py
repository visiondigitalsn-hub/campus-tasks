from pathlib import Path
import re,html
from reportlab.platypus import SimpleDocTemplate,Paragraph,Spacer,PageBreak,Table,TableStyle,KeepTogether
from reportlab.lib.styles import getSampleStyleSheet,ParagraphStyle
from reportlab.lib import colors
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.enums import TA_CENTER
from pypdf import PdfReader
root=Path(__file__).resolve().parents[1]
out=root/'output/pdf';out.mkdir(parents=True,exist_ok=True)
for name,file in [('Campus','C:/Windows/Fonts/arial.ttf'),('CampusBold','C:/Windows/Fonts/arialbd.ttf')]: pdfmetrics.registerFont(TTFont(name,file))
pdfmetrics.registerFontFamily('Campus',normal='Campus',bold='CampusBold',italic='Campus',boldItalic='CampusBold')
styles=getSampleStyleSheet()
styles.add(ParagraphStyle(name='BodyCampus',fontName='Campus',fontSize=10.6,leading=15.6,spaceAfter=9,textColor=colors.HexColor('#243c39')))
styles.add(ParagraphStyle(name='Chapter',fontName='CampusBold',fontSize=21,leading=27,spaceAfter=21,textColor=colors.HexColor('#245b51')))
styles.add(ParagraphStyle(name='SubCampus',fontName='CampusBold',fontSize=12,leading=17,spaceBefore=9,spaceAfter=8,textColor=colors.HexColor('#245b51')))
styles.add(ParagraphStyle(name='Cover',fontName='CampusBold',fontSize=37,leading=44,alignment=TA_CENTER,textColor=colors.HexColor('#245b51')))
styles.add(ParagraphStyle(name='CenterCampus',fontName='Campus',fontSize=14,leading=22,alignment=TA_CENTER,spaceAfter=15,textColor=colors.HexColor('#243c39')))
source=(root/'docs/rapport.tex').read_text(encoding='utf-8')
parts=re.split(r'\\section\{([^}]+)\}',source)[1:]
chapters=list(zip(parts[0::2],parts[1::2]))
flow=[Spacer(1,75),Paragraph('PROJET DE LICENCE 3',styles['CenterCampus']),Spacer(1,35),Paragraph('CampusTasks',styles['Cover']),Spacer(1,20),Paragraph('Gestion des tâches étudiantes',styles['CenterCampus']),Paragraph('Flutter · Spring Boot · PostgreSQL · Docker',styles['CenterCampus']),Spacer(1,65)]
for text in ['Version de travail 1.0.0','3 octobre 2026','Groupe de trois membres : à renseigner','Établissement et encadrant : à renseigner']:
 flow.append(Paragraph(text,styles['CenterCampus']))
flow += [Spacer(1,55),Paragraph('Ce rapport présente le code et les procédures préparés localement. Les publications, le déploiement distant et les essais sur téléphone restent à réaliser. Ajouter les liens et captures après vérification réelle.',styles['BodyCampus']),PageBreak(),Paragraph('Sommaire',styles['Chapter'])]
for i,(title,_) in enumerate(chapters,1):
 flow += [Paragraph(f'{i}. {html.escape(title)}',styles['SubCampus']),Paragraph(f'Page {i+2}',styles['BodyCampus'])]
flow += [Spacer(1,22),Paragraph('Lecture du rapport',styles['SubCampus']),Paragraph("Le document suit le parcours du besoin à la livraison : conception, sécurité, API, mobile, exploitation, versions et vérifications. Il décrit le code réalisé à partir du cahier des charges. Les conventions pourront être adaptées aux cours du professeur lorsqu'ils seront transmis.",styles['BodyCampus']),PageBreak()]
def clean(s):
 s=re.sub(r'\\texttt\{([^}]+)\}',r'\1',s)
 s=s.replace(r'\_', '_').replace(r'\newpage','').replace(r'\end{document}','')
 return html.escape(s.strip())
for i,(title,content) in enumerate(chapters,1):
 flow.append(Paragraph(f'{i}. {html.escape(title)}',styles['Chapter']))
 tableblock=re.search(r'\\begin\{center\}.*?\\end\{center\}',content,re.S)
 if tableblock:
  content=content[:tableblock.start()]+'\n\n[TABLE]\n\n'+content[tableblock.end():]
 content=re.sub(r'\\subsection\*\{([^}]+)\}',r'\n\n[SUB]\1\n\n',content)
 for part in re.split(r'\n\s*\n',content):
  if not part.strip(): continue
  if part.strip()=='[TABLE]':
   rows=[['Table','Données principales'],['students','Identifiant, nom, email unique, mot de passe haché'],['subjects','Propriétaire, nom et description'],['tasks','Propriétaire, matière, titre, date limite, priorité, statut et création'],['auth_tokens','Propriétaire, empreinte du jeton, expiration']]
   t=Table([[Paragraph(html.escape(c),styles['BodyCampus']) for c in row] for row in rows],colWidths=[88,377])
   t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),colors.HexColor('#e3ede7')),('VALIGN',(0,0),(-1,-1),'TOP'),('BOTTOMPADDING',(0,0),(-1,-1),4),('TOPPADDING',(0,0),(-1,-1),6),('LINEBELOW',(0,0),(-1,-1),.4,colors.HexColor('#cad7d0'))]))
   flow += [t,Spacer(1,12)]
  elif part.strip().startswith('[SUB]'):
   flow.append(Paragraph(clean(part.strip()[5:]),styles['SubCampus']))
  else: flow.append(Paragraph(clean(part).replace('\n',' '),styles['BodyCampus']))
 if i<len(chapters):flow.append(PageBreak())
def footer(canvas,doc):
 canvas.saveState();canvas.setFont('Campus',9);canvas.setFillColor(colors.HexColor('#627c73'))
 canvas.drawString(64,810,'CampusTasks · Rapport de travail · 1.0.0');canvas.drawRightString(530,30,str(doc.page));canvas.restoreState()
pdf=out/'CampusTasks-rapport.pdf'
SimpleDocTemplate(str(pdf),pagesize=(595.28,841.89),leftMargin=64,rightMargin=64,topMargin=63,bottomMargin=53,title='CampusTasks - Rapport de projet L3',author='Groupe CampusTasks - membres à renseigner').build(flow,onFirstPage=footer,onLaterPages=footer)
reader=PdfReader(pdf)
print(f'PDF : {len(reader.pages)} pages')
assert len(reader.pages)==10, f'Rapport hors cible : {len(reader.pages)}'
print('Chapitre final présent :', 'Éléments à finaliser' in reader.pages[-1].extract_text())
