from datetime import datetime
from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Pt, RGBColor


def add_field(paragraph, field_code):
    run = paragraph.add_run()
    fld_char_begin = OxmlElement('w:fldChar')
    fld_char_begin.set(qn('w:fldCharType'), 'begin')

    instr_text = OxmlElement('w:instrText')
    instr_text.set(qn('xml:space'), 'preserve')
    instr_text.text = field_code

    fld_char_separate = OxmlElement('w:fldChar')
    fld_char_separate.set(qn('w:fldCharType'), 'separate')

    fld_char_end = OxmlElement('w:fldChar')
    fld_char_end.set(qn('w:fldCharType'), 'end')

    run._r.append(fld_char_begin)
    run._r.append(instr_text)
    run._r.append(fld_char_separate)
    run._r.append(fld_char_end)


def set_cell_shading(cell, fill='E9EEF8'):
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement('w:shd')
    shd.set(qn('w:val'), 'clear')
    shd.set(qn('w:color'), 'auto')
    shd.set(qn('w:fill'), fill)
    tc_pr.append(shd)


def style_document(doc):
    normal = doc.styles['Normal']
    normal.font.name = 'Times New Roman'
    normal.font.size = Pt(12)
    normal.paragraph_format.space_after = Pt(8)
    normal.paragraph_format.line_spacing = 1.15

    h1 = doc.styles['Heading 1']
    h1.font.name = 'Times New Roman'
    h1.font.size = Pt(16)
    h1.font.bold = True
    h1.font.color.rgb = RGBColor(0x12, 0x2A, 0x52)
    h1.paragraph_format.space_before = Pt(18)
    h1.paragraph_format.space_after = Pt(10)

    h2 = doc.styles['Heading 2']
    h2.font.name = 'Times New Roman'
    h2.font.size = Pt(14)
    h2.font.bold = True
    h2.font.color.rgb = RGBColor(0x1E, 0x3A, 0x5F)
    h2.paragraph_format.space_before = Pt(12)
    h2.paragraph_format.space_after = Pt(8)

    h3 = doc.styles['Heading 3']
    h3.font.name = 'Times New Roman'
    h3.font.size = Pt(12)
    h3.font.bold = True
    h3.paragraph_format.space_before = Pt(8)
    h3.paragraph_format.space_after = Pt(6)

    caption = doc.styles['Caption']
    caption.font.name = 'Times New Roman'
    caption.font.size = Pt(11)
    caption.font.italic = True


def set_margins(doc):
    for section in doc.sections:
        section.top_margin = Cm(3)
        section.bottom_margin = Cm(3)
        section.left_margin = Cm(4)
        section.right_margin = Cm(3)


def add_page_number_footer(doc):
    for section in doc.sections:
        footer = section.footer
        p = footer.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.add_run('Halaman ')
        add_field(p, 'PAGE')


def add_cover(doc, app_name, version, developer, year):
    section = doc.sections[0]
    section.different_first_page_header_footer = True

    table = doc.add_table(rows=1, cols=1)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False
    table.columns[0].width = Cm(13)
    cell = table.cell(0, 0)
    set_cell_shading(cell, 'DDE8F5')
    cell_p = cell.paragraphs[0]
    cell_p.alignment = WD_ALIGN_PARAGRAPH.CENTER

    title = cell_p.add_run('PANDUAN PENGGUNAAN APLIKASI\n')
    title.bold = True
    title.font.size = Pt(22)
    title.font.name = 'Times New Roman'
    title.font.color.rgb = RGBColor(0x0F, 0x2A, 0x4A)

    app = cell_p.add_run(f'{app_name}\n\n')
    app.bold = True
    app.font.size = Pt(20)
    app.font.name = 'Times New Roman'

    meta = cell_p.add_run(
        f'Nama Aplikasi : {app_name}\n'
        f'Versi Aplikasi : {version}\n'
        f'Developer      : {developer}\n'
        f'Tahun Pembuatan: {year}'
    )
    meta.font.size = Pt(12)

    doc.add_paragraph('\n')
    tagline = doc.add_paragraph('Dokumen ini disusun sebagai panduan resmi penggunaan aplikasi untuk kebutuhan akademik, penelitian, dan publikasi.')
    tagline.alignment = WD_ALIGN_PARAGRAPH.CENTER


def add_toc(doc):
    doc.add_page_break()
    doc.add_heading('DAFTAR ISI', level=1)
    p = doc.add_paragraph()
    add_field(p, 'TOC \\o "1-3" \\h \\z \\u')
    doc.add_paragraph('Catatan: klik kanan pada daftar isi lalu pilih Update Field untuk memperbarui nomor halaman.').italic = True


def add_image_placeholder(doc, chapter_label, title_text, seq_name, width_cm=12.5, height_cm=7.0):
    t = doc.add_table(rows=1, cols=1)
    t.alignment = WD_TABLE_ALIGNMENT.CENTER
    t.autofit = False
    cell = t.cell(0, 0)
    cell.width = Cm(width_cm)
    cell_p = cell.paragraphs[0]
    cell_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = cell_p.add_run('[PLACEHOLDER SCREENSHOT/GAMBAR]')
    run.bold = True
    run.font.size = Pt(11)

    row = t.rows[0]
    row.height = Cm(height_cm)

    c = doc.add_paragraph(style='Caption')
    c.add_run(f'Gambar {chapter_label}.')
    add_field(c, f'SEQ {seq_name} \\* ARABIC')
    c.add_run(f' {title_text}')
    c.alignment = WD_ALIGN_PARAGRAPH.CENTER


def add_bab_1(doc, app_name):
    doc.add_page_break()
    doc.add_heading('BAB 1 INFORMASI UMUM APLIKASI', level=1)

    doc.add_paragraph(
        f'{app_name} merupakan aplikasi pembelajaran berbasis simulasi yang dirancang untuk membantu pengguna memahami pengambilan keputusan Human Resources (HR) secara legal, strategis, dan bertanggung jawab. '
        'Aplikasi ini mengintegrasikan pendekatan pembelajaran interaktif, evaluasi berbasis kecerdasan buatan, serta materi pendukung yang sistematis.'
    )
    doc.add_paragraph(
        'Fungsi utama aplikasi adalah memfasilitasi proses belajar melalui studi kasus, latihan pengambilan keputusan, kuis evaluatif, dan umpan balik analitis. '
        'Dengan demikian, pengguna dapat mempraktikkan kemampuan analitis sekaligus memahami risiko hukum maupun dampak sosial dari setiap keputusan yang diambil.'
    )
    doc.add_paragraph(
        'Aplikasi ini dikembangkan untuk mendukung kebutuhan pembelajaran akademik dan pelatihan profesional, khususnya pada bidang manajemen sumber daya manusia dan hukum ketenagakerjaan. '
        'Target pengguna mencakup mahasiswa, tenaga pendidik, praktisi HR, serta pihak lain yang membutuhkan media pembelajaran terapan dalam konteks pengambilan keputusan organisasi.'
    )
    doc.add_paragraph(
        'Secara konseptual, aplikasi menggabungkan model pembelajaran berbasis masalah (problem-based learning), gamifikasi, dan refleksi berbantuan AI. '
        'Kombinasi tersebut memberikan pengalaman belajar yang terstruktur, adaptif, dan relevan dengan dinamika kebutuhan dunia kerja kontemporer.'
    )

    add_image_placeholder(doc, '1', 'Tampilan Utama Aplikasi', 'Gambar1')


def add_bab_2(doc):
    doc.add_heading('BAB 2 TUJUAN APLIKASI', level=1)
    items = [
        'Tujuan utama aplikasi adalah menyediakan media pembelajaran keputusan HR yang legal, terukur, dan kontekstual.',
        'Aplikasi memberikan manfaat berupa peningkatan pemahaman terhadap prosedur, etika, dan risiko dalam pengambilan keputusan ketenagakerjaan.',
        'Pengguna diharapkan memperoleh kemampuan analisis kasus, penyusunan strategi respons, serta refleksi terhadap konsekuensi keputusan.',
        'Dampak penggunaan aplikasi meliputi peningkatan kualitas literasi hukum ketenagakerjaan dan keterampilan pengambilan keputusan profesional.'
    ]
    for idx, item in enumerate(items, start=1):
        doc.add_paragraph(f'{idx}. {item}')


def add_bab_3(doc):
    doc.add_heading('BAB 3 SPESIFIKASI ALAT YANG DIBUTUHKAN', level=1)

    table = doc.add_table(rows=1, cols=3)
    table.style = 'Table Grid'
    hdr = table.rows[0].cells
    hdr[0].text = 'Aspek'
    hdr[1].text = 'Spesifikasi Minimum'
    hdr[2].text = 'Spesifikasi Direkomendasikan'

    rows = [
        ('Sistem Operasi', 'Android 10 / iOS 14 / Windows 10', 'Android 12+ / iOS 16+ / Windows 11'),
        ('Processor', 'Quad-core 1.8 GHz', 'Octa-core 2.2 GHz atau lebih tinggi'),
        ('RAM', '4 GB', '8 GB atau lebih'),
        ('Storage', 'Ruang kosong 500 MB', 'Ruang kosong 2 GB'),
        ('GPU', 'GPU terintegrasi', 'GPU terintegrasi kelas menengah atau lebih baik'),
        ('Versi Software', 'Flutter runtime kompatibel dan codec video standar', 'Komponen multimedia terbaru dan dukungan hardware acceleration'),
        ('Perangkat Pendukung', 'Layar sentuh/mouse, speaker', 'Headset, koneksi internet stabil, dan perangkat input presisi')
    ]

    for r in rows:
        cells = table.add_row().cells
        cells[0].text = r[0]
        cells[1].text = r[1]
        cells[2].text = r[2]

    doc.add_paragraph(
        'Spesifikasi minimum ditujukan agar aplikasi dapat berjalan dengan fungsi dasar. Spesifikasi direkomendasikan diperlukan untuk memperoleh pengalaman belajar yang lebih stabil, '
        'khususnya saat memutar video, menjalankan simulasi interaktif, dan memproses umpan balik AI secara optimal.'
    )


def add_bab_4(doc):
    doc.add_heading('BAB 4 UPDATE APLIKASI', level=1)
    doc.add_paragraph(
        'Pembaruan aplikasi dilakukan secara berkala untuk meningkatkan kualitas fitur, kompatibilitas perangkat, serta keamanan penggunaan. '
        'Pengguna disarankan melakukan update segera setelah versi terbaru tersedia.'
    )

    langkah = [
        'Pengguna membuka aplikasi store pada perangkat.',
        'Pengguna memilih menu update pada halaman aplikasi.',
        'Pengguna menjalankan proses pembaruan dan menunggu hingga selesai.',
        'Pengguna memastikan aplikasi berhasil diperbarui dengan mengecek versi terbaru.'
    ]
    for i, l in enumerate(langkah, start=1):
        doc.add_paragraph(f'{i}. {l}')

    add_image_placeholder(doc, '4', 'Proses Membuka Store', 'Gambar4')
    add_image_placeholder(doc, '4', 'Proses Update Aplikasi', 'Gambar4')
    add_image_placeholder(doc, '4', 'Aplikasi Berhasil Diperbarui', 'Gambar4')


def add_bab_5(doc):
    doc.add_heading('BAB 5 PEMASANGAN APLIKASI', level=1)
    doc.add_paragraph(
        'Proses pemasangan aplikasi perlu dilakukan secara berurutan agar instalasi berjalan baik dan aplikasi siap digunakan tanpa kendala teknis.'
    )

    tahapan = [
        'Persiapan perangkat: pastikan ruang penyimpanan cukup dan koneksi internet tersedia.',
        'Download aplikasi melalui sumber distribusi resmi.',
        'Instal aplikasi dengan mengikuti instruksi pada perangkat.',
        'Membuka aplikasi pertama kali untuk proses inisialisasi awal.'
    ]
    for i, t in enumerate(tahapan, start=1):
        doc.add_paragraph(f'{i}. {t}')

    add_image_placeholder(doc, '5', 'File Instalasi Aplikasi', 'Gambar5')
    add_image_placeholder(doc, '5', 'Proses Instalasi', 'Gambar5')
    add_image_placeholder(doc, '5', 'Tampilan Awal Setelah Instalasi', 'Gambar5')


def add_bab_6(doc):
    doc.add_heading('BAB 6 MENU APLIKASI', level=1)

    sections = [
        ('A. Menu Home',
         [
             'Halaman Home berfungsi sebagai pusat navigasi menuju fitur utama aplikasi.',
             'Tombol yang tersedia mencakup akses ke simulasi, materi, video, kuis, dan informasi aplikasi.',
             'Pengguna dapat memilih menu sesuai kebutuhan pembelajaran pada sesi berjalan.'
         ],
         'Gambar 6.1 Tampilan Menu Home'),
        ('B. Menu Materi',
         [
             'Menu Materi menyediakan konten konseptual sebagai landasan pemahaman sebelum simulasi.',
             'Pengguna dapat memilih materi berdasarkan topik atau urutan modul yang tersedia.',
             'Setiap materi menampilkan ringkasan informasi untuk membantu proses belajar bertahap.'
         ],
         'Gambar 6.2 Tampilan Menu Materi'),
        ('C. Menu Video',
         [
             'Fitur video pembelajaran berfungsi memperkuat pemahaman melalui penjelasan audio-visual.',
             'Pengguna menjalankan video dengan menekan tombol putar pada konten yang dipilih.',
             'Kontrol video meliputi play, pause, seek, dan pengaturan tampilan layar.'
         ],
         'Gambar 6.3 Tampilan Menu Video'),
        ('D. Menu Simulasi',
         [
             'Menu simulasi menjadi inti latihan pengambilan keputusan berbasis kasus.',
             'Pengguna berinteraksi dengan skenario, opsi tindakan, dan urutan strategi penyelesaian.',
             'Sistem memberikan respons berupa evaluasi keputusan dan rekomendasi tindak lanjut.'
         ],
         'Gambar 6.4 Tampilan Menu Simulasi'),
        ('E. Menu Kuis',
         [
             'Kuis digunakan untuk mengukur tingkat pemahaman pengguna terhadap materi dan kasus.',
             'Mekanisme pengerjaan soal dilakukan dengan memilih jawaban yang paling tepat.',
             'Sistem menampilkan skor dan hasil kuis sebagai indikator capaian belajar.'
         ],
         'Gambar 6.5 Tampilan Menu Kuis'),
        ('F. Menu Informasi',
         [
             'Menu ini memuat informasi umum tentang aplikasi dan ruang lingkup penggunaannya.',
             'Informasi developer ditampilkan untuk identifikasi pengembang sistem.',
             'Versi aplikasi ditampilkan sebagai acuan validasi pembaruan perangkat lunak.'
         ],
         'Gambar 6.6 Tampilan Menu Informasi')
    ]

    for title, bullets, caption in sections:
        doc.add_heading(title, level=2)
        doc.add_heading('Uraian Fungsi dan Cara Penggunaan', level=3)
        for b in bullets:
            doc.add_paragraph(f'- {b}')
        nomor_bab = caption.split()[1].split('.')[0]
        add_image_placeholder(doc, nomor_bab, ' '.join(caption.split()[2:]), f'Gambar{nomor_bab}')


def add_bab_7(doc):
    doc.add_heading('BAB 7 INFORMASI PENGGUNAAN PERANGKAT', level=1)

    doc.add_paragraph('1. Nama Bagian Perangkat')
    doc.add_paragraph(
        'Bagian perangkat mencakup layar utama, media input, audio output, dan konektivitas jaringan yang mendukung operasi aplikasi. '
        'Setiap bagian berperan dalam menjamin interaksi pengguna berlangsung efektif.'
    )

    doc.add_paragraph('2. Tombol Kontrol')
    doc.add_paragraph(
        'Tombol kontrol meliputi tombol navigasi, tombol kembali, serta kontrol multimedia. '
        'Fungsi tombol dirancang untuk memudahkan perpindahan menu dan pengoperasian konten pembelajaran.'
    )

    doc.add_paragraph('3. Cara Penggunaan Perangkat')
    doc.add_paragraph(
        'Pengguna memastikan perangkat aktif, membuka aplikasi, memilih fitur pembelajaran, dan melakukan interaksi sesuai instruksi yang muncul. '
        'Apabila dibutuhkan, pengguna dapat menyesuaikan volume, orientasi layar, serta stabilitas koneksi internet.'
    )

    add_image_placeholder(doc, '7', 'Perangkat Pendukung', 'Gambar7')


def add_bab_8(doc):
    doc.add_heading('BAB 8 TATA CARA PENGGUNAAN APLIKASI', level=1)

    doc.add_heading('A. Memulai Aplikasi', level=2)
    doc.add_paragraph('Pengguna membuka aplikasi melalui ikon pada perangkat. Setelah splash screen, aplikasi menampilkan halaman awal sebelum menuju halaman utama.')
    doc.add_paragraph('Dari halaman awal, pengguna dapat masuk ke beranda untuk memilih fitur pembelajaran yang tersedia.')
    add_image_placeholder(doc, '8', 'Tampilan Awal Aplikasi', 'Gambar8')

    doc.add_heading('B. Navigasi Menu', level=2)
    doc.add_paragraph('Perpindahan menu dilakukan dengan menekan tombol navigasi yang tersedia pada beranda maupun halaman fitur.')
    doc.add_paragraph('Setiap tombol memiliki fungsi spesifik, seperti membuka materi, simulasi, video, kuis, atau informasi aplikasi.')
    add_image_placeholder(doc, '8', 'Navigasi Menu', 'Gambar8')

    doc.add_heading('C. Menggunakan Fitur Utama', level=2)
    doc.add_heading('Alur Operasional Fitur', level=3)
    doc.add_paragraph('Langkah:')
    doc.add_paragraph('1. Pengguna memilih menu fitur utama sesuai tujuan pembelajaran.')
    doc.add_paragraph('2. Sistem menampilkan konten, instruksi, atau skenario interaktif.')
    doc.add_paragraph('3. Pengguna melakukan interaksi berupa pemilihan opsi, navigasi, atau pengisian jawaban.')
    doc.add_paragraph('4. Sistem memberikan respons dalam bentuk evaluasi, skor, atau rekomendasi tindak lanjut.')

    add_image_placeholder(doc, '8', 'Penggunaan Fitur Utama', 'Gambar8')


def add_bab_9(doc, app_name, developer):
    doc.add_heading('BAB 9 TENTANG APLIKASI', level=1)

    info_table = doc.add_table(rows=0, cols=2)
    info_table.style = 'Table Grid'

    def add_info_row(label, value):
        row = info_table.add_row().cells
        row[0].text = label
        row[1].text = value

    add_info_row('Nama Aplikasi', app_name)
    add_info_row('Versi', '1.0')
    add_info_row('Developer', developer)
    add_info_row(
        'Tujuan Pengembangan',
        'Aplikasi dikembangkan untuk menyediakan media pembelajaran interaktif yang membantu pengguna memahami keputusan HR secara legal, etis, dan strategis.'
    )
    add_info_row(
        'Hak Cipta',
        f'© {datetime.now().year} {developer}. Seluruh hak cipta dilindungi sesuai ketentuan peraturan perundang-undangan yang berlaku.'
    )
    add_info_row(
        'Referensi',
        '1) Literatur manajemen SDM. 2) Pedoman hukum ketenagakerjaan Indonesia. 3) Dokumentasi teknis Flutter dan layanan AI pendukung.'
    )


def build_manual(output_path):
    app_name = 'LEXIMPACT AI'
    version = '1.0.0'
    developer = 'Ramzi Syuhada'
    year = str(datetime.now().year)

    doc = Document()
    style_document(doc)
    set_margins(doc)

    add_cover(doc, app_name, version, developer, year)
    add_toc(doc)
    add_bab_1(doc, app_name)
    add_bab_2(doc)
    add_bab_3(doc)
    add_bab_4(doc)
    add_bab_5(doc)
    add_bab_6(doc)
    add_bab_7(doc)
    add_bab_8(doc)
    add_bab_9(doc, app_name, developer)

    add_page_number_footer(doc)
    doc.save(output_path)


if __name__ == '__main__':
    build_manual('d:/Flutter/leximpactai/Panduan_Penggunaan_Aplikasi_LEXIMPACT_AI.docx')
