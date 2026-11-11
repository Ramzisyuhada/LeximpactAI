"""Membangun assets/data/regulasi.json dari PDF peraturan di dataset/regulasi/.

Setiap pasal menjadi satu entri berisi teks asli batang tubuh, penjelasan
pasal (jika ada), serta judul BAB/Bagian/Paragraf sebagai topik pencarian.

Pemakaian (dari root proyek):
    pip install pypdf fonttools
    python tools/build_regulasi.py
"""

import json
import re
import sys
from collections import Counter
from pathlib import Path

from pypdf import PdfReader

ROOT = Path(__file__).resolve().parent.parent
PDF_DIR = ROOT / "dataset" / "regulasi"
OUT_FILE = ROOT / "assets" / "data" / "regulasi.json"

# Daftar peraturan sesuai slide "Peraturan Perundang-undangan Kepegawaian
# dan Ketenagakerjaan" pada konsep aplikasi.
DOCS = [
    {
        "file": "uu13-2003.pdf",
        "sumber": "UU No. 13 Tahun 2003 tentang Ketenagakerjaan",
        "tahap": "",
    },
    {
        "file": "uu21-2000.pdf",
        "sumber": "UU No. 21 Tahun 2000 tentang Serikat Pekerja/Serikat Buruh",
        "tahap": "during",
    },
    {
        "file": "uu1-1970.pdf",
        "sumber": "UU No. 1 Tahun 1970 tentang Keselamatan Kerja",
        "tahap": "during",
    },
    {
        "file": "uu3-1992.pdf",
        "sumber": "UU No. 3 Tahun 1992 tentang Jaminan Sosial Tenaga Kerja",
        "tahap": "during",
        "catatan": "UU ini dinyatakan tidak berlaku oleh UU 24/2011 tentang BPJS; "
        "program jaminan sosial tenaga kerja kini diselenggarakan BPJS Ketenagakerjaan.",
    },
    {
        "file": "uu40-2004.pdf",
        "sumber": "UU No. 40 Tahun 2004 tentang Sistem Jaminan Sosial Nasional",
        "tahap": "during",
    },
    {
        "file": "uu2-2004.pdf",
        "sumber": "UU No. 2 Tahun 2004 tentang Penyelesaian Perselisihan Hubungan Industrial",
        "tahap": "during",
    },
    {
        "file": "uu11-1992.pdf",
        "sumber": "UU No. 11 Tahun 1992 tentang Dana Pensiun",
        "tahap": "post",
    },
    {
        "file": "keppres4-1980.pdf",
        "sumber": "Keppres No. 4 Tahun 1980 tentang Wajib Lapor Lowongan Pekerjaan",
        "tahap": "pre",
    },
    {
        "file": "kepmen235-2003.pdf",
        "sumber": "Kepmenakertrans No. KEP-235/MEN/2003 tentang Jenis-Jenis Pekerjaan "
        "yang Membahayakan Kesehatan, Keselamatan atau Moral Anak",
        "tahap": "pre",
    },
    {
        "file": "kepmen49-2004.pdf",
        "sumber": "Kepmenakertrans No. KEP-49/MEN/IV/2004 tentang Ketentuan Struktur "
        "dan Skala Upah",
        "tahap": "during",
    },
]

# Tahap siklus kerja untuk UU 13/2003 berdasarkan rentang nomor pasal (BAB).
UU13_TAHAP = [
    (5, 6, "pre"),  # BAB III kesempatan dan perlakuan yang sama
    (9, 30, "during"),  # BAB V pelatihan kerja
    (31, 49, "pre"),  # BAB VI-VIII penempatan, perluasan kesempatan, TKA
    (50, 66, "pre"),  # BAB IX hubungan kerja (perjanjian kerja, PKWT, outsourcing)
    (67, 149, "during"),  # BAB X-XI perlindungan, pengupahan, hubungan industrial
    (150, 172, "post"),  # BAB XII pemutusan hubungan kerja
]

# Pasal UU 13/2003 yang diubah/dihapus UU 6/2023 (Cipta Kerja).
UU13_DIUBAH = {42, 59, 66, 77, 78, 79, 88, 151, 153, 156}
UU13_DIHAPUS = {65, 89, 90, 91, 155, *range(161, 173)}

HEADER_LINES = re.compile(
    r"^(PRESIDEN|REPUBLIK INDONESIA|-\s*\d+\s*-|MENTERI TENAGA KERJA DAN TRANSMIGRASI)$"
)
PASAL_RE = re.compile(r"^Pasal\s+(\d+)\s*\.?$")
BAB_RE = re.compile(r"^BAB\s+[IVXLC]+$")
BAGIAN_RE = re.compile(r"^Bagian\s+(Ke\w+|Pertama)$", re.IGNORECASE)
PARAGRAF_RE = re.compile(r"^Paragraf\s+\d+$")
PENJELASAN_RE = re.compile(r"^PENJELASAN$")
LAMPIRAN_RE = re.compile(r"^(LAMPIRAN|Lampiran\s*:)")
PENUTUP_RE = re.compile(r"(Agar setiap orang mengetahuinya|Ditetapkan di|Disahkan di)")
CUKUP_JELAS_RE = re.compile(r"^(Cukup jelas\.?\s*)+$", re.IGNORECASE)

MAX_LAMPIRAN_CHUNK = 2500

# Kata depan yang ditulis terpisah; jangan digabung dengan kata berikutnya.
PREPOSITIONS = {"di", "ke", "dari", "se"}


def doc_id(file_name):
    return file_name[: -len(".pdf")]


def read_lines(pdf_path):
    """Teks PDF per baris, tanpa header halaman dan kata sambung halaman."""
    lines = []
    for page in PdfReader(pdf_path).pages:
        page_lines = [
            re.sub(r"\s+", " ", line).strip()
            for line in (page.extract_text() or "").splitlines()
        ]
        page_lines = [line for line in page_lines if line]

        # Header hanya dibuang di bagian atas halaman.
        while page_lines and HEADER_LINES.match(page_lines[0]):
            page_lines.pop(0)
        # Kata sambung di bawah halaman, mis. "(3) Ketentuan ..." / "Pasal 80 ...".
        if page_lines and re.search(r"(\.\.\.|…)$", page_lines[-1]):
            page_lines.pop()

        lines.extend(page_lines)
    return lines


def join_lines(lines):
    text = " ".join(lines)
    text = re.sub(r"(\w) ?- (\w)", r"\1-\2", text)  # "terus - menerus"
    text = re.sub(r"(\w) -(\w)", r"\1-\2", text)  # "sekurang -kurangnya"
    text = re.sub(r"\s+([,.;:)])", r"\1", text)
    text = re.sub(r"\(\s+", "(", text)
    text = re.sub(r"(\w)/ (\w)", r"\1/\2", text)  # "pekerja/ buruh"
    return re.sub(r"\s+", " ", text).strip()


def build_vocab(texts):
    vocab = Counter()
    for text in texts:
        vocab.update(w.lower() for w in re.findall(r"[A-Za-z]+", text))
    return vocab


def fix_split_words(text, vocab):
    """Gabungkan kata yang terpotong pembaca PDF, mis. "p aling" -> "paling".

    Dua potongan digabung bila gabungannya kata di korpus dan salah satu
    potongannya jarang, atau gabungannya jauh lebih sering daripada
    potongannya (potongan yang sama bisa berulang, mis. "pek erja").
    """
    tokens = text.split(" ")
    out = []
    i = 0
    while i < len(tokens):
        a = tokens[i]
        if i + 1 < len(tokens) and _should_join(a, tokens[i + 1], vocab):
            out.append(a + tokens[i + 1])
            i += 2
            continue
        out.append(a)
        i += 1
    return " ".join(out)


def _should_join(a, b, vocab):
    core_b = re.match(r"^([A-Za-z]+)", b)
    if not a.isalpha() or not core_b or re.match(r"^[a-z][.)]", b):
        return False

    joined = vocab[(a + core_b.group(1)).lower()]
    piece = min(vocab[a.lower()], vocab[core_b.group(1).lower()])

    # "di"/"ke"/"se" + kata: hanya bila hasilnya kata yang umum
    # ("diatur", "kesehatan"), agar "di dalamnya" tetap terpisah.
    if a.lower() in PREPOSITIONS:
        return joined >= 5 or (vocab[core_b.group(1).lower()] < 3 and joined >= 2)

    rare_piece = piece < 3 and joined >= 2
    dominant_join = piece < 50 and joined >= max(1, 3 * piece)
    return rare_piece or dominant_join


def tahap_for(doc, number):
    if doc["file"] != "uu13-2003.pdf":
        return doc["tahap"]
    for start, end, tahap in UU13_TAHAP:
        if start <= number <= end:
            return tahap
    return ""


def catatan_for(doc, number):
    if doc["file"] == "uu13-2003.pdf":
        if number in UU13_DIHAPUS:
            return "Pasal ini dihapus oleh UU 6/2023 (Cipta Kerja); ketentuannya kini diatur PP 35/2021."
        if number in UU13_DIUBAH:
            return "Pasal ini diubah oleh UU 6/2023 (Cipta Kerja); periksa bunyi terbaru."
    return doc.get("catatan")


def parse_document(doc):
    lines = read_lines(PDF_DIR / doc["file"])

    # Pisahkan batang tubuh, penjelasan, dan lampiran.
    body, penjelasan, lampiran = [], [], []
    section = body
    for line in lines:
        if section is body and PENJELASAN_RE.match(line):
            section = penjelasan
            continue
        if section is not lampiran and LAMPIRAN_RE.match(line):
            section = lampiran
        section.append(line)

    pasal = parse_body(body)
    penjelasan_map = parse_penjelasan(penjelasan)
    return pasal, penjelasan_map, lampiran


def parse_body(lines):
    """Kembalikan list (nomor, [baris], heading) untuk setiap pasal."""
    result = []
    current = None
    headings = {"bab": "", "bagian": "", "paragraf": ""}
    pending_title = None
    last_number = 0

    for line in lines:
        if PENUTUP_RE.search(line) and current is not None:
            current[1].append(PENUTUP_RE.split(line)[0])
            break

        if pending_title:
            # Baris setelah "BAB X" / "Bagian Kesatu" / "Paragraf 1" adalah judulnya.
            # Judul BAB bisa beberapa baris huruf kapital.
            if pending_title == "bab" and headings["bab"] and not line.isupper():
                pending_title = None
            else:
                headings[pending_title] = (
                    f"{headings[pending_title]} {line}".strip()
                    if pending_title == "bab"
                    else line
                )
                if pending_title != "bab":
                    pending_title = None
                continue

        if BAB_RE.match(line):
            headings = {"bab": "", "bagian": "", "paragraf": ""}
            pending_title = "bab"
            continue
        if BAGIAN_RE.match(line):
            headings["bagian"], headings["paragraf"] = "", ""
            pending_title = "bagian"
            continue
        if PARAGRAF_RE.match(line):
            pending_title = "paragraf"
            continue

        match = PASAL_RE.match(line)
        if match:
            number = int(match.group(1))
            if last_number < number <= last_number + 3:
                current = (number, [], dict(headings))
                result.append(current)
                last_number = number
                continue

        if current is not None:
            current[1].append(line)

    return result


def parse_penjelasan(lines):
    result = {}
    current = None
    last_number = 0
    for line in lines:
        if PENUTUP_RE.search(line) or line.startswith("TAMBAHAN LEMBARAN NEGARA"):
            break
        match = PASAL_RE.match(line)
        if match:
            number = int(match.group(1))
            if last_number < number <= last_number + 10:
                current = number
                result[current] = []
                last_number = number
                continue
        if current is not None:
            result[current].append(line)
    return result


def chunk_lines(lines, limit):
    chunks, current, size = [], [], 0
    for line in lines:
        if current and size + len(line) > limit:
            chunks.append(current)
            current, size = [], 0
        current.append(line)
        size += len(line) + 1
    if current:
        chunks.append(current)
    return chunks


def main():
    parsed = []
    for doc in DOCS:
        pasal, penjelasan_map, lampiran = parse_document(doc)
        parsed.append((doc, pasal, penjelasan_map, lampiran))
        print(f"{doc['file']}: {len(pasal)} pasal, "
              f"{len(penjelasan_map)} penjelasan, lampiran {len(lampiran)} baris")

    raw_texts = [
        join_lines(lines)
        for _, pasal, _, _ in parsed
        for _, lines, _ in pasal
    ]
    vocab = build_vocab(raw_texts)

    def clean(lines):
        return fix_split_words(join_lines(lines), vocab)

    documents = []
    for doc, pasal, penjelasan_map, lampiran in parsed:
        prefix = doc_id(doc["file"])
        short_title = doc["sumber"].split(" tentang ", 1)[1]

        for number, lines, headings in pasal:
            isi = clean(lines)
            if not isi:
                continue

            topik = [h for h in (headings["bab"], headings["bagian"], headings["paragraf"]) if h]
            entry = {
                "id": f"{prefix}-p{number}",
                "sumber": doc["sumber"],
                "pasal": f"Pasal {number}",
                "judul": (headings["paragraf"] or headings["bagian"] or headings["bab"].title()
                          or short_title).rstrip(". "),
                "tahap": tahap_for(doc, number),
                "topik": [t.lower() for t in topik],
                "isi": isi,
            }

            penjelasan = clean(penjelasan_map.get(number, []))
            if penjelasan and not CUKUP_JELAS_RE.match(penjelasan):
                entry["penjelasan"] = penjelasan

            catatan = catatan_for(doc, number)
            if catatan:
                entry["catatan"] = catatan

            documents.append(entry)

        chunks = chunk_lines(lampiran, MAX_LAMPIRAN_CHUNK)
        for i, chunk in enumerate(chunks, start=1):
            documents.append({
                "id": f"{prefix}-lampiran{i}",
                "sumber": doc["sumber"],
                "pasal": "Lampiran" if len(chunks) == 1 else f"Lampiran ({i}/{len(chunks)})",
                "judul": short_title,
                "tahap": doc["tahap"],
                "topik": [short_title.lower()],
                "isi": clean(chunk),
            })

    OUT_FILE.write_text(
        json.dumps(
            {
                "catatan": "Dibangkitkan otomatis oleh tools/build_regulasi.py dari PDF di "
                "dataset/regulasi/ (sumber: JDIH BPK). Jangan diedit manual.",
                "dokumen": documents,
            },
            ensure_ascii=False,
            indent=1,
        ),
        encoding="utf-8",
    )
    print(f"-> {OUT_FILE.relative_to(ROOT)}: {len(documents)} entri")


if __name__ == "__main__":
    sys.exit(main())
