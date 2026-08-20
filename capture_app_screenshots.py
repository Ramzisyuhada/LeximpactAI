"""
Script otomatis Playwright untuk mengambil screenshot ASLI dari aplikasi Flutter Web LexImpact AI.
Menyimpan screenshot beresolusi tinggi berukuran smartphone.
"""

from playwright.sync_api import sync_playwright
import time
import os

OUTPUT_DIR = r"d:\Flutter\leximpactai\screenshots"
os.makedirs(OUTPUT_DIR, exist_ok=True)

routes = [
    ("01_home_page",           "http://localhost:8080/#/"),
    ("02_materi_page",         "http://localhost:8080/#/materi"),
    ("03_quiz_page",           "http://localhost:8080/#/quiz"),
    ("04_about_page",          "http://localhost:8080/#/about"),
    ("05_simulation_page",     "http://localhost:8080/#/simulation"),
]

def capture():
    print("[RUN] Memulai Playwright Chromium...")
    with sync_playwright() as p:
        browser = p.chromium.launch(channel="msedge", headless=True)
        context = browser.new_context(
            viewport={'width': 412, 'height': 915},
            device_scale_factor=2,
            is_mobile=True,
            has_touch=True,
        )
        page = context.new_page()

        print("[INFO] Mengakses aplikasi LexImpact AI di http://localhost:8080...")

        page.goto("http://localhost:8080/#/", wait_until="networkidle")
        time.sleep(4)

        for name, url in routes:
            print(f"[CAP] Capturing: {name} -> {url}")
            page.goto(url, wait_until="networkidle")
            time.sleep(3)

            file_path = os.path.join(OUTPUT_DIR, f"{name}.png")
            page.screenshot(path=file_path, full_page=False)
            print(f"   [OK] Saved: {file_path}")

        browser.close()
    print("[DONE] Selesai mengambil semua screenshot asli!")

if __name__ == "__main__":
    capture()
