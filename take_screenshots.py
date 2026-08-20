"""
Screenshot Automation Script untuk LexImpact AI
Mengambil screenshot asli dari semua halaman aplikasi via ADB,
lalu menyisipkan gambar-gambar tersebut ke dalam dokumen Word.

Prasyarat:
- Emulator Android sudah berjalan dan app sudah diinstall/running
- ADB tersedia di PATH
"""

import subprocess
import time
import os
import sys

SCREENSHOTS_DIR = r"d:\Flutter\leximpactai\screenshots"
ADB = "adb"

def run(cmd, wait=True):
    print(f"  >> {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.stdout:
        print(result.stdout.strip())
    if result.stderr and result.returncode != 0:
        print(f"  [WARN] {result.stderr.strip()}")
    return result

def adb(cmd):
    return run(f"{ADB} {cmd}")

def screenshot(name, wait_sec=2):
    """Ambil screenshot dari emulator dan simpan ke folder lokal."""
    os.makedirs(SCREENSHOTS_DIR, exist_ok=True)
    device_path = f"/sdcard/screenshot_{name}.png"
    local_path  = os.path.join(SCREENSHOTS_DIR, f"{name}.png")

    time.sleep(wait_sec)
    adb(f"shell screencap -p {device_path}")
    time.sleep(0.5)
    adb(f"pull {device_path} \"{local_path}\"")
    adb(f"shell rm {device_path}")
    print(f"  [OK] Screenshot disimpan: {local_path}")
    return local_path

def tap(x, y):
    """Tap koordinat layar (dalam satuan dp Medium Phone 412x917)."""
    adb(f"shell input tap {x} {y}")

def swipe(x1, y1, x2, y2, duration=500):
    adb(f"shell input swipe {x1} {y1} {x2} {y2} {duration}")

def press_back():
    adb("shell input keyevent 4")

def go_home():
    """Kembali ke halaman utama app dengan beberapa kali back."""
    for _ in range(5):
        press_back()
        time.sleep(0.3)

# ─────────────────────────────────────────────────────────────
# CEK DEVICE
# ─────────────────────────────────────────────────────────────
print("\n[1] Cek device...")
result = run("adb devices")
if "emulator" not in result.stdout and "device" not in result.stdout:
    print("ERROR: Tidak ada device/emulator terhubung!")
    sys.exit(1)

time.sleep(2)

# ─────────────────────────────────────────────────────────────
# 1. HOME PAGE
# ─────────────────────────────────────────────────────────────
print("\n[2] Screenshot: Home Page...")
# Buka app via intent (package name Flutter default)
adb("shell monkey -p com.example.leximpactai -c android.intent.category.LAUNCHER 1")
time.sleep(4)  # tunggu splash + animasi
screenshot("01_home_page", wait_sec=3)

# ─────────────────────────────────────────────────────────────
# 2. MATERI PAGE (termasuk video + slide)
# ─────────────────────────────────────────────────────────────
print("\n[3] Screenshot: Materi Page...")
# Tap tombol "Materi" (posisi di bottom row, kiri)
# Berdasarkan kode: _miniMenu("Materi", Icons.menu_book, "/materi")
# Posisi kira-kira 1/4 dari kiri layar, bagian bawah
tap(103, 780)  # tombol Materi
time.sleep(3)
screenshot("02_materi_page", wait_sec=2)

# Screenshot saat video playing
tap(206, 260)  # tap area video untuk play
time.sleep(2)
screenshot("03_materi_video_playing", wait_sec=1)

# Pause video
tap(206, 260)
time.sleep(1)

# Swipe slide ke kanan beberapa kali untuk lihat slide
swipe(350, 550, 60, 550, 400)
time.sleep(1)
screenshot("04_materi_slide", wait_sec=1)

# ─────────────────────────────────────────────────────────────
# 3. KEMBALI KE HOME → SIMULASI
# ─────────────────────────────────────────────────────────────
print("\n[4] Screenshot: Simulation Page...")
go_home()
time.sleep(2)

# Tap "▶ MULAI SIMULASI" button
tap(206, 640)
time.sleep(5)  # tunggu AI generate case
screenshot("05_simulasi_loading", wait_sec=1)
time.sleep(5)  # tunggu selesai load
screenshot("06_simulasi_case", wait_sec=2)

# Tap salah satu jawaban (opsi B, kira-kira y=520)
tap(206, 520)
time.sleep(1)
screenshot("07_simulasi_selected", wait_sec=1)

# ─────────────────────────────────────────────────────────────
# 4. FEEDBACK AI (setelah submit)
# ─────────────────────────────────────────────────────────────
print("\n[5] Screenshot: AI Feedback...")
# Scroll ke bawah untuk cari tombol konfirmasi
swipe(206, 700, 206, 400, 500)
time.sleep(1)
# Tap tombol konfirmasi
tap(206, 750)
time.sleep(8)  # tunggu AI response
screenshot("08_feedback_ai", wait_sec=3)

# Scroll feedback
swipe(206, 700, 206, 300, 600)
time.sleep(1)
screenshot("09_feedback_ai_scroll", wait_sec=1)

# ─────────────────────────────────────────────────────────────
# 5. KUIS PAGE
# ─────────────────────────────────────────────────────────────
print("\n[6] Screenshot: Quiz Page...")
go_home()
time.sleep(2)

# Tap "Kuis" mini menu (kiri tengah dari 3 menu)
tap(206, 780)  # tombol Kuis
time.sleep(2)
screenshot("10_kuis_page", wait_sec=2)

# Tap jawaban pertama
tap(206, 480)
time.sleep(1)
screenshot("11_kuis_answered", wait_sec=1)

# ─────────────────────────────────────────────────────────────
# 6. TENTANG / ABOUT PAGE
# ─────────────────────────────────────────────────────────────
print("\n[7] Screenshot: About Page...")
go_home()
time.sleep(2)

# Tap "Tentang" mini menu (kanan dari 3 menu)
tap(309, 780)  # tombol Tentang
time.sleep(2)
screenshot("12_about_page", wait_sec=2)

# Scroll down about page
swipe(206, 700, 206, 300, 600)
time.sleep(1)
screenshot("13_about_page_scroll", wait_sec=1)

# ─────────────────────────────────────────────────────────────
print(f"\n✅ Semua screenshot berhasil disimpan di: {SCREENSHOTS_DIR}")
print("\nDaftar file:")
for f in sorted(os.listdir(SCREENSHOTS_DIR)):
    path = os.path.join(SCREENSHOTS_DIR, f)
    size = os.path.getsize(path)
    print(f"  {f} ({size//1024} KB)")
