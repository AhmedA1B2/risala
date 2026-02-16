import json
import os
from collections import defaultdict

# مسار مجلد السكربت نفسه
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# ملف القرآن الكامل داخل نفس المجلد
INPUT_FILE = os.path.join(BASE_DIR, "quran.json")

# مجلد حفظ السور
OUTPUT_FOLDER = os.path.join(BASE_DIR, "surahs")

# إنشاء مجلد إذا لم يكن موجوداً
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

# قراءة الملف
with open(INPUT_FILE, "r", encoding="utf-8") as f:
    data = json.load(f)

# تجميع الآيات
surahs = defaultdict(list)

for verse in data:
    surah_number = verse["surah_number"]
    surahs[surah_number].append(verse)

# إنشاء 114 ملف
for surah_number in range(1, 115):
    surah_verses = surahs.get(surah_number, [])

    output_path = os.path.join(OUTPUT_FOLDER, f"{surah_number}.json")

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(surah_verses, f, ensure_ascii=False, indent=4)

print("تم إنشاء جميع ملفات السور بنجاح ✅")
