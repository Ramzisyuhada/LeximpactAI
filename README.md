a lebih fokus ke hukum ketenagakerjaan Indonesia atau gaya lebih futuristik/akademik# 🌐 LEXIMPACT AI

> **Legal Experience for HR Decision Impact**
> Aplikasi pembelajaran berbasis **AI + Gamifikasi** untuk memahami pengambilan keputusan HR secara legal dan strategis.

---

## 🎮 Preview

LEXIMPACT AI menghadirkan pengalaman belajar interaktif melalui simulasi kasus nyata di dunia HR.

* 🔹 Simulasi berbasis skenario nyata
* 🔹 Analisis keputusan menggunakan AI
* 🔹 Game menyusun strategi (Level 3)
* 🔹 Materi + Quiz interaktif

---

## ✨ Fitur Utama

### 🎯 1. Simulasi HR Interaktif

* Level 1: Recruitment (diskriminasi, hiring)
* Level 2: HR Decision (PHK, konflik)
* Level 3: Strategic HR (game menyusun langkah)

---

### 🤖 2. AI Analysis (Mistral AI)

* Analisis keputusan user
* Evaluasi benar / salah
* Risiko hukum & dampak sosial
* Rekomendasi profesional

---

### 🧠 3. RAG (Retrieval Augmented Generation)

* Menggunakan **Supabase + Vector Embedding**
* Embedding via **Mistral AI**
* Context-aware AI response

---

### 🎮 4. Game Mode (Level 3)

* Drag & Drop langkah strategi
* Urutan solusi terbaik
* Interaktif & engaging

---

### 📚 5. Materi & Quiz

* Materi dari PPT (offline)
* Video pembelajaran (local file)
* Quiz dengan scoring system

---

## 🧱 Arsitektur

```text
Flutter (UI)
   ↓
Simulation Layer
   ↓
Mistral AI API
   ↓
RAG (Supabase Vector DB)
```

---

## 🛠️ Tech Stack

| Teknologi       | Digunakan untuk    |
| --------------- | ------------------ |
| Flutter         | Frontend mobile    |
| Dart            | Logic              |
| Mistral AI      | LLM + Embedding    |
| Supabase        | Database + Vector  |
| GoRouter        | Navigation         |
| Flutter Animate | Animasi UI         |
| Markdown        | Render AI response |

---

## 📦 Dependencies

Tambahkan di `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  flutter_animate: ^4.5.0
  google_fonts: ^6.1.0
  flutter_markdown: ^0.6.18
  go_router: ^14.0.0
  supabase_flutter: ^2.0.0
```

---

## 🚀 Cara Menjalankan

```bash
git clone https://github.com/username/leximpact-ai.git
cd leximpact-ai
flutter pub get
flutter run
```

---

## 🔐 Konfigurasi API

### 🔹 Mistral AI

```dart
final apiKey = "YOUR_API_KEY";
```

### 🔹 Supabase

```dart
await Supabase.initialize(
  url: 'YOUR_URL',
  anonKey: 'YOUR_ANON_KEY',
);
```

---

## 🧠 Contoh Output AI

```
Jawaban Terbaik: Revisi prosedur

Evaluasi:
Benar, karena menghindari diskriminasi usia.

Risiko:
- Pelanggaran hukum ketenagakerjaan
- Diskriminasi

Dampak:
- Reputasi perusahaan menurun
- Ketidakadilan

Rekomendasi:
- Gunakan kriteria berbasis kompetensi
```

---

## 📌 Roadmap

* [ ] Sistem skor & XP
* [ ] Leaderboard
* [ ] Penyimpanan progress user
* [ ] Multi-language
* [ ] Cloud sync

---

## 👨‍💻 Developer

**Ramzi Syuhada**
Flutter Developer  | AR/VR Engineer

