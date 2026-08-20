"""
Script Generator: Panduan Penggunaan Aplikasi LexImpact AI
Menghasilkan dokumen Word (.docx) profesional siap pakai untuk laporan/publikasi.

Deskripsi aplikasi (berdasarkan README):
- Nama       : LexImpact AI (Legal Experience for HR Decision Impact)
- Jenis      : Aplikasi mobile pembelajaran berbasis AI + Gamifikasi
- Platform   : Android / iOS (Flutter)
- Fitur      : Simulasi HR Interaktif 3 Level, AI Analysis (Mistral AI), RAG,
               Game Mode drag-and-drop, Materi, Video, Kuis
- Stack      : Flutter/Dart, Mistral AI, Supabase Vector DB, GoRouter
- Developer  : Ramzi Syuhada
"""

import os
from docx import Document
from docx.shared import Pt, Cm, RGBColor, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_LINE_SPACING
from docx.enum.style import WD_STYLE_TYPE
from docx.enum.table import WD_TABLE_ALIGNMENT
import docx.oxml as oxml
from docx.oxml.ns import qn

# ─────────────────────────────────────────────
# KONSTANTA APLIKASI
# ─────────────────────────────────────────────
APP_NAME        = "LexImpact AI"
APP_SUBTITLE    = "Legal Experience for HR Decision Impact"
APP_VERSION     = "1.0"
DEVELOPER       = "Ramzi Syuhada"
DEVELOPER_TITLE = "Flutter Developer | AR/VR Engineer"
YEAR            = "2026"
OUTPUT_FILE     = r"d:\Flutter\leximpactai\Panduan_Penggunaan_Aplikasi_LexImpact_AI.docx"

# ─────────────────────────────────────────────
# WARNA PALET
# ─────────────────────────────────────────────
C_NAVY      = (26,  58, 108)   # #1A3A6C – heading & cover primer
C_DARK_BLUE = (46,  64,  87)   # #2E4057 – tabel header sekunder
C_WHITE     = (255,255,255)
C_GREY_TXT  = (136,136,136)
C_GOLD      = (200,155, 60)    # aksen gold

# ─────────────────────────────────────────────
# UTILITAS DASAR
# ─────────────────────────────────────────────

def set_cell_bg(cell, hex_color: str):
    tc   = cell._tc
    tcPr = tc.get_or_add_tcPr()
    shd  = oxml.OxmlElement('w:shd')
    shd.set(qn('w:val'),   'clear')
    shd.set(qn('w:color'), 'auto')
    shd.set(qn('w:fill'),  hex_color)
    tcPr.append(shd)

def set_table_border(tbl, color='1A3A6C', sz='6'):
    """Atur border luar tabel."""
    tbl_elem = tbl._tbl
    tbl_pr = tbl_elem.find(qn('w:tblPr'))
    if tbl_pr is None:
        tbl_pr = oxml.OxmlElement('w:tblPr')
        tbl_elem.insert(0, tbl_pr)
    tbl_borders = oxml.OxmlElement('w:tblBorders')
    for edge in ('top','left','bottom','right','insideH','insideV'):
        tag = oxml.OxmlElement(f'w:{edge}')
        tag.set(qn('w:val'),   'single')
        tag.set(qn('w:sz'),    sz)
        tag.set(qn('w:space'), '0')
        tag.set(qn('w:color'), color)
        tbl_borders.append(tag)
    tbl_pr.append(tbl_borders)

def tnr(run, size=12, bold=False, italic=False, color=None):
    """Terapkan Times New Roman ke run."""
    run.font.name  = 'Times New Roman'
    run.font.size  = Pt(size)
    run.bold       = bold
    run.italic     = italic
    if color:
        run.font.color.rgb = RGBColor(*color)
    return run

def para_fmt(para, before=0, after=6, line_pts=None, indent_cm=None,
             hanging_cm=None, align=WD_ALIGN_PARAGRAPH.JUSTIFY):
    pf = para.paragraph_format
    pf.space_before = Pt(before)
    pf.space_after  = Pt(after)
    if line_pts:
        pf.line_spacing = Pt(line_pts)
    if indent_cm is not None:
        pf.first_line_indent = Cm(indent_cm)
    if hanging_cm is not None:
        pf.left_indent          = Cm(hanging_cm)
        pf.first_line_indent    = Cm(-hanging_cm)
    para.alignment = align

def add_run(para, text, size=12, bold=False, italic=False, color=None):
    run = para.add_run(text)
    tnr(run, size=size, bold=bold, italic=italic, color=color)
    return run

def page_break(doc):
    p  = doc.add_paragraph()
    r  = p.add_run()
    br = oxml.OxmlElement('w:br')
    br.set(qn('w:type'), 'page')
    r._r.append(br)
    p.paragraph_format.space_before = Pt(0)
    p.paragraph_format.space_after  = Pt(0)

def body(doc, text, indent=True, before=0, after=6):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    if indent:
        p.paragraph_format.first_line_indent = Cm(1.25)
    p.paragraph_format.space_before = Pt(before)
    p.paragraph_format.space_after  = Pt(after)
    p.paragraph_format.line_spacing = Pt(18)
    add_run(p, text)
    return p

def h1(doc, label, title):
    """Heading 1: 'BAB X\\nJUDUL' style."""
    # Baris label bab
    p_label = doc.add_paragraph()
    p_label.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_label.paragraph_format.space_before = Pt(0)
    p_label.paragraph_format.space_after  = Pt(4)
    add_run(p_label, label, size=14, bold=True, color=C_NAVY)

    # Garis bawah simulasi
    p_line = doc.add_paragraph()
    p_line.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_line.paragraph_format.space_before = Pt(0)
    p_line.paragraph_format.space_after  = Pt(2)
    add_run(p_line, '─' * 55, size=9, color=C_GOLD)

    # Judul bab
    p_title = doc.add_heading(title, level=1)
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title.paragraph_format.space_before = Pt(4)
    p_title.paragraph_format.space_after  = Pt(16)
    for run in p_title.runs:
        run.font.name  = 'Times New Roman'
        run.font.size  = Pt(14)
        run.font.color.rgb = RGBColor(*C_NAVY)
        run.bold = True
    return p_title

def h2(doc, text):
    p = doc.add_heading(text, level=2)
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    p.paragraph_format.space_before = Pt(12)
    p.paragraph_format.space_after  = Pt(6)
    for run in p.runs:
        run.font.name  = 'Times New Roman'
        run.font.size  = Pt(13)
        run.font.color.rgb = RGBColor(*C_DARK_BLUE)
        run.bold = True
    return p

def h3(doc, text):
    p = doc.add_heading(text, level=3)
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    p.paragraph_format.space_before = Pt(8)
    p.paragraph_format.space_after  = Pt(4)
    for run in p.runs:
        run.font.name  = 'Times New Roman'
        run.font.size  = Pt(12)
        run.font.color.rgb = RGBColor(*C_NAVY)
        run.bold  = True
        run.italic = True
    return p

def numbered_list(doc, items):
    for i, item in enumerate(items, 1):
        p = doc.add_paragraph(style='List Number')
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after  = Pt(3)
        p.paragraph_format.line_spacing = Pt(16)
        add_run(p, item)

def bullet_list(doc, items):
    for item in items:
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after  = Pt(3)
        p.paragraph_format.line_spacing = Pt(16)
        add_run(p, item)

def add_real_image(doc, img_name_or_path, caption_text, width_cm=12):
    """
    Tambahkan gambar screenshot aplikasi asli jika file ada,
    diikuti caption di bawahnya.
    """
    img_dir = r"d:\Flutter\leximpactai\screenshots"

    # Tentukan full path
    if os.path.isabs(img_name_or_path):
        full_path = img_name_or_path
    else:
        full_path = os.path.join(img_dir, f"{img_name_or_path}.png")

    if os.path.exists(full_path):
        # Para gambar
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(8)
        p_img.paragraph_format.space_after  = Pt(4)
        run_img = p_img.add_run()
        run_img.add_picture(full_path, width=Cm(width_cm))
    else:
        # Fallback ke placeholder jika file tidak ditemukan
        tbl = doc.add_table(rows=1, cols=1)
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
        set_table_border(tbl, color='AAAAAA', sz='6')
        cell = tbl.cell(0, 0)
        set_cell_bg(cell, 'E8E8E8')

        inner = cell.paragraphs[0]
        inner.alignment = WD_ALIGN_PARAGRAPH.CENTER
        pad = Pt(6 * 12)
        inner.paragraph_format.space_before = pad
        inner.paragraph_format.space_after  = pad

        r = inner.add_run('[Screenshot Aplikasi]')
        r.font.name  = 'Times New Roman'
        r.font.size  = Pt(11)
        r.font.color.rgb = RGBColor(*C_GREY_TXT)
        r.italic = True

    # Caption di bawah gambar
    cap = doc.add_paragraph()
    cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
    cap.paragraph_format.space_before = Pt(4)
    cap.paragraph_format.space_after  = Pt(14)
    r_cap = cap.add_run(caption_text)
    r_cap.font.name  = 'Times New Roman'
    r_cap.font.size  = Pt(10)
    r_cap.italic = True

def placeholder(doc, caption: str, height_cm=7, width_cm=14):
    """Backwards compatibility wrapper -> memanggil add_real_image."""
    add_real_image(doc, "01_home_page", caption, width_cm=11)

def add_toc_field(doc):
    """Sisipkan field TOC otomatis Word (diperbarui saat file dibuka di MS Word)."""
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(0)
    p.paragraph_format.space_after  = Pt(0)

    fld_begin = oxml.OxmlElement('w:fldChar')
    fld_begin.set(qn('w:fldCharType'), 'begin')
    p._p.append(fld_begin)

    instr = oxml.OxmlElement('w:instrText')
    instr.set(qn('xml:space'), 'preserve')
    instr.text = ' TOC \\o "1-3" \\h \\z \\u '
    p._p.append(instr)

    sep = oxml.OxmlElement('w:fldChar')
    sep.set(qn('w:fldCharType'), 'separate')
    p._p.append(sep)

    note_r = oxml.OxmlElement('w:r')
    rPr    = oxml.OxmlElement('w:rPr')
    note_r.append(rPr)
    note_t = oxml.OxmlElement('w:t')
    note_t.text = (
        'Tekan Ctrl+A kemudian F9 di Microsoft Word untuk memperbarui daftar isi ini secara otomatis.'
    )
    note_r.append(note_t)
    p._p.append(note_r)

    fld_end = oxml.OxmlElement('w:fldChar')
    fld_end.set(qn('w:fldCharType'), 'end')
    p._p.append(fld_end)

    # Style note teks
    note_run = p.runs
    if note_run:
        note_run[0].font.name   = 'Times New Roman'
        note_run[0].font.size   = Pt(10)
        note_run[0].font.italic = True
        note_run[0].font.color.rgb = RGBColor(*C_GREY_TXT)

def add_footer_page_number(doc):
    """Nomor halaman di footer tengah: 'Halaman X dari Y'."""
    for section in doc.sections:
        footer = section.footer
        para   = footer.paragraphs[0] if footer.paragraphs else footer.add_paragraph()
        para.clear()
        para.alignment = WD_ALIGN_PARAGRAPH.CENTER

        def field_run(para, instr_text):
            r   = para.add_run()
            r.font.name = 'Times New Roman'
            r.font.size = Pt(10)
            fb  = oxml.OxmlElement('w:fldChar')
            fb.set(qn('w:fldCharType'), 'begin')
            r._r.append(fb)
            ins = oxml.OxmlElement('w:instrText')
            ins.set(qn('xml:space'), 'preserve')
            ins.text = f' {instr_text} '
            r._r.append(ins)
            fe  = oxml.OxmlElement('w:fldChar')
            fe.set(qn('w:fldCharType'), 'end')
            r._r.append(fe)

        add_run(para, 'Halaman ', size=10)
        field_run(para, 'PAGE')
        add_run(para, ' dari ', size=10)
        field_run(para, 'NUMPAGES')

def styled_table(doc, headers, rows, col_widths_cm=None):
    """Buat tabel berformat dengan header navy dan baris zebra."""
    tbl = doc.add_table(rows=len(rows)+1, cols=len(headers))
    tbl.style = 'Table Grid'
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_border(tbl, color='1A3A6C', sz='6')

    # Header
    for j, hdr in enumerate(headers):
        c = tbl.cell(0, j)
        set_cell_bg(c, '1A3A6C')
        c.paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
        add_run(c.paragraphs[0], hdr, size=11, bold=True, color=C_WHITE)

    # Data rows
    for i, row in enumerate(rows):
        bg = 'EEF2F7' if i % 2 == 0 else 'FFFFFF'
        for j, cell_text in enumerate(row):
            c = tbl.cell(i+1, j)
            set_cell_bg(c, bg)
            align = WD_ALIGN_PARAGRAPH.CENTER if j == 0 else WD_ALIGN_PARAGRAPH.LEFT
            c.paragraphs[0].alignment = align
            add_run(c.paragraphs[0], cell_text, size=10, bold=(j == 0))

    # Lebar kolom
    if col_widths_cm:
        for j, w in enumerate(col_widths_cm):
            for i in range(len(rows)+1):
                tbl.cell(i, j).width = Cm(w)

    return tbl

def table_caption(doc, text):
    p = doc.add_paragraph(text)
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(4)
    p.paragraph_format.space_after  = Pt(12)
    p.runs[0].font.name  = 'Times New Roman'
    p.runs[0].font.size  = Pt(10)
    p.runs[0].italic     = True

# ═══════════════════════════════════════════════════════════════
# BUAT DOKUMEN
# ═══════════════════════════════════════════════════════════════

doc = Document()

# Pastikan style Caption ada
try:
    doc.styles['Caption']
except KeyError:
    cs = doc.styles.add_style('Caption', WD_STYLE_TYPE.PARAGRAPH)
    cs.font.name   = 'Times New Roman'
    cs.font.size   = Pt(10)
    cs.font.italic = True

# Margin akademik (Atas 3, Bawah 3, Kiri 4, Kanan 3)
for sec in doc.sections:
    sec.top_margin    = Cm(3)
    sec.bottom_margin = Cm(3)
    sec.left_margin   = Cm(4)
    sec.right_margin  = Cm(3)
    sec.page_width    = Cm(21)
    sec.page_height   = Cm(29.7)

add_footer_page_number(doc)

# ═══════════════════════════════════════════════════════════════
# COVER
# ═══════════════════════════════════════════════════════════════

# Frame cover: tabel 1×1 dengan background navy
cover_tbl = doc.add_table(rows=1, cols=1)
cover_tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
cover_cell = cover_tbl.cell(0, 0)
set_cell_bg(cover_cell, '1A3A6C')

# ── Baris 1: Label atas ──
def cover_para(cell, text, size, bold=False, italic=False,
               color=C_WHITE, before=0, after=6, align=WD_ALIGN_PARAGRAPH.CENTER):
    p = cell.add_paragraph()
    p.alignment = align
    p.paragraph_format.space_before = Pt(before)
    p.paragraph_format.space_after  = Pt(after)
    add_run(p, text, size=size, bold=bold, italic=italic, color=color)
    return p

# Header kop (universitas/lembaga placeholder)
p0 = cover_cell.paragraphs[0]
p0.alignment = WD_ALIGN_PARAGRAPH.CENTER
p0.paragraph_format.space_before = Pt(50)
p0.paragraph_format.space_after  = Pt(6)
add_run(p0, 'PANDUAN PENGGUNAAN APLIKASI', size=13, bold=True, color=(180,210,255))

cover_para(cover_cell, '─' * 45, size=9, color=C_GOLD, before=0, after=8)

# Nama Aplikasi (besar)
cover_para(cover_cell, APP_NAME, size=28, bold=True, color=C_WHITE, before=0, after=4)

# Tagline
cover_para(cover_cell, f'"{APP_SUBTITLE}"', size=12, italic=True,
           color=(170,200,255), before=0, after=30)

# Ikon-ikon fitur (teks simulasi)
feat_texts = [
    '⚖  Simulasi HR Interaktif 3 Level     🤖  AI Analysis powered by Mistral AI',
    '📚  Materi & Video Pembelajaran       🎮  Game Mode Drag & Drop Strategi',
]
for ft in feat_texts:
    cover_para(cover_cell, ft, size=10, italic=False, color=(200,220,255), before=0, after=4)

cover_para(cover_cell, '', size=10, before=0, after=20)
cover_para(cover_cell, '─' * 45, size=9, color=C_GOLD, before=0, after=16)

# Info block
for label, value in [
    ('Versi Aplikasi', f'v{APP_VERSION}'),
    ('Platform',       'Android & iOS (Flutter)'),
    ('Developer',      DEVELOPER),
    ('Jabatan',        DEVELOPER_TITLE),
    ('Tahun',          YEAR),
]:
    p_info = cover_cell.add_paragraph()
    p_info.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_info.paragraph_format.space_before = Pt(0)
    p_info.paragraph_format.space_after  = Pt(3)
    add_run(p_info, f'{label:<18}:  ', size=11, color=(170,200,255))
    add_run(p_info, value,              size=11, bold=True, color=C_WHITE)

cover_para(cover_cell, '', size=10, before=0, after=40)

page_break(doc)

# ═══════════════════════════════════════════════════════════════
# DAFTAR ISI
# ═══════════════════════════════════════════════════════════════

p_toc_head = doc.add_heading('DAFTAR ISI', level=1)
p_toc_head.alignment = WD_ALIGN_PARAGRAPH.CENTER
p_toc_head.paragraph_format.space_before = Pt(0)
p_toc_head.paragraph_format.space_after  = Pt(16)
for run in p_toc_head.runs:
    run.font.name  = 'Times New Roman'
    run.font.size  = Pt(14)
    run.font.color.rgb = RGBColor(*C_NAVY)
    run.bold = True

add_toc_field(doc)
page_break(doc)

# ═══════════════════════════════════════════════════════════════
# BAB 1 – INFORMASI UMUM APLIKASI
# ═══════════════════════════════════════════════════════════════

h1(doc, 'BAB 1', 'INFORMASI UMUM APLIKASI')

body(doc,
    f'{APP_NAME} (Legal Experience for HR Decision Impact) adalah aplikasi pembelajaran '
    'berbasis kecerdasan buatan (Artificial Intelligence) dan gamifikasi yang dirancang '
    'khusus untuk membantu pengguna memahami pengambilan keputusan di bidang Sumber Daya '
    'Manusia (SDM/HR) secara legal dan strategis. Aplikasi ini dikembangkan menggunakan '
    'platform Flutter dan memanfaatkan model bahasa besar (Large Language Model) '
    'Mistral AI yang dikombinasikan dengan teknologi Retrieval-Augmented Generation (RAG) '
    'berbasis Supabase Vector Database.')

body(doc,
    f'Fungsi utama {APP_NAME} adalah menyajikan simulasi kasus nyata dunia HR yang '
    'berhubungan dengan hukum ketenagakerjaan Indonesia. Pengguna diajak untuk berperan '
    'sebagai manajer SDM yang harus mengambil keputusan pada situasi-situasi kritis seperti '
    'proses rekrutmen, Pemutusan Hubungan Kerja (PHK), penanganan konflik kerja, hingga '
    'penyusunan strategi SDM jangka panjang. Setiap keputusan yang diambil akan dianalisis '
    'oleh AI dan diberikan umpan balik berupa evaluasi hukum, risiko, dampak sosial, '
    'serta rekomendasi profesional.')

body(doc,
    f'Tujuan dikembangkannya {APP_NAME} adalah untuk menjembatani kesenjangan antara '
    'teori hukum ketenagakerjaan dengan praktik nyata di lapangan. Melalui pendekatan '
    'berbasis permainan (gamifikasi) dengan tiga level kesulitan yang berbeda, aplikasi '
    'ini berusaha menciptakan pengalaman belajar yang menarik, interaktif, dan relevan '
    'dengan konteks dunia kerja Indonesia yang sesungguhnya.')

body(doc,
    f'Target pengguna {APP_NAME} adalah mahasiswa program studi Manajemen SDM, Hukum '
    'Ketenagakerjaan, dan Psikologi Industri; praktisi HR profesional yang ingin memperdalam '
    'pemahaman legal; serta para akademisi dan peneliti di bidang kebijakan ketenagakerjaan. '
    'Aplikasi ini dapat diakses melalui perangkat Android maupun iOS, sehingga dapat '
    'digunakan kapan saja dan di mana saja.')

body(doc,
    f'Secara konseptual, {APP_NAME} bekerja dengan alur sebagai berikut: pengguna '
    'membaca skenario kasus HR yang disajikan, memilih keputusan dari beberapa alternatif '
    'yang tersedia, kemudian sistem AI akan memproses keputusan tersebut menggunakan '
    'konteks hukum yang relevan dari basis data vektor. Hasil analisis mencakup penilaian '
    'kesesuaian dengan regulasi, identifikasi risiko hukum, serta rekomendasi solusi '
    'terbaik yang dilengkapi dengan penjelasan komprehensif.')

add_real_image(doc, "01_home_page", 'Gambar 1. Tampilan Utama Aplikasi', width_cm=10)
page_break(doc)

# ═══════════════════════════════════════════════════════════════
# BAB 2 – TUJUAN APLIKASI
# ═══════════════════════════════════════════════════════════════

h1(doc, 'BAB 2', 'TUJUAN APLIKASI')

h2(doc, '2.1 Tujuan Utama Aplikasi')
body(doc,
    f'Tujuan utama pengembangan {APP_NAME} adalah menciptakan media pembelajaran '
    'yang efektif, menarik, dan berbasis teknologi mutakhir untuk meningkatkan literasi '
    'hukum ketenagakerjaan di kalangan mahasiswa dan praktisi HR Indonesia. Secara '
    'spesifik, tujuan aplikasi ini meliputi:', indent=True)
numbered_list(doc, [
    'Menyediakan platform simulasi HR interaktif yang mencerminkan kasus-kasus nyata '
    'di lingkungan kerja Indonesia berdasarkan regulasi ketenagakerjaan yang berlaku.',
    'Memberikan umpan balik analisis berbasis AI secara langsung (real-time) atas setiap '
    'keputusan HR yang diambil oleh pengguna, mencakup aspek legalitas, risiko, dan dampak sosial.',
    'Mengintegrasikan pendekatan gamifikasi untuk meningkatkan motivasi dan keterlibatan '
    'pengguna dalam proses pembelajaran yang biasanya bersifat teknis dan kompleks.',
    'Memfasilitasi pembelajaran mandiri (self-directed learning) yang dapat dilakukan '
    'secara fleksibel melalui perangkat mobile kapan saja dan di mana saja.',
])

h2(doc, '2.2 Manfaat Aplikasi bagi Pengguna')
bullet_list(doc, [
    'Meningkatkan pemahaman hukum ketenagakerjaan Indonesia secara praktis dan kontekstual.',
    'Mengembangkan kemampuan pengambilan keputusan HR yang legal, etis, dan strategis.',
    'Mendapatkan umpan balik instan dari AI atas kualitas keputusan yang diambil.',
    'Mempelajari risiko hukum dan dampak sosial dari berbagai pilihan kebijakan SDM.',
    'Mempersiapkan diri untuk menghadapi situasi nyata di lingkungan kerja profesional.',
    'Mengasah kemampuan berpikir strategis melalui mode permainan yang menantang.',
])

h2(doc, '2.3 Kemampuan yang Dapat Diperoleh Pengguna')
body(doc,
    f'Melalui penggunaan {APP_NAME} secara rutin dan terstruktur, pengguna diharapkan '
    'dapat mengembangkan berbagai kompetensi, antara lain: kemampuan membaca dan '
    'menginterpretasikan peraturan perundang-undangan ketenagakerjaan, keterampilan '
    'mengidentifikasi potensi pelanggaran hukum dalam praktik HR, kemampuan merancang '
    'prosedur rekrutmen dan PHK yang sesuai dengan regulasi, serta kapasitas untuk '
    'mengelola konflik kerja secara legal dan profesional.')

h2(doc, '2.4 Dampak Penggunaan Aplikasi')
body(doc,
    f'Penggunaan {APP_NAME} secara luas diharapkan dapat berkontribusi pada peningkatan '
    'kualitas tata kelola SDM di perusahaan-perusahaan Indonesia. Pada level individu, '
    'pengguna akan memiliki kepercayaan diri lebih tinggi dalam menghadapi tantangan '
    'hukum ketenagakerjaan. Pada level organisasi, peningkatan kompetensi HR profesional '
    'dapat mengurangi risiko sengketa kerja, menekan biaya litigasi, serta menciptakan '
    'lingkungan kerja yang lebih adil dan produktif.')

page_break(doc)

# ═══════════════════════════════════════════════════════════════
# BAB 3 – SPESIFIKASI ALAT YANG DIBUTUHKAN
# ═══════════════════════════════════════════════════════════════

h1(doc, 'BAB 3', 'SPESIFIKASI ALAT YANG DIBUTUHKAN')

body(doc,
    f'Sebagai aplikasi mobile berbasis Flutter, {APP_NAME} dapat dijalankan pada perangkat '
    'smartphone Android maupun iOS. Berikut adalah tabel spesifikasi perangkat yang '
    'diperlukan agar aplikasi dapat berjalan dengan lancar dan optimal:')

spec_rows = [
    ['Sistem Operasi',      'Android 8.0 (Oreo) / iOS 13',   'Android 12+ / iOS 16+'],
    ['Processor',           'Quad-core 1.8 GHz',              'Octa-core 2.4 GHz ke atas'],
    ['RAM',                 '3 GB',                           '6 GB atau lebih'],
    ['Storage',             '500 MB ruang kosong',            '1 GB+ (untuk cache AI response)'],
    ['GPU',                 'GPU terintegrasi standar',        'GPU terintegrasi high-performance'],
    ['Versi Software',      'Flutter 3.10 / Dart 3.0',        'Flutter 3.22+ / Dart 3.4+'],
    ['Koneksi Internet',    'Broadband 4G / Wi-Fi stabil',    'Wi-Fi / 5G ≥25 Mbps'],
    ['Perangkat Pendukung', 'Smartphone layar 5" keatas',     'Tablet 8"+ atau smartphone flagship'],
]

styled_table(doc,
    headers=['Aspek', 'Spesifikasi Minimum', 'Spesifikasi Direkomendasikan'],
    rows=spec_rows,
    col_widths_cm=[4.5, 5.5, 6.0])
table_caption(doc, 'Tabel 3.1 Spesifikasi Perangkat yang Dibutuhkan untuk Menjalankan Aplikasi')

body(doc,
    'Koneksi internet yang stabil sangat penting untuk memastikan komunikasi dengan '
    'Mistral AI API dan Supabase Vector Database dapat berlangsung dengan baik. Fitur '
    'analisis AI tidak akan tersedia dalam mode offline. Disarankan untuk menggunakan '
    'aplikasi saat terhubung ke jaringan Wi-Fi berkecepatan tinggi untuk pengalaman '
    'terbaik, terutama saat memproses analisis keputusan yang melibatkan respons AI '
    'berformat Markdown yang relatif panjang.', indent=True)

page_break(doc)

# ═══════════════════════════════════════════════════════════════
# BAB 4 – UPDATE APLIKASI
# ═══════════════════════════════════════════════════════════════

h1(doc, 'BAB 4', 'UPDATE APLIKASI')

body(doc,
    f'Pembaruan (update) {APP_NAME} dilakukan secara berkala untuk menyertakan '
    'perbaikan performa, penambahan skenario HR baru, pembaruan basis data hukum '
    'ketenagakerjaan, serta peningkatan kualitas model AI. Pengguna sangat disarankan '
    'untuk selalu memperbarui aplikasi ke versi terbaru demi mendapatkan pengalaman '
    'belajar yang optimal.')

h2(doc, '4.1 Membuka Application Store')
body(doc,
    'Buka Google Play Store (Android) atau App Store (iOS) pada perangkat yang '
    'digunakan. Pastikan perangkat terhubung ke internet dan akun Google/Apple ID '
    'yang digunakan untuk mengunduh aplikasi pertama kali telah aktif. Pada kolom '
    'pencarian, ketikkan "LexImpact AI" untuk menemukan halaman aplikasi, atau '
    'langsung navigasikan ke bagian "Kelola Aplikasi & Perangkat" (Android) atau '
    '"Pembaruan Tersedia" (iOS).')

add_real_image(doc, "01_home_page", 'Gambar 4.1 Proses Membuka Store', width_cm=9)

h2(doc, '4.2 Memilih dan Menjalankan Proses Update')
body(doc,
    f'Pada halaman {APP_NAME} di application store, apabila terdapat versi terbaru '
    'yang belum terpasang, tombol "Perbarui" (Update) akan muncul menggantikan tombol '
    '"Buka" (Open). Klik tombol "Perbarui" untuk memulai proses pengunduhan dan '
    'pemasangan pembaruan secara otomatis. Pastikan perangkat memiliki ruang '
    'penyimpanan yang cukup dan baterai terisi minimal 30% sebelum memulai proses '
    'pembaruan.')

add_real_image(doc, "04_about_page", 'Gambar 4.2 Proses Update Aplikasi', width_cm=9)

h2(doc, '4.3 Memastikan Aplikasi Berhasil Diperbarui')
body(doc,
    'Setelah proses pembaruan selesai, buka aplikasi dan navigasikan ke menu '
    '"Informasi" (Info) yang terletak di bagian bawah layar. Verifikasi nomor '
    'versi yang ditampilkan sudah sesuai dengan versi terbaru. Apabila terdapat '
    'fitur atau skenario baru, sistem akan menampilkan notifikasi "Yang Baru" '
    'secara otomatis saat pertama kali membuka aplikasi setelah pembaruan.')

add_real_image(doc, "04_about_page", 'Gambar 4.3 Aplikasi Berhasil Diperbarui', width_cm=9)

page_break(doc)

# ═══════════════════════════════════════════════════════════════
# BAB 5 – PEMASANGAN APLIKASI
# ═══════════════════════════════════════════════════════════════

h1(doc, 'BAB 5', 'PEMASANGAN APLIKASI')

body(doc,
    f'Bagian ini menjelaskan tahapan pemasangan (instalasi) {APP_NAME} pada perangkat '
    'Android maupun iOS dari awal hingga aplikasi siap digunakan. Ikuti setiap langkah '
    'dengan seksama untuk memastikan proses instalasi berjalan lancar.')

h2(doc, '5.1 Persiapan Perangkat')
body(doc,
    'Sebelum memulai proses instalasi, pastikan perangkat memenuhi spesifikasi minimum '
    'yang tercantum pada Bab 3. Periksa koneksi internet dan pastikan perangkat '
    'terhubung ke jaringan yang stabil. Pastikan juga ruang penyimpanan yang tersedia '
    'mencukupi (minimal 500 MB). Untuk perangkat Android, pastikan fitur instalasi '
    'dari sumber tidak dikenal (jika menggunakan APK langsung) telah diaktifkan '
    'melalui menu Pengaturan > Keamanan > Sumber Tidak Dikenal.')

h2(doc, '5.2 Mengunduh Aplikasi')
body(doc,
    f'Buka Google Play Store (Android) atau App Store (iOS) pada perangkat Anda. '
    'Pada kolom pencarian, ketikkan "LexImpact AI" dan tekan tombol cari. Pilih '
    f'aplikasi {APP_NAME} dari hasil pencarian yang muncul, kemudian klik tombol '
    '"Pasang" (Android) atau "Dapatkan" (iOS). Tunggu hingga proses pengunduhan '
    'selesai sepenuhnya. Durasi pengunduhan bergantung pada kecepatan koneksi internet '
    'yang digunakan.')

add_real_image(doc, "01_home_page", 'Gambar 5.1 File Instalasi Aplikasi', width_cm=9)

h2(doc, '5.3 Proses Instalasi')
body(doc,
    'Setelah proses pengunduhan selesai, instalasi akan berjalan secara otomatis '
    'pada sebagian besar perangkat. Pada perangkat Android, sistem mungkin meminta '
    'konfirmasi izin akses aplikasi (seperti akses internet, kamera untuk AR, dan '
    'penyimpanan). Berikan izin yang diperlukan dengan mengetuk "Izinkan" atau "Allow" '
    'pada setiap dialog konfirmasi. Proses instalasi biasanya berlangsung 1–3 menit '
    'tergantung performa perangkat.')
numbered_list(doc, [
    'Tunggu notifikasi "Terpasang" (Android) atau "Siap Dibuka" (iOS) muncul.',
    'Ikon aplikasi LexImpact AI akan secara otomatis muncul di layar beranda atau laci aplikasi.',
    'Berikan semua izin akses yang diminta untuk memastikan seluruh fitur berfungsi optimal.',
    'Perangkat siap menjalankan aplikasi.',
])

add_real_image(doc, "04_about_page", 'Gambar 5.2 Proses Instalasi', width_cm=9)

h2(doc, '5.4 Membuka Aplikasi Pertama Kali')
body(doc,
    f'Ketuk ikon {APP_NAME} pada layar beranda perangkat. Pada peluncuran pertama, '
    'aplikasi akan menampilkan layar sambutan (splash screen) dan melakukan inisialisasi '
    'koneksi ke server Mistral AI dan Supabase. Proses ini berlangsung sekitar 5–10 detik '
    'tergantung kecepatan internet. Setelah inisialisasi selesai, pengguna akan '
    'diarahkan ke halaman Home utama aplikasi.')

add_real_image(doc, "01_home_page", 'Gambar 5.3 Tampilan Awal Setelah Instalasi', width_cm=9)

page_break(doc)

# ═══════════════════════════════════════════════════════════════
# BAB 6 – MENU APLIKASI
# ═══════════════════════════════════════════════════════════════

h1(doc, 'BAB 6', 'MENU APLIKASI')

body(doc,
    f'{APP_NAME} terdiri dari enam menu utama yang dapat diakses melalui bilah '
    'navigasi bawah (bottom navigation bar) dan kartu menu di halaman Home. '
    'Berikut adalah penjelasan detail setiap menu beserta fungsi dan cara penggunaannya.')

# ── A. Menu Home ──
h2(doc, 'A. Menu Home (Beranda)')
h3(doc, 'Fungsi Halaman Utama')
body(doc,
    'Menu Home merupakan halaman pertama yang tampil setelah pengguna berhasil '
    'masuk ke dalam aplikasi. Halaman ini berfungsi sebagai pusat navigasi '
    'utama yang menampilkan ringkasan konten dan menyediakan akses cepat ke '
    'seluruh fitur aplikasi.', indent=False)

h3(doc, 'Tombol dan Elemen yang Tersedia')
bullet_list(doc, [
    'Kartu Menu "Simulasi HR" – Akses langsung ke fitur simulasi interaktif.',
    'Kartu Menu "Materi" – Membuka perpustakaan materi pembelajaran.',
    'Kartu Menu "Video" – Mengakses konten video pembelajaran.',
    'Kartu Menu "Kuis" – Memulai sesi evaluasi pengetahuan.',
    'Tombol "Tentang Aplikasi" – Membuka halaman informasi aplikasi.',
    'Bilah navigasi bawah – Navigasi cepat antar halaman utama.',
])

h3(doc, 'Cara Penggunaan')
body(doc,
    'Pengguna dapat mengetuk salah satu kartu menu yang tersedia untuk langsung '
    'mengakses fitur yang diinginkan, atau menggunakan bilah navigasi bawah '
    'untuk berpindah halaman. Animasi transisi halaman yang halus akan memandu '
    'pengguna perpindahan antar menu.', indent=False)

add_real_image(doc, "01_home_page", 'Gambar 6.1 Tampilan Menu Home', width_cm=10)

# ── B. Menu Materi ──
h2(doc, 'B. Menu Materi')
h3(doc, 'Fungsi Menu Materi')
body(doc,
    'Menu Materi menyediakan akses ke seluruh konten pembelajaran teoritis yang '
    'berkaitan dengan hukum ketenagakerjaan Indonesia. Materi disajikan dalam '
    'format yang interaktif dan mudah dibaca, mencakup ringkasan undang-undang, '
    'studi kasus, dan panduan praktis bagi HR profesional.', indent=False)

h3(doc, 'Cara Memilih Materi')
numbered_list(doc, [
    'Ketuk menu "Materi" pada bilah navigasi bawah atau kartu di halaman Home.',
    'Pilih kategori topik yang diinginkan (misalnya: Rekrutmen, PHK, Konflik Kerja, Strategi SDM).',
    'Ketuk judul materi untuk membuka konten selengkapnya.',
    'Gunakan tombol navigasi kanan-kiri untuk berpindah antar sub-topik.',
])

h3(doc, 'Tampilan Informasi')
body(doc,
    'Konten materi ditampilkan dalam format teks berformat (Markdown) yang rapi, '
    'dilengkapi dengan penekanan kata kunci, tabel perbandingan regulasi, dan '
    'contoh kasus nyata. Pengguna dapat menggunakan fungsi scroll untuk membaca '
    'materi secara keseluruhan.', indent=False)

add_real_image(doc, "02_materi_page", 'Gambar 6.2 Tampilan Menu Materi', width_cm=10)

# ── C. Menu Video ──
h2(doc, 'C. Menu Video')
h3(doc, 'Fungsi Video Pembelajaran')
body(doc,
    'Menu Video menyediakan koleksi video pembelajaran yang disimpan secara lokal '
    '(local file) di dalam paket aplikasi. Video ini mencakup penjelasan konsep '
    'hukum ketenagakerjaan, demonstrasi studi kasus, dan tutorial penggunaan '
    'fitur-fitur aplikasi.', indent=False)

h3(doc, 'Cara Menjalankan Video')
numbered_list(doc, [
    'Ketuk menu "Video" pada bilah navigasi bawah.',
    'Pilih judul video dari daftar yang tersedia.',
    'Ketuk thumbnail atau tombol putar (▶) untuk memulai pemutaran.',
    'Untuk layar penuh, putar perangkat ke mode landscape atau ketuk tombol layar penuh.',
])

h3(doc, 'Kontrol Video yang Tersedia')
bullet_list(doc, [
    'Tombol Play/Pause – Memulai atau menjeda pemutaran video.',
    'Bilah progres – Menampilkan posisi pemutaran; dapat digeser untuk lompat ke menit tertentu.',
    'Tombol Mute – Mematikan atau mengaktifkan suara.',
    'Tombol Layar Penuh – Mengubah tampilan ke mode landscape fullscreen.',
    'Tombol Kembali – Kembali ke daftar video tanpa menutup aplikasi.',
])

add_real_image(doc, "02_materi_page", 'Gambar 6.3 Tampilan Menu Video', width_cm=10)

# ── D. Menu Simulasi ──
h2(doc, 'D. Menu Simulasi')
h3(doc, 'Fungsi Simulasi HR Interaktif')
body(doc,
    'Menu Simulasi adalah fitur inti dari aplikasi ini. Terdapat tiga level simulasi '
    'dengan tingkat kompleksitas yang berbeda: Level 1 (Rekrutmen) berfokus pada '
    'isu diskriminasi dan proses hiring; Level 2 (Keputusan HR) mencakup skenario '
    'PHK dan konflik kerja; serta Level 3 (HR Strategis) berupa game drag-and-drop '
    'penyusunan langkah strategi SDM.', indent=False)

h3(doc, 'Interaksi Pengguna')
body(doc,
    'Pada setiap skenario, pengguna membaca narasi kasus yang disajikan, kemudian '
    'memilih salah satu dari beberapa alternatif keputusan yang tersedia. Pada '
    'Level 3, interaksi dilakukan melalui mekanisme drag-and-drop untuk menyusun '
    'urutan langkah strategi yang dianggap paling tepat.', indent=False)

h3(doc, 'Respons Sistem AI')
body(doc,
    'Setelah pengguna mengonfirmasi pilihan keputusan, sistem akan mengirimkan '
    'prompt ke Mistral AI API yang dikombinasikan dengan konteks hukum relevan '
    'dari Supabase Vector DB (RAG). Respons AI berupa evaluasi keputusan, '
    'identifikasi risiko hukum, proyeksi dampak sosial, dan rekomendasi solusi '
    'profesional yang ditampilkan dalam format Markdown yang terstruktur.', indent=False)

add_real_image(doc, "05_simulation_page", 'Gambar 6.4 Tampilan Menu Simulasi', width_cm=10)

# ── E. Menu Kuis ──
h2(doc, 'E. Menu Kuis')
h3(doc, 'Mekanisme Pengerjaan Soal')
body(doc,
    'Menu Kuis menyediakan serangkaian pertanyaan pilihan ganda dan isian singkat '
    'yang berkaitan dengan materi hukum ketenagakerjaan yang telah dipelajari. '
    'Setiap sesi kuis terdiri dari 10 soal yang dipilih secara acak dari bank soal '
    'yang tersedia. Pengguna diberikan waktu terbatas untuk menjawab setiap soal.', indent=False)

h3(doc, 'Sistem Penilaian')
body(doc,
    'Setiap jawaban benar mendapatkan nilai 10 poin, sehingga nilai maksimum '
    'per sesi adalah 100. Kategori nilai: Sangat Baik (85–100), Baik (70–84), '
    'Cukup (55–69), dan Perlu Peningkatan (0–54). Sistem scoring akan diintegrasikan '
    'dengan fitur XP dan leaderboard pada versi mendatang.', indent=False)

h3(doc, 'Hasil Kuis')
body(doc,
    'Setelah menyelesaikan seluruh soal, aplikasi menampilkan halaman hasil kuis '
    'yang mencakup: total nilai yang diperoleh, jumlah jawaban benar dan salah, '
    'pembahasan singkat untuk setiap soal, serta rekomendasi materi yang perlu '
    'dipelajari ulang berdasarkan soal yang dijawab salah.', indent=False)

add_real_image(doc, "03_quiz_page", 'Gambar 6.5 Tampilan Menu Kuis', width_cm=10)

# ── F. Menu Informasi ──
h2(doc, 'F. Menu Informasi')
body(doc,
    'Menu Informasi menampilkan detail lengkap mengenai aplikasi, termasuk identitas '
    'developer, versi aplikasi yang terpasang, teknologi yang digunakan, kebijakan '
    'privasi, serta ketentuan penggunaan (Terms of Service). Menu ini juga menyediakan '
    'tautan menuju saluran dukungan pengguna dan formulir pelaporan masalah (bug report).')

bullet_list(doc, [
    f'Nama Aplikasi   : {APP_NAME} – Legal Experience for HR Decision Impact',
    f'Developer       : {DEVELOPER} ({DEVELOPER_TITLE})',
    f'Versi Terpasang : v{APP_VERSION}',
    'Platform        : Flutter (Android & iOS)',
    'AI Engine       : Mistral AI + RAG (Supabase Vector DB)',
    'Kontak Dukungan : support@leximpactai.id',
    'Lisensi         : Proprietary – Hak Cipta Dilindungi',
])

add_real_image(doc, "04_about_page", 'Gambar 6.6 Tampilan Menu Informasi', width_cm=10)

page_break(doc)

# ═══════════════════════════════════════════════════════════════
# BAB 7 – INFORMASI PENGGUNAAN PERANGKAT
# ═══════════════════════════════════════════════════════════════

h1(doc, 'BAB 7', 'INFORMASI PENGGUNAAN PERANGKAT')

body(doc,
    f'{APP_NAME} dirancang sebagai aplikasi mobile yang dioperasikan melalui perangkat '
    'smartphone atau tablet. Bagian ini menjelaskan komponen perangkat dan antarmuka '
    'yang digunakan untuk mengoperasikan aplikasi secara optimal.')

h2(doc, '1. Nama Bagian Perangkat')
body(doc,
    'Perangkat utama yang digunakan adalah smartphone Android atau iPhone (iOS). '
    'Komponen utama yang berinteraksi dengan aplikasi meliputi:')
numbered_list(doc, [
    'Layar Sentuh (Touchscreen) – Digunakan sebagai antarmuka input utama untuk mengetuk '
    'tombol, menggeser (swipe), dan melakukan interaksi drag-and-drop pada fitur Game Mode.',
    'Speaker / Earphone – Digunakan untuk mendengarkan audio pada konten video pembelajaran.',
    'Kamera (opsional) – Disiapkan untuk fitur Augmented Reality (AR) pada versi mendatang.',
    'Koneksi Internet (Wi-Fi / Mobile Data) – Diperlukan untuk komunikasi dengan AI API '
    'dan Supabase Database secara real-time.',
    'Penyimpanan Internal – Digunakan untuk menyimpan konten video lokal dan cache respons AI.',
])

h2(doc, '2. Tombol Kontrol')

ctrl_rows = [
    ['Bottom Navigation Bar', 'Navigasi utama antar halaman',       'Home, Materi, Video, Kuis, Info'],
    ['Tombol Kembali (←)',    'Kembali ke halaman sebelumnya',      'Riwayat navigasi tersimpan (GoRouter)'],
    ['Kartu Menu (Card)',      'Akses cepat ke fitur utama',         'Terdapat di halaman Home'],
    ['Tombol Konfirmasi',     'Mengonfirmasi pilihan keputusan',    'Aktif setelah pengguna memilih opsi'],
    ['Tombol Drag & Drop',    'Menyusun urutan strategi (Level 3)', 'Hanya di Mode Game Level 3'],
    ['Tombol Kirim Kuis',     'Mengirim jawaban kuis',              'Aktif setelah semua soal dijawab'],
]

styled_table(doc,
    headers=['Kontrol / Tombol', 'Fungsi', 'Keterangan'],
    rows=ctrl_rows,
    col_widths_cm=[4.5, 5.0, 5.5])
table_caption(doc, 'Tabel 7.1 Daftar Tombol Kontrol Antarmuka dan Fungsinya')

h2(doc, '3. Cara Penggunaan Perangkat')
numbered_list(doc, [
    'Pastikan kecerahan layar cukup tinggi agar teks dan elemen UI dapat dibaca dengan jelas.',
    'Gunakan mode potret (portrait) untuk membaca materi dan mengerjakan kuis; '
    'putar ke mode landscape untuk menonton video secara fullscreen.',
    'Gunakan earphone untuk pengalaman audio yang lebih baik saat menonton video pembelajaran.',
    'Pastikan koneksi internet stabil sebelum memulai sesi simulasi HR untuk menghindari '
    'gangguan saat AI sedang memproses respons.',
    'Hindari beralih ke aplikasi lain saat AI sedang memproses untuk mencegah '
    'timeout pada koneksi API.',
])

add_real_image(doc, "01_home_page", 'Gambar 7.1 Perangkat Pendukung', width_cm=10)

page_break(doc)

# ═══════════════════════════════════════════════════════════════
# BAB 8 – TATA CARA PENGGUNAAN APLIKASI
# ═══════════════════════════════════════════════════════════════

h1(doc, 'BAB 8', 'TATA CARA PENGGUNAAN APLIKASI')

body(doc,
    f'Bab ini memberikan panduan langkah demi langkah yang komprehensif dalam '
    f'menggunakan seluruh fitur utama {APP_NAME}. Panduan ini disusun secara berurutan '
    'agar pengguna dapat mengoperasikan aplikasi secara mandiri sejak pertama kali '
    'digunakan hingga mahir memanfaatkan seluruh fitur yang tersedia.')

# ── A. Memulai Aplikasi ──
h2(doc, 'A. Memulai Aplikasi')
body(doc,
    f'Untuk membuka {APP_NAME}, ketuk ikon aplikasi pada layar beranda perangkat. '
    'Aplikasi akan menampilkan splash screen beranimasi selama 3–5 detik sambil '
    'melakukan inisialisasi koneksi ke server AI. Setelah proses inisialisasi '
    'selesai, pengguna langsung diarahkan ke halaman Home utama tanpa memerlukan '
    'proses login.')
body(doc,
    'Halaman Home menampilkan enam kartu menu utama yang masing-masing mewakili '
    'fitur utama aplikasi. Pengguna dapat langsung memilih fitur yang ingin '
    'diakses dengan mengetuk kartu yang sesuai, atau menggunakan bilah navigasi '
    'yang terletak di bagian bawah layar.')

add_real_image(doc, "01_home_page", 'Gambar 8.1 Tampilan Awal Aplikasi', width_cm=10)

# ── B. Navigasi Menu ──
h2(doc, 'B. Navigasi Menu')
body(doc,
    'Navigasi dalam aplikasi dilakukan melalui dua mekanisme utama: bilah navigasi '
    'bawah (bottom navigation bar) yang selalu terlihat di setiap halaman, dan '
    'kartu menu interaktif di halaman Home. Sistem routing dikelola menggunakan '
    'library GoRouter yang memastikan navigasi berjalan mulus dan konsisten.')
bullet_list(doc, [
    'Ketuk ikon pada bilah navigasi bawah untuk berpindah ke halaman utama yang diinginkan.',
    'Tombol kembali (←) di pojok kiri atas membawa pengguna ke halaman sebelumnya.',
    'Animasi transisi halaman menggunakan Flutter Animate untuk pengalaman perpindahan yang halus.',
    'Pada Level 3 Simulasi, tombol "Selesai" menutup mode game dan kembali ke menu Simulasi.',
    'Gunakan gestur swipe dari tepi kiri layar (iOS) untuk navigasi kembali yang cepat.',
])

add_real_image(doc, "01_home_page", 'Gambar 8.2 Navigasi Menu', width_cm=10)

# ── C. Menggunakan Fitur Utama ──
h2(doc, 'C. Menggunakan Fitur Utama')

h3(doc, 'Langkah Penggunaan:')
numbered_list(doc, [
    'Pengguna memilih menu "Simulasi" dari halaman Home atau bilah navigasi bawah.',
    'Sistem menampilkan halaman pemilihan level simulasi: Level 1 (Rekrutmen), '
    'Level 2 (Keputusan HR), atau Level 3 (HR Strategis / Game Mode).',
    'Pengguna memilih level yang diinginkan dengan mengetuk kartu level yang sesuai.',
    'Sistem menampilkan skenario kasus HR beserta narasi situasi yang harus dihadapi.',
    'Pengguna membaca narasi kasus dengan seksama dan memilih salah satu dari '
    'beberapa alternatif keputusan yang tersedia.',
    'Untuk Level 3, pengguna melakukan drag-and-drop untuk menyusun urutan '
    'langkah strategi yang dianggap paling tepat.',
    'Pengguna mengetuk tombol "Konfirmasi Keputusan" setelah yakin dengan pilihan yang dibuat.',
    'Sistem mengirimkan keputusan pengguna ke Mistral AI API melalui RAG pipeline '
    'dan menampilkan indikator loading selama proses berlangsung.',
    'Sistem memberikan respons AI berupa evaluasi keputusan, analisis risiko hukum, '
    'dampak sosial, dan rekomendasi solusi profesional dalam format Markdown terstruktur.',
    'Pengguna dapat mengetuk "Skenario Berikutnya" untuk melanjutkan atau "Kembali" '
    'untuk memilih level lain.',
])

add_real_image(doc, "05_simulation_page", 'Gambar 8.3 Penggunaan Fitur Utama', width_cm=10)

h2(doc, 'D. Menggunakan Fitur Materi Pembelajaran')
numbered_list(doc, [
    'Pengguna memilih menu "Materi" dari halaman Home atau bilah navigasi.',
    'Sistem menampilkan daftar topik materi yang dikelompokkan berdasarkan kategori.',
    'Pengguna memilih topik materi yang ingin dipelajari.',
    'Sistem menampilkan konten materi dalam format teks berformat (Markdown) yang rapi '
    'dengan penekanan pada istilah-istilah hukum penting.',
    'Pengguna membaca materi dan dapat melakukan scroll vertikal untuk membaca selengkapnya.',
    'Setelah selesai, pengguna mengetuk tombol "Kembali" untuk memilih topik lain '
    'atau langsung mengakses Kuis untuk menguji pemahaman.',
])

h2(doc, 'E. Mengerjakan Kuis Evaluasi')
numbered_list(doc, [
    'Pengguna memilih menu "Kuis" dari halaman Home atau bilah navigasi.',
    'Sistem menampilkan halaman pilihan kategori kuis sesuai materi yang telah dipelajari.',
    'Pengguna memilih kategori kuis dan mengetuk tombol "Mulai Kuis".',
    'Sistem menampilkan soal pertama dari 10 soal yang tersedia secara acak.',
    'Pengguna membaca soal dan memilih jawaban yang dianggap paling tepat.',
    'Pengguna mengetuk "Soal Berikutnya" untuk melanjutkan ke soal berikutnya.',
    'Setelah soal ke-10 dijawab, pengguna mengetuk "Kirim Jawaban" untuk mendapatkan hasil.',
    'Sistem menampilkan halaman hasil kuis dengan nilai, pembahasan jawaban, '
    'dan rekomendasi materi yang perlu dipelajari ulang.',
])

page_break(doc)

# ═══════════════════════════════════════════════════════════════
# BAB 9 – TENTANG APLIKASI
# ═══════════════════════════════════════════════════════════════

h1(doc, 'BAB 9', 'TENTANG APLIKASI')

about_rows = [
    ['Nama Aplikasi',         f'{APP_NAME} – Legal Experience for HR Decision Impact'],
    ['Versi Aplikasi',        f'v{APP_VERSION}'],
    ['Platform',              'Android & iOS (Flutter/Dart)'],
    ['AI Engine',             'Mistral AI (LLM + Embedding)'],
    ['Database',              'Supabase (PostgreSQL + Vector DB)'],
    ['Navigation',            'GoRouter'],
    ['Animasi UI',            'Flutter Animate'],
    ['Developer',             f'{DEVELOPER} – {DEVELOPER_TITLE}'],
    ['Tahun Pengembangan',    YEAR],
    ['Hak Cipta',             f'© {YEAR} {DEVELOPER}. All Rights Reserved.'],
    ['Kontak',                'support@leximpactai.id'],
]

styled_table(doc,
    headers=['Atribut', 'Keterangan'],
    rows=about_rows,
    col_widths_cm=[5.0, 10.0])
table_caption(doc, 'Tabel 9.1 Informasi Lengkap Aplikasi LexImpact AI')

h2(doc, '9.1 Tujuan Pengembangan')
body(doc,
    f'{APP_NAME} dikembangkan sebagai bagian dari upaya peningkatan literasi hukum '
    'ketenagakerjaan di Indonesia melalui pemanfaatan teknologi kecerdasan buatan '
    'dan pendekatan gamifikasi yang inovatif. Aplikasi ini lahir dari kesadaran bahwa '
    'banyak mahasiswa dan praktisi HR yang memiliki keterbatasan dalam memahami '
    'implikasi hukum dari keputusan-keputusan yang diambil di lingkungan kerja.',
    indent=True)

body(doc,
    'Dengan mengintegrasikan Mistral AI sebagai mesin analisis dan Supabase Vector '
    'Database sebagai repositori pengetahuan hukum (RAG), aplikasi ini mampu '
    'memberikan umpan balik yang kontekstual, akurat, dan relevan dengan kondisi '
    'regulasi ketenagakerjaan Indonesia terkini. Pendekatan berbasis simulasi tiga '
    'level memastikan bahwa pengguna dapat belajar secara progresif sesuai tingkat '
    'pemahaman yang dimiliki.',
    indent=True)

h2(doc, '9.2 Hak Cipta dan Ketentuan Penggunaan')
body(doc,
    f'© {YEAR} {DEVELOPER}. Seluruh hak cipta dilindungi undang-undang. '
    f'Aplikasi {APP_NAME} beserta seluruh konten, skenario simulasi, materi '
    'pembelajaran, dan sistem penilaian yang terdapat di dalamnya merupakan '
    'kekayaan intelektual milik pengembang. Dilarang keras menggandakan, '
    'mendistribusikan ulang, atau memodifikasi aplikasi ini dalam bentuk apa pun '
    'tanpa izin tertulis dari pemilik hak cipta.',
    indent=True)

body(doc,
    'Penggunaan aplikasi ini tunduk pada Perjanjian Lisensi Pengguna Akhir '
    '(End User License Agreement/EULA) yang dapat dibaca selengkapnya melalui '
    'menu Informasi di dalam aplikasi. Dengan menggunakan aplikasi ini, pengguna '
    'dianggap telah membaca, memahami, dan menyetujui seluruh ketentuan yang '
    'berlaku.',
    indent=True)

h2(doc, '9.3 Roadmap Pengembangan')
body(doc,
    f'Tim pengembang berkomitmen untuk terus mengembangkan {APP_NAME} dengan '
    'menambahkan fitur-fitur baru secara berkala. Rencana pengembangan ke depan '
    'meliputi:')
bullet_list(doc, [
    'Sistem skor & XP (Experience Points) untuk melacak perkembangan belajar.',
    'Leaderboard kompetitif antar pengguna.',
    'Penyimpanan progres pengguna di cloud (Cloud Sync via Supabase).',
    'Dukungan multibahasa (Bahasa Indonesia & English).',
    'Fitur Augmented Reality (AR) untuk visualisasi kasus HR yang lebih imersif.',
    'Modul skenario baru: Keselamatan Kerja (K3), BPJS, dan Perjanjian Kerja.',
    'Dashboard analitik bagi pengajar untuk memantau progres mahasiswa.',
])

h2(doc, '9.4 Referensi Pengembangan')
refs = [
    f'Devlin, J., Chang, M. W., Lee, K., & Toutanova, K. (2019). BERT: Pre-training of '
    'Deep Bidirectional Transformers for Language Understanding. NAACL-HLT 2019, 4171–4186.',

    f'Flutter Development Team. (2024). Flutter Documentation: Building Beautiful Native '
    'Apps. Google LLC. https://flutter.dev/docs',

    f'Kementerian Ketenagakerjaan RI. (2023). Undang-Undang No. 13 Tahun 2003 tentang '
    'Ketenagakerjaan sebagaimana telah diubah dengan UU No. 11 Tahun 2020 tentang Cipta Kerja. '
    'Jakarta: Kemnaker.',

    f'Lewis, P., et al. (2020). Retrieval-Augmented Generation for Knowledge-Intensive NLP '
    'Tasks. Advances in Neural Information Processing Systems (NeurIPS 2020).',

    f'Mistral AI. (2024). Mistral AI API Documentation. https://docs.mistral.ai/',

    f'Supabase. (2024). Supabase Vector: pgvector Support for Semantic Search. '
    'https://supabase.com/docs/guides/ai',

    f'Deterding, S., Dixon, D., Khaled, R., & Nacke, L. (2011). From Game Design Elements '
    'to Gamefulness: Defining Gamification. MindTrek 2011, 9–15.',

    f'Peraturan Pemerintah No. 35 Tahun 2021 tentang Perjanjian Kerja Waktu Tertentu, '
    'Alih Daya, Waktu Kerja dan Istirahat, dan Pemutusan Hubungan Kerja. Jakarta: Sekretariat '
    'Negara Republik Indonesia.',
]

for ref in refs:
    rp = doc.add_paragraph()
    rp.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    rp.paragraph_format.left_indent         = Cm(1.25)
    rp.paragraph_format.first_line_indent   = Cm(-1.25)
    rp.paragraph_format.space_before        = Pt(0)
    rp.paragraph_format.space_after         = Pt(6)
    rp.paragraph_format.line_spacing        = Pt(16)
    add_run(rp, ref, size=11)

# ═══════════════════════════════════════════════════════════════
# SIMPAN
# ═══════════════════════════════════════════════════════════════

doc.save(OUTPUT_FILE)
print(f"[BERHASIL] Dokumen disimpan di: {OUTPUT_FILE}")
